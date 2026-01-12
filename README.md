# F4TURE - Futuristic Collaboration App

**F4TURE** is a modern, high-performance Flutter application designed for seamless collaboration. It features a stunning futuristic UI with neon aesthetics, glassmorphism, and dynamic backgrounds, integrated with robust task management and real-time chat capabilities.

## 🚀 Key Features

*   **Futuristic UI/UX**:
    *   **Immersive Home**: Video backgrounds, neon glow effects, and interactive elements.
    *   **Glassmorphism**: Floating navigation bars and translucent overlays.
    *   **Animations**: Smooth transitions and dynamic visual feedback.
*   **Super Home Dashboard**:
    *   **Unified Hub**: Centralized access to Chats, Tasks, and Settings.
    *   **Custom Navigation**: "Glass" floating pill navbar.
*   **Real-time Chat**:
    *   **Group Messaging**: Create and manage groups (Public/Private/Committee).
    *   **Multimedia Support**: Send text, images, and files.
    *   **Integration**: Seamlessly create tasks and issues directly from chats.
*   **Task & Issue Management**:
    *   **Committee Tools**: specialized tools for committee groups to track tasks and report issues.
    *   **Status Tracking**: Real-time updates on task progress.
*   **Authentication**:
    *   Secure phone number login via Firebase.

## 📂 Project Structure

This project follows the **GetX** pattern for scalable and maintainable code.

```
lib/
├── app/
│   ├── modules/            # Feature-based modules (View-Controller-Binding)
│   │   ├── authentication/ # Login & Setup
│   │   ├── chat/           # Chat logic, Group details
│   │   ├── home/           # Landing page (Futuristic UI)
│   │   ├── super_home/     # Main Dashboard (Tabs container)
│   │   └── user_profile/   # User Profile display & edits
│   ├── global_tasks_controller.dart # Shared logic
│   ├── data/               # Models, Services, Providers
│   ├── core/               # Constants, Themes, Utilities
│   └── routes/             # App navigation definitions
└── main.dart               # Entry point
```

## 🛠️ Setup & Running

### Prerequisites
*   Flutter SDK installed.
*   Android Studio / VS Code.
*   Firebase project configured.

### Running the App
1.  **Get Dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Run**:
    ```bash
    flutter run
    ```

### Creating New Pages
We use the `get_cli` tool to generate boilerplate code efficiently.

To create a new page (Module + Controller + View + Binding + Route):
```bash
get create page <page_name>
```
*Example:* `get create page dashboard`

## 🔐 Test Credentials

Use the following test accounts to log in and explore the app:

| Phone Number | OTP | Role |
| :--- | :--- | :--- |
| **91111111111** | `111111` | Admin / User |
| **9999999999** | `111111` | User |
