# Quick Start Guide - Refactored Code

## 🚀 Quick Overview

Kode sudah di-refactor menjadi **clean code** dengan struktur yang lebih baik. Berikut panduan singkat untuk mulai menggunakan code yang baru.

## 📁 Struktur Folder Baru

```
lib/
├── constants/              # Konstanta aplikasi
│   ├── app_colors.dart    # Warna-warna aplikasi
│   └── app_strings.dart   # Text/string aplikasi
│
├── utils/                  # Helper functions
│   ├── validators.dart    # Validasi form
│   └── image_helper.dart  # Helper untuk gambar
│
├── widgets/                # Widget reusable
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── scan_result_widgets.dart
│   └── history_widgets.dart
│
├── pages/                  # Halaman aplikasi (SUDAH REFACTORED)
│   ├── auth/
│   │   └── login.dart     ✅ REFACTORED
│   ├── about_app.dart     ✅ REFACTORED
│   ├── scan_result.dart   ✅ REFACTORED
│   └── history.dart       ✅ REFACTORED
```

## 🎯 Cara Menggunakan

### 1. Import Constants

**Sebelum:**
```dart
backgroundColor: const Color(0xFF4CAF50),
Text('Login berhasil'),
```

**Sesudah:**
```dart
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

backgroundColor: AppColors.primary,
Text(AppStrings.loginSuccess),
```

### 2. Menggunakan Custom Button

```dart
import '../widgets/custom_button.dart';

// Primary button
CustomButton.primary(
  text: 'Login',
  onPressed: () => _handleLogin(),
  isLoading: _isLoading,
)

// Secondary button
CustomButton.secondary(
  text: 'Cancel',
  onPressed: () => Navigator.pop(context),
)

// Outline button
CustomButton.outline(
  text: 'Skip',
  onPressed: () {},
)

// Danger button (untuk delete, dll)
CustomButton.danger(
  text: 'Delete',
  onPressed: () => _handleDelete(),
)
```

### 3. Menggunakan Custom TextField

```dart
import '../widgets/custom_text_field.dart';
import '../utils/validators.dart';

// Email field
CustomTextField.email(
  controller: _emailController,
  validator: Validators.email,
  label: 'Email',
  hint: 'contoh@email.com',
)

// Password field (auto toggle visibility)
CustomTextField.password(
  controller: _passwordController,
  validator: Validators.password,
  onSubmitted: (_) => _submit(),
)

// Phone field
CustomTextField.phone(
  controller: _phoneController,
  validator: Validators.phone,
)

// Name field
CustomTextField.name(
  controller: _nameController,
  validator: Validators.name,
)

// Custom field
CustomTextField(
  controller: _controller,
  label: 'Custom Label',
  hint: 'Enter text',
  keyboardType: TextInputType.text,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Field harus diisi';
    }
    return null;
  },
)
```

### 4. Menggunakan Validators

```dart
import '../utils/validators.dart';

// Email validation
validator: Validators.email,

// Password validation (default min 6 karakter)
validator: Validators.password,

// Password dengan custom min length
validator: (value) => Validators.password(value, minLength: 8),

// Phone validation
validator: Validators.phone,

// Required field
validator: (value) => Validators.required(value, fieldName: 'Nama'),

// Combine multiple validators
validator: (value) => Validators.compose([
  () => Validators.required(value),
  () => Validators.minLength(value, 8),
  () => Validators.maxLength(value, 20),
]),
```

### 5. Menggunakan Image Helper

```dart
import '../utils/image_helper.dart';

// Auto-detect image source (file/network/asset)
ImageHelper.buildImage(
  path: imagePath,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)

// Rounded image
ImageHelper.buildRoundedImage(
  path: imagePath,
  width: 100,
  height: 100,
  borderRadius: 12,
)

// Circular image (untuk avatar)
ImageHelper.buildCircularImage(
  path: imagePath,
  size: 50,
)

// Check if image exists
if (ImageHelper.fileExists(imagePath)) {
  // Do something
}

// Get file from path
final file = ImageHelper.getImageFile(imagePath);
```

### 6. Menggunakan Colors Utility

```dart
import '../constants/app_colors.dart';

// Primary colors
AppColors.primary
AppColors.primaryLight
AppColors.primaryDark

// Background
AppColors.background
AppColors.surface

// Text colors
AppColors.textPrimary
AppColors.textSecondary
AppColors.textTertiary

// Category colors
AppColors.categoryOrganic      // Hijau
AppColors.categoryInorganic    // Biru
AppColors.categoryB3           // Merah

// Get category color dynamically
AppColors.getCategoryColor('Organik')     // Returns green
AppColors.getCategoryColor('Anorganik')   // Returns blue
AppColors.getCategoryColor('B3')          // Returns red

// Get category icon
AppColors.getCategoryIcon('Organik')      // Returns Icons.eco
AppColors.getCategoryIcon('Anorganik')    // Returns Icons.recycling

// Parse hex color
AppColors.fromHex('#FF5733')
```

## 🎨 Contoh Lengkap: Form Login

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key}) : super(key: key);

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Your login logic here
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.loginSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.errorLogin),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email field
                CustomTextField.email(
                  controller: _emailController,
                  validator: Validators.email,
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                CustomTextField.password(
                  controller: _passwordController,
                  validator: Validators.password,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleLogin(),
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                CustomButton.primary(
                  text: AppStrings.login,
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## ✅ Checklist Migration

Jika ingin migrate code lama ke struktur baru:

- [ ] Replace hardcoded colors dengan `AppColors.*`
- [ ] Replace hardcoded strings dengan `AppStrings.*`
- [ ] Replace custom button widgets dengan `CustomButton.*`
- [ ] Replace TextField/TextFormField dengan `CustomTextField.*`
- [ ] Replace validation logic dengan `Validators.*`
- [ ] Extract large widgets menjadi separate widgets
- [ ] Split long methods (<30 lines per method)
- [ ] Move business logic keluar dari UI

## 🎓 Best Practices

### DO ✅
```dart
// Use constants
backgroundColor: AppColors.primary,
Text(AppStrings.loginSuccess),

// Use reusable widgets
CustomButton.primary(
  text: 'Submit',
  onPressed: _handleSubmit,
)

// Use validators
validator: Validators.email,

// Small, focused methods
void _handleLogin() {
  if (!_formKey.currentState!.validate()) return;
  _performLogin();
}
```

### DON'T ❌
```dart
// Don't hardcode colors
backgroundColor: const Color(0xFF4CAF50),

// Don't hardcode strings
Text('Login berhasil'),

// Don't create inline buttons repeatedly
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF4CAF50),
    // ... lots of styling code
  ),
  child: const Text('Submit'),
)

// Don't write inline validation
validator: (value) {
  if (value?.isEmpty ?? true) return 'Email required';
  if (!value!.contains('@')) return 'Invalid email';
  // ... more validation
}
```

## 📚 File Reference

| Need | Import |
|------|--------|
| Colors | `import '../constants/app_colors.dart';` |
| Strings | `import '../constants/app_strings.dart';` |
| Buttons | `import '../widgets/custom_button.dart';` |
| TextFields | `import '../widgets/custom_text_field.dart';` |
| Validation | `import '../utils/validators.dart';` |
| Images | `import '../utils/image_helper.dart';` |

## 🐛 Troubleshooting

**Error: No named parameter with the name 'xxx'**
- Check constructor documentation
- Some parameters have default values
- Don't pass parameters that match defaults

**Error: Cannot import**
- Check import path (relative vs absolute)
- Make sure file exists
- Run `flutter pub get`

**Widget not updating**
- Make sure to call `setState(() {})`
- Check if widget is mounted before setState

## 💡 Tips

1. **Code Organization**: Keep files < 300 lines
2. **Widget Extraction**: Extract widgets when repeated 2+ times
3. **Constants First**: Always use constants over hardcoded values
4. **Validators**: Create custom validators in `validators.dart`
5. **Reusability**: If you write same code twice, make it a widget/function

---

**Happy Coding! 🚀**