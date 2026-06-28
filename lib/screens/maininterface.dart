import 'package:flutter/material.dart';
import 'package:qarazdare/providers/image_service.dart';
import 'package:qarazdare/widgets/deletion_alert.dart';
import 'package:qarazdare/providers/notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qarazdare/screens/person.dart';
import 'package:qarazdare/screens/form.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:qarazdare/models/model.dart';

class Maininterface extends ConsumerWidget {
  const Maininterface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(serviceProvider);

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_alt_1,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Contacts Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first person',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const Fourm(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Person'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          data.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 199, 242, 172),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: ListTile(
                  title: Text(
                    //-----> Display the person's name by accessing from state (data list) using the index
                    data[index].name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data[index].address ?? 'No address provided',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        'Tap to View detail',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  leading: InkWell(
                    onTap: () => _showImagePicker(context, ref, data[index]),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: data[index].imagePath != null
                          ? FileImage(File(data[index].imagePath!))
                              as ImageProvider?
                          : null,
                      child: data[index].imagePath == null
                          ? Text(
                              data[index].name[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: ((context) =>

                            ///----> Pass the person's id to the DeletionAlert widget to delete the person while accessing by index from the state (data list)
                            DeletionAlert(personID: data[index].id)),
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    ///-----Use index of state (list of persons) to navigate to the Person screen and pass the index as an argument
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => Person(index: index))),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePicker(
      BuildContext context, WidgetRef ref, PersonModel person) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _handleImagePick(context, ref, person, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.green),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _handleImagePick(context, ref, person, ImageSource.camera);
              },
            ),
            if (person.imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _handleRemoveImage(context, ref, person);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePick(BuildContext context, WidgetRef ref,
      PersonModel person, ImageSource source) async {
    try {
      final imageService = ImageService();

      // Pick image (permissions are handled inside)
      final File? pickedFile = await imageService.pickImage(source);
      if (pickedFile == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No image selected or permission denied'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saving image...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Save image
      final String? savedPath =
          await imageService.saveImage(pickedFile, person.id);

      if (savedPath == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save image'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Update person in database
      final updatedPerson = PersonModel(
        id: person.id,
        name: person.name,
        address: person.address,
        imagePath: savedPath,
      );

      await ref.read(serviceProvider.notifier).updatePerson(updatedPerson);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // FIXED: Using mounted check properly
  Future<void> _handleRemoveImage(
      BuildContext context, WidgetRef ref, PersonModel person) async {
    try {
      final imageService = ImageService();

      // Delete the image file
      await imageService.deleteImage(person.imagePath);

      // Update person without image
      final updatedPerson = PersonModel(
        id: person.id,
        name: person.name,
        address: person.address,
        imagePath: null,
      );

      await ref.read(serviceProvider.notifier).updatePerson(updatedPerson);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image removed'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      return;
    }
  }
}
