import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';

class EditProfileSheet extends StatefulWidget {
  final UserProfile currentUser;

  const EditProfileSheet({super.key, required this.currentUser});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentUser.identity.fullName,
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Update Profile", style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),

          // Avatar Picker
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : null,
                child: _selectedImage == null
                    ? Icon(Icons.camera_alt, color: theme.primaryColor)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Tap to change photo",
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ),

          const SizedBox(height: 24),

          // Name Field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Display Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Save Button
          BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded && !state.isUpdating) {
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              final isUpdating = state is ProfileLoaded && state.isUpdating;

              return ElevatedButton(
                onPressed: isUpdating
                    ? null
                    : () {
                        context.read<ProfileBloc>().add(
                          UpdateUserProfile(
                            fullName: _nameController.text,
                            imageFile: _selectedImage,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Changes"),
              );
            },
          ),
        ],
      ),
    );
  }
}
