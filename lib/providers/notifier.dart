import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qarazdare/models/model.dart';
import 'package:qarazdare/database/dbhelper.dart';
import 'dart:io'; // ADD THIS

class Service extends Notifier<List<PersonModel>> {
  @override
  List<PersonModel> build() {
    readAll();
    return [];
  }

  Future<void> insert(PersonModel personObj) async {
    final db = Dbhelper();
    final realID = await db.insertData(personObj);
    final newObj = PersonModel(
      id: realID,
      name: personObj.name,
      address: personObj.address,
      imagePath: personObj.imagePath, // ADD THIS
    );

    state = List.from(state)..add(newObj);
  }

  Future<void> readAll() async {
    final db = Dbhelper();
    final maps = await db.getAll();
    List<PersonModel> persons = [];
    for (var map in maps) {
      persons.add(PersonModel.fromMap(map));
    }
    state = persons;
  }

  Future<PersonModel?> readSinglePerson(int id) async {
    final db = Dbhelper();
    final Map<String, dynamic>? result = await db.readPerson(id);
    if (result != null) {
      return PersonModel.fromMap(result);
    }
    return null;
  }

  //---ADD THIS: Update person with new image
  Future<void> updatePerson(PersonModel updatedPerson) async {
    final db = Dbhelper();
    await db.updatePerson(updatedPerson);

    // Update state
    final List<PersonModel> newState = List.from(state);
    final index = newState.indexWhere((p) => p.id == updatedPerson.id);
    if (index != -1) {
      newState[index] = updatedPerson;
      state = newState;
    }
  }

  //---ADD THIS: Delete image file
  Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> deleteRow(int id) async {
    final db = Dbhelper();

    // Get person to delete their image
    final person = await db.readPerson(id);
    if (person != null) {
      final imagePath = person['imagePath'] as String?;
      if (imagePath != null) {
        await deleteImageFile(imagePath);
      }
    }

    await db.deletePerson(id);
    final List<PersonModel> finalList = List.from(state);
    finalList.removeWhere((person) => person.id == id);
    state = finalList;
  }
}

final serviceProvider =
    NotifierProvider<Service, List<PersonModel>>(() => Service());
