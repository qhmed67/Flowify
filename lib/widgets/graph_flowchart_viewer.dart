import 'package:flutter/material.dart';
import '../models/flowchart_json.dart';

class GraphFlowchartViewer extends StatefulWidget {
  final FlowchartJson flowchartData;

  const GraphFlowchartViewer({super.key, required this.flowchartData});

  @override
  _GraphFlowchartViewerState createState() => _GraphFlowchartViewerState();
}

class _GraphFlowchartViewerState extends State<GraphFlowchartViewer> {
  final Map<String, Offset> _nodePositions = {};
  final Map<String, FlowchartJsonNode> _nodeMap = {};
  Size _canvasSize = Size.zero;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    // Build node map for easy lookup
    for (var node in widget.flowchartData.nodes) {
      _nodeMap[node.id] = node;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnStartNode();
    });
  }

  void _centerOnStartNode() {
    if (widget.flowchartData.nodes.isEmpty) return;
    final startNode = widget.flowchartData.nodes.firstWhere(
      (n) => n.type.toLowerCase() == 'start',
      orElse: () => widget.flowchartData.nodes.first,
    );

    // Ensure layout is calculated before trying to center
    final algorithm = LaneLayoutAlgorithm(widget.flowchartData);
    final layout = algorithm.run();
    _nodePositions.addAll(layout.positions);
    _canvasSize = layout.size;

    final Offset? startNodeCenter = _nodePositions[startNode.id];

    if (startNodeCenter == null) return;

    // Center the viewport
    final viewport = MediaQuery.of(context).size;
    _transformationController.value = Matrix4.identity()
      ..translate(
        -startNodeCenter.dx + viewport.width / 2,
        -startNodeCenter.dy + viewport.height / 2,
      );
    setState(() {});
  }

  void _showRawJsonDialog(BuildContext context) {
    // Convert flowchart data to pretty JSON string
    final jsonData = widget.flowchartData.toJson();

    // Format nodes
    String nodesStr = 'NODES:\n';
    for (var node in widget.flowchartData.nodes) {
      nodesStr +=
          '  {id: "${node.id}", type: "${node.type}", label: "${node.label}", axis: "${node.axis}"}\n';
    }

    // Format edges
    String edgesStr = '\nEDGES:\n';
    for (var edge in widget.flowchartData.edges) {
      edgesStr +=
          '  {from: "${edge.from}", to: "${edge.to}", direction: "${edge.direction}"}\n';
    }

    // Count IF nodes and their outgoing edges
    String analysisStr = '\nANALYSIS:\n';
    for (var node in widget.flowchartData.nodes) {
      if (node.type.toLowerCase() == 'if' ||
          node.type.toLowerCase() == 'decision') {
        final outgoingEdges =
            widget.flowchartData.edges.where((e) => e.from == node.id).toList();
        analysisStr += '  IF "${node.id}" (${node.label}) on ${node.axis}:\n';
        analysisStr += '    - Outgoing edges: ${outgoingEdges.length}\n';
        for (var edge in outgoingEdges) {
          final targetNode =
              widget.flowchartData.nodes.firstWhere((n) => n.id == edge.to);
          analysisStr +=
              '      → "${edge.to}" (${targetNode.type}) on ${targetNode.axis}\n';
        }
        if (outgoingEdges.length != 2) {
          analysisStr +=
              '    ⚠️ WARNING: IF should have 2 edges, but has ${outgoingEdges.length}!\n';
        }
      }
    }

    final fullText = nodesStr + edgesStr + analysisStr;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raw JSON from AI'),
        content: SingleChildScrollView(
          child: SelectableText(
            fullText,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final algorithm = LaneLayoutAlgorithm(widget.flowchartData);
    final layout = algorithm.run();
    _nodePositions.addAll(layout.positions);
    _canvasSize = layout.size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flowchart Viewer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Show Raw JSON',
            onPressed: () {
              _showRawJsonDialog(context);
            },
          ),
        ],
      ),
      body: InteractiveViewer(
        constrained: false,
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(500),
        minScale: 0.1,
        maxScale: 4.0,
        child: SizedBox(
          width: _canvasSize.width,
          height: _canvasSize.height,
          child: Stack(
            children: [
              // Layer 1: Edges
              CustomPaint(
                size: _canvasSize,
                painter: OrthogonalEdgePainter(
                  edges: widget.flowchartData.edges,
                  nodePositions: _nodePositions,
                  nodeMap: _nodeMap,
                ),
              ),
              // Layer 2: Nodes
              ...widget.flowchartData.nodes.map((node) {
                final pos = _nodePositions[node.id] ?? Offset.zero;
                double width = 150;
                double height = 60;
                if (node.type.toLowerCase() == 'if' ||
                    node.type.toLowerCase() == 'decision') {
                  // Dynamic width based on text length
                  final textLength = node.label.length;
                  width = (textLength * 8.0)
                      .clamp(200.0, 400.0); // Min 200, max 400
                  height = 100;
                } else if (node.type.toLowerCase() == 'while' ||
                    node.type.toLowerCase() == 'for') {
                  width = 180;
                  height = 60;
                } else if (node.type.toLowerCase() == 'merge') {
                  width = 20; // Small circle
                  height = 20;
                }

                return Positioned(
                  left: pos.dx - width / 2,
                  top: pos.dy - height / 2,
                  width: width,
                  height: height,
                  child: Center(child: _buildNodeWidget(node)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeWidget(FlowchartJsonNode node) {
    // Fix: Don't render empty nodes (often created by layout artifacts)
    if (node.label.trim().isEmpty && node.type.toLowerCase() != 'merge') {
      return const SizedBox.shrink();
    }

    switch (node.type.toLowerCase()) {
      case 'start':
      case 'end':
        return _buildPillNode(
            node, const Color(0xFFE1D5E7), const Color(0xFF9673A6));
      case 'input':
      case 'output':
        return _buildParallelogramNode(
            node, const Color(0xFFD5E8D4), const Color(0xFF82B366));
      case 'process':
      case 'assignment':
      case 'statement':
      case 'variable_declaration':
        return _buildRectangleNode(
            node, const Color(0xFFFFF2CC), const Color(0xFFD6B656));
      case 'if':
      case 'decision':
        return _buildDiamondNode(
            node, const Color(0xFFFFE6CC), const Color(0xFFD79B00));
      case 'while':
      case 'for':
        return _buildHexagonNode(
            node, const Color(0xFFFFE6CC), const Color(0xFFD79B00));
      case 'merge':
        return _buildMergeNode();
      default:
        return _buildRectangleNode(node, Colors.white, Colors.black);
    }
  }

  Widget _buildPillNode(
      FlowchartJsonNode node, Color color, Color borderColor) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Text(node.label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }

  Widget _buildRectangleNode(
      FlowchartJsonNode node, Color color, Color borderColor) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Text(node.label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 14)),
      ),
    );
  }

  Widget _buildParallelogramNode(
      FlowchartJsonNode node, Color color, Color borderColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform(
          transform: Matrix4.skewX(-0.3),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor, width: 2),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(node.label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildDiamondNode(
      FlowchartJsonNode node, Color color, Color borderColor) {
    // Calculate dynamic size based on text
    final textLength = node.label.length;
    final containerWidth = (textLength * 8.0).clamp(200.0, 400.0);
    final rotatedSquareSize = (containerWidth * 0.5).clamp(70.0, 140.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: 0.785398, // 45 degrees
          child: Container(
            width: rotatedSquareSize,
            height: rotatedSquareSize,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor, width: 2),
            ),
          ),
        ),
        SizedBox(
          width: containerWidth * 0.85, // 85% of container for text
          child: Center(
            child: Text(node.label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMergeNode() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFB6C1), // Light pink/red like in the examples
        border: Border.all(color: const Color(0xFFFF69B4), width: 2),
      ),
    );
  }

  Widget _buildHexagonNode(
      FlowchartJsonNode node, Color color, Color borderColor) {
    return CustomPaint(
      painter: HexagonPainter(color: color, borderColor: borderColor),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Text(node.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 14)),
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  HexagonPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(20, 0);
    path.lineTo(size.width - 20, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 20, size.height);
    path.lineTo(20, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LayoutResult {
  final Map<String, Offset> positions;
  final Size size;
  LayoutResult(this.positions, this.size);
}

class LaneLayoutAlgorithm {
  final FlowchartJson flowchartData;

  LaneLayoutAlgorithm(this.flowchartData);

  LayoutResult run() {
    final positions = <String, Offset>{};

    const double baseLaneWidth = 320.0; // Increased for nested structures
    const double verticalSpacing = 140.0; // Increased to prevent overlap

    // Calculate dynamic lane width based on maximum nesting depth
    int maxNestingDepth = 0;
    for (var node in flowchartData.nodes) {
      if (node.axis.startsWith('V')) {
        final axisValue = node.axis.substring(1);
        if (axisValue.isNotEmpty && axisValue != '0') {
          final offset = (int.tryParse(axisValue) ?? 0).abs();
          if (offset > maxNestingDepth) maxNestingDepth = offset;
        }
      }
    }

    // Use wider lanes for deeper nesting
    final laneWidth = baseLaneWidth + (maxNestingDepth > 2 ? 40.0 : 0.0);
    const double startY = 50.0;

    var startNode = flowchartData.nodes.firstWhere(
        (n) => n.type.toLowerCase() == 'start',
        orElse: () => flowchartData.nodes.first);

    Map<String, int> levels = {};
    List<String> queue = [startNode.id];
    levels[startNode.id] = 0;

    int maxLevel = 0;

    while (queue.isNotEmpty) {
      String currentId = queue.removeAt(0);
      int currentLevel = levels[currentId]!;
      if (currentLevel > maxLevel) maxLevel = currentLevel;

      var outgoing = flowchartData.edges.where((e) => e.from == currentId);
      for (var edge in outgoing) {
        if (!levels.containsKey(edge.to)) {
          levels[edge.to] = currentLevel + 1;
          queue.add(edge.to);
        }
      }
    }

    // CRITICAL FIX: Ensure all nodes respect their dependencies (longest path)
    // BFS gives us shortest path, but we need longest path for proper positioning
    // Note: Loop-back edges create cycles, so we need a safety limit
    bool changed = true;
    int iterations = 0;
    final maxIterations = flowchartData.nodes.length * 2; // Safety limit

    while (changed && iterations < maxIterations) {
      changed = false;
      iterations++;

      for (var edge in flowchartData.edges) {
        if (levels.containsKey(edge.from) && levels.containsKey(edge.to)) {
          final fromLevel = levels[edge.from]!;
          final toLevel = levels[edge.to]!;

          // Skip loop-back edges (where target is above source)
          if (toLevel < fromLevel - 1) continue;

          // Ensure "to" node is at least one level below "from" node
          if (toLevel <= fromLevel) {
            levels[edge.to] = fromLevel + 1;
            changed = true;
          }
        }
      }
    }

    // CRITICAL FIX: Collision Resolution
    // Ensure no two nodes share the same (Level, Axis)
    // If collision occurs, shift one node down and propagate changes
    bool collisionFound = true;
    int collisionIterations = 0;
    final maxCollisionIterations = flowchartData.nodes.length * 2;

    while (collisionFound && collisionIterations < maxCollisionIterations) {
      collisionFound = false;
      collisionIterations++;

      // 1. Check for collisions
      final occupied = <String, String>{}; // "Level,Axis" -> NodeID

      // Sort by ID for deterministic behavior
      final sortedNodes = flowchartData.nodes.toList()
        ..sort((a, b) => a.id.compareTo(b.id));

      for (var node in sortedNodes) {
        final level = levels[node.id] ?? 0;
        final axis = node.axis;
        final key = "$level,$axis";

        if (occupied.containsKey(key)) {
          // Collision! Move this node down
          levels[node.id] = level + 1;
          collisionFound = true;
        } else {
          occupied[key] = node.id;
        }
      }

      // 2. Re-enforce dependencies (Longest Path) if shifts occurred
      if (collisionFound) {
        bool depChanged = true;
        int depIter = 0;
        while (depChanged && depIter < maxIterations) {
          depChanged = false;
          depIter++;
          for (var edge in flowchartData.edges) {
            if (levels.containsKey(edge.from) && levels.containsKey(edge.to)) {
              final fromLevel = levels[edge.from]!;
              final toLevel = levels[edge.to]!;
              // Skip loop-backs
              if (toLevel < fromLevel - 1) continue;

              if (toLevel <= fromLevel) {
                levels[edge.to] = fromLevel + 1;
                depChanged = true;
              }
            }
          }
        }
      }
    }

    // Update maxLevel after longest-path calculation
    maxLevel = 0;
    for (var level in levels.values) {
      if (level > maxLevel) maxLevel = level;
    }

    // Ensure End nodes are at the very bottom (one level below max)
    for (var node in flowchartData.nodes) {
      if (node.type.toLowerCase() == 'end') {
        // Find the max level of all nodes that connect TO this End node
        int maxPredecessorLevel = 0;
        for (var edge in flowchartData.edges) {
          if (edge.to == node.id && levels.containsKey(edge.from)) {
            final predLevel = levels[edge.from]!;
            if (predLevel > maxPredecessorLevel)
              maxPredecessorLevel = predLevel;
          }
        }
        levels[node.id] = maxPredecessorLevel + 1;
      }
    }

    double minX = 0;
    double maxX = 0;
    double maxY = 0;

    double centerX = 400.0;

    for (var node in flowchartData.nodes) {
      int level = levels[node.id] ?? 0;
      double y = startY + level * verticalSpacing;

      double x = centerX;
      // Parse axis dynamically (V0, V+1, V-1, V+2, V-2, etc.)
      if (node.axis.startsWith('V')) {
        final axisValue = node.axis.substring(1); // Remove 'V'
        if (axisValue.isNotEmpty && axisValue != '0') {
          final offset = int.tryParse(axisValue) ?? 0;
          x += offset * laneWidth;
        }
      }

      positions[node.id] = Offset(x, y);

      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    // CRITICAL FIX: Shift all positions to the right if minX is negative
    // This ensures nodes on V-2, V-3, etc. are visible
    if (minX < 0) {
      final shiftAmount = -minX + 100; // Add 100px left margin
      for (var key in positions.keys) {
        positions[key] = positions[key]! + Offset(shiftAmount, 0);
      }
      // Update bounds
      maxX += shiftAmount;
      minX = 100; // New left edge
    }

    return LayoutResult(positions, Size(maxX + 400, maxY + 200));
  }
}

class OrthogonalEdgePainter extends CustomPainter {
  final List<FlowchartJsonConnection> edges;
  final Map<String, Offset> nodePositions;
  final Map<String, FlowchartJsonNode> nodeMap;

  OrthogonalEdgePainter({
    required this.edges,
    required this.nodePositions,
    required this.nodeMap,
  });

  Size _getNodeSize(FlowchartJsonNode node) {
    if (node.type.toLowerCase() == 'if' ||
        node.type.toLowerCase() == 'decision') {
      final textLength = node.label.length;
      final width = (textLength * 8.0).clamp(200.0, 400.0);
      return Size(width, 100);
    } else if (node.type.toLowerCase() == 'while' ||
        node.type.toLowerCase() == 'for') {
      return const Size(180, 60);
    } else if (node.type.toLowerCase() == 'merge') {
      return const Size(20, 20); // Small circle
    }
    return const Size(150, 60);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    Map<String, int> incomingCounts = {};
    for (var edge in edges) {
      incomingCounts[edge.to] = (incomingCounts[edge.to] ?? 0) + 1;
    }

    for (var edge in edges) {
      final startNode = nodeMap[edge.from];
      final endNode = nodeMap[edge.to];

      if (startNode == null || endNode == null) continue;

      var startCenter = nodePositions[edge.from];
      var endCenter = nodePositions[edge.to];

      if (startCenter == null || endCenter == null) continue;

      final startNodeSize = _getNodeSize(startNode);
      final endNodeSize = _getNodeSize(endNode);

      final startTopLeft = startCenter -
          Offset(startNodeSize.width / 2, startNodeSize.height / 2);
      final endTopLeft =
          endCenter - Offset(endNodeSize.width / 2, endNodeSize.height / 2);

      bool isConvergence = (incomingCounts[edge.to] ?? 0) > 1;

      final path = Path();

      // RULE: End nodes should NEVER have outgoing arrows
      if (startNode.type.toLowerCase() == 'end') {
        continue; // Skip this edge entirely
      }

      // 1. ANY IF/DECISION -> TRUE (to right side, regardless of IF's axis)
      if ((startNode.type.toLowerCase() == 'if' ||
              startNode.type.toLowerCase() == 'decision') &&
          startCenter.dx < endCenter.dx) {
        // End is to the RIGHT
        // Calculate dynamic diamond right edge
        final rotatedSquareSize =
            (startNodeSize.width * 0.5).clamp(70.0, 140.0);
        final diamondRightEdge =
            startCenter + Offset(rotatedSquareSize * 0.707, 0);
        final p2 = endTopLeft + Offset(endNodeSize.width / 2, 0);

        path.moveTo(diamondRightEdge.dx, diamondRightEdge.dy);
        path.lineTo(p2.dx, diamondRightEdge.dy); // Horizontal RIGHT
        path.lineTo(p2.dx, p2.dy); // Vertical DOWN (FINAL)

        _drawLabel(canvas, textPainter, "True",
            diamondRightEdge + const Offset(10, -20));
      }

      // 2. ANY IF/DECISION -> FALSE (Left or Vertical)
      // Fix: Prioritize going Left -> Down -> Target. Only go straight down if very close.
      else if (startNode.type.toLowerCase() == 'if' ||
          startNode.type.toLowerCase() == 'decision') {
        // Calculate layout metrics
        final isVertical = (startCenter.dx - endCenter.dx).abs() < 40;
        final verticalDistance = endTopLeft.dy -
            (startTopLeft.dy + startNodeSize.height); // Gap between nodes
        final hasSpace = verticalDistance > 30; // Threshold for "space"

        if (isVertical && !hasSpace) {
          // NO SPACE: Go straight down (Bottom -> Top)
          final p1 = startTopLeft +
              Offset(startNodeSize.width / 2, startNodeSize.height);
          final p2 = endTopLeft + Offset(endNodeSize.width / 2, 0);

          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy);

          _drawLabel(canvas, textPainter, "False", p1 + const Offset(5, 10));
        } else {
          // HAS SPACE (or Target is Left): Go Left -> Down -> Target
          // Calculate dynamic diamond left edge
          final rotatedSquareSize =
              (startNodeSize.width * 0.5).clamp(70.0, 140.0);
          final diamondLeftEdge =
              startCenter - Offset(rotatedSquareSize * 0.707, 0);

          // Path: Left Tip -> Step Left -> Down -> Horizontal to Target X -> Down to Target Y
          final stepLeftX = diamondLeftEdge.dx - 30.0;
          final stepDownY = endTopLeft.dy - 20.0; // Just above target
          final targetX = endTopLeft.dx + endNodeSize.width / 2;

          path.moveTo(diamondLeftEdge.dx, diamondLeftEdge.dy);
          path.lineTo(stepLeftX, diamondLeftEdge.dy); // Step Left
          path.lineTo(stepLeftX, stepDownY); // Down to target level
          path.lineTo(targetX, stepDownY); // Horizontal to target X
          path.lineTo(targetX, endTopLeft.dy); // Connect to target top

          _drawLabel(canvas, textPainter, "False",
              diamondLeftEdge - const Offset(30, -20));
        }
      }
      // 3. WHILE/FOR -> TRUE (Right to Loop Body)
      else if ((startNode.type.toLowerCase() == 'while' ||
              startNode.type.toLowerCase() == 'for') &&
          startCenter.dx < endCenter.dx) {
        // End is to the RIGHT
        final p1 = startTopLeft +
            Offset(startNodeSize.width, startNodeSize.height / 2);
        final p2 = endTopLeft + Offset(endNodeSize.width / 2, 0);

        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p1.dy); // Go RIGHT to align with target X
        path.lineTo(p2.dx, p2.dy); // Go DOWN to target top (FINAL)

        _drawLabel(canvas, textPainter, "True", p1 + const Offset(10, -20));
      }
      // 5. WHILE/FOR -> FALSE (Down to Exit)
      else if ((startNode.type.toLowerCase() == 'while' ||
              startNode.type.toLowerCase() == 'for') &&
          startCenter.dy < endCenter.dy &&
          (startCenter.dx - endCenter.dx).abs() < 50) {
        final p1 = startTopLeft +
            Offset(startNodeSize.width / 2, startNodeSize.height);
        final p2 = endTopLeft + Offset(endNodeSize.width / 2, 0);

        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy); // Straight down

        _drawLabel(canvas, textPainter, "False", p1 + const Offset(5, 5));
      }
      // 6. MERGE NODE -> Any node (ensure orthogonal routing)
      else if (startNode.type.toLowerCase() == 'merge') {
        final p1 = startCenter + const Offset(0, 10); // Bottom of merge circle

        if ((startCenter.dx - endCenter.dx).abs() < 50) {
          // Target is roughly below - go straight down
          final p2 = endTopLeft + Offset(endNodeSize.width / 2, 0);
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy); // Vertical DOWN (FINAL)
        } else if (startCenter.dx < endCenter.dx) {
          // Target is to the RIGHT - go down then right
          final p2 = endTopLeft + Offset(0, endNodeSize.height / 2);
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p1.dx, p2.dy); // Vertical DOWN
          path.lineTo(p2.dx, p2.dy); // Horizontal RIGHT (FINAL)
        } else {
          // Target is to the LEFT - go down then left
          final p2 =
              endTopLeft + Offset(endNodeSize.width, endNodeSize.height / 2);
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p1.dx, p2.dy); // Vertical DOWN
          path.lineTo(p2.dx, p2.dy); // Horizontal LEFT (FINAL)
        }
      }
      // 7. LOOP BACK (from loop body back to WHILE/FOR)
      else if (startCenter.dy > endCenter.dy &&
          (startNode.axis == 'V+1' || startNode.axis.startsWith('V+')) &&
          (endNode.type.toLowerCase() == 'while' ||
              endNode.type.toLowerCase() == 'for')) {
        final p1 = startTopLeft +
            Offset(startNodeSize.width / 2, startNodeSize.height);
        final targetEntryPoint =
            endTopLeft + Offset(endNodeSize.width, endNodeSize.height / 2);

        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p1.dx, p1.dy + 20);
        path.lineTo(targetEntryPoint.dx + 20, p1.dy + 20);
        path.lineTo(targetEntryPoint.dx + 20, targetEntryPoint.dy);
        path.lineTo(targetEntryPoint.dx,
            targetEntryPoint.dy); // Final segment horizontal left
      }
      // 8. GENERIC UPWARD LOOP (e.g. Merge -> While) - Route via Left Gutter
      // Fix: Route large upward loops around the LEFT side to avoid cutting through the center
      else if (startCenter.dy > endCenter.dy + 50) {
        final p1 = startTopLeft +
            Offset(startNodeSize.width / 2, startNodeSize.height);

        // Target entry: Left side of the target node
        final targetEntryPoint = endTopLeft + Offset(0, endNodeSize.height / 2);

        // Route: Down -> Left -> Up -> Right
        final safeLeftX = 40.0; // Fixed left gutter
        final bottomTurnY = p1.dy + 20.0;

        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p1.dx, bottomTurnY); // Down
        path.lineTo(safeLeftX, bottomTurnY); // Left to gutter
        path.lineTo(safeLeftX, targetEntryPoint.dy); // Up to target level
        path.lineTo(
            targetEntryPoint.dx, targetEntryPoint.dy); // Right to target
      }
      // 6. CONVERGENCE (Multiple inputs to one node) - MUST BE ORTHOGONAL
      else if (isConvergence) {
        if (startCenter.dx > endCenter.dx) {
          // Coming from Right (V+1 to V0)
          final p1 = startTopLeft +
              Offset(startNodeSize.width / 2, startNodeSize.height);

          // Determine entry point based on end node type
          Offset targetEntryPoint;
          if (endNode.type.toLowerCase() == 'merge') {
            // For merge nodes, enter from the right side
            targetEntryPoint = endCenter +
                const Offset(10, 0); // Slightly to the right of center
          } else {
            // For other nodes, enter from top-right area
            targetEntryPoint =
                endTopLeft + Offset(endNodeSize.width, endNodeSize.height / 2);
          }

          // Perfect orthogonal path: Down, then Left
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(
              p1.dx, targetEntryPoint.dy); // Vertical DOWN to target Y-level
          path.lineTo(targetEntryPoint.dx,
              targetEntryPoint.dy); // Horizontal LEFT (FINAL)
        } else if (startCenter.dx < endCenter.dx) {
          // Coming from Left (V-1 to V0)
          final p1 = startTopLeft +
              Offset(startNodeSize.width / 2, startNodeSize.height);

          // Determine entry point
          Offset targetEntryPoint;
          if (endNode.type.toLowerCase() == 'merge') {
            // For merge nodes, enter from the left side
            targetEntryPoint = endCenter -
                const Offset(10, 0); // Slightly to the left of center
          } else {
            // For other nodes, enter from top-left area
            targetEntryPoint = endTopLeft + Offset(0, endNodeSize.height / 2);
          }

          // Perfect orthogonal path: Down, then Right
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(
              p1.dx, targetEntryPoint.dy); // Vertical DOWN to target Y-level
          path.lineTo(targetEntryPoint.dx,
              targetEntryPoint.dy); // Horizontal RIGHT (FINAL)
        } else {
          // Vertical (V0 -> V0) -> Enter Top
          final p1 = startTopLeft +
              Offset(startNodeSize.width / 2, startNodeSize.height);
          final p2 = endTopLeft + Offset(endNodeSize.width / 2, 0);
          path.moveTo(p1.dx, p1.dy);
          path.lineTo(p2.dx, p2.dy); // Vertical down (FINAL)
        }
      }
      // Default Vertical
      else {
        final p1 = startTopLeft +
            Offset(startNodeSize.width / 2, startNodeSize.height);
        final p2 = endTopLeft + Offset(endNodeSize.width / 2, 0);
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy);
      }

      canvas.drawPath(path, paint);
      _drawArrowHead(canvas, path, paint);
    }
  }

  void _drawLabel(Canvas canvas, TextPainter painter, String text, Offset pos) {
    painter.text = TextSpan(
      text: text,
      style: const TextStyle(
          color: Colors.black, fontSize: 12, backgroundColor: Colors.white),
    );
    painter.layout();
    painter.paint(canvas, pos);
  }

  void _drawArrowHead(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final lastMetric = metrics.last;

    // Get the end point
    final endTangent = lastMetric.getTangentForOffset(lastMetric.length);
    if (endTangent == null) return;
    final endPoint = endTangent.position;

    // Get a point slightly before the end to determine direction
    final beforeEndTangent =
        lastMetric.getTangentForOffset(lastMetric.length - 1);
    if (beforeEndTangent == null) return;
    final beforeEndPoint = beforeEndTangent.position;

    // Calculate the direction of the final segment
    final dx = endPoint.dx - beforeEndPoint.dx;
    final dy = endPoint.dy - beforeEndPoint.dy;

    double angle;
    if (dy.abs() > dx.abs()) {
      // Vertical arrow
      angle = dy > 0 ? 1.5708 : -1.5708; // 90 degrees down or up
    } else {
      // Horizontal arrow
      angle = dx > 0 ? 0 : 3.14159; // 0 degrees right or 180 left
    }

    canvas.save();
    canvas.translate(endPoint.dx, endPoint.dy);
    canvas.rotate(angle);

    final headPath = Path();
    headPath.moveTo(0, 0);
    headPath.lineTo(-10, -5);
    headPath.lineTo(-10, 5);
    headPath.close();

    canvas.drawPath(
        headPath,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
