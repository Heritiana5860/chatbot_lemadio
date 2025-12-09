import 'dart:convert';
import 'package:assistant_lemadio/models/faq.dart';
import 'package:assistant_lemadio/models/message.dart';
import 'package:assistant_lemadio/models/sales_center.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lemadio_formation.db');

    return await openDatabase(
      path,
      version: 3, // ✅ Incrémenter la version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des messages
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        sources TEXT,
        feedback TEXT
      )
    ''');

    // Table de l'historique
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        sources TEXT,
        timestamp TEXT NOT NULL,
        sales_center_id TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Table des questions en attente
    await db.execute('''
      CREATE TABLE pending_questions (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // ✅ Table des feedbacks avec flag de synchronisation
    await db.execute('''
      CREATE TABLE feedbacks (
        message_id TEXT PRIMARY KEY,
        feedback TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        question TEXT,
        answer TEXT,
        sales_center_id TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Table des FAQ
    await db.execute('''
      CREATE TABLE faq (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        keywords TEXT NOT NULL
      )
    ''');

    await _insertDefaultFaqs(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE history ADD COLUMN sales_center_id TEXT');
      await db.execute(
        'ALTER TABLE history ADD COLUMN synced INTEGER DEFAULT 0',
      );
    }

    if (oldVersion < 3) {
      // ✅ Ajouter les nouvelles colonnes à la table feedbacks
      try {
        await db.execute('ALTER TABLE feedbacks ADD COLUMN question TEXT');
        await db.execute('ALTER TABLE feedbacks ADD COLUMN answer TEXT');
        await db.execute(
          'ALTER TABLE feedbacks ADD COLUMN sales_center_id TEXT',
        );
        await db.execute(
          'ALTER TABLE feedbacks ADD COLUMN synced INTEGER DEFAULT 0',
        );
      } catch (e) {
        debugPrint('⚠️ Colonnes déjà existantes ou erreur: $e');
      }
    }
  }

  Future<void> _insertDefaultFaqs(Database db) async {
    final defaultFaqs = Faq.defaults;

    final batch = db.batch();
    for (final faq in defaultFaqs) {
      batch.insert('faq', {
        'question': faq.question,
        'answer': faq.answer,
        'keywords': jsonEncode(faq.keywords),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // CENTRE DE VENTE

  Future<void> saveSalesCenter(String center) async {
    final prefs = await this.prefs;
    await prefs.setString('sales_center', center);
  }

  Future<SalesCenter?> getSalesCenter() async {
    final prefs = await this.prefs;
    final centerName = prefs.getString('sales_center');

    if (centerName == null) return null;

    try {
      debugPrint('Centre de vente récupéré : $centerName');
      return SalesCenter.fromJson(jsonDecode(centerName));
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSalesCenter() async {
    final prefs = await this.prefs;
    await prefs.remove('sales_center');
  }

  // MESSAGES

  Future<void> saveMessages(List<Message> messages) async {
    final db = await database;
    await db.delete('messages');

    for (final message in messages) {
      await db.insert('messages', {
        'id': message.id,
        'content': message.content,
        'is_user': message.isUser ? 1 : 0,
        'timestamp': message.timestamp.toIso8601String(),
        'sources': jsonEncode(message.sources),
        'feedback': message.feedback,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Message>> getMessages() async {
    final db = await database;
    final maps = await db.query('messages', orderBy: 'timestamp ASC');

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'] as String,
        content: maps[i]['content'] as String,
        isUser: (maps[i]['is_user'] as int) == 1,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        sources: List<String>.from(
          jsonDecode(maps[i]['sources'] as String? ?? '[]'),
        ),
        feedback: maps[i]['feedback'] as String?,
      );
    });
  }

  // HISTORIQUE

  Future<void> saveToHistory(Message question, Message? answer) async {
    final db = await database;
    final salesCenter = await getSalesCenter();

    await db.insert('history', {
      'question': question.content,
      'answer': answer?.content ?? 'En attente...',
      'sources': jsonEncode(answer?.sources ?? []),
      'timestamp': question.timestamp.toIso8601String(),
      'sales_center_id': salesCenter,
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUnsyncedHistory() async {
    final db = await database;

    final prefs = await SharedPreferences.getInstance();
    final salesCenterName = prefs.getString('sales_center') ?? 'MOBILE_APP';

    final result = await db.query(
      'history',
      where: 'synced = ?',
      whereArgs: [0],
    );

    debugPrint(
      '📊 [STORAGE] Historique non synchronisé: ${result.length} entrées',
    );

    return result.map((row) {
      String sourcesJson;
      if (row['sources'] is String) {
        sourcesJson = row['sources'] as String;
      } else {
        sourcesJson = jsonEncode(row['sources'] ?? []);
      }

      return {
        'id': row['id'],
        'question': row['question'],
        'answer': row['answer'],
        'sources': sourcesJson,
        'timestamp': row['timestamp'],
        'sales_center_id': salesCenterName,
      };
    }).toList();
  }

  Future<void> markAsSynced(int historyId) async {
    final db = await database;
    await db.update(
      'history',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('history', orderBy: 'timestamp DESC', limit: 100);
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }

  // QUESTIONS EN ATTENTE

  Future<void> savePendingQuestion(Message question) async {
    final db = await database;
    await db.insert('pending_questions', {
      'id': question.id,
      'content': question.content,
      'timestamp': question.timestamp.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Message>> getPendingQuestions() async {
    final db = await database;
    final maps = await db.query('pending_questions', orderBy: 'timestamp ASC');

    return List.generate(maps.length, (i) {
      return Message(
        id: maps[i]['id'] as String,
        content: maps[i]['content'] as String,
        isUser: true,
        timestamp: DateTime.parse(maps[i]['timestamp'] as String),
        sources: [],
      );
    });
  }

  Future<void> removePendingQuestion(String id) async {
    final db = await database;
    await db.delete('pending_questions', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ FEEDBACKS AVEC SYNCHRONISATION

  Future<void> saveFeedback(
    String messageId,
    String feedback,
    String question,
    String answer,
  ) async {
    final db = await database;
    final salesCenter = await getSalesCenter();

    await db.insert('feedbacks', {
      'message_id': messageId,
      'feedback': feedback,
      'timestamp': DateTime.now().toIso8601String(),
      'question': question,
      'answer': answer,
      'sales_center_id': salesCenter ?? 'MOBILE_APP',
      'synced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    debugPrint('💾 Feedback sauvegardé localement: $feedback');
  }

  /// ✅ Récupérer les feedbacks non synchronisés
  Future<List<Map<String, dynamic>>> getUnsyncedFeedbacks() async {
    final db = await database;

    final result = await db.query(
      'feedbacks',
      where: 'synced = ?',
      whereArgs: [0],
    );

    debugPrint('Résultat: $result');

    debugPrint(
      '👍 [STORAGE] Feedbacks non synchronisés: ${result.length} entrées',
    );

    return result.map((row) {
      return {
        'message_id': row['message_id'],
        'feedback': row['feedback'],
        'timestamp': row['timestamp'],
        'question': row['question'],
        'answer': row['answer'],
        'sales_center_id': row['sales_center'] ?? 'MOBILE_APP',
      };
    }).toList();
  }

  /// ✅ Marquer un feedback comme synchronisé
  Future<void> markFeedbackAsSynced(String messageId) async {
    final db = await database;
    await db.update(
      'feedbacks',
      {'synced': 1},
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
  }

  Future<List<Map<String, dynamic>>> getFeedbacks() async {
    final db = await database;
    return await db.query('feedbacks');
  }

  // FAQ
  Future<String?> getFaqAnswer(String question) async {
    final db = await database;
    final questionLower = question.toLowerCase().trim();
    final faqs = await db.query('faq');

    debugPrint('');
    debugPrint('🔍 RECHERCHE FAQ');
    debugPrint('Question: "$question"');
    debugPrint('Question (lowercase): "$questionLower"');
    debugPrint('Nombre de FAQs: ${faqs.length}');
    debugPrint('───────────────────────────────────────');

    if (faqs.isEmpty) {
      debugPrint('⚠️ ERREUR: Aucune FAQ dans la base !');
      return null;
    }

    for (var i = 0; i < faqs.length; i++) {
      final faq = faqs[i];
      final faqKeywordsRaw = faq['keywords'] as String;

      // ✅ CORRECTION: Décoder le JSON au lieu de split(',')
      List<String> keywords;
      try {
        // Les keywords sont stockés en JSON: ["vente","créer","nouvelle"]
        final decoded = jsonDecode(faqKeywordsRaw);
        keywords = List<String>.from(decoded);
      } catch (e) {
        // Fallback: si ce n'est pas du JSON, utiliser split
        keywords = faqKeywordsRaw.split(',');
      }

      debugPrint('');
      debugPrint('Test FAQ #${i + 1}: ${faq['question']}');
      debugPrint('  Keywords bruts: "$faqKeywordsRaw"');
      debugPrint('  Keywords décodés: $keywords');

      // Vérifier chaque mot-clé
      for (final keyword in keywords) {
        final keywordTrimmed = keyword.toLowerCase().trim();
        final match = questionLower.contains(keywordTrimmed);

        debugPrint('    - "$keywordTrimmed" → ${match ? "✅ MATCH" : "❌"}');

        if (match) {
          debugPrint('');
          debugPrint('✅ FAQ TROUVÉE !');
          debugPrint('Question FAQ: ${faq['question']}');
          return faq['answer'] as String;
        }
      }
    }

    debugPrint('');
    debugPrint('❌ Aucune FAQ correspondante trouvée');
    return null;
  }

  // Future<void> debugFaqs() async {
  //   final db = await database;
  //   final faqs = await db.query('faq');

  //   debugPrint('═══════════════════════════════════════');
  //   debugPrint('🔍 DEBUG FAQs - Total: ${faqs.length} FAQs');
  //   debugPrint('═══════════════════════════════════════');

  //   if (faqs.isEmpty) {
  //     debugPrint('⚠️ AUCUNE FAQ TROUVÉE - La base est vide !');
  //     debugPrint('💡 Solution: Réinitialiser la base de données');
  //   } else {
  //     for (var i = 0; i < faqs.length; i++) {
  //       final faq = faqs[i];
  //       debugPrint('');
  //       debugPrint('FAQ #${i + 1}:');
  //       debugPrint('  Question: ${faq['question']}');
  //       debugPrint('  Keywords: ${faq['keywords']}');
  //       debugPrint(
  //         '  Answer (50 premiers chars): ${(faq['answer'] as String).substring(0, 50)}...',
  //       );
  //     }
  //   }

  //   debugPrint('═══════════════════════════════════════');
  // }

  Future<void> addFaq(String question, String answer, String keywords) async {
    final db = await database;
    await db.insert('faq', {
      'question': question,
      'answer': answer,
      'keywords': keywords,
    });
  }

  // PREFERENCES

  Future<void> saveApiUrl(String url) async {
    final prefs = await this.prefs;
    await prefs.setString('api_url', url);
  }

  Future<String?> getApiUrl() async {
    final prefs = await this.prefs;
    return prefs.getString('api_url');
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await this.prefs;
    await prefs.setBool('onboarding_completed', completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await this.prefs;
    return prefs.getBool('onboarding_completed') ?? false;
  }

  // NETTOYAGE

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> resetAll() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('history');
    await db.delete('pending_questions');
    await db.delete('feedbacks');

    final prefs = await this.prefs;
    await prefs.clear();
  }
}
