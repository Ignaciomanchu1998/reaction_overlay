import 'package:flutter/material.dart';
import 'package:reaction_overlay/reaction_overlay.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reaction Overlay',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Reaction Overlay')),
        body: const _Items(),
      ),
    );
  }
}

class _Items extends StatelessWidget {
  const _Items();

  @override
  Widget build(BuildContext context) {
    final Map<int, GlobalKey> itemsKeys = {};

    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        itemsKeys[index] = GlobalKey();
        return ListTile(
          key: itemsKeys[index],
          title: Text('Item $index'),
          onTap: () => AppReactionOverlayManager().showReactionOverlay(
            context: context,
            itemKey: itemsKeys,
            itemId: index,
            buttons: [
              IconButton(
                icon: const Text("👍", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You liked this item.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("❤️", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You loved this item.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("😂", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You laughed at this item.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("😮", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You were surprised.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("😡", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You hated this item.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("👎", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You disliked this item.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("😡", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You hated this item.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("😡", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You hated this item.')),
                  );
                },
              ),
              IconButton(
                icon: const Text("😡", style: TextStyle(fontSize: 24)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You hated this item.')),
                  );
              })
            ],
          ),
        );
      },
    );
  }
}
