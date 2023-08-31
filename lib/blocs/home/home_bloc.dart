import 'dart:io';

import 'package:async_zip/async_zip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  File? editFile;
  List<ZipEntry> entries = [];
  String tempDir = "";
  String destDir = "";
  String srcDir = "";
  HomeBloc() : super(HomeInitial()) {
    // on<HomeEvent>((event, emit) {});
    on<OnAddFile>(_addFile);
    on<HomeInit>((event, emit) async {
      Directory directory = await getTemporaryDirectory();
      tempDir = directory.path;
      destDir = "$tempDir/dest";
      srcDir = "$tempDir/nth";
      await _clearCache();
    });
    on<OnSaveFile>(_saveFile);
  }
  _addFile(OnAddFile event, Emitter emit) async {
    await _clearCache();
    editFile = event.file;
    _extract();
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
  }
}
