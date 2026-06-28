import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qarazdare/models/model.dart';
import 'package:qarazdare/database/dbhelper.dart';
import 'dart:io'; // ADD THIS

class Service extends Notifier<List<PersonModel>> {
  @override
  List<PersonModel> build() {
    //------build method is called when the provider is 1st created, before it, it first reads the data from database and then returns the state
    readAll();
    return [];
  }

//----used to insert data into database and then update the state
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

//----used to convert the json data from database to model and store in state
  Future<void> readAll() async {
    final db = Dbhelper();
    final maps = await db.getAll();
    List<PersonModel> persons = [];
    for (var map in maps) {
      persons.add(PersonModel.fromMap(map));
    }
    state = persons;
  }

//---used to read a single person by id
//---I never called it anywhere.....
  // Future<PersonModel?> readSinglePerson(int id) async {
  //   final db = Dbhelper();
  //   final Map<String, dynamic>? result = await db.readPerson(id);
  //   if (result != null) {
  //     return PersonModel.fromMap(result);
  //   }
  //   return null;
  // }

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

//---called when user deletes a person, it deletes the person from database and also deletes the image file if it exists
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
//---use of lambda function to delete the person from database and then update the state by removing the person from the list
    await db.deletePerson(id);
    final List<PersonModel> finalList = List.from(state);

    ///----removing the person from state is used to update the UI after deleting the person from database
    finalList.removeWhere((person) => person.id == id);
    state = finalList;
  }
}

final serviceProvider =
    NotifierProvider<Service, List<PersonModel>>(() => Service());
