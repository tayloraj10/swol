import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class ProgressionsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  const ProgressionsDialog({super.key, required this.dataList});

  @override
  State<ProgressionsDialog> createState() => _ProgressionsDialogState();
}

class _ProgressionsDialogState extends State<ProgressionsDialog> {
  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Scaffold(
            body: Center(
              child: Stack(
                children: [
                  InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.01,
                    maxScale: 5.6,
                    child: GraphView(
                      graph: graph,
                      algorithm: BuchheimWalkerAlgorithm(
                          builder, TreeEdgeRenderer(builder)),
                      paint: Paint()
                        ..color = Colors.green
                        ..strokeWidth = 1
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        var a = node.key?.value as String;
                        return rectangleWidget(a);
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget rectangleWidget(String a) {
    return InkWell(
      onTap: () {
        // print('clicked');
      },
      child: a != 'Base'
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Colors.blue, spreadRadius: 1),
                ],
              ),
              child: Text(a.split('_')[0]))
          : Container(),
    );
  }

  createNodes(List<Map<String, dynamic>> dataList) {
    // final node1 = Node.Id('1');
    // final node2 = Node.Id('2');
    // final node3 = Node.Id('German Hang');
    // final node4 = Node.Id('Tuck Back Lever');

    List<Node> nodes = [Node.Id('Base')];
    // graph.addEdge(node1, node2, paint: Paint()..color = Colors.blue);
    // graph.addEdge(node3, node3, paint: Paint()..color = Colors.transparent);
    // graph.addEdge(node3, node4, paint: Paint()..color = Colors.blue);

    //make nodes
    for (var data in dataList) {
      var newNode = Node.Id(data['name'] + '_' + data['id']);
      nodes.add(newNode);
      var node = nodes
          .firstWhere((n) => n.key?.value == data['name'] + '_' + data['id']);
      // print(node);
      if (data['base_exercise'] != null) {
        graph.addEdge(nodes[0], node,
            paint: Paint()..color = Colors.transparent);
      }
    }
    //make edges
    for (var data in dataList) {
      if (data['next_progressions'] != null) {
        var node = nodes
            .firstWhere((n) => n.key?.value == data['name'] + '_' + data['id']);
        for (var next in data['next_progressions']) {
          var connectionNode =
              nodes.firstWhere((n) => n.key?.value.contains(next));
          // print(node);
          // print(connectionNode);
          graph.addEdge(node, connectionNode,
              paint: Paint()..color = Colors.blue);
        }
      }
    }
    // print(nodes);
  }

  @override
  void initState() {
    super.initState();
    createNodes(widget.dataList);
    // final node1 = Node.Id('1');
    // final node1_5 = Node.Id('20');
    // final node2 = Node.Id('2');
    // final node3 = Node.Id('3');
    // final node4 = Node.Id('4');
    // final node5 = Node.Id('5');
    // final node6 = Node.Id('6');
    // final node8 = Node.Id('7');
    // final node7 = Node.Id('8');
    // final node9 = Node.Id('9');
    // final node10 = Node.Id('10');
    // final node11 = Node.Id('11');
    // final node12 = Node.Id('12');

    // graph.addEdge(node1_5, node1_5, paint: Paint()..color = Colors.transparent);
    // graph.addEdge(node1, node2, paint: Paint()..color = Colors.blue);
    // graph.addEdge(node1, node3);
    // graph.addEdge(node1, node4);
    // graph.addEdge(node2, node5);
    // graph.addEdge(node2, node6);
    // graph.addEdge(node6, node7);
    // graph.addEdge(node6, node8);
    // graph.addEdge(node4, node9);
    // graph.addEdge(node4, node10);
    // graph.addEdge(node4, node11);
    // graph.addEdge(node11, node12);
    // graph.addEdge(node1_5, node2, paint: Paint()..color = Colors.blue);

    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (50)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}
