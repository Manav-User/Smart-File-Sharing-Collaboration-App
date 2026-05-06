import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/file_model.dart';
import '../providers/file_provider.dart';
import '../theme/app_theme.dart';
import 'file_details_screen.dart';

class SearchFilterScreen extends StatelessWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(builder: (context, prov, _) {
      final files = prov.filteredFiles;
      final types = ['All', ...prov.fileTypes];
      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.accentGold, AppTheme.accentPink]), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.search_rounded, color: Colors.white, size: 26)),
                const SizedBox(width: 14),
                const Text('Search & Filter', style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 20),
              // Search bar
              TextField(
                onChanged: prov.setSearchQuery,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search files by name...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  suffixIcon: prov.searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppTheme.textSecondary), onPressed: () => prov.setSearchQuery('')) : null,
                ),
              ),
              const SizedBox(height: 16),
              // Type filter chips
              const Text('File Type', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(height: 38, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: types.length, itemBuilder: (ctx, i) {
                final t = types[i]; final sel = prov.filterType == t;
                return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
                  onTap: () => prov.setFilterType(t),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: sel ? AppTheme.accentPink.withOpacity(0.2) : AppTheme.surfaceLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.accentPink : Colors.transparent)),
                    child: Text(t, style: TextStyle(color: sel ? AppTheme.accentPink : AppTheme.textSecondary, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                  ),
                ));
              })),
              const SizedBox(height: 12),
              // Shared/Personal filter
              const Text('Ownership', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(children: ['All', 'Personal', 'Shared'].map((s) {
                final sel = prov.filterShared == s;
                return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
                  onTap: () => prov.setFilterShared(s),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: sel ? AppTheme.accentTeal.withOpacity(0.2) : AppTheme.surfaceLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.accentTeal : Colors.transparent)),
                    child: Text(s, style: TextStyle(color: sel ? AppTheme.accentTeal : AppTheme.textSecondary, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 8),
              // Results count + clear
              Row(children: [
                Text('${files.length} result${files.length != 1 ? "s" : ""}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const Spacer(),
                if (prov.searchQuery.isNotEmpty || prov.filterType != 'All' || prov.filterShared != 'All')
                  TextButton.icon(onPressed: prov.clearFilters, icon: const Icon(Icons.clear_all, size: 18), label: const Text('Clear Filters'), style: TextButton.styleFrom(foregroundColor: AppTheme.accentPink)),
              ]),
            ]),
          )),
          if (files.isEmpty)
            SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.search_off_rounded, size: 56, color: AppTheme.textSecondary.withOpacity(0.4)),
              const SizedBox(height: 16),
              const Text('No files match your filters', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
            ])))
          else
            SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _card(context, files[i]), childCount: files.length))),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ]),
      );
    });
  }

  Widget _card(BuildContext ctx, FileItem f) {
    final fc = AppTheme.getFileColor(f.fileType);
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => FileDetailsScreen(fileId: f.id))),
      child: Container(padding: const EdgeInsets.all(16), decoration: AppTheme.glassCard, child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: fc.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(AppTheme.getFileIcon(f.fileType), color: fc, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.fileName, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: fc.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
              child: Text(f.fileType.toUpperCase(), style: TextStyle(color: fc, fontSize: 10, fontWeight: FontWeight.w600))),
            const SizedBox(width: 8),
            if (f.isShared) const Icon(Icons.group_rounded, size: 14, color: AppTheme.accentTeal),
            if (f.isShared) const SizedBox(width: 4),
            if (f.isShared) const Text('Shared', style: TextStyle(color: AppTheme.accentTeal, fontSize: 11)),
            const Spacer(),
            Text(DateFormat('MMM d').format(f.updatedAt), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ]),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
      ])),
    ));
  }
}
