# 🌍 Real English - Mobile Client

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Clean-Architecture-green?style=for-the-badge)

---

## 🌱 The Philosophy: Why We Exist

### The Broken Path
For most of us, learning English has been a source of anxiety, not joy. We spent **12 years** in school memorizing grammar rules, dissecting sentences like biology specimens, and stressing over exams.

Yet, when we try to speak, we freeze. We translate in our heads. We fear making mistakes. **The educational system treated language like a subject to be studied, not a skill to be lived.** It asked too much of your logic, and too little of your intuition.

### The Natural Miracle
Think back to how you learned your first language (Amharic, Oromiffa, Tigrinya).
*   Did you study a textbook at age two? **No.**
*   Did you take a grammar exam at age three? **No.**
*   **You simply lived.**

You listened to stories. You watched people. You guessed meaning from context. You made mistakes, and nobody graded you "F". You absorbed the patterns **unconsciously**.

### The Real English Way
**Real English** is a digital environment designed to recreate that natural, child-like state of acquisition.
*   **Stop Studying:** No textbooks. No lectures.
*   **Start Absorbing:** Interactive stories, addictive videos, and safe practice.
*   **Bloom:** We track your growth like a garden, not a report card.

---

## 📱 Core Features (MVP)

### 1. 📖 Interactive Story Trails
We replaced traditional tests with **Playful Narratives**.
*   **The Concept:** Users play through animated stories. Instead of answering grammar questions, they make contextual choices (e.g., *Choosing "sunglasses" over "umbrella" on a sunny day*) to advance the plot.
*   **The Tech:** Dynamic JSON-based graph engine, pre-cached assets for smooth storytelling.

### 2. 🎬 Immersion Feed (Shorts)
We replaced lectures with **Addiction**.
*   **The Concept:** A TikTok-style vertical video feed. 15-60 second clips covering slang, culture, and vocabulary with dual-language subtitles.
*   **The Tech:** `preload_page_view` for infinite scrolling, optimized video caching, and overlay UI that respects navigation.

### 3. 🌻 My Growth Garden
We replaced grades with **Nature**.
*   **The Concept:** A visual profile where progress is a blooming tree. Streaks are "Sunlight," lessons are "Water."
*   **The Tech:** Custom Shimmer loaders, gamification logic, and organic UI themes.

---

## 🏗️ Architecture

The app follows **Clean Architecture** combined with a **Feature-First** directory structure. This ensures scalability, testability, and separation of concerns.

### **Folder Structure**
```bash
lib/
├── app/                 # Global App Config (Theme, Routes, Injection)
├── core/                # Shared logic (Network, Failures, UseCase Interface)
├── features/
│   ├── auth/            # Sign In, Sign Up (Organic UI)
│   ├── story_trails/    # The Interactive Story Engine
│   ├── daily_immersion/ # The Video Feed Logic
│   └── profile/         # User Growth & Garden
└── main.dart            # Entry Point
