import 'dart:io';

class BookInfo {
  String srcName;
  String srcCover;
  String srcCreator;
  String destName;
  String destCover;
  String destCreator;
  File? cover;

  BookInfo(this.srcName, this.srcCover, {this.destName = "", this.destCover = "", this.srcCreator = "", this.destCreator = ""});
}