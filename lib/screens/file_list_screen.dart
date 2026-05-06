import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/file_model.dart';
import '../providers/file_provider.dart';
import '../theme/app_theme.dart';
import 'file_details_screen.dart';
import 'file_upload_screen.dart';

class FileListScreen extends StatelessWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(
      builder: (context, provider, _) {
        final files = provider.personalFiles;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentPink,
                                  AppTheme.accentPurple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.folder_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Files',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${files.length} file${files.length != 1 ? 's' : ''}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildSyncIndicator(provider),
                        ],
                      ),
                      if (provider.pendingSyncFiles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildPendingSyncBanner(provider),
                      ],
                    ],
                  ),
                ),
              ),

              // Files list
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accentPink),
                  ),
                )
              else if (files.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(context),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildFileCard(context, files[index], provider);
                      },
                      childCount: files.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_file_list',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FileUploadScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add File'),
          ),
        );
      },
    );
  }

  Widget _buildSyncIndicator(FileProvider provider) {
    return GestureDetector(
      onTap: () => provider.toggleOnlineStatus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: provider.isOnline
              ? AppTheme.success.withOpacity(0.15)
              : AppTheme.warning.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: provider.isOnline
                ? AppTheme.success.withOpacity(0.4)
                : AppTheme.warning.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    provider.isOnline ? AppTheme.success : AppTheme.warning,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              provider.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color:
                    provider.isOnline ? AppTheme.success : AppTheme.warning,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingSyncBanner(FileProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_rounded, color: AppTheme.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${provider.pendingSyncFiles.length} file(s) pending sync',
              style: const TextStyle(
                  color: AppTheme.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (!provider.isOnline)
            const Text(
              'Go online to sync',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_rounded,
                size: 56, color: AppTheme.accentPink),
          ),
          const SizedBox(height: 20),
          const Text(
            'No files yet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first file',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(
      BuildContext context, FileItem file, FileProvider provider) {
    final fileColor = AppTheme.getFileColor(file.fileType);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FileDetailsScreen(fileId: file.id),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassCard,
            child: Row(
              children: [
                // File icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: fileColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppTheme.getFileIcon(file.fileType),
                    color: fileColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              file.fileName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (file.hasConflict)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'CONFLICT',
                                style: TextStyle(
                                  color: AppTheme.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (file.hasPendingSync && !file.hasConflict)
                            const Icon(Icons.sync_rounded,
                                color: AppTheme.warning, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        file.description,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildTag(
                              file.fileType.toUpperCase(), fileColor),
                          const SizedBox(width: 8),
                          _buildTag(
                            'v${file.versions.length}',
                            AppTheme.accentTeal,
                          ),
                          if (file.comments.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.comment_rounded,
                                size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 3),
                            Text(
                              '${file.comments.length}',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            DateFormat('MMM d').format(file.updatedAt),
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
