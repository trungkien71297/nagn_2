import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nagn_2/blocs/home/home_bloc.dart';
import 'package:nagn_2/ui/widget/segmented_widget.dart';

import '../../utils/widget_util.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    context.read<HomeBloc>().add(HomeInit());
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                BlocListener<HomeBloc, HomeState>(
                  listenWhen: (prev, current) => current is HomeGetFilesStatus,
                  listener: (context, state) {
                    if (state is HomeGetFilesStatus) {
                      if (state.status == ProcessStatus.failed) {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: const Text(
                                  "ERROR!",
                                  style: TextStyle(color: Colors.red),
                                ),
                                content: Text("Can not load ebook, please try again!\n${state.message}", maxLines: 2,),
                                backgroundColor: Colors.black,
                                icon: const Icon(
                                    Icons.done_outline_rounded),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("OK"))
                                ],
                              );
                            });
                      }
                    }
                  },
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['epub']);
                        if (result != null) {
                          File file = File(result.files.single.path!);
                          if (context.mounted) {
                            context.read<HomeBloc>().add(OnAddFile(file));
                          }
                        } else {}
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Add file")),
                ),
                Expanded(
                    child: Stack(
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            scrollDirection: Axis.vertical,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [_coverPage(context), _infoPage(context)],
                          ),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SegmentedWidget(
                          onChangeSegment: (index) =>
                              _pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.bounceIn),
                        ),
                      ),
                    )
                  ],
                )),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    BlocListener<HomeBloc, HomeState>(
                      listenWhen: (prev, current) => current is HomeSaveStatus,
                      listener: (context, state) {
                        if (state is HomeSaveStatus) {
                          switch (state.status) {
                            case ProcessStatus.success:
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: const Text("SUCCESS"),
                                      content:
                                          const Text("Save file successfully"),
                                      backgroundColor: Colors.black,
                                      icon: const Icon(
                                          Icons.done_outline_rounded),
                                      actions: [
                                        TextButton(
                                            onPressed: () {},
                                            child: const Text("Go to folder")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("OK"))
                                      ],
                                    );
                                  });
                              break;
                            case ProcessStatus.failed:
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: const Text(
                                        "ERROR!",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      content: const Text(
                                          "Can't save file, please try again!"),
                                      backgroundColor: Colors.black,
                                      icon: const Icon(
                                          Icons.done_outline_rounded),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("OK"))
                                      ],
                                    );
                                  });
                              break;
                            default:
                              break;
                          }
                        }
                      },
                      child: ElevatedButton.icon(
                          onPressed: () {

                            context.read<HomeBloc>().add(OnSaveFile());
                          },
                          icon: const Icon(Icons.save_as),
                          label: const Text("Save")),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (prev, current) => current is HomeLoadStatus,
            builder: (context, state) {
              if (state is HomeLoadStatus) {
                return state.isLoading
                    ? state.isSave
                        ? Container(
                            color: Colors.blueGrey.withOpacity(0.3),
                            child: Center(child: loading),
                          )
                        : Container(
                            color: Colors.blueGrey.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ))
                    : Container();
              } else {
                return Container();
              }
            },
          )
        ],
      ),
    );
  }

  _coverPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: FractionallySizedBox(
          widthFactor: 0.7,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1 / 1.6,
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (prev, current) => current is HomeGetBookInfo,
                builder: (context, state) {
                  if (state is HomeGetBookInfo) {
                    return state.book.cover != null
                        ? Image.file(state.book.cover!)
                        : Container(
                            color: const Color.fromRGBO(210, 210, 210, 1),
                            child: const Center(
                              child: Icon(
                                Icons.menu_book_sharp,
                                color: Colors.black45,
                              ),
                            ),
                          );
                  } else {
                    return Container(
                      color: const Color.fromRGBO(210, 210, 210, 1),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_sharp,
                          color: Colors.black45,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        )),
        const SizedBox(
          height: 15,
        ),
        OutlinedButton.icon(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ["JPEG", "PNG", "GIF", "SVG"]);
              if (result != null) {
                File file = File(result.files.single.path!);
                if (context.mounted) {
                  context.read<HomeBloc>().add(OnSelectCover(file));
                }
              } else {}
            },
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text("Change cover")),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  _infoPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: SingleChildScrollView(
        child: TapRegion(
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: context.read<HomeBloc>().nameTextController,
                decoration: const InputDecoration(
                    labelText: "Book title", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: context.read<HomeBloc>().authorTextController,
                decoration: const InputDecoration(
                    labelText: "Author(s)", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton.icon(
                  onPressed: () => context.read<HomeBloc>().add(OnResetInfo()),
                  icon: const Icon(Icons.restore),
                  label: const Text("Reset Info"))
            ],
          ),
        ),
      ),
    );
  }
}
