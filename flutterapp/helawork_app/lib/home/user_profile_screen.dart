import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helawork_app/providers/user_profile_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          "Create Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF1E1E2C),
                        backgroundImage:
                            _pickedImage != null ? FileImage(_pickedImage!) : null,
                        child: _pickedImage == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      context,
                      label: "Bio",
                      onChanged: (val) => profileProvider.setProfileField('bio', val),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      context,
                      label: "Skills (comma-separated)",
                      onChanged: (val) => profileProvider.setProfileField('skills', val),
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      context,
                      label: "Experience",
                      onChanged: (val) => profileProvider.setProfileField('experience', val),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      context,
                      label: "Portfolio Link",
                      onChanged: (val) => profileProvider.setProfileField('portfolio_link', val),
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      context,
                      label: "Hourly Rate",
                      keyboardType: TextInputType.number,
                      onChanged: (val) => profileProvider.setProfileField('hourly_rate', val),
                    ),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            profileProvider.saveProfile(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Save Profile",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
      validator: (val) => val == null || val.isEmpty ? 'This field cannot be empty' : null,
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
      Provider.of<UserProfileProvider>(context, listen: false)
          .setProfileField('profile_picture', _pickedImage);
    }
  }
}
