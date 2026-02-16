import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Archive extends StatefulWidget {
  const Archive({super.key});

  @override
  State<Archive> createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  final box = Hive.box("database");
  List<dynamic> archive = [];

  @override
  void initState(){
    archive = List<dynamic>.from(box.get("archive", defaultValue: []));
    super.initState();
  }

  void _restoreTask(BuildContext context, int index) {
    final restoredItem = archive[index];
    final updatedTodo = List<dynamic>.from(box.get("todo", defaultValue: []));

    setState(() {
      archive.removeAt(index);
    });

    updatedTodo.add(restoredItem);
    box.put("todo", updatedTodo);
    box.put("archive", archive);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Archive"),
      ),
      child: archive.isEmpty
          ? Center(
              child: Text(
                "Nothing archived",
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 24),
              itemCount: archive.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Slidable(
                    key: ValueKey('${archive[index]["task"]}_$index'),
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      extentRatio: 0.35,
                      children: [
                        SlidableAction(
                          onPressed: (_) => _restoreTask(context, index),
                          backgroundColor: CupertinoColors.activeGreen,
                          foregroundColor: CupertinoColors.white,
                          icon: CupertinoIcons.arrow_uturn_left,
                          label: 'Restore',
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onLongPress: () {
                        showCupertinoDialog(context: context, builder: (context) {
                          return CupertinoActionSheet(
                            message: Text("Delete \"${archive[index]["task"]}\" ?"),
                            actions: [
                              CupertinoButton(
                                  child: Text("Delete", style: TextStyle(color: CupertinoColors.destructiveRed)),
                                  onPressed: () {
                                    setState(() {
                                      archive.removeAt(index);
                                      box.put("archive", archive);
                                    });
                                    Navigator.pop(context);
                                  }),
                              CupertinoButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ],
                          );
                        });
                      },
                      onTap: () {
                        setState(() {
                          archive[index]["isDone"] = !archive[index]["isDone"];
                          box.put("archive", archive);
                        });
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
                              (archive[index]["isDone"] ? CupertinoIcons.check_mark_circled : CupertinoIcons.circle),
                              size: 20,
                              color: CupertinoColors.white,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                archive[index]["task"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  decoration: (archive[index]["isDone"]
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none),
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
              },
            ),
    );
  }
}
