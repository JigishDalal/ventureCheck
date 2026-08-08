# VentureCheck: AI Startup Validation

![VentureCheck Banner](https://img.shields.io/badge/VentureCheck-AI%20Startup%20Validation-00C4B4?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**Stop Guessing. Start Building Validated Ideas.**

VentureCheck is a powerful Flutter application that leverages AI to validate startup ideas instantly. From a simple voice or text prompt, VentureCheck generates a comprehensive, data-driven business report complete with SWOT analysis, competitor research, market size estimation, and an instant full-stack code prompt for your MVP.

---

## 🌟 Key Features

### 🎙️ Effortless Idea Entry
*   **Voice-to-Text Support:** Describe your startup concept naturally using the integrated microphone feature.
*   **Smart Suggestions:** Not sure where to start? Pick from popular AI-generated startup templates.
*   **Sleek Interface:** Premium glassmorphism design for a distraction-free idea capture experience.

### 🧠 Instant AI Analysis
*   **Deep Dive Validation:** The AI deconstructs your idea, audits the market for direct competitors, analyzes pricing models, and generates strategic recommendations.
*   **Dynamic Loading:** Transparent checklist showing exactly what the AI is analyzing in real-time.

### 📊 Comprehensive Reports
*   **Strategic Insights:** Instant SWOT analysis highlighting Strengths, Weaknesses, Opportunities, and Threats.
*   **Competitor Landscape:** Understand competitive risks and opportunities.
*   **Scoring System:** Visual circular scores (out of 100) indicating the viability and priority of your idea (Proceed vs. Pivot).
*   **Export & Share:** Export beautifully styled PDF documents or copy the Markdown report to share with your team.

### 💻 Pro Feature: MVP Generator Prompt
*   **Build Your MVP in Minutes:** Generates a complete, structured full-stack code prompt tailored to your idea.
*   **AI Coding Assistant Ready:** Copy and paste the generated prompt directly into AI coding assistants (like Cursor, Claude, Antigravity) to start building your MVP immediately.

### 📁 Validation Portfolio
*   **History Dashboard:** Keep track of all your validated ideas in one organized dashboard.
*   **Quick Glances:** View high-level tags (Market View, Priority, Category) for past ideas at a glance.

---

## 📸 Screenshots & Marketing

*Use these contexts to generate images or understand the app flow:*

1.  **Splash Screen:** Premium launch experience with animated progress bar and glowing ambient background.
2.  **Dashboard:** Organized validation history with swipe-to-delete and visual scoring.
3.  **Report Detail:** Multi-tab interface featuring Overview, SWOT, Competitors, Customer Feedback, Launch Strategy, and the PRO MVP Prompt.
4.  **Settings:** Secure, on-device configuration for your Gemini API key.

---

## 🛠️ Tech Stack & Architecture

*   **Framework:** Flutter (Dart)
*   **State Management:** BLoC (Business Logic Component) pattern for predictable state transitions (e.g., `ValidationBloc`, `HistoryBloc`).
*   **AI Integration:** Powered by the Google Gemini API for deep natural language processing and report generation.
*   **Local Storage:** Secure, on-device storage for your API key and validation history.
*   **UI/UX:** Custom theme (`AppTheme`) implementing modern glassmorphism, rich gradients, and micro-animations.
*   **PDF Generation:** Uses `printing` and `pdf` packages for generating exportable reports.

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK installed ([Setup Guide](https://docs.flutter.dev/get-started/install))
*   A free **Google Gemini API Key** (Get one from [Google AI Studio](https://aistudio.google.com/))

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/projectthink.git
    cd projectthink
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the app**
    ```bash
    flutter run
    ```

4.  **Configure API Key**
    *   Launch the app.
    *   Tap the **Settings (Gear Icon)** in the top right of the dashboard.
    *   Paste your Gemini API key and tap **Save Changes**.

---

## 🛡️ Privacy & Security

Your API key and validation history are stored **locally on your device**. VentureCheck does not send your startup ideas or API keys to any third-party servers other than Google's Gemini API for processing.

---

*Built with Flutter. Design inspired by modern, premium AI tools.*
