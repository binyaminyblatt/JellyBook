// The purpose of this file is to allow the user to read the book/comic they have downloaded

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jellybook/screens/downloaderScreen.dart';
import 'package:jellybook/providers/fileNameFromTitle.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jellybook/models/entry.dart';
import 'package:jellybook/providers/progress.dart';

// cbr/cbz reader
class CbrCbzReader extends StatefulWidget {
  final String title;
  final String comicId;

  const CbrCbzReader({
    Key? key,
    required this.title,
    required this.comicId,
  }) : super(key: key);

  @override
  _CbrCbzReaderState createState() => _CbrCbzReaderState();
}

class _CbrCbzReaderState extends State<CbrCbzReader> {
  late String title;
  late String comicId;
  late int pageNum;
  late int pageNums;
  late double progress;
  late String path;
  late List<String> chapters = [];
  late List<String> pages = [];

  Future<void> createPageList() async {
    debugPrint("chapters: $chapters");
    var formats = [".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".tiff"];
    List<String> pageFiles = [];
    for (var chapter in chapters) {
      List<FileSystemEntity> files = Directory(chapter).listSync();
      for (var file in files) {
        if (file.path.endsWith(formats[0]) ||
            file.path.endsWith(formats[1]) ||
            file.path.endsWith(formats[2]) ||
            file.path.endsWith(formats[3]) ||
            file.path.endsWith(formats[4]) ||
            file.path.endsWith(formats[5]) ||
            file.path.endsWith(formats[6])) {
          pageFiles.add(file.path);
        }
      }
    }
    pageFiles.sort();
    for (var page in pageFiles) {
      pages.add(page);
      pageNums++;
    }
  }

  @override
  void initState() {
    super.initState();
    title = widget.title;
    comicId = widget.comicId;
    pageNum = Hive.box('bookShelf').get(comicId).pageNum;
    progress = Hive.box('bookShelf').get(comicId).progress;
  }

  Future<void> checkDownloaded() async {
    // get it from the database
    var db = Hive.box<Entry>('bookShelf');

    // get the entry
    var entry = db.get(comicId);

    var downloaded = entry!.downloaded;

    if (downloaded == false) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              DownloadScreen(
            comicId: comicId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  Future<void> saveProgress(int page) async {
    var db = Hive.box<Entry>('bookShelf');

    // get the box that stores the entries
    var entries = db.values.toList();

    // get the entry
    var entry = entries.firstWhere((element) => element.id == comicId);

    // update the entry
    entry.pageNum = page;

    // update the progress
    entry.progress = (page / pages.length) * 100;

    // delete the old entry and add the new one
    entries.remove(entry);
    entries.add(entry);

    debugPrint("saved progress");
    debugPrint("page num: ${entry.pageNum}");
  }

  Future<void> getChapters() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    // get the file path from the database
    var box = Hive.box<Entry>('bookShelf');

    if (box.isNotEmpty) {
      // get the entry that matches the id
      var entry = box.get(comicId);
      path = entry!.path;
      pageNum = entry.pageNum;
      progress = entry.progress;
      debugPrint("path: $path");
      debugPrint("page num: $pageNum");
      debugPrint("progress: $progress");
    }

    // get list of all entries
    var entries = Hive.box<Entry>('bookShelf').values.toList();
    debugPrint('entries: $entries');

    // find the entry with the same comicId
    var entry = entries.firstWhere((element) => element.id == comicId);

    // get the box that stores the entries
    // var entries = box.get('entries') as List<Entry>;

    // get the entry

    // print the entry
    debugPrint(entry.toString());

    // check if the entry is downloaded
    if (entry.downloaded) {
      // get the file path
      path = entry.folderPath;
      progress = entry.progress;
    }

    debugPrint(path);

    // get a list of all the files in the folder
    var files = Directory(path).listSync();

    // List<FileSystemEntity> files = Directory(path).listSync();
    debugPrint(files.toString());
    // what we want to do is recursively go through the folder and get all the last directories that dont contain any other directories
    // then we want to add them to the chapters list
    // max depth of 3
    // the way we will do the checking is by checkign to see if the file is ends with a jpg, jpeg, png...
    var formats = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff'];
    for (var file in files) {
      if (file.path.endsWith(formats[0]) ||
          file.path.endsWith(formats[1]) ||
          file.path.endsWith(formats[2]) ||
          file.path.endsWith(formats[3]) ||
          file.path.endsWith(formats[4]) ||
          file.path.endsWith(formats[5]) ||
          file.path.endsWith(formats[6])) {
        debugPrint("file: $file");
        if (!chapters.contains(file.parent.path)) {
          chapters.add(file.parent.path);
        }
      } else {
        debugPrint("file: $file");
        List<FileSystemEntity> files2 = Directory(file.path).listSync();
        for (var file2 in files2) {
          if (file2.path.endsWith(formats[0]) ||
              file2.path.endsWith(formats[1]) ||
              file2.path.endsWith(formats[2]) ||
              file2.path.endsWith(formats[3]) ||
              file2.path.endsWith(formats[4]) ||
              file2.path.endsWith(formats[5]) ||
              file2.path.endsWith(formats[6])) {
            debugPrint("file2: $file2");
            if (!chapters.contains(file2.parent.path)) {
              chapters.add(file2.parent.path);
            }
          } else {
            debugPrint("file2: $file2");
            List<FileSystemEntity> files3 = Directory(file2.path).listSync();
            for (var file3 in files3) {
              if (file3.path.endsWith(formats[0]) ||
                  file3.path.endsWith(formats[1]) ||
                  file3.path.endsWith(formats[2]) ||
                  file3.path.endsWith(formats[3]) ||
                  file3.path.endsWith(formats[4]) ||
                  file3.path.endsWith(formats[5]) ||
                  file3.path.endsWith(formats[6])) {
                debugPrint("file3: $file3");
                if (!chapters.contains(file3.parent.path)) {
                  chapters.add(file3.parent.path);
                }
              } else {
                debugPrint("file3: $file3");
                List<FileSystemEntity> files4 =
                    Directory(file3.path).listSync();
                for (var file4 in files4) {
                  if (file4.path.endsWith(formats[0]) ||
                      file4.path.endsWith(formats[1]) ||
                      file4.path.endsWith(formats[2]) ||
                      file4.path.endsWith(formats[3]) ||
                      file4.path.endsWith(formats[4]) ||
                      file4.path.endsWith(formats[5]) ||
                      file4.path.endsWith(formats[6])) {
                    debugPrint("file4: $file4");
                    if (!chapters.contains(file4.parent.path)) {
                      chapters.add(file4.parent.path);
                    }
                  } else {
                    debugPrint("file4: $file4");
                    List<FileSystemEntity> files5 =
                        Directory(file4.path).listSync();
                    for (var file5 in files5) {
                      if (file5.path.endsWith(formats[0]) ||
                          file5.path.endsWith(formats[1]) ||
                          file5.path.endsWith(formats[2]) ||
                          file5.path.endsWith(formats[3]) ||
                          file5.path.endsWith(formats[4]) ||
                          file5.path.endsWith(formats[5]) ||
                          file5.path.endsWith(formats[6])) {
                        debugPrint("file5: $file5");
                        if (!chapters.contains(file5.parent.path)) {
                          chapters.add(file5.parent.path + "/");
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    debugPrint("Chapters:");
    debugPrint(chapters.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getChapters(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: FutureBuilder(
              // get progress requires the comicId
              future: getProgress(comicId),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                    future: createPageList(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                itemCount: pages.length,
                                controller: PageController(
                                  initialPage: pageNum,
                                ),
                                itemBuilder: (context, index) {
                                  return InteractiveViewer(
                                    child: Image.file(
                                      File(pages[index]),
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                },
                                onPageChanged: (index) {
                                  saveProgress(index);
                                  progress = index / pageNums;
                                  // getProgress();
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}