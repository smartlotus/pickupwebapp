import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/capsule_provider.dart';

class AiHubScreen extends StatelessWidget {
  const AiHubScreen({Key? key}) : super(key: key);

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

  void _showSettingsDialog(BuildContext context, CapsuleProvider provider) {
    final keyController = TextEditingController(text: provider.apiKey ?? '');
    final urlController = TextEditingController(text: provider.apiBaseUrl);
    final modelController = TextEditingController(text: provider.apiModelName);

    final accent = Theme.of(context).colorScheme.primary;
    final presetColor = provider.isMonochrome ? const Color(0xFF2A2A2A) : Colors.blueGrey[800];
    final actionColor = provider.isMonochrome ? const Color(0xFF2E2E2E) : Colors.teal;
    final exportColor = provider.isMonochrome ? const Color(0xFF232323) : Colors.indigo;
    final dangerColor = provider.isMonochrome ? Colors.white70 : Colors.redAccent;

    showDialog(
      context: context,
      builder: (context) {
        String? testResult;
        bool isTesting = false;
        bool obscureKey = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(
                provider.t('ai_settings'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(provider.t('model_presets'), style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: presetColor, foregroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              urlController.text = 'https://generativelanguage.googleapis.com';
                              modelController.text = 'gemini-1.5-flash';
                            });
                          },
                          child: const Text('Gemini 1.5'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: presetColor, foregroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              urlController.text = 'https://api.deepseek.com';
                              modelController.text = 'deepseek-chat';
                            });
                          },
                          child: const Text('DeepSeek'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: presetColor, foregroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              urlController.text = 'https://open.bigmodel.cn/api/paas/v4';
                              modelController.text = 'glm-4';
                            });
                          },
                          child: const Text('GLM-4'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: presetColor, foregroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              urlController.text = 'https://api.siliconflow.cn';
                              modelController.text = 'Pro/deepseek-ai/DeepSeek-V3';
                            });
                          },
                          child: const Text('SiliconFlow'),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    TextFormField(
                      controller: keyController,
                      obscureText: obscureKey,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: provider.t('api_key_required'),
                        hintText: provider.t('api_key_hint'),
                        labelStyle: provider.isMonochrome
                            ? const TextStyle(color: Colors.white70)
                            : const TextStyle(color: Colors.amberAccent),
                        hintStyle: const TextStyle(color: Colors.white24),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accent)),
                        suffixIcon: IconButton(
                          icon: Icon(obscureKey ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                          onPressed: () => setState(() => obscureKey = !obscureKey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(provider.t('advanced_network'), style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          TextFormField(
                            controller: urlController,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: provider.t('api_base_url'),
                              labelStyle: const TextStyle(color: Colors.white54),
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: modelController,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: provider.t('model_name'),
                              labelStyle: const TextStyle(color: Colors.white54),
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (testResult != null)
                      Builder(
                        builder: (context) {
                          final isSuccess = testResult!.toLowerCase().contains('successful') || testResult!.contains('成功');
                          final isPending = testResult == provider.t('testing_connection');
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isPending ? Colors.white24 : (isSuccess ? Colors.green : Colors.redAccent),
                              ),
                            ),
                            child: Text(testResult!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          );
                        },
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isTesting
                          ? null
                          : () async {
                              setState(() {
                                isTesting = true;
                                testResult = provider.t('testing_connection');
                              });
                              final res = await provider.testApiConnection(keyController.text, urlController.text, modelController.text);
                              setState(() {
                                isTesting = false;
                                testResult = res;
                              });
                            },
                      icon: isTesting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.speed, color: Colors.white, size: 20),
                      label: Text(provider.t('test_api'), style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: actionColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await provider.exportDataAsJson(context);
                      },
                      icon: const Icon(Icons.download, color: Colors.white, size: 20),
                      label: Text(provider.t('export_json'), style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: exportColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await provider.resetTutorial();
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.play_circle_outline, color: Colors.white, size: 20),
                      label: Text(provider.t('rerun_tutorial'), style: const TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 40),
                    Text(provider.t('developer_credits'), style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      provider.t('about_copy'),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(provider.t('visit_website'), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse('https://pickup30.netlify.app/');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: const Text(
                        'https://pickup30.netlify.app/',
                        style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await provider.setApiConfig('', '', '');
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(provider.t('clear'), style: TextStyle(color: dangerColor)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(provider.t('cancel'), style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black),
                  onPressed: () async {
                    await provider.setApiConfig(keyController.text, urlController.text, modelController.text);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(provider.t('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAiChatDialog(BuildContext context, CapsuleProvider provider) {
    if (provider.apiKey == null || provider.apiKey!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.t('need_api_key_first'))));
      return;
    }

    final questionController = TextEditingController();
    final accent = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) {
        bool isThinking = false;
        double progress = 0.0;
        String progressStage = provider.t('ai_progress_preparing');
        Timer? progressTimer;

        void stopProgressTimer() {
          progressTimer?.cancel();
          progressTimer = null;
        }

        void startProgressTimer(StateSetter setState) {
          stopProgressTimer();
          progress = 0.03;
          progressStage = provider.t('ai_progress_preparing');
          progressTimer = Timer.periodic(const Duration(milliseconds: 260), (timer) {
            if (!context.mounted) {
              timer.cancel();
              return;
            }
            final next = (progress + 0.04).clamp(0.0, 0.94);
            setState(() {
              progress = next;
              if (progress < 0.22) {
                progressStage = provider.t('ai_progress_preparing');
              } else if (progress < 0.52) {
                progressStage = provider.t('ai_progress_reading');
              } else if (progress < 0.82) {
                progressStage = provider.t('ai_progress_reasoning');
              } else {
                progressStage = provider.t('ai_progress_finalizing');
              }
            });
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161616),
              title: Row(
                children: [
                  Icon(Icons.psychology, color: accent),
                  const SizedBox(width: 8),
                  Text(provider.t('memory_recall_ai'), style: const TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: provider.t('question_hint'),
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  if (isThinking)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.t('ai_progress_label'),
                          style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                            backgroundColor: Colors.white12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).round()}% · $progressStage',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    stopProgressTimer();
                    Navigator.pop(context);
                  },
                  child: Text(provider.t('cancel'), style: const TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black),
                  onPressed: isThinking
                      ? null
                      : () async {
                          final text = questionController.text.trim();
                          if (text.isEmpty) return;
                          setState(() {
                            isThinking = true;
                            progress = 0.03;
                            progressStage = provider.t('ai_progress_preparing');
                          });
                          startProgressTimer(setState);
                          FocusScope.of(context).unfocus();
                          try {
                            await provider.askAiAboutMemories(text);
                            if (context.mounted) {
                              stopProgressTimer();
                              setState(() {
                                progress = 1.0;
                                progressStage = provider.t('ai_progress_done');
                              });
                              await Future.delayed(const Duration(milliseconds: 220));
                              if (context.mounted) Navigator.pop(context);
                            }
                          } finally {
                            stopProgressTimer();
                          }
                        },
                  child: Text(provider.t('send')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _performAnalysis(BuildContext context, CapsuleProvider provider) async {
    if (provider.apiKey == null || provider.apiKey!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.t('need_api_key_first'))));
      return;
    }

    final accent = Theme.of(context).colorScheme.primary;

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      barrierColor: Colors.black87,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: accent,
              onPrimary: Colors.black,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange == null) return;

    final sDate = DateTime(pickedRange.start.year, pickedRange.start.month, pickedRange.start.day);
    final eDate = DateTime(pickedRange.end.year, pickedRange.end.month, pickedRange.end.day, 23, 59, 59);
    final hasEntries = provider.entries.any((e) => e.timestamp.compareTo(sDate) >= 0 && e.timestamp.compareTo(eDate) <= 0);

    if (!hasEntries) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.t('no_memories_sector'))));
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          content: Row(
            children: [
              CircularProgressIndicator(color: accent),
              const SizedBox(width: 24),
              Expanded(child: Text(provider.t('scan_temporal'), style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      );
    }

    await provider.analyzeDateRange(pickedRange.start, pickedRange.end);
    if (context.mounted) Navigator.pop(context);
  }

  void _showCommentDialog(BuildContext context, CapsuleProvider provider, String aiEntryId) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(provider.t('add_reflection'), style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: commentController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: provider.t('reflection_hint'),
            hintStyle: const TextStyle(color: Colors.white30),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(provider.t('cancel'), style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.isNotEmpty) {
                await provider.addCommentToAiEntry(aiEntryId, commentController.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(provider.t('post')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CapsuleProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final recallColor = provider.isMonochrome ? Colors.white : Colors.lightBlueAccent;
    final analysisColor = provider.isMonochrome ? const Color(0xFFE0E0E0) : Colors.amber;
    final chipColor = provider.isMonochrome ? const Color(0xFF2A2A2A) : Colors.blueGrey[800]!;
    final dateFormat = provider.language == AppLanguage.zh ? 'yyyy-MM-dd HH:mm' : 'MMM dd, yyyy - hh:mm a';

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.t('neural_center'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
            icon: Icon(
              Icons.settings,
              color: (provider.apiKey != null && provider.apiKey!.isNotEmpty) ? accent : Colors.white54,
            ),
            onPressed: () => _showSettingsDialog(context, provider),
            tooltip: provider.t('ai_settings'),
          ),
        ],
      ),
      body: Consumer<CapsuleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.aiEntries.isEmpty) {
            return Center(
              child: Text(
                provider.t('awakening'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.aiEntries.length,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              final entry = provider.aiEntries[index];
              final isRecall = entry.type.toString().contains('recall');
              final edge = isRecall ? recallColor : analysisColor;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: edge.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(isRecall ? Icons.psychology : Icons.analytics, color: edge, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat(dateFormat).format(entry.timestamp),
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white30, size: 20),
                            onPressed: () => provider.deleteAiEntry(entry.id),
                            tooltip: provider.t('delete_ai_record'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius: BorderRadius.circular(12).copyWith(topRight: Radius.zero),
                        ),
                        child: Text(entry.question, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: edge.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12).copyWith(topLeft: Radius.zero),
                        ),
                        child: Text(entry.answer, style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 15)),
                      ),
                      const SizedBox(height: 8),
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
                                          style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showCommentDialog(context, provider, entry.id),
                          icon: const Icon(Icons.comment, size: 16, color: Colors.white54),
                          label: Text(provider.t('reflect'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CapsuleProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            top: false,
            child: Container(
              color: const Color(0xFF121212),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAiChatDialog(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: recallColor,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        icon: const Icon(Icons.psychology),
                        label: Text(provider.t('recall_memory'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _performAnalysis(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: analysisColor,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        icon: const Icon(Icons.analytics),
                        label: Text(provider.t('time_analysis'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
