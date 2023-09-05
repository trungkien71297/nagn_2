import 'dart:io';

import 'package:async_zip/async_zip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nagn_2/models/book_info.dart';
import 'package:nagn_2/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  File? editFile;
  List<ZipEntry> entries = [];
  String tempDir = "";
  String destDir = "";
  String srcDir = "";
  String metadataFile = "";
  String contentFile = "";
  XmlDocument? content;
  BookInfo book = BookInfo("", "");
  TextEditingController nameTextController = TextEditingController();
  TextEditingController authorTextController = TextEditingController();
  HomeBloc() : super(HomeInitial()) {
    // on<HomeEvent>((event, emit) {});
    on<OnAddFile>(_addFile);
    on<HomeInit>((event, emit) async {
      Directory directory = await getApplicationCacheDirectory();
      tempDir = directory.path;
      destDir = "$tempDir/dest";
      srcDir = "$tempDir/nth";
      await _clearCache();
    });
    on<OnSaveFile>(_saveFile);
    on<OnResetInfo>(_resetInfo);
    on<OnSelectCover>(_onSelectCover);
  }
  _addFile(OnAddFile event, Emitter emit) async {
    await _clearCache();
    editFile = event.file;
    await _extract();
    emit(HomeGetBookInfo(book));
  }

  _saveFile(HomeEvent event, Emitter emit) async {
    await _archive();
  }

  _extract() async {
    if (editFile != null) {
      final reader = ZipFileReader();
      final tempExtract = Directory(srcDir);
      if (kDebugMode) {
        print(tempExtract);
      }
      try {
        reader.open(File(editFile!.path));
        entries = await reader.entries();
        await extractZipArchive(editFile!, tempExtract, callback: (entry, totalEntries) {
            //TODO: Progress indicator
        });
        //Progress content file
        await _getMetaData();
        await _getContent();
        await _getBookInfo();
      } catch (e) {
        //TODO: Exception handler
      } finally {
        await reader.close();
      }
    }
  }

  _archive() async {
    if(entries.isNotEmpty) {
      final archiveFile = File("$destDir/${_getName(editFile!.path)}");
      final writer = ZipFileWriter();
      try {
        await writer.create(archiveFile);
        for (var entry in entries) {
          if(!entry.isDir) {
            //TODO: Progress
            await writer.writeFile(entry.name, File("$srcDir/${entry.name}"));
          }
        }
      } catch (e) {
          //TODO: Exception handler
      } finally {
        await writer.close();
      }
    }
  }

  String _getName(String path) {
    var res = path.split("/");
    return res.last;
  }

  _clearCache() async {
    editFile = null;
    entries.clear();
    Directory src = Directory(srcDir);
    if (await src.exists()) {
      await src.delete(recursive: true);
    }
    src.create();
    Directory dest = Directory(destDir);
    if(await dest.exists()) {
      await dest.delete(recursive: true);
    }
    dest.create();
    book = BookInfo("", "");
  }

  _getMetaData() async {
    try {
      final metaFile = File("$srcDir/$DEFAULT_META_PATH");
      if (await metaFile.exists()) {
        final fileContent = metaFile.readAsStringSync();
        final xml = XmlDocument.parse(fileContent);
        final rootfiles = xml.findAllElements(xmlRootFileNode);
        if (rootfiles.isNotEmpty) {
          contentFile = rootfiles.first.getAttribute(xmlPathFileAttribute) ?? "";
        } else {
          //TODO: handle not have content file
        }
      } else {
        //TODO: handle not have metadata file
      }
    } catch(ex) {
      //TODO: handle cannot read metadata file
    }
  }

  _getContent() async {
    if (contentFile.isNotEmpty) {
      try {
        final file = File("$srcDir/$contentFile");
        if (await file.exists()) {
          final fileContent = file.readAsStringSync();
          content = XmlDocument.parse(fileContent);
        } else {
          //TODO: handle not have content file
        }
      } catch(ex) {
        //TODO: handle can not read content file
      }
    } else {
      //TODO: handle not have content file
    }
  }

  _getBookInfo() async {
    if(content != null) {
      var attributeCover = "";
      var metadata = content!.findAllElements("metadata").first;
      var creator = metadata.findAllElements("dc:creator");
      if (creator.isNotEmpty) {
        book.srcCreator = creator.first.innerText;
        authorTextController.text = book.srcCreator;
      }
      var title = metadata.findAllElements("dc:title");
      if (title.isNotEmpty) {
        book.srcName = title.first.innerText;
        nameTextController.text = book.srcName;
      }
      for (var item in  metadata.findAllElements("meta")) {
        if (item.getAttribute("name") == "cover") {
          attributeCover = item.getAttribute("content") ?? "";
        }
      }
      var manifest = content!.findAllElements("manifest").first;
      var cover = "";
      if (attributeCover.isNotEmpty) {
        for (var item in  manifest.findAllElements("item")) {
          if (item.getAttribute("id") == attributeCover) {
            final pref = contentFile.lastIndexOf("/") > -1 ? contentFile.substring(0, contentFile.lastIndexOf("/")) : "";
            final absolutePath = pref.isNotEmpty ? "$pref/${item.getAttribute("href") ?? ""}" : item.getAttribute("href") ?? "";
            cover = "$srcDir/$absolutePath";
          }
        }
      } else {
        for (var item in  manifest.findAllElements("item")) {
          if (item.getAttribute("properties") == xmlCoverAttribute) {
            final pref = contentFile.lastIndexOf("/") > -1 ? contentFile.substring(0, contentFile.lastIndexOf("/")) : "";
            final absolutePath = pref.isNotEmpty ? "$pref/${item.getAttribute("href") ?? ""}" : item.getAttribute("href") ?? "";
            cover = "$srcDir/$absolutePath";
          }
        }
      }
      var coverFile = File(cover);
      if (await coverFile.exists()) {
        book.srcCover = cover;
        book.cover = coverFile;
      } else {
        book.srcCover = "";
      }
    }
  }

  _resetInfo(OnResetInfo event, Emitter emitter) {
    book.destCreator = "";
    book.destCover = "";
    book.destName = "";
    book.cover = null;
    nameTextController.text = book.srcName;
    authorTextController.text = book.srcCreator;
    emitter(HomeGetBookInfo(book));
  }

  _onSelectCover(OnSelectCover event, Emitter emitter) {
      book.cover = event.file;
      emitter(HomeGetBookInfo(book));
  }
}
