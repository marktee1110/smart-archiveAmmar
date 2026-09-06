import 'package:flutter/material.dart';

void main() {
  runApp(const SmartArchiveApp());
}

class SmartArchiveApp extends StatelessWidget {
  const SmartArchiveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الأرشيف الذكي',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        fontFamily: 'Cairo',
      ),
      home: const HomeScreen(),
      scaffoldMessengerKey: ScaffoldMessengerKey.current,
    );
  }
}

class ScaffoldMessengerKey {
  static final current = GlobalKey<ScaffoldMessengerState>();
}

class ArchiveItem {
  final String name;
  final String type;
  final String fileExtension;
  final String date;

  ArchiveItem({required this.name, required this.type, required this.fileExtension, required this.date});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ArchiveItem> _allItems = [
    ArchiveItem(name: 'المستندات القانونية', type: 'folder', fileExtension: '', date: '2026-09-01'),
    ArchiveItem(name: 'الهوية الشخصية ممسوحة', type: 'file', fileExtension: 'png', date: '2026-09-02'),
    ArchiveItem(name: 'تقرير العمل السنوي', type: 'file', fileExtension: 'pdf', date: '2026-08-25'),
    ArchiveItem(name: 'ملاحظات الاجتماع السريع', type: 'file', fileExtension: 'txt', date: '2026-09-03'),
    ArchiveItem(name: 'صور الفواتير والوصولات', type: 'folder', fileExtension: '', date: '2026-08-15'),
  ];

  List<ArchiveItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSynced = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.name.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _addNewItem(String name, String type, String ext) {
    setState(() {
      _allItems.insert(0, ArchiveItem(
        name: name,
        type: type,
        fileExtension: ext,
        date: DateTime.now().toString().split(' ')[0],
      ));
      _onSearchChanged();
    });
  }

  void _openFileWithOptions(ArchiveItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('فتح الملف: ${item.name}.${item.fileExtension}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('اختر التطبيق المناسب للتشغيل:'),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('عارض ملفات PDF الافتراضي'),
                  onTap: () => _simulatedOpen(item.name, 'PDF Viewer'),
                ),
                ListTile(
                  leading: const Icon(Icons.image, color: Colors.blue),
                  title: const Text('معرض الصور بالنظام'),
                  onTap: () => _simulatedOpen(item.name, 'System Gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields, color: Colors.green),
                  title: const Text('محرر النصوص المتقدم'),
                  onTap: () => _simulatedOpen(item.name, 'Text Editor'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _simulatedOpen(String fileName, String appName) {
    Navigator.pop(context);
    ScaffoldMessengerKey.current.currentState?.showSnackBar(
      SnackBar(content: Text('تم فتح "$fileName" بنجاح باستخدام $appName')),
    );
  }

  void _triggerGoogleDriveSync() {
    ScaffoldMessengerKey.current.currentState?.showSnackBar(
      const SnackBar(content: Text('جاري الاتصال بـ Google Drive ومزامنة الملفات...')),
    );
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSynced = true;
      });
      ScaffoldMessengerKey.current.currentState?.showSnackBar(
        const SnackBar(content: Text('تمت المزامنة بنجاح! جميع ملفاتك آمنة على السحابة الآن.')),
      );
    });
  }

  void _showCreateDialog() {
    final textController = TextEditingController();
    String selectedType = 'file';
    String selectedExt = 'txt';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('إنشاء عنصر جديد'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text('النوع: '),
                        Radio<String>(
                          value: 'file',
                          groupValue: selectedType,
                          onChanged: (val) => setDialogState(() => selectedType = val!),
                        ),
                        const Text('ملف'),
                        Radio<String>(
                          value: 'folder',
                          groupValue: selectedType,
                          onChanged: (val) => setDialogState(() => selectedType = val!),
                        ),
                        const Text('مجلد'),
                      ],
                    ),
                    if (selectedType == 'file')
                      DropdownButton<String>(
                        value: selectedExt,
                        items: const [
                          DropdownMenuItem(value: 'txt', child: Text('ملف نصي (txt)')),
                          DropdownMenuItem(value: 'pdf', child: Text('مستند (pdf)')),
                          DropdownMenuItem(value: 'png', child: Text('صورة (png)')),
                        ],
                        onChanged: (val) => setDialogState(() => selectedExt = val!),
                      ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                  ElevatedButton(
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        _addNewItem(textController.text, selectedType, selectedType == 'file' ? selectedExt : '');
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أرشيفي الذكي 🗂️'),
          actions: [
            IconButton(
              icon: Icon(_isSynced ? Icons.cloud_done : Icons.cloud_queue, color: _isSynced ? Colors.greenAccent : Colors.white),
              tooltip: 'مزامنة مع Google Drive',
              onPressed: _triggerGoogleDriveSync,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1)),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'البحث الذكي الفوري عن أي ملف...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
            ),
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(child: Text('لم يتم العثور على ملفات مطابقة للبحث!'))
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isFolder = item.type == 'folder';
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isFolder ? Colors.amber.shade700 : Colors.teal.shade700,
                              child: Icon(isFolder ? Icons.folder : Icons.insert_drive_file, color: Colors.white),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${item.date} ${isFolder ? "" : " • ." + item.fileExtension}'),
                            trailing: const Icon(Icons.open_in_new, size: 20),
                            onTap: () {
                              if (!isFolder) {
                                _openFileWithOptions(item);} else {ScaffoldMessengerKey.current.currentState?.showSnackBar(SnackBar(content: Text('فتح مجلد: ${item.name}')),);}},),);},),),],),floatingActionButton: FloatingActionButton(onPressed: _showCreateDialog,backgroundColor: Colors.teal,child: const Icon(Icons.add, color: Colors.white),),),);}}
