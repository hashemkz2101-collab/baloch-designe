import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await AppDb.instance.init();
  runApp(const BalochDesignApp());
}

class BalochDesignApp extends StatelessWidget {
  const BalochDesignApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Baloch Design',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF245B55)),
      scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0),
    ),
    home: const Directionality(textDirection: TextDirection.rtl, child: HomePage()),
  );
}

class AppDb {
  AppDb._();
  static final instance = AppDb._();
  Database? _db;
  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    await Directory(dir.path).create(recursive: true);
    _db = await databaseFactory.openDatabase(
      p.join(dir.path, 'baloch_design.db'),
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE models(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, code TEXT, notes TEXT)');
          await db.execute('CREATE TABLE parts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, code TEXT, image_path TEXT)');
          await db.execute('CREATE TABLE designs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, model_id INTEGER, canvas_json TEXT NOT NULL, updated_at TEXT NOT NULL)');
        },
      ),
    );
  }
  Database get db => _db!;
  Future<List<Map<String, Object?>>> list(String table) => db.query(table, orderBy: 'id DESC');
  Future<void> add(String table, Map<String, Object?> values) async { await db.insert(table, values); }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int selected = 0;
  final pages = const [DashboardPage(), ModelsPage(), PartsPage(), DesignerPage(), SavedDesignsPage()];
  final labels = const ['خانه', 'مدل‌ها', 'قطعات', 'محیط طراحی', 'طرح‌های ذخیره‌شده'];
  final icons = const [Icons.dashboard_outlined, Icons.category_outlined, Icons.extension_outlined, Icons.design_services_outlined, Icons.folder_open_outlined];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Row(children: [
      Container(
        width: 226, color: const Color(0xFF183F3B),
        child: Column(children: [
          const SizedBox(height: 24),
          const Text('BALOCH DESIGN', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('طراحی مستقل', style: TextStyle(color: Colors.white70))),
          const Divider(color: Colors.white24),
          for (int i=0; i<labels.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: ListTile(
                selected: selected == i,
                selectedTileColor: const Color(0xFF2B625B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(icons[i], color: Colors.white),
                title: Text(labels[i], style: const TextStyle(color: Colors.white)),
                onTap: () => setState(() => selected = i),
              ),
            ),
          const Spacer(),
          const Padding(padding: EdgeInsets.all(16), child: Text('نسخه آزمایشی ۰.۱', style: TextStyle(color: Colors.white60, fontSize: 11))),
        ]),
      ),
      Expanded(child: pages[selected]),
    ]),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('خوش آمدید', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('محیط مستقل طراحی مدل‌ها و قطعات بلوچ دیزاین', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 28),
      Wrap(spacing: 16, runSpacing: 16, children: const [
        _FeatureCard(icon: Icons.category, title: 'مدیریت مدل‌ها', detail: 'ثبت و دسته‌بندی مدل‌ها'),
        _FeatureCard(icon: Icons.extension, title: 'کتابخانه قطعات', detail: 'ثبت کد و مشخصات قطعات'),
        _FeatureCard(icon: Icons.design_services, title: 'بوم طراحی', detail: 'چیدمان و ویرایش قطعات'),
        _FeatureCard(icon: Icons.save_alt, title: 'ذخیره محلی', detail: 'اطلاعات روی همین کامپیوتر'),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Row(children: [
          Icon(Icons.info_outline, color: Color(0xFF245B55)),
          SizedBox(width: 12),
          Expanded(child: Text('این نسخه، پایه اولیه برنامه است. امکانات طراحی تخصصی و کاتالوگ کامل قطعات در مراحل بعد اضافه می‌شوند.')),
        ]),
      ),
    ]),
  );
}
class _FeatureCard extends StatelessWidget {
  final IconData icon; final String title; final String detail;
  const _FeatureCard({required this.icon, required this.title, required this.detail});
  @override Widget build(BuildContext context) => Container(
    width: 230, height: 130, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5EBE8))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF245B55), size: 27), const Spacer(),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(detail, style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  );
}

class ModelsPage extends StatefulWidget { const ModelsPage({super.key}); @override State<ModelsPage> createState()=>_ModelsPageState(); }
class _ModelsPageState extends State<ModelsPage> {
  List<Map<String,Object?>> items=[];
  @override void initState(){super.initState(); refresh();}
  Future<void> refresh() async { items=await AppDb.instance.list('models'); if(mounted)setState((){}); }
  Future<void> addItem() async {
    final name=TextEditingController(), code=TextEditingController(), notes=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('مدل جدید'),content:SizedBox(width:360,child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,decoration:const InputDecoration(labelText:'نام مدل')),
      TextField(controller:code,decoration:const InputDecoration(labelText:'کد مدل')),
      TextField(controller:notes,decoration:const InputDecoration(labelText:'توضیحات')),
    ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('انصراف')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('ذخیره'))]));
    if(ok==true && name.text.trim().isNotEmpty){await AppDb.instance.add('models',{'name':name.text.trim(),'code':code.text.trim(),'notes':notes.text.trim()}); await refresh();}
  }
  @override Widget build(BuildContext context)=>_ListPage(title:'مدل‌ها',subtitle:'مدل‌های طراحی را ثبت و مدیریت کنید',items:items,onAdd:addItem);
}
class PartsPage extends StatefulWidget { const PartsPage({super.key}); @override State<PartsPage> createState()=>_PartsPageState(); }
class _PartsPageState extends State<PartsPage> {
  List<Map<String,Object?>> items=[];
  @override void initState(){super.initState(); refresh();}
  Future<void> refresh() async {items=await AppDb.instance.list('parts');if(mounted)setState((){});}
  Future<void> addItem() async {
    final name=TextEditingController(),code=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:const Text('قطعه جدید'),content:SizedBox(width:340,child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:name,decoration:const InputDecoration(labelText:'نام قطعه')),
      TextField(controller:code,decoration:const InputDecoration(labelText:'کد قطعه')),
    ])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('انصراف')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('ذخیره'))]));
    if(ok==true&&name.text.trim().isNotEmpty){await AppDb.instance.add('parts',{'name':name.text.trim(),'code':code.text.trim()});await refresh();}
  }
  @override Widget build(BuildContext context)=>_ListPage(title:'کتابخانه قطعات',subtitle:'قطعات و کدهای مورد استفاده در طراحی',items:items,onAdd:addItem);
}
class _ListPage extends StatelessWidget {
  final String title,subtitle; final List<Map<String,Object?>> items; final VoidCallback onAdd;
  const _ListPage({required this.title,required this.subtitle,required this.items,required this.onAdd});
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),Text(subtitle,style:const TextStyle(color:Colors.black54))])),FilledButton.icon(onPressed:onAdd,icon:const Icon(Icons.add),label:const Text('افزودن'))]),
    const SizedBox(height:22),
    Expanded(child:items.isEmpty?const Center(child:Text('هنوز موردی ثبت نشده است')):ListView.separated(itemCount:items.length,separatorBuilder:(_,__)=>const SizedBox(height:8),itemBuilder:(ctx,i)=>Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.widgets_outlined)),title:Text('${items[i]['name']??''}'),subtitle:Text('کد: ${items[i]['code']??'—'}'))))),
  ]));
}


class DesignerPage extends StatefulWidget {
  const DesignerPage({super.key});
  @override
  State<DesignerPage> createState() => _DesignerPageState();
}

class _DesignerPageState extends State<DesignerPage> {
  final GlobalKey canvasKey = GlobalKey();
  final List<CanvasPart> parts = [];
  int? selected;
  String designName = 'طرح جدید';

  void addPart() {
    setState(() {
      parts.add(CanvasPart(
        'قطعه ${parts.length + 1}',
        Offset(80 + parts.length * 18, 70 + parts.length * 18),
      ));
      selected = parts.length - 1;
    });
  }

  Future<void> save() async {
    final data = jsonEncode(parts.map((e) => {
      'name': e.name,
      'x': e.position.dx,
      'y': e.position.dy,
      'rotation': e.rotation,
      'scale': e.scale,
    }).toList());
    await AppDb.instance.add('designs', {
      'name': designName,
      'model_id': null,
      'canvas_json': data,
      'updated_at': DateTime.now().toIso8601String(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('طرح در پایگاه‌داده محلی ذخیره شد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'محیط طراحی',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                ),
              ),
              OutlinedButton.icon(
                onPressed: addPart,
                icon: const Icon(Icons.add),
                label: const Text('افزودن قطعه'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: save,
                icon: const Icon(Icons.save),
                label: const Text('ذخیره طرح'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 190,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ابزارها',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text('نسخه اولیه بوم'),
                          const SizedBox(height: 8),
                          const Text('• افزودن قطعه آزمایشی'),
                          const Text('• انتخاب و جابه‌جایی'),
                          const Text('• ذخیره مختصات'),
                          const Spacer(),
                          if (selected != null && selected! < parts.length) ...[
                            Text('انتخاب: ${parts[selected!].name}'),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => setState(() {
                                    parts[selected!].rotation -= 0.1;
                                  }),
                                  icon: const Icon(Icons.rotate_left),
                                ),
                                IconButton(
                                  onPressed: () => setState(() {
                                    parts[selected!].rotation += 0.1;
                                  }),
                                  icon: const Icon(Icons.rotate_right),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                parts.removeAt(selected!);
                                selected = null;
                              }),
                              child: const Text('حذف قطعه'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    color: const Color(0xFFE9EEEC),
                    child: Center(
                      child: RepaintBoundary(
                        key: canvasKey,
                        child: LayoutBuilder(
                          builder: (ctx, constraints) {
                            return Container(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              color: Colors.white,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(painter: GridPainter()),
                                  ),
                                  for (int i = 0; i < parts.length; i++)
                                    Positioned(
                                      left: parts[i].position.dx,
                                      top: parts[i].position.dy,
                                      child: GestureDetector(
                                        onTap: () => setState(() => selected = i),
                                        onPanUpdate: (details) => setState(() {
                                          parts[i].position += details.delta;
                                          selected = i;
                                        }),
                                        child: Transform.rotate(
                                          angle: parts[i].rotation,
                                          child: Container(
                                            padding: const EdgeInsets.all(18),
                                            decoration: BoxDecoration(
                                              color: selected == i
                                                  ? const Color(0xFFD8EAE5)
                                                  : const Color(0xFFF2F4F3),
                                              border: Border.all(
                                                color: selected == i
                                                    ? const Color(0xFF245B55)
                                                    : Colors.black26,
                                                width: selected == i ? 2 : 1,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(parts[i].name),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CanvasPart {String name; Offset position; double rotation=0,scale=1; CanvasPart(this.name,this.position);}
class GridPainter extends CustomPainter {
  @override void paint(Canvas canvas,Size size){final p=Paint()..color=const Color(0xFFEFF2F0)..strokeWidth=1;for(double x=0;x<size.width;x+=24){canvas.drawLine(Offset(x,0),Offset(x,size.height),p);}for(double y=0;y<size.height;y+=24){canvas.drawLine(Offset(0,y),Offset(size.width,y),p);}}
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
class SavedDesignsPage extends StatefulWidget {const SavedDesignsPage({super.key});@override State<SavedDesignsPage> createState()=>_SavedDesignsPageState();}
class _SavedDesignsPageState extends State<SavedDesignsPage>{
  List<Map<String,Object?>> items=[];@override void initState(){super.initState();load();}
  Future<void> load()async{items=await AppDb.instance.list('designs');if(mounted)setState((){});}
  @override Widget build(BuildContext context)=>_ListPage(title:'طرح‌های ذخیره‌شده',subtitle:'طرح‌های ثبت‌شده روی همین کامپیوتر',items:items.map((e)=>{...e,'code':e['updated_at']}).toList(),onAdd:load);
}
