import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/file_model.dart';
import '../providers/file_provider.dart';
import '../theme/app_theme.dart';
import 'file_details_screen.dart';

class SharedFilesScreen extends StatelessWidget {
  const SharedFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(builder: (context, prov, _) {
      final shared = prov.sharedFiles;
      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.accentTeal, AppTheme.accentBlue]),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.group_rounded,
                      color: Colors.white, size: 26)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Shared Files',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                Text(
                    '${shared.length} file${shared.length != 1 ? "s" : ""} shared',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14)),
              ]),
            ]),
          )),
          if (shared.isEmpty)
            SliverFillRemaining(
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                  Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.share_rounded,
                          size: 56, color: AppTheme.accentTeal)),
                  const SizedBox(height: 20),
                  const Text('No shared files',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Open a file and tap the share button',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ])))
          else
            SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _card(context, shared[i], prov),
                        childCount: shared.length))),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ]),
      );
    });
  }

  Widget _card(BuildContext ctx, FileItem f, FileProvider prov) {
    final fc = AppTheme.getFileColor(f.fileType);
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => FileDetailsScreen(fileId: f.id))),
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCard,
              child: Row(children: [
                Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: fc.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(AppTheme.getFileIcon(f.fileType),
                        color: fc, size: 26)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(f.fileName,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(f.description,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppTheme.accentTeal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.group_rounded,
                                      size: 12, color: AppTheme.accentTeal),
                                  SizedBox(width: 4),
                                  Text('Shared',
                                      style: TextStyle(
                                          color: AppTheme.accentTeal,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600))
                                ])),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMM d').format(f.updatedAt),
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ]),
                    ])),
                IconButton(
                    icon: const Icon(Icons.person_remove_rounded,
                        color: AppTheme.textSecondary, size: 20),
                    onPressed: () async {
                      final newShared = await prov.toggleShare(f.id);
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(
                              newShared ? 'File shared!' : 'File unshared')));
                    },
                    tooltip: 'Unshare'),
              ])),
        ));
  }
}
