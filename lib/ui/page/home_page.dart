import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                child: Row(
              children: [
                Expanded(
                    child: Container(
                  color: Colors.yellow,
                )),
                Expanded(
                    child: Container(
                  color: Colors.blue,
                ))
              ],
            )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
