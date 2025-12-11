import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Icon(
              PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
              color: const Color(0xFF2E3A2F),
              size: 24,
            ),
          ),
        ),
        title: const Text(
          'Akun Saya',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
                color: Colors.grey.shade300,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                'https://via.placeholder.com/100',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF4CAF50),
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
                // TODO: Implement image picker
                debugPrint('Change profile picture');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.camera(PhosphorIconsStyle.regular),
                  size: 18,
                  color: Colors.black,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A2F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon,
                      color: const Color(0xFF607D6B), size: 20)
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
        const Text(
          'Nomor Telepon',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A2F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Masukkan nomor telepon',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefix: Container(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ID',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E3A2F),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                      size: 12,
                      color: const Color(0xFF607D6B),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 20,
                      color: const Color(0xFFE0E0E0),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '+62 ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E3A2F),
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
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _saveProfile();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
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
    // TODO: Implement save profile logic with API
    debugPrint('Saving profile...');
    debugPrint('Name: ${_nameController.text}');
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Birth Date: ${_birthDateController.text}');
    debugPrint('Phone: +62 ${_phoneController.text}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui'),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Go back to profile page
    Navigator.pop(context);
  }
}