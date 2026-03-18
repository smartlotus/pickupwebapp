import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/capsule_entry.dart';
import '../models/ai_entry.dart';

enum AppThemeStyle {
  defaultPurple,
  monochrome,
}

enum AppLanguage {
  zh,
  en,
}

class CapsuleProvider extends ChangeNotifier {
  static const String _storageKey = 'omni_capsule_entries';
  static const String _aiStorageKey = 'omni_capsule_ai_records';
  static const String _apiKeyKey = 'omni_capsule_api_key';
  static const String _apiBaseUrlKey = 'omni_capsule_base_url';
  static const String _apiModelKey = 'omni_capsule_model_name';
  static const String _themeStyleKey = 'pickup_theme_style';
  static const String _languageKey = 'pickup_app_language';
  static const String _themeMigrationKey = 'pickup_theme_migrated_v1';
  static const String _tutorialCompletedKey = 'pickup_tutorial_completed';
  static const AppLanguage _defaultStartupLanguage = AppLanguage.zh;
  
  List<CapsuleEntry> _entries = [];
  List<AiEntry> _aiEntries = [];
  bool _isLoading = true;
  bool _tutorialCompleted = false;
  
  String? _apiKey;
  String _apiBaseUrl = 'https://generativelanguage.googleapis.com';
  String _apiModelName = 'gemini-1.5-flash';
  AppThemeStyle _themeStyle = AppThemeStyle.monochrome;
  AppLanguage _language = _defaultStartupLanguage;

  List<CapsuleEntry> get entries => _entries;
  List<AiEntry> get aiEntries => _aiEntries;
  bool get isLoading => _isLoading;
  String? get apiKey => _apiKey;
  String get apiBaseUrl => _apiBaseUrl;
  String get apiModelName => _apiModelName;
  AppThemeStyle get themeStyle => _themeStyle;
  AppLanguage get language => _language;
  bool get isMonochrome => _themeStyle == AppThemeStyle.monochrome;
  bool get tutorialCompleted => _tutorialCompleted;

  CapsuleProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString(_apiKeyKey);
      _apiBaseUrl = prefs.getString(_apiBaseUrlKey) ?? 'https://generativelanguage.googleapis.com';
      _apiModelName = prefs.getString(_apiModelKey) ?? 'gemini-1.5-flash';
      final themeRaw = prefs.getString(_themeStyleKey);
      final hasThemeMigration = prefs.getBool(_themeMigrationKey) ?? false;
      if (!hasThemeMigration && themeRaw == AppThemeStyle.defaultPurple.name) {
        _themeStyle = AppThemeStyle.monochrome;
        await prefs.setString(_themeStyleKey, _themeStyle.name);
      } else {
        _themeStyle = AppThemeStyle.values.firstWhere(
          (style) => style.name == (themeRaw ?? AppThemeStyle.monochrome.name),
          orElse: () => AppThemeStyle.monochrome,
        );
      }
      if (!hasThemeMigration) {
        await prefs.setBool(_themeMigrationKey, true);
      }
      final languageRaw = prefs.getString(_languageKey) ?? _defaultStartupLanguage.name;
      _language = AppLanguage.values.firstWhere(
        (lang) => lang.name == languageRaw,
        orElse: () => _defaultStartupLanguage,
      );
      
      final String? entriesJson = prefs.getString(_storageKey);
      if (entriesJson != null) {
        final List<dynamic> decodedList = jsonDecode(entriesJson);
        _entries = decodedList
            .map((item) => CapsuleEntry.fromJson(item as Map<String, dynamic>))
            .toList();
        _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      final String? aiEntriesJson = prefs.getString(_aiStorageKey);
      if (aiEntriesJson != null) {
        final List<dynamic> decodedAi = jsonDecode(aiEntriesJson);
        _aiEntries = decodedAi
            .map((item) => AiEntry.fromJson(item as Map<String, dynamic>))
            .toList();
        _aiEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      if (prefs.containsKey(_tutorialCompletedKey)) {
        _tutorialCompleted = prefs.getBool(_tutorialCompletedKey) ?? false;
      } else {
        // Existing users with records should not be forced through onboarding.
        _tutorialCompleted = _entries.isNotEmpty || _aiEntries.isNotEmpty;
        await prefs.setBool(_tutorialCompletedKey, _tutorialCompleted);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setApiConfig(String key, String baseUrl, String modelName) async {
    _apiKey = key.trim();
    _apiBaseUrl = baseUrl.trim().isEmpty ? 'https://generativelanguage.googleapis.com' : baseUrl.trim();
    _apiModelName = modelName.trim().isEmpty ? 'gemini-1.5-flash' : modelName.trim();
    
    final prefs = await SharedPreferences.getInstance();
    if (_apiKey!.isEmpty) {
      await prefs.remove(_apiKeyKey);
      _apiKey = null;
    } else {
      await prefs.setString(_apiKeyKey, _apiKey!);
    }
    await prefs.setString(_apiBaseUrlKey, _apiBaseUrl);
    await prefs.setString(_apiModelKey, _apiModelName);
    
    notifyListeners();
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    if (_themeStyle == style) return;
    _themeStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeStyleKey, style.name);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.name);
    notifyListeners();
  }

  Future<void> completeTutorial() async {
    if (_tutorialCompleted) return;
    _tutorialCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
    notifyListeners();
  }

  Future<void> resetTutorial() async {
    _tutorialCompleted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, false);
    notifyListeners();
  }

  String t(String key) {
    final map = _language == AppLanguage.zh ? _zhTexts : _enTexts;
    return map[key] ?? _enTexts[key] ?? key;
  }

  String tf(String key, [Map<String, String> params = const {}]) {
    var value = t(key);
    params.forEach((paramKey, paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }

  static const Map<String, String> _enTexts = {
    'nav_pickup': 'Pickup',
    'nav_ai_hub': 'AI Hub',
    'theme': 'Theme',
    'theme_default': 'Purple + Black',
    'theme_mono': 'Black + White',
    'lang': 'Language',
    'lang_zh': 'Chinese',
    'lang_en': 'English',
    'capture_moment': 'Capture Moment',
    'edit_moment': 'Edit Moment',
    'attach_photo': 'Attach Photo',
    'photo_attached': 'Photo Attached',
    'track_hint': 'Attach a track to this memory...',
    'content_hint': 'What''s on your mind?',
    'reflections': 'Reflections',
    'talk_past': 'Talk to your past self...',
    'save_entry': 'Save Entry',
    'erase_memory': 'Erase Memory',
    'erase_confirm': 'This memory will be deleted permanently. Continue?',
    'cancel': 'Cancel',
    'erase': 'Erase',
    'need_text_or_image': 'Please add some text or an image before saving.',
    'home_empty': 'No memories yet. Start capturing.',
    'import_migrate': 'Import / Migrate',
    'export_journal': 'Export Journal',
    'about_dev': 'About',
    'import_title': 'Import / Migrate Data',
    'import_desc': 'Paste your export JSON and import to this device.',
    'paste_json_hint': 'Paste JSON here...',
    'replace_data': 'Replace existing local data',
    'merge_hint': 'Off = merge + deduplicate',
    'json_empty': 'JSON cannot be empty.',
    'paste': 'Paste',
    'import': 'Import',
    'import_failed': 'Import failed',
    'about_pickup': 'About Pickup',
    'official_website': 'Official Website',
    'open_ios_guide': 'Open iOS Install Guide',
    'about_copy': '© 2026 Pickup App. Developed by 渚有潜.',
    'about_author': '',
    'close': 'Close',
    'install_banner': 'Install Pickup to your iPhone home screen for full-screen experience.',
    'guide': 'Guide',
    'view_edit': 'View & Edit Entry',
    'ai_settings': 'AI Hub Settings',
    'model_presets': 'Model Presets',
    'api_key_required': 'API Key (Required)',
    'api_key_hint': 'Enter API key...',
    'advanced_network': 'Advanced Network',
    'api_base_url': 'API Base URL',
    'model_name': 'Model Name',
    'test_api': 'Test API',
    'export_json': 'Export JSON',
    'developer_credits': 'Developer & Credits',
    'visit_website': 'Visit Website',
    'clear': 'Clear',
    'save': 'Save',
    'memory_recall_ai': 'Memory Recall AI',
    'question_hint': 'e.g. What did I do today?',
    'send': 'Send',
    'add_reflection': 'Add Reflection',
    'reflection_hint': 'Your thoughts on this result...',
    'post': 'Post',
    'neural_center': 'Neural Center',
    'recall_memory': 'Recall Memory',
    'time_analysis': 'Time Analysis',
    'awakening': 'Ask or analyze to wake your AI memory partner.',
    'reflect': 'Reflect',
    'delete_ai_record': 'Delete AI Record',
    'scan_temporal': 'Scanning date range...',
    'need_api_key_first': 'Please configure API Key first.',
    'no_memories_sector': 'No memories found in this range.',
    'record_imported': 'Import complete',
    'testing_connection': 'Testing connection...',
    'export_empty': 'No records to export.',
    'export_copied': 'Share unavailable. JSON copied to clipboard.',
    'export_failed': 'Failed to export data.',
    'ai_offline_key': 'AI is unavailable. Check API Key in settings.',
    'ai_offline_network': 'AI unavailable. Check your network or API settings.',
    'ai_no_records': 'No memory records found in this range.',
    'ai_no_memories_yet': 'No memories yet for recall.',
    'ai_analysis_empty': 'Analysis completed, but no output was returned.',
    'ai_analysis_bad_format': 'Analysis returned, but format was unrecognized.',
    'ai_http_error': 'AI service error: {code}. Check base URL and token.',
    'ai_api_error': 'API error: {code}.',
    'ai_connection_failed': 'Connection failed. Please try again.',
    'api_key_empty': 'API Key cannot be empty.',
    'api_ok': 'Connection successful! AI says: {text}',
    'api_ok_target': 'Connection successful!',
    'api_fail': 'Connection failed: {code}\nDetails: {detail}',
    'api_error': 'Connection error: {error}',
    'settings': 'Settings',
    'rerun_tutorial': 'Run Tutorial Again',
    'tutorial_skip': 'Skip',
    'tutorial_next': 'Next',
    'tutorial_start': 'Start',
    'tutorial_step1_title': 'Welcome to Pickup',
    'tutorial_step1_desc': 'Capture text, photos, and moments in one place.',
    'tutorial_step2_title': 'Capture Fast',
    'tutorial_step2_desc': 'Tap + to add a memory with image and music.',
    'tutorial_step3_title': 'AI Hub',
    'tutorial_step3_desc': 'Recall your memories and analyze your day.',
    'tutorial_step4_title': 'Settings & Data',
    'tutorial_step4_desc': 'Theme, language, import, and export are here.',
    'ai_progress_label': 'AI Analysis Progress',
    'ai_progress_preparing': 'Preparing request',
    'ai_progress_reading': 'Reading memories',
    'ai_progress_reasoning': 'Analyzing',
    'ai_progress_finalizing': 'Finalizing answer',
    'ai_progress_done': 'Done',
  };
  static const Map<String, String> _zhTexts = {
    'nav_pickup': 'Pickup',
    'nav_ai_hub': 'AI Hub',
    'theme': '配色',
    'theme_default': '默认（紫黑）',
    'theme_mono': '黑白',
    'lang': '语言',
    'lang_zh': '中文',
    'lang_en': '英文',
    'capture_moment': '记录此刻',
    'edit_moment': '编辑记录',
    'attach_photo': '添加图片',
    'photo_attached': '已添加图片',
    'track_hint': '给这条记录加一首歌...',
    'content_hint': '这一刻你在想什么？',
    'reflections': '回看',
    'talk_past': '和过去的自己说句话...',
    'save_entry': '保存记录',
    'erase_memory': '删除记录',
    'erase_confirm': '这条记录将永久删除，确定继续？',
    'cancel': '取消',
    'erase': '删除',
    'need_text_or_image': '请先输入文字或添加图片。',
    'home_empty': '还没有记录，开始写第一条吧。',
    'import_migrate': '导入/迁移',
    'export_journal': '导出',
    'about_dev': '关于',
    'import_title': '导入/迁移数据',
    'import_desc': '粘贴导出的 JSON 并导入到本机。',
    'paste_json_hint': '在此粘贴 JSON...',
    'replace_data': '覆盖本地现有数据',
    'merge_hint': '关闭=合并并去重',
    'json_empty': 'JSON 不能为空。',
    'paste': '粘贴',
    'import': '导入',
    'import_failed': '导入失败',
    'about_pickup': '关于 Pickup',
    'official_website': '官网',
    'open_ios_guide': '打开 iOS 安装指南',
    'about_copy': '© 2026 Pickup App. Developed by 渚有潜.',
    'about_author': '',
    'close': '关闭',
    'install_banner': '添加到 iPhone 主屏后可全屏使用。',
    'guide': '指南',
    'view_edit': '查看/编辑',
    'ai_settings': 'AI 设置',
    'model_presets': '模型预设',
    'api_key_required': 'API Key（必填）',
    'api_key_hint': '请输入 API Key...',
    'advanced_network': '高级网络',
    'api_base_url': '接口地址',
    'model_name': '模型名',
    'test_api': '连通性测试',
    'export_json': '导出 JSON',
    'developer_credits': '开发者信息',
    'visit_website': '访问官网',
    'clear': '清空',
    'save': '保存',
    'memory_recall_ai': '记忆召回',
    'question_hint': '例如：我今天做了什么？',
    'send': '发送',
    'add_reflection': '添加感想',
    'reflection_hint': '写下你对结果的看法...',
    'post': '发布',
    'neural_center': 'Neural Center',
    'recall_memory': '召回记忆',
    'time_analysis': '时段分析',
    'awakening': '通过提问或时段分析，唤醒你的 AI 记忆助手。',
    'reflect': '回看',
    'delete_ai_record': '删除 AI 记录',
    'scan_temporal': '正在分析时段数据...',
    'need_api_key_first': '请先在设置里填写 API Key。',
    'no_memories_sector': '该时间段没有记录。',
    'record_imported': '导入完成',
    'testing_connection': '正在测试连接...',
    'export_empty': '没有可导出的记录。',
    'export_copied': '无法分享，已复制 JSON 到剪贴板。',
    'export_failed': '导出失败。',
    'ai_offline_key': 'AI 不可用，请先检查设置中的 API Key。',
    'ai_offline_network': 'AI 不可用，请检查网络或接口设置。',
    'ai_no_records': '该时段没有记录。',
    'ai_no_memories_yet': '你还没有可召回的记录。',
    'ai_analysis_empty': '分析完成，但没有返回内容。',
    'ai_analysis_bad_format': '收到分析结果，但格式无法识别。',
    'ai_http_error': 'AI 服务错误：{code}。请检查接口地址和 Token。',
    'ai_api_error': '接口错误：{code}。',
    'ai_connection_failed': '连接失败，请稍后重试。',
    'api_key_empty': 'API Key 不能为空。',
    'api_ok': '连接成功！AI 返回：{text}',
    'api_ok_target': '连接成功！',
    'api_fail': '连接失败：状态码 {code}\n详情：{detail}',
    'api_error': '连接异常：{error}',
    'settings': '设置',
    'rerun_tutorial': '重新运行新手教程',
    'tutorial_skip': '跳过',
    'tutorial_next': '下一步',
    'tutorial_start': '开始使用',
    'tutorial_step1_title': '欢迎使用 Pickup',
    'tutorial_step1_desc': '在这里记录文字、图片与当下时刻。',
    'tutorial_step2_title': '快速记录',
    'tutorial_step2_desc': '点击 +，即可添加图文与音乐记录。',
    'tutorial_step3_title': 'AI Hub',
    'tutorial_step3_desc': '召回记忆，分析你的每日状态。',
    'tutorial_step4_title': '设置与数据',
    'tutorial_step4_desc': '可在这里切换主题、语言和导入导出。',
    'ai_progress_label': 'AI 分析进度',
    'ai_progress_preparing': '准备请求',
    'ai_progress_reading': '读取记忆',
    'ai_progress_reasoning': '分析内容',
    'ai_progress_finalizing': '整理答案',
    'ai_progress_done': '完成',
  };
  Future<String> analyzeDateRange(DateTime start, DateTime end) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return t('ai_offline_key');
    }

    final sDate = DateTime(start.year, start.month, start.day);
    final eDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final filtered = _entries.where((e) {
      return e.timestamp.compareTo(sDate) >= 0 && e.timestamp.compareTo(eDate) <= 0;
    }).toList();

    if (filtered.isEmpty) {
      return t('ai_no_records');
    }

    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final sb = StringBuffer();
    for (var e in filtered) {
      final dateStr = DateFormat('MMM dd, yyyy').format(e.timestamp);
      sb.writeln("Date: $dateStr");
      if (e.songInfo != null && e.songInfo!.isNotEmpty) {
        sb.writeln("Listening to: ${e.songInfo}");
      }
      sb.writeln("Content: ${e.content}");
      if (e.comments.isNotEmpty) {
        sb.writeln("Self-Reflections:");
        for (var c in e.comments) {
          final cTime = DateFormat('yyyy-MM-dd HH:mm').format(c.timestamp);
          sb.writeln("  - [$cTime]: ${c.text}");
        }
      }
      sb.writeln("");
    }

    final startDateStr = DateFormat('MMM dd, yyyy').format(start);
    final endDateStr = DateFormat('MMM dd, yyyy').format(end);
    final analysisQuestion = '${t('time_analysis')}: $startDateStr - $endDateStr';
    final prompt = "You are an empathetic psychological time-travel assistant. Here are my diary entries and later self-reflections from $startDateStr to $endDateStr. Please provide a comprehensive, beautifully written summary of my overall mood, recurring themes, and warm concluding advice based on both my original entries and my later thoughts.\n\nEntries:\n${sb.toString()}";

    try {
      // Unified API Adapter logic
      if (_apiBaseUrl.contains('generativelanguage.googleapis.com') && _apiModelName.contains('gemini')) {
        // Native Gemini SDK
        final model = GenerativeModel(
          model: _apiModelName,
          apiKey: _apiKey!,
        );
        final response = await model.generateContent([Content.text(prompt)]);
        final resText = response.text?.trim() ?? t('ai_analysis_empty');
        _addAiEntry(AiEntry(id: const Uuid().v4(), question: analysisQuestion, answer: resText, type: AiEntryType.summary, timestamp: DateTime.now()));
        return resText;
      } else {
        // OpenAI-Compatible Format Adapter
        // Automatically append /v1/chat/completions if missing and not explicitly configured
        String urlStr = _apiBaseUrl;
        if (!urlStr.endsWith('/chat/completions') && !urlStr.endsWith('/v1')) {
          urlStr = urlStr.endsWith('/') ? '${urlStr}v1/chat/completions' : '$urlStr/v1/chat/completions';
        } else if (urlStr.endsWith('/v1')) {
          urlStr = '$urlStr/chat/completions';
        }

        final response = await http.post(
          Uri.parse(urlStr),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            "model": _apiModelName,
            "messages": [
              {"role": "user", "content": prompt}
            ],
          }),
        );

        if (response.statusCode == 200) {
          final jsonResp = jsonDecode(utf8.decode(response.bodyBytes));
          final resText = jsonResp['choices']?[0]?['message']?['content']?.trim() ?? t('ai_analysis_bad_format');
          _addAiEntry(AiEntry(id: const Uuid().v4(), question: analysisQuestion, answer: resText, type: AiEntryType.summary, timestamp: DateTime.now()));
          return resText;
        } else {
          debugPrint('HTTP Error: ${response.statusCode} - ${response.body}');
          return tf('ai_http_error', {'code': response.statusCode.toString()});
        }
      }
    } catch (e) {
      debugPrint('AI generation error: $e');
      return t('ai_offline_network');
    }
  }

  Future<String> askAiAboutMemories(String question) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return t('ai_offline_key');
    }

    if (_entries.isEmpty) {
      return t('ai_no_memories_yet');
    }

    // Prepare context using recent/relevant entries (up to 50 for token limits context)
    final contextEntries = _entries.take(50).toList();
    contextEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final sb = StringBuffer();
    for (var e in contextEntries) {
      final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(e.timestamp);
      sb.writeln("[$dateStr]: ${e.content}");
      if (e.songInfo != null && e.songInfo!.isNotEmpty) {
        sb.writeln(" (Listening to: ${e.songInfo})");
      }
    }

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final prompt = "Today is $todayStr. You are my memory assistant. Based on my diary context below, please answer my question accurately and conversationally. Do not make up information that is not in the diary.\n\nMy Question: $question\n\nDiary Context:\n${sb.toString()}";

    try {
      if (_apiBaseUrl.contains('generativelanguage.googleapis.com') && _apiModelName.contains('gemini')) {
        final model = GenerativeModel(model: _apiModelName, apiKey: _apiKey!);
        final response = await model.generateContent([Content.text(prompt)]);
        final resText = response.text?.trim() ?? t('ai_analysis_empty');
        _addAiEntry(AiEntry(id: const Uuid().v4(), question: question, answer: resText, type: AiEntryType.recall, timestamp: DateTime.now()));
        return resText;
      } else {
        String urlStr = _apiBaseUrl;
        if (!urlStr.endsWith('/chat/completions') && !urlStr.endsWith('/v1')) {
          urlStr = urlStr.endsWith('/') ? '${urlStr}v1/chat/completions' : '$urlStr/v1/chat/completions';
        } else if (urlStr.endsWith('/v1')) {
          urlStr = '$urlStr/chat/completions';
        }

        final response = await http.post(
          Uri.parse(urlStr),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            "model": _apiModelName,
            "messages": [
              {"role": "user", "content": prompt}
            ],
          }),
        );

        if (response.statusCode == 200) {
          final jsonResp = jsonDecode(utf8.decode(response.bodyBytes));
          final resText = jsonResp['choices']?[0]?['message']?['content']?.trim() ?? t('ai_analysis_bad_format');
          _addAiEntry(AiEntry(id: const Uuid().v4(), question: question, answer: resText, type: AiEntryType.recall, timestamp: DateTime.now()));
          return resText;
        } else {
          return tf('ai_api_error', {'code': response.statusCode.toString()});
        }
      }
    } catch (e) {
      debugPrint('AI Chat Error: $e');
      return t('ai_connection_failed');
    }
  }

  Future<String> testApiConnection(String testKey, String testUrl, String testModel) async {
    if (testKey.trim().isEmpty) return t('api_key_empty');
    
    try {
      final prompt = "Hello! Please reply ONLY with the text: OK";
      if (testUrl.contains('generativelanguage.googleapis.com') && testModel.contains('gemini')) {
        final model = GenerativeModel(model: testModel, apiKey: testKey.trim());
        final response = await model.generateContent([Content.text(prompt)]);
        return tf('api_ok', {'text': response.text?.trim() ?? 'OK'});
      } else {
        String urlStr = testUrl.trim();
        if (!urlStr.endsWith('/chat/completions') && !urlStr.endsWith('/v1')) {
          urlStr = urlStr.endsWith('/') ? '${urlStr}v1/chat/completions' : '$urlStr/v1/chat/completions';
        } else if (urlStr.endsWith('/v1')) {
          urlStr = '$urlStr/chat/completions';
        }

        final response = await http.post(
          Uri.parse(urlStr),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${testKey.trim()}',
          },
          body: jsonEncode({
            "model": testModel.trim(),
            "messages": [
              {"role": "user", "content": prompt}
            ],
            "max_tokens": 10,
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          return t('api_ok_target');
        } else {
          return tf('api_fail', {
            'code': response.statusCode.toString(),
            'detail': response.body,
          });
        }
      }
    } catch (e) {
      return tf('api_error', {'error': e.toString()});
    }
  }

  Future<void> addEntry(CapsuleEntry entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _saveEntries();
  }
  
  Future<void> updateEntry(String id, String newContent, String? newImagePath, String? newSongInfo) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = CapsuleEntry(
        id: id,
        content: newContent,
        imagePath: newImagePath,
        songInfo: newSongInfo,
        timestamp: _entries[index].timestamp,
        comments: _entries[index].comments,
      );
      notifyListeners();
      await _saveEntries();
    }
  }

  Future<void> addCommentToEntry(String id, String commentText) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      final updatedComments = List<Comment>.from(_entries[index].comments);
      updatedComments.add(Comment(text: commentText, timestamp: DateTime.now()));
      
      _entries[index] = CapsuleEntry(
        id: id,
        content: _entries[index].content,
        imagePath: _entries[index].imagePath,
        songInfo: _entries[index].songInfo,
        timestamp: _entries[index].timestamp,
        comments: updatedComments,
      );
      notifyListeners();
      await _saveEntries();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await _saveEntries();
  }

  void _addAiEntry(AiEntry entry) {
    _aiEntries.insert(0, entry);
    notifyListeners();
    _saveAiEntries();
  }

  Future<void> addCommentToAiEntry(String id, String commentText) async {
    final index = _aiEntries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updatedComments = List<Comment>.from(_aiEntries[index].comments);
      updatedComments.add(Comment(text: commentText, timestamp: DateTime.now()));
      
      _aiEntries[index] = AiEntry(
        id: id,
        question: _aiEntries[index].question,
        answer: _aiEntries[index].answer,
        type: _aiEntries[index].type,
        timestamp: _aiEntries[index].timestamp,
        comments: updatedComments,
      );
      notifyListeners();
      await _saveAiEntries();
    }
  }

  Future<void> deleteAiEntry(String id) async {
    _aiEntries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await _saveAiEntries();
  }

  Future<void> exportDataAsJson(BuildContext context) async {
    if (_entries.isEmpty && _aiEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('export_empty'))),
      );
      return;
    }

    String? jsonString;
    try {
      final exportPayload = {
        'exportedAt': DateTime.now().toIso8601String(),
        'entries': _entries.map((entry) => entry.toJson()).toList(),
        'aiEntries': _aiEntries.map((entry) => entry.toJson()).toList(),
      };

      jsonString = const JsonEncoder.withIndent('  ').convert(exportPayload);
      await Share.share(jsonString, subject: 'Pickup Archive JSON');
    } catch (e) {
      debugPrint('Export Error: $e');
      if (context.mounted) {
        if (jsonString != null) {
          await Clipboard.setData(ClipboardData(text: jsonString));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('export_copied'))),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('export_failed'))),
          );
        }
      }
    }
  }

  Future<Map<String, int>> importDataFromJson(
    String rawJson, {
    bool replaceExisting = false,
  }) async {
    final parsed = jsonDecode(rawJson);

    List<dynamic> rawEntries = const [];
    List<dynamic> rawAiEntries = const [];

    if (parsed is List) {
      // Legacy export format: only diary entries list.
      rawEntries = parsed;
    } else if (parsed is Map<String, dynamic>) {
      final maybeEntries = parsed['entries'];
      final maybeAiEntries = parsed['aiEntries'];
      if (maybeEntries is List) {
        rawEntries = maybeEntries;
      }
      if (maybeAiEntries is List) {
        rawAiEntries = maybeAiEntries;
      }
    } else {
      throw const FormatException('Unsupported JSON format.');
    }

    final importedEntries = <CapsuleEntry>[];
    final importedAiEntries = <AiEntry>[];

    for (final item in rawEntries) {
      try {
        if (item is Map<String, dynamic>) {
          importedEntries.add(CapsuleEntry.fromJson(item));
        } else if (item is Map) {
          importedEntries.add(CapsuleEntry.fromJson(Map<String, dynamic>.from(item)));
        }
      } catch (_) {
        // Skip malformed entry items.
      }
    }

    for (final item in rawAiEntries) {
      try {
        if (item is Map<String, dynamic>) {
          importedAiEntries.add(AiEntry.fromJson(item));
        } else if (item is Map) {
          importedAiEntries.add(AiEntry.fromJson(Map<String, dynamic>.from(item)));
        }
      } catch (_) {
        // Skip malformed AI items.
      }
    }

    int entriesImported = 0;
    int entriesSkipped = 0;
    int aiImported = 0;
    int aiSkipped = 0;

    if (replaceExisting) {
      _entries = importedEntries;
      _aiEntries = importedAiEntries;
      entriesImported = importedEntries.length;
      aiImported = importedAiEntries.length;
    } else {
      final existingEntryFingerprints = _entries.map(_entryFingerprint).toSet();
      for (final entry in importedEntries) {
        final fp = _entryFingerprint(entry);
        if (existingEntryFingerprints.contains(fp)) {
          entriesSkipped += 1;
          continue;
        }
        existingEntryFingerprints.add(fp);
        _entries.add(entry);
        entriesImported += 1;
      }

      final existingAiFingerprints = _aiEntries.map(_aiFingerprint).toSet();
      for (final entry in importedAiEntries) {
        final fp = _aiFingerprint(entry);
        if (existingAiFingerprints.contains(fp)) {
          aiSkipped += 1;
          continue;
        }
        existingAiFingerprints.add(fp);
        _aiEntries.add(entry);
        aiImported += 1;
      }
    }

    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _aiEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    await _saveEntries();
    await _saveAiEntries();
    notifyListeners();

    return {
      'entriesImported': entriesImported,
      'entriesSkipped': entriesSkipped,
      'aiImported': aiImported,
      'aiSkipped': aiSkipped,
    };
  }

  String _entryFingerprint(CapsuleEntry entry) {
    return '${entry.id}|${entry.timestamp.toIso8601String()}|${entry.content}';
  }

  String _aiFingerprint(AiEntry entry) {
    return '${entry.id}|${entry.timestamp.toIso8601String()}|${entry.question}|${entry.answer}';
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = 
          _entries.map((entry) => entry.toJson()).toList();
      final String encodedList = jsonEncode(jsonList);
      await prefs.setString(_storageKey, encodedList);
    } catch (e) {
      debugPrint('Error saving entries: $e');
    }
  }

  Future<void> _saveAiEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = 
          _aiEntries.map((e) => e.toJson()).toList();
      await prefs.setString(_aiStorageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving AI entries: $e');
    }
  }
}

