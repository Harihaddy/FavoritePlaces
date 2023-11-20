import 'dart:io';

import 'package:favorite_places/model/places.dart';
import 'package:favorite_places/providers/user_plase.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlacesSereen extends ConsumerStatefulWidget {
  const AddPlacesSereen({
    super.key,
  });

  @override
  ConsumerState<AddPlacesSereen> createState() {
    return _AddPlacesSereenState();
  }
}

class _AddPlacesSereenState extends ConsumerState<AddPlacesSereen> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _SelectedLocation;

  void _savePlace() {
    final enteredTitle = _titleController.text;

    if (enteredTitle.isEmpty ||
        _selectedImage == null ||
        _SelectedLocation == null) {
      return;
    }
    ref
        .read(UserPlaseProvider.notifier)
        .addPlase(enteredTitle, _selectedImage!, _SelectedLocation!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: _titleController,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
            const SizedBox(height: 10),
            ImageInput(
              onPictImage: (image) => _selectedImage = image,
            ),
            const SizedBox(height: 16),
            Locationinput(
              onSelectedLocation: (location) {
                _SelectedLocation = location;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: _savePlace,
                icon: const Icon(Icons.add),
                label: const Text('Add Place'))
          ],
        ),
      ),
    );
  }
}
