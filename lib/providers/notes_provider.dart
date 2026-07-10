import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/session_note.dart';

class NotesProvider extends ChangeNotifier {
  List<SessionNote> _notes = [];
  static const _storageKey = 'session_notes';
  final _uuid = const Uuid();

  List<SessionNote> get notes => List.unmodifiable(_notes);

  List<SessionNote> notesForPatient(String patientId) =>
      _notes.where((n) => n.patientId == patientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _notes = list
          .map((e) => SessionNote.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> addNote(String patientId, String content) async {
    final note = SessionNote(
      id: _uuid.v4(),
      patientId: patientId,
      content: content.trim(),
      createdAt: DateTime.now(),
    );
    _notes.add(note);
    notifyListeners();
    await _persist();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_notes.map((n) => n.toJson()).toList()),
    );
  }
}
