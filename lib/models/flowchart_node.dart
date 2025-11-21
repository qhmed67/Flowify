class FlowchartNode {
  final String id;
  final String label;
  final NodeType type;
  final double? x;
  final double? y;
  final double? width;
  final double? height;

  FlowchartNode({
    required this.id,
    required this.label,
    required this.type,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  factory FlowchartNode.fromMermaid(String nodeId, String nodeText, NodeType type) {
    return FlowchartNode(
      id: nodeId,
      label: nodeText,
      type: type,
    );
  }
}

enum NodeType {
  start,      // ([Start]) - Rounded rectangle
  process,    // [Process] - Rectangle
  decision,   // {Decision} - Diamond
  end,        // ([End]) - Rounded rectangle
  io,         // Input/Output - Parallelogram (represented as rectangle for now)
}

