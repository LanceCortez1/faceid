import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'archive.dart';

class Errands extends StatefulWidget {
  const Errands({super.key});

  @override
  State<Errands> createState() => _ErrandsState();
}

class _ErrandsState extends State<Errands> {
  final box = Hive.box("database");
  List<dynamic> todo = [];
  List<dynamic> archive = [];
  TextEditingController _task = TextEditingController();

  @override
  void initState(){
    setState(() {
      todo = box.get("todo", defaultValue: []);
      archive = box.get("archive", defaultValue: []);
    });
    super.initState();
  }
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return CupertinoPageScaffold(child: Stack(
      children: [
        (todo.isEmpty) ? ListView(
          children: [
            Text("No Errands Today", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 30),)
          ],
        ) : ListView.builder(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 140 + bottomInset),
            itemCount: todo.length,
            itemBuilder: (context, index){
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    extentRatio: 0.5,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          setState(() {
                            archive.add(todo[index]);
                            todo.removeAt(index);
                            box.put("todo", todo);
                            box.put("archive", archive);
                          });
                        },
                        backgroundColor: CupertinoColors.systemBlue,
                        foregroundColor: CupertinoColors.white,
                        icon: CupertinoIcons.archivebox,
                        label: 'Archive',
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          showCupertinoDialog(context: context, builder: (context){
                            return CupertinoActionSheet(
                              message: Text("Delete \"${todo[index]["task"]}\" ?"),
                              actions: [
                                CupertinoButton(child: Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed),), onPressed: (){
                                  setState(() {
                                    todo.removeAt(index);
                                    box.put("todo", todo);
                                  });
                                  Navigator.pop(context);
                                }),
                                CupertinoButton(child: Text("Cancel"), onPressed: (){
                                  Navigator.pop(context);
                                }),
                              ],
                            );
                          });
                        },
                        backgroundColor: CupertinoColors.destructiveRed,
                        foregroundColor: CupertinoColors.white,
                        icon: CupertinoIcons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onLongPress: (){
                      showCupertinoDialog(context: context, builder: (context){
                        return CupertinoActionSheet(

                          message: Text("Delete \"${todo[index]["task"]}\" ?"),
                          actions: [
                            CupertinoButton(child: Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed),), onPressed: (){
                              setState(() {
                                todo.removeAt(index);
                                box.put("todo", todo);
                              });
                              Navigator.pop(context);
                            }),
                            CupertinoButton(child: Text("Cancel"), onPressed: (){
                              Navigator.pop(context);
                            }),
                          ],
                        );
                      });
                    },
                    onTap: (){
                      setState(() {
                        todo[index]["isDone"] =! todo[index]["isDone"];
                        box.put("todo", todo);
                      });
                      print(todo[index]["isDone"]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.darkBackgroundGray.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: CupertinoColors.white.withOpacity(0.08)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            (todo[index]["isDone"] ? CupertinoIcons.check_mark_circled : CupertinoIcons.circle),
                            size: 20,
                            color: CupertinoColors.white,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              todo[index]["task"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                decoration: (todo[index]["isDone"] ? TextDecoration.lineThrough : TextDecoration.none),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
          }
        ),
        Positioned(
          bottom: 20 + bottomInset,
          right: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.all(12),
                  onPressed: () async {
                    await Navigator.push(context, CupertinoPageRoute(builder: (context) => Archive()));
                    setState(() {
                      todo = box.get("todo", defaultValue: []);
                      archive = box.get("archive", defaultValue: []);
                    });
                  },
                  child: Icon(CupertinoIcons.archivebox, color: CupertinoColors.white, size: 24),
                ),
              ),
              SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.all(12),
                  onPressed: (){
                    showCupertinoDialog(context: context, builder: (context){
                      return CupertinoActionSheet(
                        title: Text("Add ToDo"),
                        message: CupertinoTextField(
                          controller: _task,
                        ),
                        actions: [
                          CupertinoButton(child: Text("Save"), onPressed: (){
                            if (_task.text != ""){
                              setState(() {
                                todo.add({
                                  "task" : _task.text,
                                  "isDone" : false,
                                });
                                box.put("todo", todo);
                              });
                              _task.text = "";
                              Navigator.pop(context);
                            }
                          }),
                          CupertinoButton(child: Text("Cancel", style: TextStyle(color: CupertinoColors.destructiveRed),), onPressed: (){
                            _task.text = "";
                            Navigator.pop(context);
                          })
                        ],

                      );
                    });
                  },
                  child: Icon(CupertinoIcons.plus, color: CupertinoColors.white, size: 24),
                ),
              )
            ],
          ),
        )
      ],
    ));
  }
}
