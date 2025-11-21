import '../models/flowchart_node.dart';
import '../models/flowchart_edge.dart';

/// Helper class to build flowcharts programmatically
class FlowchartBuilder {
  /// Builds the example flowchart from the user's specification
  static FlowchartData buildExampleFlowchart() {
    final nodes = [
      FlowchartNode(id: 'A', label: 'Start', type: NodeType.start),
      FlowchartNode(id: 'B', label: 'Initialize sum = 0', type: NodeType.process),
      FlowchartNode(id: 'C', label: 'Initialize counter = 1', type: NodeType.process),
      FlowchartNode(id: 'D', label: 'Is counter <= 5?', type: NodeType.decision),
      FlowchartNode(id: 'E', label: 'Input number', type: NodeType.io),
      FlowchartNode(id: 'F', label: 'Add number to sum', type: NodeType.process),
      FlowchartNode(id: 'G', label: 'Increment counter', type: NodeType.process),
      FlowchartNode(id: 'H', label: 'Print sum', type: NodeType.io),
      FlowchartNode(id: 'I', label: 'End', type: NodeType.end),
    ];

    final edges = [
      FlowchartEdge(from: 'A', to: 'B'),
      FlowchartEdge(from: 'B', to: 'C'),
      FlowchartEdge(from: 'C', to: 'D'),
      FlowchartEdge(from: 'D', to: 'E', label: 'Yes'),
      FlowchartEdge(from: 'E', to: 'F'),
      FlowchartEdge(from: 'F', to: 'G'),
      FlowchartEdge(from: 'G', to: 'D'),
      FlowchartEdge(from: 'D', to: 'H', label: 'No'),
      FlowchartEdge(from: 'H', to: 'I'),
    ];

    return FlowchartData(nodes: nodes, edges: edges);
  }
}

class FlowchartData {
  final List<FlowchartNode> nodes;
  final List<FlowchartEdge> edges;

  FlowchartData({
    required this.nodes,
    required this.edges,
  });
}

