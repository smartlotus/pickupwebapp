import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/capsule_provider.dart';
import '../utils/image_source.dart';
import '../utils/pwa_environment.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return Consumer<CapsuleProvider>(
          builder: (context, provider, child) {
            final accent = Theme.of(context).colorScheme.primary;
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    provider.t('theme'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<AppThemeStyle>(
                    value: AppThemeStyle.defaultPurple,
                    groupValue: provider.themeStyle,
                    onChanged: (value) async {
                      if (value == null) return;
                      await provider.setThemeStyle(value);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    title: Text(provider.t('theme_default'), style: const TextStyle(color: Colors.white)),
                    activeColor: accent,
                  ),
                  RadioListTile<AppThemeStyle>(
                    value: AppThemeStyle.monochrome,
                    groupValue: provider.themeStyle,
                    onChanged: (value) async {
                      if (value == null) return;
                      await provider.setThemeStyle(value);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    title: Text(provider.t('theme_mono'), style: const TextStyle(color: Colors.white)),
                    activeColor: accent,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return Consumer<CapsuleProvider>(
          builder: (context, provider, child) {
            final accent = Theme.of(context).colorScheme.primary;
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    provider.t('lang'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<AppLanguage>(
                    value: AppLanguage.zh,
                    groupValue: provider.language,
                    onChanged: (value) async {
                      if (value == null) return;
                      await provider.setLanguage(value);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    title: Text(provider.t('lang_zh'), style: const TextStyle(color: Colors.white)),
                    activeColor: accent,
                  ),
                  RadioListTile<AppLanguage>(
                    value: AppLanguage.en,
                    groupValue: provider.language,
                    onChanged: (value) async {
                      if (value == null) return;
                      await provider.setLanguage(value);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    title: Text(provider.t('lang_en'), style: const TextStyle(color: Colors.white)),
                    activeColor: accent,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openInstallGuide() async {
    final localGuide = Uri.parse('install-ios.html');
    if (await canLaunchUrl(localGuide)) {
      await launchUrl(localGuide, mode: LaunchMode.platformDefault);
      return;
    }

    final websiteGuide = Uri.parse('https://pickuplotus.netlify.app/install-ios.html');
    if (await canLaunchUrl(websiteGuide)) {
      await launchUrl(websiteGuide, mode: LaunchMode.platformDefault);
    }
  }

  void _showImportDialog(BuildContext context) {
    final provider = context.read<CapsuleProvider>();
    final importController = TextEditingController();
    var replaceExisting = false;
    var isImporting = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final accent = Theme.of(dialogContext).colorScheme.primary;
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                provider.t('import_title'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.t('import_desc'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: importController,
                      minLines: 8,
                      maxLines: 12,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: provider.t('paste_json_hint'),
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF141414),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: replaceExisting,
                      onChanged: (value) => setState(() => replaceExisting = value),
                      activeColor: accent,
                      title: Text(
                        provider.t('replace_data'),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      subtitle: Text(
                        provider.t('merge_hint'),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: isImporting
                      ? null
                      : () async {
                          final clip = await Clipboard.getData(Clipboard.kTextPlain);
                          if (clip?.text != null && clip!.text!.isNotEmpty) {
                            setState(() {
                              importController.text = clip.text!;
                              errorText = null;
                            });
                          }
                        },
                  icon: const Icon(Icons.paste, size: 16),
                  label: Text(provider.t('paste')),
                ),
                TextButton(
                  onPressed: isImporting ? null : () => Navigator.pop(dialogContext),
                  child: Text(provider.t('cancel'), style: const TextStyle(color: Colors.white54)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                  onPressed: isImporting
                      ? null
                      : () async {
                          final raw = importController.text.trim();
                          if (raw.isEmpty) {
                            setState(() => errorText = provider.t('json_empty'));
                            return;
                          }
                          setState(() {
                            isImporting = true;
                            errorText = null;
                          });
                          try {
                            final result = await provider.importDataFromJson(
                              raw,
                              replaceExisting: replaceExisting,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${provider.t('record_imported')}: '
                                    '${result['entriesImported']} + ${result['aiImported']}',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isImporting = false;
                              errorText = '${provider.t('import_failed')}: $e';
                            });
                          }
                        },
                  icon: isImporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.upload_file, size: 18),
                  label: Text(provider.t('import')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    final provider = context.read<CapsuleProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          provider.t('about_pickup'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.t('about_copy'),
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(provider.t('official_website'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final url = Uri.parse('https://pickup30.netlify.app/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Text(
                'https://pickup30.netlify.app/',
                style: TextStyle(
                  color: accent,
                  decoration: TextDecoration.underline,
                  decorationColor: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(provider.t('close'), style: const TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallBanner(BuildContext context, CapsuleProvider provider) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: accent.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_iphone, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.t('install_banner'),
              style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.35),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _openInstallGuide,
            child: Text(provider.t('guide')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CapsuleProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final showInstallBanner = shouldShowIosInstallBanner();
    final dateFormat = provider.language == AppLanguage.zh ? 'yyyy-MM-dd HH:mm' : 'MMM dd, yyyy - hh:mm a';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.t('nav_pickup'),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: Colors.white54),
            onPressed: () => _showThemeDialog(context),
            tooltip: provider.t('theme'),
          ),
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.white54),
            onPressed: () => _showLanguageDialog(context),
            tooltip: provider.t('lang'),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white54),
            onPressed: () => _showImportDialog(context),
            tooltip: provider.t('import_migrate'),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white54),
            onPressed: () async => provider.exportDataAsJson(context),
            tooltip: provider.t('export_journal'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white54),
            onPressed: () => _showAboutDialog(context),
            tooltip: provider.t('about_dev'),
          ),
        ],
      ),
      body: Consumer<CapsuleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.entries.isEmpty) {
            return Column(
              children: [
                if (showInstallBanner) _buildInstallBanner(context, provider),
                Expanded(
                  child: Center(
                    child: Text(
                      provider.t('home_empty'),
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              if (showInstallBanner) _buildInstallBanner(context, provider),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.entries.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final entry = provider.entries[index];
                    final imageProvider = imageProviderFromStoredSource(entry.imagePath);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat(dateFormat).format(entry.timestamp),
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      if (entry.songInfo != null && entry.songInfo!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.music_note, color: accent, size: 14),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                entry.songInfo!,
                                                style: TextStyle(
                                                  color: accent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white30, size: 20),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => EditorScreen(existingEntry: entry)),
                                    );
                                  },
                                  tooltip: provider.t('view_edit'),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              entry.content,
                              style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white),
                            ),
                            if (entry.comments.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF181818),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: entry.comments.map((c) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${DateFormat('MM-dd HH:mm').format(c.timestamp)}: ',
                                                style: TextStyle(
                                                  color: accent,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const TextSpan(
                                                text: '',
                                              ),
                                              TextSpan(
                                                text: c.text,
                                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            if (imageProvider != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image(
                                    image: imageProvider,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditorScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
