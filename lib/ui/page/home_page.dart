import 'package:flutter/material.dart';
import 'package:nagn_2/ui/widget/segmented_widget.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Add file")),
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
                  child: SegmentedWidget(
                    onChangeSegment: (index) => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.bounceIn),
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
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save),
                      label: const Text("Save")),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save_as),
                      label: const Text("Save as a copy")),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
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
              child: Container(
                color: const Color.fromRGBO(210, 210, 210, 1),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_sharp,
                    color: Colors.black45,
                  ),
                ),
              ),
            ),
          ),
        )),
        const SizedBox(
          height: 15,
        ),
        OutlinedButton.icon(
            onPressed: () {},
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
      padding: EdgeInsets.only(left: 50, right: 50),
      child: SingleChildScrollView(
        child: TapRegion(
          onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Book title", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Author(s)", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: "Publisher", border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.restore),
                  label: const Text("Reset Info"))
            ],
          ),
        ),
      ),
    );
  }
}
