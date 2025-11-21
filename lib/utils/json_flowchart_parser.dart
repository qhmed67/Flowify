import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/flowchart_json.dart';

/// Parser for structured JSON flowchart output from AI
///
/// Extracts flowchart structure and returns FlowchartJson model.
class JsonFlowchartParser {
  /// Parse JSON string into FlowchartJson
  ///
  /// Extracts node and connection information from AI's JSON response.
  static FlowchartJson? parseJson(String jsonString) {
    try {
      // Try to extract JSON from the response (might have markdown code blocks)
      String cleanJson = jsonString.trim();

      // Remove markdown code blocks if present
      if (cleanJson.startsWith('```')) {
        final lines = cleanJson.split('\n');
        cleanJson =
            lines.where((line) => !line.startsWith('```')).join('\n').trim();
      }

      // Remove any text before the first {
      final jsonStart = cleanJson.indexOf('{');
      if (jsonStart > 0) {
        cleanJson = cleanJson.substring(jsonStart);
      }

      // Remove any text after the last }
      final jsonEnd = cleanJson.lastIndexOf('}');
      if (jsonEnd >= 0 && jsonEnd < cleanJson.length - 1) {
        cleanJson = cleanJson.substring(0, jsonEnd + 1);
      }

      final jsonMap = json.decode(cleanJson) as Map<String, dynamic>;
      final flowchart = FlowchartJson.fromJson(jsonMap);
      return _filterEmptyNodes(flowchart);
    } catch (e) {
      debugPrint('Error parsing JSON flowchart: $e');
      return null;
    }
  }

  /// Removes nodes with empty labels and reconnects their edges
  static FlowchartJson _filterEmptyNodes(FlowchartJson flowchart) {
    var nodes = List<FlowchartJsonNode>.from(flowchart.nodes);
    var edges = List<FlowchartJsonConnection>.from(flowchart.edges);
    bool changed = true;

    // Iteratively remove empty nodes (handling chains of empty nodes)
    while (changed) {
      changed = false;
      // Identify empty nodes (excluding structural nodes like start/end/merge)
      final emptyNodes = nodes
          .where((n) =>
              n.label.trim().isEmpty &&
              !['start', 'end', 'merge'].contains(n.type.toLowerCase()))
          .toList();

      for (var node in emptyNodes) {
        // Find connections
        final incoming = edges.where((e) => e.to == node.id).toList();
        final outgoing = edges.where((e) => e.from == node.id).toList();

        // Reconnect incoming to outgoing
        for (var inEdge in incoming) {
          for (var outEdge in outgoing) {
            // Preserve edge label/direction (prioritize outgoing, then incoming)
            String direction = outEdge.direction;
            if (direction.isEmpty || direction.toLowerCase() == 'null') {
              direction = inEdge.direction;
            }

            edges.add(FlowchartJsonConnection(
              from: inEdge.from,
              to: outEdge.to,
              direction: direction,
            ));
          }
        }

        // Remove the empty node and its original connections
        nodes.remove(node);
        edges.removeWhere((e) => e.from == node.id || e.to == node.id);
        changed = true;
      }
    }

    return FlowchartJson(nodes: nodes, edges: edges);
  }
}
