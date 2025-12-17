"""
Main application file for Pilar API with Hugging Face dashboard enhancements.

Key features:
- APP_MODE awareness (demo | production) for route toggling.
- Deterministic startup sequence: init_model_service → load_model → init_prediction_service.
- Hugging Face friendly configuration (HOST/PORT env support).
- Built-in dashboard (/) showing live request logs and self-test status.
- JSON endpoints for dashboard data and manual self-test triggering.
"""

from __future__ import annotations

import json
import logging
import os
import time
from collections import deque
from datetime import datetime
from pathlib import Path
from typing import Any, Deque, Dict, List, Optional

import numpy as np
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, JSONResponse

from .api import health, predict
from .core.config import APP_MODE
from .core.logger import setup_logger
from .core.database import test_supabase_connection, get_connection_status
from .services.model_service import get_model_service, init_model_service
from .services.prediction_service import (
    get_prediction_service,
    init_prediction_service,
)

# ---------------------------------------------------------------------------
# Logging & dashboard state
# ---------------------------------------------------------------------------

logger = setup_logger(__name__)

BASE_DIR = Path(__file__).resolve().parent.parent

RECENT_REQUESTS: Deque[Dict[str, Any]] = deque(maxlen=200)
RECENT_EVENTS: Deque[Dict[str, Any]] = deque(maxlen=200)
SELF_TEST_HISTORY: Deque[Dict[str, Any]] = deque(maxlen=20)
SELF_TEST_CACHE: Dict[str, Any] = {"timestamp": None, "payload": None}


def utc_timestamp() -> str:
    """Return current UTC timestamp in ISO format with seconds precision."""
    return datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def append_event(level: str, message: str, meta: Optional[Dict[str, Any]] = None) -> None:
    """Record an event for the dashboard event log and mirror to standard logging."""
    entry = {
        "timestamp": utc_timestamp(),
        "level": level.upper(),
        "message": message,
        "meta": meta or {},
    }
    RECENT_EVENTS.appendleft(entry)

    log_level = getattr(logging, level.upper(), logging.INFO)
    if meta:
        logger.log(log_level, "%s | %s", message, json.dumps(meta, default=str))
    else:
        logger.log(log_level, message)


def record_request_log(entry: Dict[str, Any]) -> None:
    """Store request/response telemetry for dashboard display."""
    RECENT_REQUESTS.appendleft(entry)
    if entry["status"] >= 400:
        append_event(
            "ERROR",
            "Request returned error status",
            {
                "method": entry["method"],
                "path": entry["path"],
                "status": entry["status"],
            },
        )


def run_model_service_test() -> Dict[str, Any]:
    """Check whether the model service is ready."""
    service = get_model_service()
    if not service:
        return {
            "name": "model_service",
            "status": "bad",
            "detail": "Model service not initialised",
        }

    snapshot = service.get_model_info()
    ready = snapshot.get("loaded") and snapshot.get("validated")
    detail = {
        "loaded": snapshot.get("loaded", False),
        "validated": snapshot.get("validated", False),
        "components": snapshot.get("components", []),
    }
    return {
        "name": "model_service",
        "status": "ok" if ready else "bad",
        "detail": detail,
    }


def run_prediction_smoke_test() -> Dict[str, Any]:
    """Execute a dummy prediction to ensure the model pipeline is healthy."""
    service = get_prediction_service()
    if not service:
        return {
            "name": "prediction",
            "status": "bad",
            "detail": "Prediction service not ready",
        }

    try:
        n_features = len(service.feature_names)
        dummy = np.random.rand(1, n_features).astype("float32")
        result = service.predict(dummy)
        detail = {
            "wasteType": result.get("waste_type"),
            "category": result.get("category"),
            "confidence": round(result.get("confidence", 0.0), 2),
        }
        return {
            "name": "prediction",
            "status": "ok",
            "detail": detail,
        }
    except Exception as exc:  # pragma: no cover - smoke test only
        append_event("ERROR", "Prediction smoke test failed", {"error": str(exc)})
        return {
            "name": "prediction",
            "status": "bad",
            "detail": str(exc),
        }


def run_self_tests() -> Dict[str, Any]:
    """Run all self-tests and cache the latest result."""
    tests = [run_model_service_test(), run_prediction_smoke_test()]
    overall_ok = all(test["status"] == "ok" for test in tests)

    payload = {
        "timestamp": utc_timestamp(),
        "overall": "ok" if overall_ok else "bad",
        "tests": tests,
    }

    SELF_TEST_HISTORY.appendleft(payload)
    SELF_TEST_CACHE["timestamp"] = datetime.utcnow()
    SELF_TEST_CACHE["payload"] = payload

    append_event(
        "INFO" if overall_ok else "WARNING",
        "Self-test completed",
        {"overall": payload["overall"]},
    )
    return payload


def get_cached_self_tests(max_age_seconds: int = 15) -> Dict[str, Any]:
    """Return cached self-test results or rerun if stale."""
    cached_at: Optional[datetime] = SELF_TEST_CACHE.get("timestamp")
    if not cached_at:
        return run_self_tests()

    freshness = (datetime.utcnow() - cached_at).total_seconds()
    if freshness > max_age_seconds:
        return run_self_tests()
    return SELF_TEST_CACHE["payload"]


def get_model_snapshot() -> Dict[str, Any]:
    """Return model metadata for the dashboard."""
    service = get_model_service()
    if not service:
        return {
            "loaded": False,
            "validated": False,
            "components": [],
            "source": None,
            "waste_classes": [],
            "threshold": None,
        }

    info = service.get_model_info()
    return {
        "loaded": info.get("loaded", False),
        "validated": info.get("validated", False),
        "components": info.get("components", []),
        "source": info.get("source"),
        "waste_classes": info.get("waste_classes", []),
        "threshold": info.get("threshold"),
    }


def build_dashboard_payload() -> Dict[str, Any]:
    """Assemble the JSON payload consumed by the dashboard UI."""
    self_test = get_cached_self_tests()
    return {
        "meta": {
            "appMode": APP_MODE,
            "host": os.getenv("HOST") or os.getenv("HF_HOST") or "0.0.0.0",
            "port": os.getenv("PORT")
            or os.getenv("HF_PORT")
            or os.getenv("SPACE_PORT")
            or "7860",
            "timestamp": utc_timestamp(),
        },
        "model": get_model_snapshot(),
        "selfTest": self_test,
        "selfTestHistory": list(SELF_TEST_HISTORY),
        "recentRequests": list(RECENT_REQUESTS),
        "recentEvents": list(RECENT_EVENTS),
    }


def build_dashboard_html() -> str:
    """Return the interactive dashboard HTML page."""
    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Pilar API Dashboard</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    :root {{
      color-scheme: light dark;
      --bg: #0b1723;
      --text: #ecf2f8;
      --muted: #8aa0b6;
      --accent: #4ade80;
      --danger: #f87171;
      --card-bg: rgba(13, 26, 42, 0.65);
      --border: rgba(255, 255, 255, 0.08);
    }}
    body {{
      margin: 0;
      font-family: "Inter", "Segoe UI", sans-serif;
      background: radial-gradient(circle at top, #102a44 0%, #050b10 60%);
      color: var(--text);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: stretch;
    }}
    header {{
      padding: 32px 24px 16px;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }}
    header h1 {{
      margin: 0;
      font-size: clamp(28px, 4vw, 40px);
      font-weight: 700;
      letter-spacing: 0.02em;
    }}
    header p {{
      margin: 0;
      max-width: 960px;
      color: var(--muted);
      line-height: 1.5;
    }}
    main {{
      flex: 1;
      padding: 0 24px 40px;
      display: grid;
      gap: 20px;
    }}
    .grid {{
      display: grid;
      gap: 16px;
    }}
    @media (min-width: 960px) {{
      .grid {{
        grid-template-columns: repeat(12, 1fr);
      }}
      .span-4 {{ grid-column: span 4; }}
      .span-8 {{ grid-column: span 8; }}
      .span-12 {{ grid-column: span 12; }}
    }}
    .card {{
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 18px;
      padding: 20px;
      backdrop-filter: blur(18px);
      box-shadow: 0 18px 45px rgba(15, 23, 42, 0.35);
    }}
    .card h2 {{
      margin: 0 0 12px;
      font-size: 18px;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      color: var(--muted);
    }}
    .status-tag {{
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 6px 10px;
      border-radius: 999px;
      font-size: 13px;
      letter-spacing: 0.04em;
    }}
    .status-ok {{
      background: rgba(74, 222, 128, 0.12);
      color: var(--accent);
      border: 1px solid rgba(74, 222, 128, 0.35);
    }}
    .status-bad {{
      background: rgba(248, 113, 113, 0.12);
      color: var(--danger);
      border: 1px solid rgba(248, 113, 113, 0.35);
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
    }}
    th, td {{
      padding: 10px;
      border-bottom: 1px solid var(--border);
      text-align: left;
    }}
    th {{
      font-weight: 600;
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: 0.08em;
      font-size: 12px;
    }}
    tbody tr:hover {{
      background: rgba(255, 255, 255, 0.04);
    }}
    .actions {{
      display: flex;
      justify-content: flex-end;
      gap: 12px;
      margin-bottom: 16px;
    }}
    button {{
      cursor: pointer;
      border-radius: 12px;
      border: 1px solid rgba(255, 255, 255, 0.2);
      background: transparent;
      color: inherit;
      padding: 10px 18px;
      font-size: 14px;
      transition: all 0.2s ease;
    }}
    button:hover {{
      background: rgba(255, 255, 255, 0.08);
      border-color: rgba(255, 255, 255, 0.4);
    }}
    button[disabled] {{
      opacity: 0.45;
      cursor: not-allowed;
    }}
    .muted-text {{
      color: var(--muted);
      font-size: 14px;
      margin: 0;
      line-height: 1.5;
    }}
    .playground {{
      display: flex;
      flex-direction: column;
      gap: 18px;
    }}
    @media (min-width: 960px) {{
      .playground {{
        flex-direction: row;
      }}
    }}
    .playground .column {{
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }}
    .input-label {{
      display: flex;
      flex-direction: column;
      gap: 6px;
      font-size: 14px;
      color: var(--muted);
      letter-spacing: 0.02em;
    }}
    .input-label input[type="file"] {{
      margin-top: 4px;
      padding: 10px 12px;
      border-radius: 12px;
      border: 1px solid var(--border);
      background: rgba(15, 23, 42, 0.35);
      color: inherit;
    }}
    .preview-container {{
      position: relative;
      width: 100%;
      aspect-ratio: 1 / 1;
      border: 1px dashed rgba(255, 255, 255, 0.18);
      border-radius: 16px;
      background: rgba(255, 255, 255, 0.03);
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }}
    .preview-placeholder {{
      color: var(--muted);
      font-size: 14px;
      text-align: center;
      padding: 20px;
      line-height: 1.4;
    }}
    .preview-container img {{
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: none;
    }}
    .preview-container.has-image img {{
      display: block;
    }}
    .preview-container.has-image .preview-placeholder {{
      display: none;
    }}
    .camera-wrapper {{
      display: flex;
      flex-direction: column;
      gap: 12px;
    }}
    .camera-wrapper video {{
      width: 100%;
      border-radius: 16px;
      border: 1px solid var(--border);
      background: rgba(0, 0, 0, 0.35);
      aspect-ratio: 3 / 4;
      object-fit: cover;
    }}
    .camera-actions {{
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }}
    .result-box {{
      font-size: 14px;
      line-height: 1.5;
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 12px 14px;
      min-height: 56px;
      display: flex;
      align-items: center;
    }}
    .result-box.success {{
      border-color: rgba(74, 222, 128, 0.35);
      color: var(--accent);
    }}
    .result-box.error {{
      border-color: rgba(248, 113, 113, 0.35);
      color: var(--danger);
    }}
    footer {{
      padding: 24px;
      text-align: center;
      font-size: 13px;
      color: var(--muted);
    }}
    .pill {{
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 14px;
      border-radius: 999px;
      border: 1px solid var(--border);
      background: rgba(255, 255, 255, 0.03);
      font-size: 13px;
    }}
    .pill strong {{
      letter-spacing: 0.08em;
      color: var(--text);
    }}
  </style>
</head>
<body>
  <header>
    <h1>♻️ Pilar API Dashboard</h1>
    <p>
      Selamat datang di kontrol panel Hugging Face untuk API klasifikasi sampah.
      Di sini kamu dapat memantau status model, menjalankan self-test, dan
      menginspeksi request log secara real-time.
    </p>
    <div class="pills" style="display:flex; flex-wrap:wrap; gap:10px;">
      <span class="pill"><strong>MODE</strong> <span id="app-mode">loading…</span></span>
      <span class="pill"><strong>HOST</strong> <span id="app-host">loading…</span></span>
      <span class="pill"><strong>PORT</strong> <span id="app-port">loading…</span></span>
      <span class="pill"><strong>LAST SELF-TEST</strong> <span id="self-test-time">loading…</span></span>
    </div>
  </header>

  <main>
    <div class="grid">
      <section class="card span-4">
        <h2>Model Status</h2>
        <div id="model-status"></div>
      </section>

      <section class="card span-4">
        <div class="actions">
          <button id="test-database">Test Connection</button>
        </div>
        <h2>Database Status</h2>
        <div id="database-status"></div>
      </section>

      <section class="card span-4">
        <div class="actions">
          <button id="refresh-tests">Run Self-Test</button>
          <button id="refresh-data">Refresh Data</button>
        </div>
        <h2>Self-Test</h2>
        <div id="self-test-summary"></div>
        <table>
          <thead>
            <tr>
              <th>Test</th>
              <th>Status</th>
              <th>Detail</th>
            </tr>
          </thead>
          <tbody id="self-test-table"></tbody>
        </table>
      </section>

      <section class="card span-12">
        <h2>Prediction Playground</h2>
        <p class="muted-text">
          Coba model secara langsung dari browser. Upload gambar atau gunakan kamera (opsional), lalu kirim ke endpoint <code>/api/predict</code>.
        </p>
        <div class="playground">
          <div class="column">
            <label class="input-label" for="playground-upload">
              <span>Upload gambar (jpg/png)</span>
              <input type="file" id="playground-upload" accept="image/*" />
            </label>
            <div class="preview-container" id="playground-preview-box">
              <span class="preview-placeholder">Belum ada gambar dipilih. Upload file atau ambil foto.</span>
              <img id="playground-preview-image" alt="Preview input" />
            </div>
            <button id="playground-send" disabled>Kirim ke Model</button>
            <div class="result-box" id="playground-result">Belum ada prediksi.</div>
          </div>
          <div class="column">
            <div class="camera-wrapper">
              <video id="playground-video" autoplay playsinline muted></video>
              <canvas id="playground-canvas" width="0" height="0" style="display:none;"></canvas>
              <div class="camera-actions">
                <button id="playground-start-camera">Nyalakan Kamera</button>
                <button id="playground-capture" disabled>Ambil Foto</button>
              </div>
              <p class="muted-text" id="playground-camera-hint">Gunakan kamera untuk menangkap gambar secara langsung (opsional).</p>
            </div>
          </div>
        </div>
      </section>

      <section class="card span-12">
        <h2>Recent Requests</h2>
        <table>
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>Method</th>
              <th>Path</th>
              <th>Status</th>
              <th>Duration (ms)</th>
              <th>Client</th>
            </tr>
          </thead>
          <tbody id="request-logs"></tbody>
        </table>
      </section>

      <section class="card span-12">
        <h2>Events</h2>
        <table>
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>Level</th>
              <th>Message</th>
              <th>Meta</th>
            </tr>
          </thead>
          <tbody id="event-logs"></tbody>
        </table>
      </section>
    </div>
  </main>

  <footer>
    Pilar API • XGBoost Hybrid Waste Classification • {APP_MODE.upper()} mode
  </footer>

  <script>
    const statusBadge = (state) => {{
      const normalized = (state || "").toLowerCase();
      const cls = normalized === "ok" ? "status-tag status-ok" : "status-tag status-bad";
      const label = normalized === "ok" ? "OK" : "BAD";
      return `<span class="${{cls}}">● ${{label}}</span>`;
    }};

    const renderModelStatus = (snapshot) => {{
      if (!snapshot) return "<p>Model status unavailable.</p>";
      const rows = [
        `<div>Loaded: <strong>${{snapshot.loaded}}</strong></div>`,
        `<div>Validated: <strong>${{snapshot.validated}}</strong></div>`,
        `<div>Source: <strong>${{snapshot.source || "n/a"}}</strong></div>`,
        `<div>Threshold: <strong>${{snapshot.threshold ?? "n/a"}}</strong></div>`,
        `<div>Components: <strong>${{(snapshot.components || []).join(", ") || "n/a"}}</strong></div>`,
        `<div>Waste classes: <strong>${{(snapshot.waste_classes || []).join(", ") || "n/a"}}</strong></div>`
      ];
      return rows.join("");
    }};

    const renderSelfTestTable = (tests) => {{
      if (!Array.isArray(tests) || !tests.length) {{
        return `<tr><td colspan="3">Self-test belum pernah dijalankan.</td></tr>`;
      }}
      return tests.map((test) => {{
        const detail = typeof test.detail === "object"
          ? JSON.stringify(test.detail)
          : (test.detail || "-");
        return `
          <tr>
            <td>${{test.name}}</td>
            <td>${{statusBadge(test.status)}}</td>
            <td><code>${{detail}}</code></td>
          </tr>
        `;
      }}).join("");
    }};

    const renderRequestLogs = (logs) => {{
      if (!Array.isArray(logs) || !logs.length) {{
        return `<tr><td colspan="6">Belum ada request masuk.</td></tr>`;
      }}
      return logs.map((log) => `
        <tr>
          <td>${{log.timestamp}}</td>
          <td>${{log.method}}</td>
          <td>${{log.path}}</td>
          <td>${{statusBadge(log.status >= 400 ? "bad" : "ok")}} ${{log.status}}</td>
          <td>${{log.duration_ms}}</td>
          <td>${{log.client || "-"}}</td>
        </tr>
      `).join("");
    }};

    const renderEventLogs = (events) => {{
      if (!Array.isArray(events) || !events.length) {{
        return `<tr><td colspan="4">Belum ada event tercatat.</td></tr>`;
      }}
      return events.map((event) => {{
        const meta = Object.keys(event.meta || {{}}).length
          ? JSON.stringify(event.meta)
          : "-";
        return `
          <tr>
            <td>${{event.timestamp}}</td>
            <td>${{statusBadge(event.level === "ERROR" ? "bad" : "ok")}} ${{event.level}}</td>
            <td>${{event.message}}</td>
            <td><code>${{meta}}</code></td>
          </tr>
        `;
      }}).join("");
    }};

    async function fetchStatus() {{
      const response = await fetch("/dashboard/status");
      if (!response.ok) throw new Error("Failed to fetch status");
      return response.json();
    }}

    async function refreshDashboard() {{
      try {{
        const data = await fetchStatus();
        document.getElementById("app-mode").textContent = data.meta.appMode;
        document.getElementById("app-host").textContent = data.meta.host;
        document.getElementById("app-port").textContent = data.meta.port;
        document.getElementById("self-test-time").textContent = data.selfTest.timestamp;

        document.getElementById("model-status").innerHTML = renderModelStatus(data.model);
        document.getElementById("self-test-summary").innerHTML = `
          Overall status: ${{
            statusBadge(data.selfTest.overall)
          }}
        `;

        // Update database status
        await refreshDatabaseStatus();
        document.getElementById("self-test-table").innerHTML = renderSelfTestTable(data.selfTest.tests);
        document.getElementById("request-logs").innerHTML = renderRequestLogs(data.recentRequests);
        document.getElementById("event-logs").innerHTML = renderEventLogs(data.recentEvents);
      }} catch (err) {{
        console.error(err);
        document.getElementById("event-logs").innerHTML = `
          <tr><td colspan="4">Gagal memuat data dashboard: ${{err.message}}</td></tr>
        `;
      }}
    }}

    async function triggerSelfTest() {{
      try {{
        const response = await fetch("/dashboard/self-test", {{ method: "POST" }});
        if (!response.ok) throw new Error("Self-test failed");
        await refreshDashboard();
      }} catch (err) {{
        console.error(err);
        alert("Self-test gagal dijalankan. Lihat log untuk detail.");
      }}
    }}

    async function fetchDatabaseStatus() {{
      try {{
        const response = await fetch("/dashboard/database-status");
        if (!response.ok) throw new Error("Failed to fetch database status");
        return response.json();
      }} catch (err) {{
        console.error(err);
        return {{ app_mode: "unknown", credentials_set: false, client_initialized: false, error: err.message }};
      }}
    }}

    async function testDatabaseConnection() {{
      try {{
        document.getElementById("database-status").innerHTML = `<p style="color: var(--muted);">🔄 Testing connection...</p>`;
        const response = await fetch("/dashboard/test-database", {{ method: "POST" }});
        if (!response.ok) throw new Error("Database test failed");
        const result = await response.json();
        renderDatabaseStatus(result);
      }} catch (err) {{
        console.error(err);
        document.getElementById("database-status").innerHTML = `<p style="color: var(--danger);">❌ Test error: ${{err.message}}</p>`;
      }}
    }}

    function renderDatabaseStatus(status) {{
      const container = document.getElementById("database-status");
      if (!container) return;

      let html = `<div style="display: flex; flex-direction: column; gap: 12px;">`;

      // App Mode
      html += `<div><strong>Mode:</strong> <span style="color: ${{status.app_mode === 'production' ? 'var(--accent)' : 'var(--muted)'}};">${{status.app_mode || 'unknown'}}</span></div>`;

      if (status.app_mode === 'demo') {{
        html += `<div style="color: var(--muted);">ℹ️ Demo mode - database not required</div>`;
      }} else {{
        // Credentials
        if (status.credentials_set !== undefined) {{
          html += `<div><strong>Credentials:</strong> ${{status.credentials_set ? '✅ Set' : '❌ Not set'}}</div>`;
        }}

        // Connection Status
        if (status.connection_ok !== undefined) {{
          html += `<div><strong>Connection:</strong> ${{status.connection_ok ? '✅ Connected' : '❌ Failed'}}</div>`;
        }}

        // Client Initialized
        if (status.client_initialized !== undefined) {{
          html += `<div><strong>Client:</strong> ${{status.client_initialized ? '✅ Initialized' : '⏳ Not initialized'}}</div>`;
        }}

        // Message
        if (status.message) {{
          const color = status.success ? 'var(--accent)' : 'var(--danger)';
          html += `<div style="color: ${{color}}; margin-top: 8px;"><strong>${{status.success ? '✅' : '❌'}}</strong> ${{status.message}}</div>`;
        }}

        // Details
        if (status.details) {{
          html += `<div style="color: var(--muted); font-size: 0.9em; margin-top: 4px;">${{status.details}}</div>`;
        }}
      }}

      html += `</div>`;
      container.innerHTML = html;
    }}

    async function refreshDatabaseStatus() {{
      try {{
        const status = await fetchDatabaseStatus();
        renderDatabaseStatus(status);
      }} catch (err) {{
        console.error(err);
      }}
    }}

    function initPredictionPlayground() {{
      const uploadInput = document.getElementById("playground-upload");
      const sendButton = document.getElementById("playground-send");
      const previewBox = document.getElementById("playground-preview-box");
      const previewImage = document.getElementById("playground-preview-image");
      const resultBox = document.getElementById("playground-result");
      const startCameraButton = document.getElementById("playground-start-camera");
      const captureButton = document.getElementById("playground-capture");
      const videoEl = document.getElementById("playground-video");
      const canvasEl = document.getElementById("playground-canvas");
      const cameraHint = document.getElementById("playground-camera-hint");

      if (!uploadInput || !sendButton || !previewBox || !previewImage || !resultBox) {{
        return;
      }}

      const state = {{
        file: null,
        name: null,
        url: null,
        busy: false,
        stream: null,
      }};

      const updateSendButton = () => {{
        sendButton.disabled = state.busy || !state.file;
      }};

      const setResult = (message, mode = null) => {{
        resultBox.textContent = message;
        resultBox.classList.remove("error", "success");
        if (mode === "error") {{
          resultBox.classList.add("error");
        }} else if (mode === "success") {{
          resultBox.classList.add("success");
        }}
      }};

      const revokePreviewUrl = () => {{
        if (state.url) {{
          URL.revokeObjectURL(state.url);
          state.url = null;
        }}
      }};

      const setPreview = (file) => {{
        revokePreviewUrl();
        if (file) {{
          const objectUrl = URL.createObjectURL(file);
          state.url = objectUrl;
          previewImage.src = objectUrl;
          previewBox.classList.add("has-image");
        }} else {{
          previewImage.removeAttribute("src");
          previewBox.classList.remove("has-image");
        }}
      }};

      const setFile = (file, name = null) => {{
        state.file = file;
        state.name = name || (file ? file.name : null);
        setPreview(file);
        updateSendButton();
      }};

      uploadInput.addEventListener("change", (event) => {{
        const file = event.target.files && event.target.files[0];
        if (!file) {{
          setFile(null);
          setResult("Belum ada gambar yang dipilih.", null);
          return;
        }}
        setFile(file, file.name);
        setResult(`File terpilih: ${{file.name}}. Tekan tombol Kirim ke Model untuk memulai prediksi.`, null);
      }});

      const stopStream = () => {{
        if (state.stream) {{
          state.stream.getTracks().forEach((track) => track.stop());
          state.stream = null;
        }}
        if (videoEl) {{
          videoEl.srcObject = null;
        }}
        if (startCameraButton) {{
          startCameraButton.textContent = "Nyalakan Kamera";
        }}
        if (captureButton) {{
          captureButton.disabled = true;
        }}
      }};

      window.addEventListener("beforeunload", stopStream);
      window.addEventListener("unload", stopStream);

      if (startCameraButton && captureButton && videoEl && canvasEl) {{
        const hasCamera = Boolean(navigator.mediaDevices && navigator.mediaDevices.getUserMedia);
        if (!hasCamera) {{
          startCameraButton.disabled = true;
          startCameraButton.textContent = "Kamera tidak didukung";
          captureButton.disabled = true;
          if (cameraHint) {{
            cameraHint.textContent = "Browser kamu tidak mendukung kamera untuk halaman ini.";
          }}
        }} else {{
          startCameraButton.addEventListener("click", async () => {{
            if (state.stream) {{
              stopStream();
              setResult("Kamera dimatikan.", null);
              return;
            }}
            try {{
              const stream = await navigator.mediaDevices.getUserMedia({{ video: {{ facingMode: "environment" }} }});
              state.stream = stream;
              videoEl.srcObject = stream;
              captureButton.disabled = false;
              startCameraButton.textContent = "Matikan Kamera";
              setResult("Kamera aktif. Ambil foto atau upload file untuk mencoba model.", null);
            }} catch (err) {{
              console.error(err);
              setResult(`Gagal mengakses kamera: ${{err.message}}`, "error");
            }}
          }});

          captureButton.addEventListener("click", () => {{
            if (!state.stream) {{
              setResult("Nyalakan kamera terlebih dahulu.", "error");
              return;
            }}
            const track = state.stream.getVideoTracks()[0];
            const settings = track && track.getSettings ? track.getSettings() : {{}};
            const width = settings.width || videoEl.videoWidth || 640;
            const height = settings.height || videoEl.videoHeight || 480;
            canvasEl.width = width;
            canvasEl.height = height;
            const ctx = canvasEl.getContext("2d");
            if (!ctx) {{
              setResult("Kamera tidak didukung pada browser ini.", "error");
              return;
            }}
            ctx.drawImage(videoEl, 0, 0, width, height);
            canvasEl.toBlob((blob) => {{
              if (!blob) {{
                setResult("Gagal mengambil foto dari kamera.", "error");
                return;
              }}
              const filename = `playground-capture-${{Date.now()}}.jpg`;
              const capturedFile = new File([blob], filename, {{ type: blob.type || "image/jpeg" }});
              uploadInput.value = "";
              setFile(capturedFile, filename);
              setResult("Foto berhasil diambil. Tekan tombol Kirim ke Model untuk memprediksi.", null);
            }}, "image/jpeg", 0.92);
          }});
        }}
      }}

      sendButton.addEventListener("click", async () => {{
        if (!state.file || state.busy) {{
          if (!state.file) {{
            setResult("Pilih atau ambil satu gambar terlebih dahulu.", "error");
          }}
          return;
        }}

        state.busy = true;
        updateSendButton();
        setResult("Mengirim gambar ke model…", null);

        try {{
          const formData = new FormData();
          formData.append("file", state.file, state.name || state.file.name);

          const response = await fetch("/api/predict", {{
            method: "POST",
            body: formData,
          }});

          let jsonPayload;
          try {{
            jsonPayload = await response.json();
          }} catch (parseErr) {{
            throw new Error("Gagal membaca respons dari server.");
          }}

          if (!response.ok) {{
            const detail = jsonPayload && (jsonPayload.detail || jsonPayload.message);
            throw new Error(detail || `Request gagal dengan status ${{response.status}}`);
          }}

          if (jsonPayload && jsonPayload.success && jsonPayload.data) {{
            const data = jsonPayload.data;
            const confidenceValue = typeof data.confidence === "number"
              ? data.confidence.toFixed(2)
              : data.confidence;
            setResult(
              `Prediksi: ${{data.wasteType}} • ${{data.category}} (confidence ${{confidenceValue}}%)`,
              "success"
            );
          }} else {{
            setResult(JSON.stringify(jsonPayload), null);
          }}
        }} catch (err) {{
          console.error(err);
          setResult(`Gagal melakukan prediksi: ${{err.message}}`, "error");
        }} finally {{
          state.busy = false;
          updateSendButton();
        }}
      }});

      setResult("Belum ada prediksi.", null);
      updateSendButton();
    }}

    initPredictionPlayground();

    document.getElementById("refresh-tests").addEventListener("click", triggerSelfTest);
    document.getElementById("refresh-data").addEventListener("click", refreshDashboard);
    document.getElementById("test-database").addEventListener("click", testDatabaseConnection);

    refreshDashboard();
    setInterval(refreshDashboard, 5000);
  </script>
</body>
</html>
    """


# ---------------------------------------------------------------------------
# FastAPI application setup
# ---------------------------------------------------------------------------

app = FastAPI(
    title="Pilar API",
    description="API untuk klasifikasi sampah menggunakan XGBoost Hybrid Model",
    version="2.0.0",
)

HF_HOST = os.getenv("HOST") or os.getenv("HF_HOST") or "0.0.0.0"


def _resolve_port() -> int:
    for key in ("PORT", "HF_PORT", "SPACE_PORT"):
        raw = os.getenv(key)
        if not raw:
            continue
        try:
            return int(raw)
        except ValueError:
            append_event("WARNING", "Invalid port value detected", {"key": key, "value": raw})
    return 7860


HF_PORT = _resolve_port()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log every request and response, capturing timing and status."""
    start = time.perf_counter()
    timestamp = utc_timestamp()
    client_host = request.client.host if request.client else "-"

    # Special logging for auth endpoints
    if "/api/auth/" in request.url.path:
        logger.info("=" * 80)
        logger.info(f"[MIDDLEWARE] 🔥 AUTH REQUEST DETECTED!")
        logger.info(f"[MIDDLEWARE] Method: {request.method}")
        logger.info(f"[MIDDLEWARE] Path: {request.url.path}")
        logger.info(f"[MIDDLEWARE] Full URL: {request.url}")
        logger.info(f"[MIDDLEWARE] Client: {client_host}")
        logger.info(f"[MIDDLEWARE] Headers: {dict(request.headers)}")
        logger.info("=" * 80)

    try:
        response = await call_next(request)
        status_code = response.status_code

        # Special logging for auth responses
        if "/api/auth/" in request.url.path:
            logger.info("=" * 80)
            logger.info(f"[MIDDLEWARE] 🔥 AUTH RESPONSE")
            logger.info(f"[MIDDLEWARE] Status: {status_code}")
            logger.info(f"[MIDDLEWARE] Path: {request.url.path}")
            logger.info("=" * 80)

        return response
    except Exception as exc:  # pragma: no cover - passthrough for observability
        status_code = 500
        append_event(
            "ERROR",
            "Unhandled exception during request",
            {"path": request.url.path, "error": str(exc)},
        )
        logger.error(f"[MIDDLEWARE] ❌ Exception in request: {exc}")
        raise
    finally:
        duration_ms = round((time.perf_counter() - start) * 1000, 2)
        record_request_log(
            {
                "timestamp": timestamp,
                "method": request.method,
                "path": request.url.path,
                "status": status_code,
                "duration_ms": duration_ms,
                "client": client_host,
            }
        )
        logger.info(
            "[TRACE] %s %s -> %s (%.2f ms)",
            request.method,
            request.url.path,
            status_code,
            duration_ms,
        )


@app.on_event("startup")
async def startup_event() -> None:
    """Initialise model and prediction services during application startup."""
    append_event(
        "INFO",
        "Starting Pilar API",
        {"app_mode": APP_MODE, "base_dir": str(BASE_DIR)},
    )

    # Test database connection
    logger.info("=" * 60)
    logger.info("[STARTUP] Testing database connection...")
    db_test = test_supabase_connection()
    if db_test['success']:
        logger.info(f"[STARTUP] ✅ {db_test['message']}")
        logger.info(f"[STARTUP] {db_test['details']}")
    else:
        logger.error(f"[STARTUP] ❌ {db_test['message']}")
        logger.error(f"[STARTUP] {db_test['details']}")

    append_event(
        "INFO" if db_test['success'] else "WARNING",
        "Database connection test",
        db_test,
    )
    logger.info("=" * 60)

    model_service = init_model_service(base_dir=BASE_DIR)
    append_event("INFO", "Model service initialised")

    model = model_service.load_model()
    append_event(
        "INFO",
        "Model loaded successfully",
        {"keys": list(model.keys())},
    )

    init_prediction_service(model)
    append_event("INFO", "Prediction service initialised")

    run_self_tests()
    append_event("INFO", "Startup sequence completed")


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Log shutdown event for visibility."""
    append_event("INFO", "Shutting down Pilar API")


# ---------------------------------------------------------------------------
# Dashboard & API routes
# ---------------------------------------------------------------------------

@app.get("/", response_class=HTMLResponse)
async def dashboard() -> HTMLResponse:
    """Serve the interactive dashboard UI."""
    return HTMLResponse(build_dashboard_html())


@app.get("/dashboard/status", response_class=JSONResponse)
async def dashboard_status() -> JSONResponse:
    """Expose dashboard data for the front-end poller."""
    return JSONResponse(build_dashboard_payload())


@app.post("/dashboard/self-test", response_class=JSONResponse)
async def dashboard_self_test() -> JSONResponse:
    """Trigger self-tests manually from the dashboard."""
    payload = run_self_tests()
    return JSONResponse(payload)


@app.get("/dashboard/database-status", response_class=JSONResponse)
async def dashboard_database_status() -> JSONResponse:
    """Get current database connection status."""
    status = get_connection_status()
    return JSONResponse(status)


@app.post("/dashboard/test-database", response_class=JSONResponse)
async def dashboard_test_database() -> JSONResponse:
    """Test database connection and return detailed results."""
    result = test_supabase_connection()
    return JSONResponse(result)


# Register existing API routers
app.include_router(health.router)
app.include_router(predict.router)

append_event("INFO", "Core routers registered", {"routes": ["health", "predict"]})

if APP_MODE.lower() == "production":
    try:
        from . import auth
        from .api import users

        app.include_router(auth.router)
        app.include_router(users.router)
        append_event("INFO", "Production routers enabled", {"routes": ["auth", "users"]})
        logger.info("=" * 80)
        logger.info("[MAIN] ✅ Production routers (auth, users) mounted successfully")
        logger.info("[MAIN] 🔐 Auth router prefix: /api/auth")
        logger.info("[MAIN] 👥 Users router prefix: /api")
        logger.info("[MAIN] Available auth endpoints:")
        logger.info("[MAIN]   - POST /api/auth/login")
        logger.info("[MAIN]   - POST /api/auth/register")
        logger.info("[MAIN]   - POST /api/auth/forgot-password")
        logger.info("[MAIN]   - POST /api/auth/reset-password")
        logger.info("[MAIN]   - POST /api/auth/change-password")
        logger.info("[MAIN]   - GET  /api/auth/me")
        logger.info("[MAIN]   - POST /api/auth/logout")
        logger.info("=" * 80)
    except ImportError as exc:
        append_event(
            "WARNING",
            "Failed to import production routers",
            {"error": str(exc)},
        )
        logger.error(f"[MAIN] ❌ Failed to import production routers: {exc}")
        logger.exception(exc)
else:
    append_event("INFO", "Auth/users routers disabled (demo mode)")
    logger.info("[MAIN] ⚠️  Demo mode - auth/users routers not mounted")


logger.info("[ROUTES] Ready for deployment in %s mode", APP_MODE.upper())


if __name__ == "__main__":
    import uvicorn

    append_event(
        "INFO",
        "Starting uvicorn manually",
        {"host": HF_HOST, "port": HF_PORT},
    )
    uvicorn.run("app.main:app", host=HF_HOST, port=HF_PORT)
