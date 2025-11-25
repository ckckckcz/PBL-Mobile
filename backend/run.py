import uvicorn
from pathlib import Path

if __name__ == "__main__":
    # Get the directory where this script is located
    backend_dir = Path(__file__).parent

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
