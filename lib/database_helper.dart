import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'faq.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE faq (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        answer TEXT
      )
    ''');

    await db.insert('faq', {
      'question': 'Как подключить новый тариф?',
      'answer':
          'Вы можете подключить новый тариф через личный кабинет, мобильное приложение или обратившись в офис продаж.'
    });
    await db.insert('faq', {
      'question': 'Как узнать остаток минут, SMS и интернета?',
      'answer':
          'Остатки можно проверить в мобильном приложении, личном кабинете или с помощью USSD-команды *100#.'
    });
    await db.insert('faq', {
      'question': 'Как восстановить утерянную SIM-карту?',
      'answer':
          'Для восстановления SIM-карты обратитесь в ближайший офис с документом, удостоверяющим личность.'
    });
    await db.insert('faq', {
      'question': 'Как отключить подписки и платные услуги?',
      'answer':
          'Отключение подписок доступно через мобильное приложение, личный кабинет или с помощью команды *505#.'
    });
    await db.insert('faq', {
      'question': 'Что делать, если связь плохо работает?',
      'answer':
          'Проверьте настройки телефона, перезагрузите устройство. Если проблема сохраняется, обратитесь в поддержку.'
    });
    await db.insert('faq', {
      'question': 'Как перейти с другого оператора со своим номером?',
      'answer':
          'Подайте заявку на перенос номера через наш офис или сайт, предоставив паспорт и SIM-карту текущего оператора.'
    });
    await db.insert('faq', {
      'question': 'Какие способы оплаты услуг доступны?',
      'answer':
          'Вы можете оплатить услуги через терминалы, банковские карты, мобильное приложение, сайт или автоплатеж.'
    });
    await db.insert('faq', {
      'question': 'Как настроить мобильный интернет?',
      'answer':
          'Настройки интернета приходят автоматически при установке SIM-карты. Если они не настроились, отправьте пустое SMS на номер 1234.'
    });
    await db.insert('faq', {
      'question': 'Как отключить роуминг?',
      'answer':
          'Роуминг отключается через мобильное приложение, личный кабинет или USSD-команду *155#.'
    });
    await db.insert('faq', {
      'question':
          'Что мне делать, если мое интернет-соединение продолжает пропадать?',
      'answer':
          'Сначала перезагрузите свой модем или маршрутизатор. Если проблема не устранена, проверьте, нет ли сбоев в работе в вашем регионе, или обратитесь в службу поддержки клиентов за дополнительной помощью.'
    });
  }
}