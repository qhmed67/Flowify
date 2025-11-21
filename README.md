# Flowchart Designer 🎨

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)

A powerful, standalone Flutter application that generates interactive flowcharts from code snippets and programming questions using **DeepSeek R1 AI** and **Mermaid.js**.

Built with native Flutter rendering (no WebViews!) for high performance and a smooth user experience.

## ✨ Features

- **🤖 AI-Powered Generation:** Instantly converts code or logic problems into visual flowcharts.
- **⚡ Native Rendering:** Uses `graphview` for native Flutter rendering, ensuring crisp graphics and smooth interactions.
- **🖱️ Interactive Canvas:** Zoom, pan, and tap nodes to explore complex diagrams.
- **🧩 Smart Layout:** Intelligent routing algorithms that handle loops, branches, and complex logic without overlap.
- **🛠️ Standalone:** No backend server required! The app communicates directly with the OpenRouter API.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0.0 or higher)
- An [OpenRouter API Key](https://openrouter.ai/keys) (for DeepSeek R1 access)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/qhmed67/Flowify.git
    cd Flowify
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure API Key:**
    Create a file named `api_config.dart` in `lib/config/` (if it doesn't exist) or update the existing one.
    *Note: `lib/config/api_config.dart` is git-ignored for security.*

    ```dart
    // lib/config/api_config.dart
    class ApiConfig {
      static const String openRouterApiKey = 'YOUR_OPENROUTER_API_KEY';
      static const String siteUrl = 'https://your-site-url.com'; // Optional
      static const String siteName = 'Flowchart Designer'; // Optional
      static const String model = 'deepseek/deepseek-r1:free';
    }
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 📖 Usage

1.  **Launch the app.**
2.  **Enter your prompt:** Type a programming question (e.g., "Check if a number is prime") or paste a code snippet.
3.  **Generate:** Tap the "Generate Flowchart" button.
4.  **Interact:**
    - **Zoom/Pan:** Use two fingers to zoom and drag to pan.
    - **Refresh:** Tap the refresh button to clear and start over.

## 📂 Project Structure

```
lib/
├── config/          # App configuration (API keys, constants)
├── models/          # Data models (FlowchartJson, Node, Edge)
├── services/        # API services (OpenRouter integration)
├── utils/           # Helper functions (JSON parsing)
├── widgets/         # UI Components
│   ├── graph_flowchart_viewer.dart  # Main flowchart rendering engine
│   ├── loading_screen.dart          # Animated loading state
│   └── ...
└── main.dart        # App entry point
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the project
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
