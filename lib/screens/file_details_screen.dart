import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/file_provider.dart';
import '../theme/app_theme.dart';

class FileDetailsScreen extends StatefulWidget {
  final String fileId;
  const FileDetailsScreen({super.key, required this.fileId});
  @override
  State<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends State<FileDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _commentCtrl = TextEditingController();
  final _updateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _commentCtrl.dispose();
    _updateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(builder: (context, prov, _) {
      final file = prov.getFileById(widget.fileId);
      if (file == null) {
        return Scaffold(
            appBar: AppBar(),
            body: const Center(
                child: Text('File not found',
                    style: TextStyle(color: AppTheme.textPrimary))));
      }
      final fc = AppTheme.getFileColor(file.fileType);
      return Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              expandedHeight: 190,
              pinned: true,
              backgroundColor: AppTheme.primaryDark,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [fc.withOpacity(0.3), AppTheme.primaryDark],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: SafeArea(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                          color: fc.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: Icon(
                                          AppTheme.getFileIcon(file.fileType),
                                          color: fc,
                                          size: 28)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(file.fileName,
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700),
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${file.fileType} • v${file.versions.length} • ${file.isShared ? "Shared" : "Personal"}',
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13)),
                                      ])),
                                ]),
                                const SizedBox(height: 10),
                                Text(file.description,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14,
                                        height: 1.4),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ]))),
                ),
              ),
              actions: [
                IconButton(
                    icon: Icon(
                        file.isShared
                            ? Icons.group_rounded
                            : Icons.person_rounded,
                        color: file.isShared
                            ? AppTheme.accentTeal
                            : AppTheme.textSecondary),
                    onPressed: () async {
                      final newShared = await prov.toggleShare(file.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              newShared ? 'File shared!' : 'File unshared')));
                    }),
                IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.error),
                    onPressed: () => _confirmDelete(context, prov)),
              ],
            ),
            if (file.hasConflict)
              SliverToBoxAdapter(child: _conflictBanner(file, prov)),
            SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _TabBarDel(TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppTheme.accentPink,
                  indicatorWeight: 3,
                  labelColor: AppTheme.accentPink,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: [
                    const Tab(
                        icon: Icon(Icons.info_outline_rounded, size: 20),
                        text: 'Details'),
                    Tab(
                        icon: const Icon(Icons.history_rounded, size: 20),
                        text: 'Versions (${file.versions.length})'),
                    Tab(
                        icon: const Icon(Icons.comment_outlined, size: 20),
                        text: 'Comments (${file.comments.length})')
                  ],
                ))),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _detailsTab(file, prov),
              _versionsTab(file),
              _commentsTab(file, prov)
            ],
          ),
        ),
      );
    });
  }

  Widget _conflictBanner(file, FileProvider prov) => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.error.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
            SizedBox(width: 8),
            Text('Conflict Detected',
                style: TextStyle(
                    color: AppTheme.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w700))
          ]),
          const SizedBox(height: 6),
          const Text('This file was updated multiple times offline.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => prov.resolveConflict(file.id, 'latest'),
                    icon: const Icon(Icons.update_rounded, size: 18),
                    label: const Text('Use Latest'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentTeal,
                        side: const BorderSide(color: AppTheme.accentTeal)))),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => prov.resolveConflict(file.id, 'keep_all'),
                    icon: const Icon(Icons.layers_rounded, size: 18),
                    label: const Text('Keep All'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentGold,
                        side: const BorderSide(color: AppTheme.accentGold)))),
          ]),
        ]),
      );

  Widget _detailsTab(file, FileProvider prov) {
    Widget row(IconData ic, String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.glassCard,
            child: Row(children: [
              Icon(ic, color: AppTheme.accentTeal, size: 22),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(v,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500))
              ]),
            ])));
    return ListView(padding: const EdgeInsets.all(20), children: [
      row(Icons.drive_file_rename_outline, 'File Name', file.fileName),
      row(Icons.category_rounded, 'Type', file.fileType),
      row(Icons.description_outlined, 'Description', file.description),
      row(Icons.calendar_today_rounded, 'Created',
          DateFormat('MMM d, yyyy – h:mm a').format(file.createdAt)),
      row(Icons.update_rounded, 'Last Updated',
          DateFormat('MMM d, yyyy – h:mm a').format(file.updatedAt)),
      row(Icons.layers_rounded, 'Versions', '${file.versions.length}'),
      row(file.isShared ? Icons.group_rounded : Icons.person_rounded, 'Status',
          file.isShared ? 'Shared' : 'Personal'),
      row(Icons.sync_rounded, 'Sync Status',
          file.hasPendingSync ? 'Pending' : 'Synced'),
      const SizedBox(height: 16),
      SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
              onPressed: () => _showUpdateDlg(prov, file),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Update File (New Version)'))),
    ]);
  }

  Widget _versionsTab(file) {
    final versions = List.from(file.versions.reversed);
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: versions.length,
        itemBuilder: (ctx, i) {
          final v = versions[i];
          final latest = i == 0;
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: latest
                              ? AppTheme.accentPink
                              : AppTheme.surfaceLight,
                          border: latest
                              ? null
                              : Border.all(
                                  color:
                                      AppTheme.textSecondary.withOpacity(0.3))),
                      child: Center(
                          child: Text('v${v.versionNumber}',
                              style: TextStyle(
                                  color: latest
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)))),
                  if (i < versions.length - 1)
                    Container(
                        width: 2, height: 50, color: AppTheme.surfaceLight),
                ]),
                const SizedBox(width: 14),
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: AppTheme.glassCard,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text('Version ${v.versionNumber}',
                                    style: TextStyle(
                                        color: latest
                                            ? AppTheme.accentPink
                                            : AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                                if (latest) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: AppTheme.accentPink
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Text('LATEST',
                                          style: TextStyle(
                                              color: AppTheme.accentPink,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)))
                                ],
                              ]),
                              const SizedBox(height: 6),
                              Text(v.description,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(
                                  DateFormat('MMM d, yyyy – h:mm a')
                                      .format(v.timestamp),
                                  style: TextStyle(
                                      color: AppTheme.textSecondary
                                          .withOpacity(0.7),
                                      fontSize: 12)),
                            ]))),
              ]));
        });
  }

  Widget _commentsTab(file, FileProvider prov) {
    return Column(children: [
      Expanded(
          child: file.comments.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: AppTheme.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('No comments yet',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text('Start the conversation!',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                    ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: file.comments.length,
                  itemBuilder: (ctx, i) {
                    final c = file.comments[i];
                    return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: AppTheme.glassCard,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        AppTheme.accentPurple.withOpacity(0.3),
                                    child: Text(c.author[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: AppTheme.accentTeal,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700))),
                                const SizedBox(width: 10),
                                Text(c.author,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(
                                    DateFormat('MMM d, h:mm a')
                                        .format(c.timestamp),
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                                const SizedBox(width: 4),
                                GestureDetector(
                                    onTap: () =>
                                        prov.deleteComment(file.id, c.id),
                                    child: const Icon(Icons.close_rounded,
                                        size: 16,
                                        color: AppTheme.textSecondary)),
                              ]),
                              const SizedBox(height: 8),
                              Text(c.text,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      height: 1.4)),
                            ]));
                  })),
      Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: const BoxDecoration(
              color: AppTheme.secondaryDark,
              border: Border(top: BorderSide(color: AppTheme.surfaceLight))),
          child: SafeArea(
              child: Row(children: [
            const CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accentPurple,
                child: Icon(Icons.person, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Expanded(
                child: TextField(
                    controller: _commentCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        filled: true,
                        fillColor: AppTheme.surfaceLight,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none)))),
            const SizedBox(width: 8),
            Container(
                decoration: const BoxDecoration(
                    color: AppTheme.accentPink, shape: BoxShape.circle),
                child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () async {
                      if (_commentCtrl.text.trim().isEmpty) return;
                      final err = await prov.addComment(
                          fileId: file.id, text: _commentCtrl.text);
                      if (err == null)
                        _commentCtrl.clear();
                      else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err)));
                      }
                    })),
          ]))),
    ]);
  }

  void _showUpdateDlg(FileProvider prov, file) {
    _updateCtrl.clear();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.cardBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Update File',
                  style: TextStyle(color: AppTheme.textPrimary)),
              content: TextField(
                  controller: _updateCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Enter updated description...')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppTheme.textSecondary))),
                ElevatedButton(
                    onPressed: () async {
                      if (_updateCtrl.text.trim().isEmpty) return;
                      final err = await prov.updateFile(
                          fileId: file.id, description: _updateCtrl.text);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (err != null)
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err)));
                      else
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'File updated – new version created!')));
                    },
                    child: const Text('Update')),
              ],
            ));
  }

  void _confirmDelete(BuildContext context, FileProvider prov) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.cardBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Delete File',
                  style: TextStyle(color: AppTheme.textPrimary)),
              content: const Text('Are you sure? This cannot be undone.',
                  style: TextStyle(color: AppTheme.textSecondary)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppTheme.textSecondary))),
                ElevatedButton(
                    onPressed: () {
                      prov.deleteFile(widget.fileId);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error),
                    child: const Text('Delete')),
              ],
            ));
  }
}

class _TabBarDel extends SliverPersistentHeaderDelegate {
  final TabBar tab;
  _TabBarDel(this.tab);

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.primaryDark,
      child: tab,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDel old) => old.tab != tab;
}
