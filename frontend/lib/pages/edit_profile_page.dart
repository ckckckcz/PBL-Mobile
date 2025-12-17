import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../theme/app_typography.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userBirthDate;

  const EditProfilePage({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userBirthDate,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
    _birthDateController = TextEditingController(text: widget.userBirthDate);
    _phoneController = TextEditingController(
        text: widget.userPhone.replaceFirst('+62 ', ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Icon(
              PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Akun Saya',
          style: AppTypography.bodyLargeSemibold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildProfilePicture(),
                  const SizedBox(height: 32),
                  _buildTextField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    hintText: 'Masukkan nama lengkap',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'Masukkan email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Tanggal Lahir',
                    controller: _birthDateController,
                    hintText: 'DD/MM/YYYY',
                    readOnly: true,
                    prefixIcon:
                        PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),
                  _buildPhoneField(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                'https://via.placeholder.com/100',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary,
                    child: Icon(
                      PhosphorIcons.user(PhosphorIconsStyle.regular),
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                debugPrint('Change profile picture');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 3,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.camera(PhosphorIconsStyle.regular),
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool readOnly = false,
    PhosphorIconData? prefixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMediumMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: AppTypography.bodyMediumRegular.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.bodyMediumRegular.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Field ini tidak boleh kosong';
              }
              if (label == 'Email' && !value.contains('@')) {
                return 'Email tidak valid';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomor Telepon',
          style: AppTypography.bodyMediumMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: AppTypography.bodyMediumRegular.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Masukkan nomor telepon',
              hintStyle: AppTypography.bodyMediumRegular.copyWith(
                color: AppColors.textTertiary,
              ),
              prefix: Container(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ID',
                      style: AppTypography.bodyMediumRegular.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 20,
                      color: AppColors.border,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+62 ',
                      style: AppTypography.bodyMediumRegular.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor telepon tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _saveProfile();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          'Simpan',
          style: AppTypography.bodyMediumSemibold.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 5, 23),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _saveProfile() {
    debugPrint('Saving profile...');
    debugPrint('Name: ${_nameController.text}');
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Birth Date: ${_birthDateController.text}');
    debugPrint('Phone: +62 ${_phoneController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profil berhasil diperbarui',
          style: AppTypography.bodyMediumMedium.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }
}