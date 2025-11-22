# Flowify 🎨

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/AI-Powered-4A90E2?style=for-the-badge" alt="AI-Powered"/>
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License"/>
</div>

<div align="center">
  <h3>✨ AI-Powered Flowchart Generator</h3>
  <p>Transform your ideas, code snippets, and logic problems into beautiful, interactive flowcharts instantly</p>
</div>

---

## 🚀 Overview

**Flowify** is a powerful, mobile-first Flutter application that leverages **DeepSeek R1 AI** (via OpenRouter) to generate professional flowcharts from natural language descriptions, code snippets, or programming problems. With native Flutter rendering and intelligent layout algorithms, Flowify delivers crisp, interactive diagrams optimized for Android and iOS devices.

### 💡 Key Features

- **🤖 AI-Powered Generation**: Instantly converts natural language, code, or logic problems into visual flowcharts using state-of-the-art AI
- **⚡ Native Rendering**: Built with Flutter's custom painting API - no WebViews, no performance compromises
- **🧠 Smart Layout Engine**: Advanced vertical lane system handles complex nested structures, loops, and branches with automatic collision detection
- **🎨 Interactive Canvas**: 
  - Zoom and pan for exploring large diagrams
  - Tap nodes to inspect details
  - Smooth animations and transitions
- **🔧 Complex Structure Support**:
  - IF/ELSE statements with automatic merge nodes
  - WHILE/FOR loops with proper loop-back routing
  - Nested structures with intelligent axis management
  - Multiple data types (input, output, process, decision, merge)
- **🎯 Beautiful UI**: Modern Material Design 3 interface with animated loading screens and intuitive controls
- **🔒 Secure**: Standalone architecture - no backend server required, communicates directly with OpenRouter API
- **📱 Mobile-First**: Optimized for Android and iOS devices

---

## 🏗️ Project Structure

```
Flowify/
├── lib/
│   ├── config/
│   │   └── api_config.dart          # API configuration (requires your OpenRouter key)
│   ├── models/
│   │   ├── flowchart_json.dart      # JSON data models for flowchart structure
│   │   ├── flowchart_node.dart      # Node model definitions
│   │   └── flowchart_edge.dart      # Edge/connection model definitions
│   ├── services/
│   │   └── openrouter_service.dart  # AI service integration with DeepSeek R1
│   ├── utils/
│   │   ├── flowchart_builder.dart   # Programmatic flowchart building utilities
│   │   └── json_flowchart_parser.dart # JSON parsing and validation logic
│   ├── widgets/
│   │   ├── graph_flowchart_viewer.dart # Main flowchart rendering engine
│   │   └── loading_screen.dart      # Animated loading state widget
│   └── main.dart                    # App entry point and UI
├── android/                         # Android platform configuration
├── ios/                             # iOS platform configuration
├── assets/                          # Static assets
├── pubspec.yaml                     # Flutter dependencies
└── README.md                        # This file
```

---

## 🔥 How It Works

### 1. **User Input** → Natural Language / Code
   Users type or paste their logic description, code snippet, or programming problem into the intuitive text interface.

### 2. **AI Processing** → DeepSeek R1 Analysis
   The app sends the input to DeepSeek R1 AI via OpenRouter API. The AI analyzes the logic and generates a structured JSON representation with:
   - **Nodes**: Different types (start, end, input, output, process, if/decision, while/for, merge)
   - **Edges**: Connections between nodes with directional information
   - **Axis System**: Vertical lanes (V0, V+1, V-1, etc.) for layout positioning

### 3. **Layout Algorithm** → Intelligent Positioning
   The **LaneLayoutAlgorithm** processes the JSON:
   - Calculates hierarchical levels using longest-path algorithm
   - Resolves collisions by shifting nodes vertically
   - Positions nodes according to their axis assignments
   - Handles loop-back edges and convergence points

### 4. **Rendering** → Native Flutter Canvas
   The **GraphFlowchartViewer** renders the flowchart:
   - Custom painters for different node shapes (rectangles, diamonds, hexagons, parallelograms, circles)
   - Orthogonal edge routing with intelligent pathfinding
   - Interactive gestures for zoom, pan, and exploration
   - Real-time layout adjustments for optimal visualization

### 5. **User Interaction** → Explore & Inspect
   Users can:
   - Zoom in/out and pan around the canvas
   - View raw JSON data for debugging
   - Export or share flowcharts
   - Generate new flowcharts from the main screen

---

## 🎯 Core Technologies & Power

### **AI Engine: DeepSeek R1**
- Advanced reasoning capabilities for complex logic analysis
- Structured JSON output following strict formatting rules
- Support for nested conditions, loops, and multi-branch logic
- Handles edge cases like merge nodes, convergence points, and loop-backs

### **Layout System: Vertical Lane Algorithm**
- **Dynamic Lane Width**: Adjusts based on nesting depth
- **Collision Detection**: Automatically resolves overlapping nodes
- **Longest-Path Algorithm**: Ensures proper dependency ordering
- **Axis Management**: V0 (center), V+1 (right), V-1 (left) for branching

### **Rendering Engine: Custom Flutter Painters**
- **Node Shapes**: 
  - Pills (start/end)
  - Parallelograms (input/output)
  - Rectangles (process/assignment)
  - Diamonds (IF/decision) - dynamically sized
  - Hexagons (WHILE/FOR loops)
  - Circles (merge nodes)
- **Edge Routing**: Orthogonal paths with intelligent arrow placement
- **Interactive View**: Transformation controller for zoom/pan
- **Performance**: 60 FPS rendering even with complex diagrams

### **Architecture: Standalone & Secure**
- No backend server required
- Direct API communication with OpenRouter
- Local processing and rendering
- Configurable timeout (up to 3 minutes for complex logic)

---

## 📦 Installation & Setup

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- An [OpenRouter API Key](https://openrouter.ai/keys) (free tier available)

### Step-by-Step Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/qhmed67/Flowify.git
   cd Flowify
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Key:**
   
   Create or edit `lib/config/api_config.dart`:
   ```dart
   class ApiConfig {
     // Get your API key from: https://openrouter.ai/keys
     static const String openRouterApiKey = 'YOUR_OPENROUTER_API_KEY_HERE';
     
     static const String openRouterApiUrl = 
         'https://openrouter.ai/api/v1/chat/completions';
     
     // Recommended models (free tier):
     // - "deepseek/deepseek-chat" (FREE, recommended)
     // - "deepseek/deepseek-r1:free" (FREE, rate-limited)
     // - "google/gemini-flash-1.5" (FREE alternative)
     static const String model = 'deepseek/deepseek-r1:free';
     
     static const int requestTimeout = 180; // 3 minutes
     static const int maxTokens = 1000;
   }
   ```

   ⚠️ **Security Note**: Never commit your API key to version control. The `api_config.dart` file is already in `.gitignore`.

4. **Run the app:**
   ```bash
   # For Android (requires connected device/emulator)
   flutter run
   
   # For iOS (requires macOS and Xcode)
   flutter run
   
   # Specify device
   flutter devices                    # List available devices
   flutter run -d <device_id>        # Run on specific device
   ```

---

## 💻 Usage

### Basic Usage

1. **Launch Flowify**
2. **Enter your prompt** in the text field:
   - Natural language: *"Check if a number is prime"*
   - Code snippet: *"for i in range(10): print(i)"*
   - Logic problem: *"Find the maximum of three numbers"*
3. **Tap "Generate Flowchart"**
4. **Wait for AI processing** (usually 10-30 seconds)
5. **Explore the generated flowchart**:
   - **Zoom**: Pinch or use scroll wheel
   - **Pan**: Drag with mouse or touch
   - **Inspect**: Tap nodes or use the code icon to view raw JSON

### Advanced Features

- **View Raw JSON**: Tap the code icon (📄) in the flowchart viewer to see the AI-generated JSON structure
- **Generate Multiple**: Return to the main screen to create new flowcharts
- **Complex Logic**: The AI can handle nested IF statements, multiple loops, and complex branching

### Example Prompts

```
"Calculate the factorial of a number"
"Implement binary search algorithm"
"Check if a string is a palindrome"
"Sort an array using bubble sort"
"Find the greatest common divisor of two numbers"
"Determine if a year is a leap year"
```

---

## 🎨 Features Deep Dive

### **Intelligent Layout System**

The app uses a sophisticated vertical lane system:
- **V0**: Main axis (center lane) - sequential flow, condition nodes, merge points
- **V+1, V+2, ...**: Right lanes - TRUE branches, loop bodies
- **V-1, V-2, ...**: Left lanes - FALSE branches, alternative paths

This ensures:
- ✅ No overlapping nodes
- ✅ Clear visual hierarchy
- ✅ Proper branch alignment
- ✅ Readable complex structures

### **Node Type System**

| Type | Shape | Use Case |
|------|-------|----------|
| `start` | Pill (rounded) | Beginning of flowchart |
| `end` | Pill (rounded) | End of flowchart |
| `input` | Parallelogram | Data input operations |
| `output` | Parallelogram | Data output operations |
| `process` | Rectangle | Calculations, assignments |
| `if` / `decision` | Diamond | Conditional branching |
| `while` / `for` | Hexagon | Loop structures |
| `merge` | Circle | Convergence points for branches |

### **Edge Routing**

The app intelligently routes connections:
- **Orthogonal paths**: Only horizontal and vertical segments
- **Smart routing**: Avoids crossing through nodes
- **Label placement**: "True"/"False" labels on branches
- **Arrow heads**: Properly oriented at connection points
- **Loop-back handling**: Routes upward connections via side gutters

---

## 🔧 Configuration

### API Configuration (`lib/config/api_config.dart`)

```dart
class ApiConfig {
  // Your OpenRouter API key
  static const String openRouterApiKey = 'YOUR_KEY';
  
  // API endpoint
  static const String openRouterApiUrl = 
      'https://openrouter.ai/api/v1/chat/completions';
  
  // AI Model selection
  static const String model = 'deepseek/deepseek-r1:free';
  
  // Request settings
  static const int requestTimeout = 180;  // seconds
  static const int maxTokens = 1000;      // response size limit
}
```

### Layout Parameters (`lib/widgets/graph_flowchart_viewer.dart`)

You can customize the layout by modifying constants in `LaneLayoutAlgorithm`:
- `baseLaneWidth`: Horizontal spacing between lanes (default: 320px)
- `verticalSpacing`: Vertical spacing between levels (default: 140px)
- `startY`: Top margin (default: 50px)

---

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Fully Supported | Native rendering, optimized for mobile |
| iOS | ✅ Fully Supported | Native rendering, optimized for mobile |

**Note**: This app is designed specifically for mobile devices. Web, Windows, macOS, and Linux platforms are not supported.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow Flutter/Dart style guidelines
- Add comments for complex logic
- Update documentation for new features
- Test on multiple platforms if possible
- Keep commits atomic and well-described

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Ahmed Youssef

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👤 Author

**Ahmed Youssef**

- GitHub: [@qhmed67](https://github.com/qhmed67)
- Project Link: [https://github.com/qhmed67/Flowify](https://github.com/qhmed67/Flowify)

---

##  Acknowledgments

- **DeepSeek AI** for powerful reasoning capabilities
- **OpenRouter** for seamless API access
- **Flutter Team** for an amazing cross-platform framework
- **Community** for feedback and contributions

---

## 📊 Project Stats

- **Language**: Dart (Flutter)
- **Architecture**: Standalone (no backend)
- **AI Model**: DeepSeek R1
- **Rendering**: Native Flutter Custom Painters
- **Minimum Flutter Version**: 3.0.0
- **Platform Support**: Android & iOS (Mobile-first design)

---

## ⭐ Star History

If you find this project helpful, please consider giving it a ⭐ on GitHub!

---

<div align="center">
  <p>Made with ❤️ using Flutter and AI</p>
  <p>Transform ideas into flowcharts, instantly</p>
</div>
