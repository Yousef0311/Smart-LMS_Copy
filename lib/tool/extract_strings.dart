import 'dart:io';

/// أداة بسيطة لاستخراج النصوص من ملفات دارت للترجمة
void main() async {
  // المجلد الذي تحتوي على ملفات المشروع
  final projectDir = Directory('lib');

  // التجميعة التي ستحتوي على كل النصوص المستخرجة
  final Set<String> translationKeys = {};

  // أنماط النصوص التي نريد استخراجها (تعديل حسب الحاجة)
  final RegExp textPattern = RegExp(
    r'''['"]([^'"]+)['"](?!\.tr\(\))''',
  );

  // النماذج التي نريد تجاهلها - مثل المسارات والأسماء التقنية
  final List<String> ignorePatterns = [
    'assets/',
    'http',
    '@',
    'color',
    'png',
    'jpg',
    'null',
    'true',
    'false',
    r'\d+', // الأرقام
    '#', // رموز الألوان
    'const ',
    'final ',
    '{',
    '}',
    'vsync:',
    'context',
    'import',
    'package:',
    'route',
    '\.dart',
  ];

  // البحث في كل الملفات بشكل متكرر
  await _processDirectory(
      projectDir, translationKeys, textPattern, ignorePatterns);

  // إنشاء ملف JSON بالنتائج
  final Map<String, String> translations = {};
  for (final key in translationKeys) {
    translations[key] = key; // نفس القيمة كمفتاح للإنجليزية
  }

  final jsonOutput = _formatJson(translations);

  // حفظ الملف
  File('assets/lang/en.json').writeAsStringSync(jsonOutput);

  // إنشاء ملف العربية مع فراغات للترجمة
  final Map<String, String> arTranslations = {};
  for (final key in translationKeys) {
    arTranslations[key] = ''; // قيمة فارغة للترجمة لاحقاً
  }

  final arJsonOutput = _formatJson(arTranslations);
  File('assets/lang/ar.json').writeAsStringSync(arJsonOutput);

  print('تم استخراج ${translationKeys.length} نص للترجمة.');
  print('تم إنشاء ملفات الترجمة en.json و ar.json في مجلد assets/lang');
}

/// معالجة مجلد والمجلدات الفرعية بشكل متكرر
Future<void> _processDirectory(Directory dir, Set<String> keys, RegExp pattern,
    List<String> ignorePatterns) async {
  await for (final entity in dir.list()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      _processFile(entity, keys, pattern, ignorePatterns);
    } else if (entity is Directory) {
      await _processDirectory(entity, keys, pattern, ignorePatterns);
    }
  }
}

/// استخراج النصوص من ملف
void _processFile(
    File file, Set<String> keys, RegExp pattern, List<String> ignorePatterns) {
  final content = file.readAsStringSync();

  // استخراج كل النصوص المطابقة للنمط
  final matches = pattern.allMatches(content);

  for (final match in matches) {
    final text = match.group(1);
    if (text != null && text.isNotEmpty) {
      bool shouldIgnore = false;

      // تجاهل النصوص التي تطابق أنماط التجاهل
      for (final ignorePattern in ignorePatterns) {
        if (text.contains(RegExp(ignorePattern))) {
          shouldIgnore = true;
          break;
        }
      }

      // أيضاً تجاهل النصوص القصيرة جداً
      if (text.length < 2) {
        shouldIgnore = true;
      }

      if (!shouldIgnore) {
        keys.add(text);
      }
    }
  }
}

/// تنسيق خرج JSON بشكل جميل مع ترتيب المفاتيح
String _formatJson(Map<String, String> map) {
  // ترتيب المفاتيح أبجدياً
  final sortedMap = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

  // تنسيق الإخراج
  final buffer = StringBuffer();
  buffer.writeln('{');

  int index = 0;
  sortedMap.forEach((key, value) {
    buffer
        .write('  "${_escapeJsonString(key)}": "${_escapeJsonString(value)}"');
    if (index < sortedMap.length - 1) {
      buffer.writeln(',');
    } else {
      buffer.writeln();
    }
    index++;
  });

  buffer.write('}');
  return buffer.toString();
}

/// معالجة الأحرف الخاصة في سلاسل JSON
String _escapeJsonString(String text) {
  return text
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\r')
      .replaceAll('\t', '\\t');
}
