import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nagn_2/blocs/home/home_bloc.dart';
import 'package:nagn_2/ui/widget/ad_banner.dart';
import 'package:nagn_2/ui/widget/segmented_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/widget_util.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    context.read<HomeBloc>().add(HomeInit());
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                    listenWhen: (prev, current) =>
                        current is HomeGetFilesStatus,
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
                                  content: Text(
                                    "Can't load ebook, please try again!\n${state.message}",
                                    maxLines: 2,
                                  ),
                                  backgroundColor: Colors.black,
                                  icon:
                                      const Icon(Icons.error_outline_outlined),
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
                          final res = await _checkPermission(context);
                          if (res) {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['epub']);
                            if (result != null && result.paths.first != null) {
                              File file = File(result.paths.first!);
                              if (context.mounted) {
                                context.read<HomeBloc>().add(OnAddFile(file));
                              }
                            }
                          }
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
                              children: [
                                _coverPage(context),
                                _infoPage(context)
                              ],
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
                  const AdBanner(),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      StreamBuilder(
                        stream: context.read<HomeBloc>().isSaved,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final state = snapshot.data!;
                            Widget? dialog;
                            switch (state.status) {
                              case ProcessStatus.success:
                                dialog = AlertDialog(
                                  title: const Text("SUCCESS"),
                                  content: const Text("Save file successfully"),
                                  backgroundColor: Colors.black,
                                  icon: const Icon(Icons.done_outline_rounded),
                                  actions: [
                                    //TODO: Do later

                                    // TextButton(
                                    //     onPressed: () {},
                                    //     child: const Text("Go to folder")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("OK"))
                                  ],
                                );
                                break;
                              case ProcessStatus.failed:
                                dialog = errorDialog(context,
                                    "Can't save file. try again!\n${state.message}");
                                break;
                              default:
                                break;
                            }
                            if (dialog != null) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                showDialog(
                                  context: context,
                                  builder: (context) => dialog!,
                                );
                              });
                            }
                          }
                          return ElevatedButton.icon(
                              onPressed: () async {
                                final res = await _checkPermission(context);
                                if (res) {
                                  if (context.mounted) {
                                    context.read<HomeBloc>().add(OnSaveFile());
                                  }
                                }
                              },
                              icon: const Icon(Icons.save_as),
                              label: const Text("Save"));
                        },
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
            StreamBuilder(
              stream: context.read<HomeBloc>().isLoading,
              initialData: HomeLoadStatus(false, false),
              builder: (context, snapshot) {
                final state = snapshot.data!;
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
              },
            )
          ],
        ),
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
              if (context.read<HomeBloc>().editFile != null) {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["JPEG", "PNG", "GIF", "SVG"]);
                if (result != null) {
                  File file = File(result.files.single.path!);
                  if (context.mounted) {
                    context.read<HomeBloc>().add(OnSelectCover(file));
                  }
                } else {}
              }
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
              TextField(
                controller: context.read<HomeBloc>().fileNameTextController,
                decoration: const InputDecoration(
                    labelText: "File name", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton.icon(
                  onPressed: () => context.read<HomeBloc>().add(OnResetInfo()),
                  icon: const Icon(Icons.restore),
                  label: const Text("Reset Info")),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkPermission(context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isIOS ||
        (Platform.isAndroid && androidInfo.version.sdkInt < 33)) {
      var status = await Permission.storage.status;
      if (status.isPermanentlyDenied) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text(
                    "ERROR!",
                    style: TextStyle(color: Colors.red),
                  ),
                  content: const Text("Please provide storage permission"),
                  backgroundColor: Colors.black,
                  icon: const Icon(
                    Icons.error_outline_outlined,
                    color: Colors.red,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          openAppSettings();
                        },
                        child: const Text("Open setting")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("OK"))
                  ],
                ));

        return false;
      }

      if (status.isDenied) {
        if (await Permission.storage.request().isGranted) {
          return true;
        }
        showDialog(
            context: context,
            builder: (context) =>
                errorDialog(context, "Please provide storage permission"));
        return false;
      }
      return true;
    } else {
      // var status = await Permission.manageExternalStorage.status;
      // if (status.isPermanentlyDenied) {
      //   showDialog(
      //       context: context,
      //       builder: (context) => AlertDialog(
      //             title: const Text(
      //               "ERROR!",
      //               style: TextStyle(color: Colors.red),
      //             ),
      //             content: const Text("Please provide storage permission"),
      //             backgroundColor: Colors.black,
      //             icon: const Icon(
      //               Icons.error_outline_outlined,
      //               color: Colors.red,
      //             ),
      //             actions: [
      //               TextButton(
      //                   onPressed: () {
      //                     openAppSettings();
      //                   },
      //                   child: const Text("Open setting")),
      //               TextButton(
      //                   onPressed: () {
      //                     Navigator.of(context).pop();
      //                   },
      //                   child: const Text("OK"))
      //             ],
      //           ));
      //   return false;
      // }

      // if (status.isDenied) {
      //   if (await Permission.manageExternalStorage.request().isGranted &&
      //       await Permission.accessMediaLocation.request().isGranted &&
      //       await Permission.storage.request().isGranted) {
      //     return true;
      //   }
      //   showDialog(
      //       context: context,
      //       builder: (context) =>
      //           errorDialog(context, "Please provide storage permission"));
      //   return false;
      // }
      return true;
    }
  }
}
