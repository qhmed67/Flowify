/// Structured JSON model for flowchart data from DeepSeek (Logic Only)
class FlowchartJson {
  final List<FlowchartJsonNode> nodes;
  final List<FlowchartJsonConnection> edges;

  FlowchartJson({
    required this.nodes,
    required this.edges,
  });

  factory FlowchartJson.fromJson(Map<String, dynamic> json) {
    return FlowchartJson(
      nodes: (json['nodes'] as List<dynamic>?)
              ?.map((node) => FlowchartJsonNode.fromJson(node as Map<String, dynamic>))
              .toList() ??
          [],
      edges: (json['edges'] as List<dynamic>?)
              ?.map((conn) => FlowchartJsonConnection.fromJson(conn as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'edges': edges.map((conn) => conn.toJson()).toList(),
    };
  }
}

class FlowchartJsonNode {
  final String id;
  final String type; // start, end, process, decision, etc.
  final String label;
  final String axis; // V0, V+1, V-1, etc.

  FlowchartJsonNode({
    required this.id,
    required this.type,
    required this.label,
    this.axis = 'V0',
  });

  factory FlowchartJsonNode.fromJson(Map<String, dynamic> json) {
    return FlowchartJsonNode(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'process',
      label: json['label'] as String? ?? '',
      axis: json['axis'] as String? ?? 'V0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'axis': axis,
    };
  }
}

class FlowchartJsonConnection {
  final String from;
  final String to;
  final String direction; // vertical, horizontal

  FlowchartJsonConnection({
    required this.from,
    required this.to,
    this.direction = 'vertical',
  });

  factory FlowchartJsonConnection.fromJson(Map<String, dynamic> json) {
    return FlowchartJsonConnection(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      direction: json['direction'] as String? ?? 'vertical',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'direction': direction,
    };
  }
}
