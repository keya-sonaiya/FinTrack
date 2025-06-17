# 💰 FinTrack - Personal Finance Tracker App

FinTrack is a cross-platform personal finance tracker app built using **Flutter** and **Supabase**. It allows users to manage income and expenses, visualize data with charts, view transaction history, and more — all in a clean and intuitive UI.

## 🚀 Features

- ✅ Sign Up / Login / Logout using Supabase Auth
- ➕ Add, Edit, Delete Transactions
- 📂 Categorized Income and Expenses
- 📊 View Statistics (Monthly, Weekly, Yearly)
- 🔍 Searchable Transaction History
- 🌗 Light and Dark Mode with Toggle
- 🧠 Smooth animations and transitions
- 👤 Profile Drawer with User Info
- 🧾 Summary Cards & Recent Transactions

## 🛠️ Tech Stack

- **Flutter** – UI framework
- **Supabase** – Backend (Database + Auth)
- **fl_chart** – Pie Charts
- **intl** – Date formatting
- **Provider / ValueNotifier** – Theme handling

## ⚙️ Installation & Setup

1. **Clone the repository**

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

2. **Install Dependencies**

Make sure you have Flutter installed. Then, run:

```bash
flutter pub get
```

3. **Supabase Configuration**

- Go to [https://supabase.com](https://supabase.com) and create a project.
- From your Supabase project dashboard, copy:
  - **Project URL**
  - **anon/public API key**

- Then, open `main.dart` and update:

```dart
await Supabase.initialize(
  url: 'https://your-project-id.supabase.co',
  anonKey: 'your-anon-key',
);
```
4. **Create Supabase Tables**

5. **Run the App**

Make sure an emulator or device is connected, then:

```bash
flutter run
```

