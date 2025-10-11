import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),
      home: const MyHomePage(title: 'CopyPasste'),
    );
  }
}

var uuid = Uuid();

class titleBodyPair {
  final String id;
  String title;
  String body;

  // Yeni nesne oluşturmak için ana constructor
  titleBodyPair(this.title, this.body) : id = uuid.v4();

  // JSON'dan nesne oluşturmak için 'factory constructor'
  factory titleBodyPair.fromJson(Map<String, dynamic> json) {
    return titleBodyPair._internal(json['id'], json['title'], json['body']);
  }

  // Sadece dahili kullanım için özel bir constructor
  titleBodyPair._internal(this.id, this.title, this.body);

  // Nesneyi JSON'a çevirmek için metot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
    };
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<titleBodyPair> _items = <titleBodyPair>[];
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  void _AddNew() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add a password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _titleController.clear();
                _bodyController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String body = _bodyController.text;
                setState(() {
                  // Düzeltme: Artık ID otomatik oluşuyor, index'e gerek yok.
                  _items.add(titleBodyPair(title, body));
                });
                Navigator.of(dialogContext).pop();
                _titleController.clear();
                _bodyController.clear();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // --- DÜZELTME: _EditOld metodunu ID alacak şekilde güncelledim ---
  void _EditOld(String id) {
    // ID'ye göre güncellenecek öğeyi bul
    final itemToEdit = _items.firstWhere((item) => item.id == id);

    _titleController.text = itemToEdit.title;
    _bodyController.text = itemToEdit.body;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _titleController.clear();
                _bodyController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Değişiklikleri kaydet
                setState(() {
                  itemToEdit.title = _titleController.text;
                  itemToEdit.body = _bodyController.text;
                });
                Navigator.of(dialogContext).pop();
                _titleController.clear();
                _bodyController.clear();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
    ),
    body: ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      buildDefaultDragHandles: false,
      itemCount: _items.length,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final titleBodyPair item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
      itemBuilder: (BuildContext context, int index) {
        final item = _items[index];

        return ListTile(
          key: ValueKey(item.id),
          leading: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          title: Text(item.title),
          onTap: () {
            final data = ClipboardData(text: item.body);
            Clipboard.setData(data);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${item.title}" için şifre kopyalandı!'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _EditOld(item.id);
            },
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _AddNew,
      tooltip: 'Add New',
      child: const Icon(Icons.add),
    ),
  );
  }


}