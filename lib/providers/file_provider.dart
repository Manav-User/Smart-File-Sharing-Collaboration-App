import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/file_model.dart';
import '../services/local_storage_service.dart';

class FileProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final Uuid _uuid = const Uuid();

  List<FileItem> _files = [];
  bool _isOnline = false;
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'All';
  String _filterShared = 'All'; // All, Personal, Shared

  // Getters
  List<FileItem> get allFiles => _files;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterShared => _filterShared;

  List<FileItem> get filteredFiles {
    List<FileItem> result = List.from(_files);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((f) =>
              f.fileName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Type filter
    if (_filterType != 'All') {
      result = result.where((f) => f.fileType == _filterType).toList();
    }

    // Shared filter
    if (_filterShared == 'Shared') {
      result = result.where((f) => f.isShared).toList();
    } else if (_filterShared == 'Personal') {
      result = result.where((f) => !f.isShared).toList();
    }

    return result;
  }

  List<FileItem> get sharedFiles => _files.where((f) => f.isShared).toList();
  List<FileItem> get personalFiles => _files.where((f) => !f.isShared).toList();
  List<FileItem> get pendingSyncFiles =>
      _files.where((f) => f.hasPendingSync).toList();
  List<FileItem> get conflictFiles =>
      _files.where((f) => f.hasConflict).toList();

  List<String> get fileTypes {
    final types = _files.map((f) => f.fileType).toSet().toList();
    types.sort();
    return types;
  }

  // Initialize
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _files = await _storage.loadFiles();
    _isLoading = false;
    notifyListeners();
  }

  // Search & Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterShared(String filter) {
    _filterShared = filter;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = 'All';
    _filterShared = 'All';
    notifyListeners();
  }

  // Toggle online/offline
  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    if (_isOnline) {
      _syncData();
    }
    notifyListeners();
  }

  // CRUD Operations
  Future<String?> addFile({
    required String fileName,
    required String fileType,
    required String description,
  }) async {
    // Validate
    if (fileName.trim().isEmpty) return 'File name is required';
    if (fileType.trim().isEmpty) return 'File type is required';
    if (description.trim().isEmpty) return 'Description is required';

    // Check duplicate names
    if (_files.any(
        (f) => f.fileName.toLowerCase() == fileName.trim().toLowerCase())) {
      return 'A file with this name already exists';
    }

    final now = DateTime.now();
    final file = FileItem(
      id: _uuid.v4(),
      fileName: fileName.trim(),
      fileType: fileType.trim(),
      description: description.trim(),
      createdAt: now,
      updatedAt: now,
      versions: [
        FileVersion(
          id: _uuid.v4(),
          versionNumber: 1,
          description: 'Initial version',
          timestamp: now,
        ),
      ],
      hasPendingSync: !_isOnline,
    );

    _files.insert(0, file);
    await _save();
    return null; // success
  }

  Future<String?> updateFile({
    required String fileId,
    required String description,
  }) async {
    if (description.trim().isEmpty) return 'Description is required';

    final idx = _files.indexWhere((f) => f.id == fileId);
    if (idx == -1) return 'File not found';

    final file = _files[idx];
    final now = DateTime.now();

    // Check for conflict: if file was already updated offline and we're updating again
    if (file.hasPendingSync && !_isOnline) {
      file.hasConflict = true;
    }

    file.description = description.trim();
    file.updatedAt = now;
    file.hasPendingSync = !_isOnline;

    // Add new version
    final newVersion = FileVersion(
      id: _uuid.v4(),
      versionNumber: file.versions.length + 1,
      description: description.trim(),
      timestamp: now,
    );
    file.versions.add(newVersion);

    await _save();
    return null;
  }

  Future<void> deleteFile(String fileId) async {
    _files.removeWhere((f) => f.id == fileId);
    await _save();
  }

  // Sharing
  Future<bool> toggleShare(String fileId) async {
    final idx = _files.indexWhere((f) => f.id == fileId);
    if (idx == -1) return false;
    _files[idx].isShared = !_files[idx].isShared;
    _files[idx].updatedAt = DateTime.now();
    _files[idx].hasPendingSync = !_isOnline;
    await _save();
    return _files[idx].isShared;
  }

  // Comments
  Future<String?> addComment({
    required String fileId,
    required String text,
    String author = 'You',
  }) async {
    if (text.trim().isEmpty) return 'Comment cannot be empty';

    final idx = _files.indexWhere((f) => f.id == fileId);
    if (idx == -1) return 'File not found';

    final comment = Comment(
      id: _uuid.v4(),
      text: text.trim(),
      author: author,
      timestamp: DateTime.now(),
    );
    _files[idx].comments.add(comment);
    _files[idx].hasPendingSync = !_isOnline;
    await _save();
    return null;
  }

  Future<void> deleteComment(String fileId, String commentId) async {
    final idx = _files.indexWhere((f) => f.id == fileId);
    if (idx == -1) return;
    _files[idx].comments.removeWhere((c) => c.id == commentId);
    await _save();
  }

  // Conflict Resolution
  Future<void> resolveConflict(String fileId, String strategy) async {
    final idx = _files.indexWhere((f) => f.id == fileId);
    if (idx == -1) return;

    if (strategy == 'latest') {
      // Keep only the latest version
      if (_files[idx].versions.length > 1) {
        final latest = _files[idx].versions.last;
        _files[idx].description = latest.description;
        _files[idx].updatedAt = latest.timestamp;
      }
    }
    // 'keep_all' = do nothing, keep all versions

    _files[idx].hasConflict = false;
    _files[idx].hasPendingSync = !_isOnline;
    await _save();
  }

  // Sync simulation
  void _syncData() {
    for (var file in _files) {
      file.hasPendingSync = false;
    }
    _save();
  }

  FileItem? getFileById(String id) {
    try {
      return _files.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    await _storage.saveFiles(_files);
    notifyListeners();
  }
}
