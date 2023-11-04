import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nagn_2/di.dart';
import 'package:nagn_2/models/book_info.dart';
import 'package:nagn_2/utils/constants.dart';
import 'package:nagn_2/utils/method_channel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:mime/mime.dart';
import '../../models/custom_exception.dart';
import 'package:path/path.dart' as p;
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  File? editFile;
  Archive? _archive;
  String tempDir = "";
  String destDir = "";
  String saveDir = "";
  String srcDir = "";
  String metadataFile = "";
  String contentFile = "";
  XmlDocument? content;
  XmlElement? imageElement;
  BookInfo book = BookInfo("", "");
  TextEditingController nameTextController = TextEditingController();
  TextEditingController authorTextController = TextEditingController();
  TextEditingController fileNameTextController = TextEditingController();
  final StreamController<HomeLoadStatus> _isLoadingStream =
      StreamController.broadcast();
  Stream<HomeLoadStatus> get isLoading => _isLoadingStream.stream;

  final StreamController<HomeSaveStatus> _saveStream =
      StreamController.broadcast();
  Stream<HomeSaveStatus> get isSaved => _saveStream.stream;
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
    try {
      _isLoadingStream.sink.add(HomeLoadStatus(true, false));
      await _clearCache();
      editFile = event.file;
      fileNameTextController.text = _getName(editFile!.path, removeExt: true);
      await _extract();
      _isLoadingStream.sink.add(HomeLoadStatus(false, false));
      emit(HomeGetBookInfo(book));
    } catch (e) {
      _clearCache();
      emit(HomeGetBookInfo(book));
      _isLoadingStream.sink.add(HomeLoadStatus(false, false));
      emit(HomeGetFilesStatus(ProcessStatus.failed, e.toString()));
    }
  }

  _saveFile(HomeEvent event, Emitter emitter) async {
    if (editFile != null) {
      _isLoadingStream.sink.add(HomeLoadStatus(true, true));
      MethodChannelExecutor.channel.setMethodCallHandler((call) async {
        if (call.method == 'SAVE_FILE_RESULT') {
          final result = call.arguments['result'] as bool;
          if (result) {
            _isLoadingStream.sink.add(HomeLoadStatus(false, true));
            _saveStream.sink.add(HomeSaveStatus(ProcessStatus.success, ""));
          } else {
            _isLoadingStream.sink.add(HomeLoadStatus(false, true));
            _saveStream.sink
                .add(HomeSaveStatus(ProcessStatus.failed, "Cannot save file"));
          }
        }
      });
      try {
        await _saveFileOnTemp();
        _archiveFile();
      } catch (e) {
        _isLoadingStream.sink.add(HomeLoadStatus(false, true));
        _saveStream.sink
            .add(HomeSaveStatus(ProcessStatus.failed, e.toString()));
      }
    }
  }

  _saveFileOnTemp() async {
    if (content != null) {
      try {
        var metadata = content!.findAllElements("metadata").first;
        bool isUpdate = false;
        if (book.destCover.isNotEmpty) {
          isUpdate = true;
          final content = await book.cover!.readAsBytes();
          final file = File(book.srcCover);
          var oldName = p.basename(file.path);
          var newName = p.basename(book.destCover);
          await file.delete();
          file.writeAsBytesSync(content);
          final mime = lookupMimeType(book.destCover);
          imageElement?.setAttribute("media-type", mime);
          var a = imageElement?.getAttribute("href") ?? '';
          a.replaceAll(oldName, newName);
          imageElement?.setAttribute("href", a);
        }

        if (book.srcName != nameTextController.text) {
          isUpdate = true;
          var title = metadata.findAllElements("dc:title").first;

          for (int i = title.attributes.length - 1; i >= 0; i--) {
            final attribute = title.attributes[i];
            title.removeAttribute(attribute.qualifiedName);
          }

          title.innerText = nameTextController.text;

          var metas = metadata.findAllElements("meta");
          for (var meta in metas) {
            final name =
                meta.getAttributeNode("calibre:title_sort")?.value ?? "";
            if (name.isNotEmpty) {
              meta.setAttribute("content", nameTextController.text);
            }
          }
        }
        if (book.srcCreator != authorTextController.text) {
          isUpdate = true;
          var creator = metadata.findAllElements("dc:creator").first;
          for (int i = creator.attributes.length - 1; i >= 0; i--) {
            final attribute = creator.attributes[i];
            creator.removeAttribute(attribute.qualifiedName);
          }
          creator.innerText = authorTextController.text;
        }
        if (isUpdate) {
          final file = File("$srcDir/$contentFile");
          await file.writeAsString(content!.toXmlString());
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  _extract() async {
    if (editFile != null) {
      try {
        var bytes = editFile!.readAsBytesSync();
        _archive = ZipDecoder().decodeBytes(bytes);
        extractArchiveToDisk(_archive!, srcDir);
        await _getMetaData();
        await _getContent();
        await _getBookInfo();
      } catch (e) {
        rethrow;
      }
    }
  }

  _archiveFile() {
    if (_archive != null) {
      var encoder = ZipFileEncoder();
      try {
        encoder.zipDirectory(Directory(srcDir),
            filename: "$destDir/${fileNameTextController.text}.epub");
        getIt<MethodChannelExecutor>()
            .saveFile('$destDir/${fileNameTextController.text}.epub');
      } catch (e) {
        rethrow;
      }
    }
  }

  String _getName(String path, {removeExt = false}) {
    var res = path.split("/").last;
    if (removeExt) {
      res = res.replaceAll('.epub', '');
    }
    return res;
  }

  _clearCache() async {
    editFile = null;
    _archive = null;
    Directory src = Directory(srcDir);
    if (await src.exists()) {
      await src.delete(recursive: true);
    }
    src.create();
    //For test
    Directory dest = Directory(destDir);
    if (await dest.exists()) {
      await dest.delete(recursive: true);
    }
    dest.create();
    book = BookInfo("", "");
    nameTextController.clear();
    authorTextController.clear();
    fileNameTextController.clear();
  }

  _getMetaData() async {
    try {
      final metaFile = File("$srcDir/$defaultMetadataPath");
      if (await metaFile.exists()) {
        final fileContent = metaFile.readAsStringSync();
        final xml = XmlDocument.parse(fileContent);
        final rootfiles = xml.findAllElements(xmlRootFileNode);
        if (rootfiles.isNotEmpty) {
          contentFile =
              rootfiles.first.getAttribute(xmlPathFileAttribute) ?? "";
        } else {
          throw CustomException("Can't load metadata file");
        }
      } else {
        throw CustomException("Can't load metadata file");
      }
    } catch (ex) {
      throw CustomException("Can't load metadata file");
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
          throw CustomException("Can't load content file");
        }
      } catch (ex) {
        throw CustomException("Can't load content file");
      }
    } else {
      throw CustomException("Can't load content file");
    }
  }

  _getBookInfo() async {
    if (content != null) {
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
      for (var item in metadata.findAllElements("meta")) {
        if (item.getAttribute("name") == "cover") {
          attributeCover = item.getAttribute("content") ?? "";
        }
      }
      var manifest = content!.findAllElements("manifest").first;
      var cover = "";
      if (attributeCover.isNotEmpty) {
        for (var item in manifest.findAllElements("item")) {
          if (item.getAttribute("id") == attributeCover) {
            imageElement = item;
            final pref = contentFile.lastIndexOf("/") > -1
                ? contentFile.substring(0, contentFile.lastIndexOf("/"))
                : "";
            final absolutePath = pref.isNotEmpty
                ? "$pref/${item.getAttribute("href") ?? ""}"
                : item.getAttribute("href") ?? "";
            cover = "$srcDir/$absolutePath";
          }
        }
      } else {
        for (var item in manifest.findAllElements("item")) {
          if (item.getAttribute("properties") == xmlCoverAttribute) {
            imageElement = item;
            final pref = contentFile.lastIndexOf("/") > -1
                ? contentFile.substring(0, contentFile.lastIndexOf("/"))
                : "";
            final absolutePath = pref.isNotEmpty
                ? "$pref/${item.getAttribute("href") ?? ""}"
                : item.getAttribute("href") ?? "";
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
    book.cover = book.srcCover.isNotEmpty ? File(book.srcCover) : null;
    nameTextController.text = book.srcName;
    authorTextController.text = book.srcCreator;
    fileNameTextController.text = _getName(editFile!.path, removeExt: true);
    emitter(HomeGetBookInfo(book));
  }

  _onSelectCover(OnSelectCover event, Emitter emitter) {
    book.cover = event.file;
    book.destCover = event.file.path;
    emitter(HomeGetBookInfo(book));
  }
}
