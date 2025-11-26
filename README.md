# 💸 SplitsPay - Smart Group Expense Manager & Travel Assistant

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Gemini](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=googlebard&logoColor=white)
![PhonePe](https://img.shields.io/badge/PhonePe-5F259F?style=for-the-badge&logo=phonepe&logoColor=white)

**A revolutionary mobile application for intelligent expense splitting, group wallet management, and AI-powered travel planning.**

*Developed by **Satvacoders** 🚀*

[Features](#-key-features) • [Demo](#-demo) • [Installation](#-installation) • [Architecture](#-architecture) • [Team](#-team)

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Technology Stack](#-technology-stack)
- [Architecture](#-architecture)
- [Installation & Setup](#-installation--setup)
- [User Guide](#-user-guide)
- [API Integration](#-api-integration)
- [Project Structure](#-project-structure)
- [Development Roadmap](#-development-roadmap)
- [Contributing](#-contributing)
- [Team](#-team)
- [License](#-license)

---

## 🌟 Overview

**SplitsPay** is a comprehensive financial management platform designed to eliminate the complexity of group expenses. Whether you're splitting a restaurant bill, managing a trip budget, or pooling money for shared expenses, SplitsPay provides intelligent, fair, and transparent solutions.

### 🎯 Problem Statement

Traditional expense splitting methods are:
- **Inaccurate**: Equal splits don't account for individual consumption
- **Time-consuming**: Manual calculations are error-prone
- **Unfair**: Children, partial consumers, and dietary restrictions aren't considered
- **Disconnected**: No integration with payment apps

### 💡 Our Solution

SplitsPay introduces **three revolutionary splitting modes**:
1. **Item-Based Split**: Assign each bill item to specific people with quantities
2. **Consumption Units**: Fair splitting based on consumption weight (adults, children, etc.)
3. **Equal Split**: Traditional equal division when appropriate

---

## ✨ Key Features

### 💰 Advanced Expense Splitting

#### 1️⃣ Item-Based Split (Recommended)
The most accurate splitting method for restaurant bills and shared purchases.

**How it works:**
1. **Add Items**: Enter each item from the bill (name, price, quantity)
2. **Assign Consumption**: For each item, select who consumed it and how many
3. **Auto-Calculate**: System calculates exact share per person
4. **Transparent Breakdown**: See exactly what each person consumed

**Example Scenario:**
```
Restaurant Bill:
├─ Pizza (₹400) × 2 = ₹800
│  ├─ Person A: 2 pizzas
│  └─ Person B: 0 pizzas
├─ Coke (₹50) × 3 = ₹150
│  ├─ Person A: 1 coke
│  ├─ Person B: 1 coke
│  └─ Person C: 1 coke

Result:
├─ Person A: ₹850 (2 pizzas + 1 coke)
├─ Person B: ₹50 (1 coke)
└─ Person C: ₹50 (1 coke)
```

#### 2️⃣ Consumption Units Split
Perfect for family dinners or mixed groups (adults + children).

**Features:**
- Quick presets: 0.5 (child), 0.7 (teen), 1.0 (adult), 1.2 (heavy eater)
- Custom units: Set any decimal value
- Fair calculation: `Cost per unit = Total / Sum of units`

#### 3️⃣ Equal Split
Simple equal division for uniform consumption scenarios.

### 💳 Seamless Payment Integration

#### QR Code Scanner
- **Auto-detect**: Scans UPI QR codes and extracts merchant details
- **Smart Amount Entry**: Prompts for amount if missing from QR
- **Multi-app Support**: Works with PhonePe, GPay, Paytm

#### Direct PhonePe Integration
- **One-tap Payment**: Opens PhonePe directly (no app chooser)
- **Deep Linking**: Passes amount and merchant details automatically
- **Fallback Support**: Gracefully handles missing apps

#### Multiple Payment Modes
- **UPI**: Full integration with PhonePe and other UPI apps
- **Card**: Record credit/debit card payments
- **Cash**: Track cash transactions

### 👥 Group Management

#### Create & Manage Groups
- **Multiple Groups**: Home, Trip, Office, Friends
- **Member Roles**: Admin, Member
- **Consumption Weights**: Set default units per member (e.g., children = 0.5)

#### Virtual Wallets
- **Pool Money**: Members add funds to group wallet
- **Real-time Balances**: Track who has contributed what
- **Low Balance Alerts**: Visual warnings for insufficient funds

### 🤖 TripBot - AI Travel Assistant

Powered by **Google Gemini 1.5 Flash**, TripBot is your intelligent travel planning companion.

#### Capabilities
1. **Budget Estimation**
   - Detailed cost breakdowns (Transport, Stay, Food, Activities)
   - Per-person and total estimates
   - Currency-aware (defaults to ₹ INR)

2. **Itinerary Planning**
   - Day-by-day schedules
   - Optimized for groups
   - Activity recommendations

3. **Expense Splitting Advice**
   - Suggests fair splitting methods
   - Handles complex scenarios (per-family vs per-head)

#### Example Queries
```
"Plan a 3-day trip to Goa for 4 people"
"Estimated cost for Manali trip?"
"Best budget hotels in Udaipur"
"How to split hotel costs for 2 families?"
```

#### Response Format
TripBot provides structured JSON-like responses:
```json
{
  "destination": "Goa",
  "duration": "3 Days",
  "estimated_total_cost": "₹8000 - ₹12000 per person",
  "breakdown": [
    {"category": "Transport", "cost": "₹2000", "details": "Flight/Train"},
    {"category": "Accommodation", "cost": "₹3000", "details": "Beach resort"},
    {"category": "Food", "cost": "₹2000", "details": "Avg ₹700/day"},
    {"category": "Activities", "cost": "₹2000", "details": "Water sports, tours"}
  ],
  "travel_tips": [
    "Book accommodations near Baga Beach for nightlife",
    "Rent scooters for local transport (₹300/day)"
  ]
}
```

---

## 🛠️ Technology Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider Pattern
- **UI Components**: Material Design 3

### Backend & Services
- **Database**: Supabase
- **AI Model**: Google Gemini 2.5 Flash
- **Authentication**: Custom Auth Service (Phone-based)

### Key Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management |
| `google_generative_ai` | ^0.4.0 | Gemini AI integration |
| `mobile_scanner` | ^3.5.5 | QR code scanning |
| `url_launcher` | ^6.2.2 | Deep linking (UPI) |
| `android_intent_plus` | ^4.0.0 | Direct app launching |
| `intl` | ^0.18.1 | Currency formatting |
| `uuid` | ^4.2.2 | Unique ID generation |

---

## 🏗️ Architecture

### Design Pattern: MVVM (Model-View-ViewModel)

```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── group_model.dart
│   ├── transaction_model.dart
│   └── bill_item_model.dart
│
├── providers/           # State management (ViewModel)
│   ├── auth_provider.dart
│   ├── group_provider.dart
│   └── navigation_provider.dart
│
├── services/            # Business logic & external APIs
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── gemini_service.dart
│
├── screens/             # UI (View)
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── payment/
│   │   ├── qr_scanner_screen.dart
│   │   ├── add_items_screen.dart
│   │   ├── assign_items_screen.dart
│   │   └── item_split_confirmation_screen.dart
│   ├── groups_screen.dart
│   ├── wallet_screen.dart
│   ├── chatbot_screen.dart
│   └── main_scaffold.dart
│
├── utils/               # Constants & helpers
│   ├── constants.dart   # Colors, spacing, text styles
│   └── helpers.dart     # Utility functions
│
└── main.dart            # Entry point
```

### Data Flow

```
User Action → Screen (View)
    ↓
Provider (ViewModel) ← notifyListeners()
    ↓
Service (Business Logic)
    ↓
Database / API
```

---

## 🚀 Installation & Setup


### Step 1: Clone the Repository

```bash
git clone https://github.com/satvacoders/splitspay.git
cd splitspay
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure API Keys

#### Gemini API Key
1. Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Open `lib/services/gemini_service.dart`
3. Replace the placeholder:
   ```dart
   static const String _apiKey = 'YOUR_ACTUAL_API_KEY';
   ```

### Step 4: Android Configuration

Ensure `android/app/src/main/AndroidManifest.xml` has:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

### Step 5: Run the App

```bash
flutter run
```

Or for release build:
```bash
flutter build apk --release
```

---

## 📱 User Guide

### Getting Started

#### 1. Sign Up / Login
- Enter your phone number
- Verify OTP (mock implementation)
- Set your name

#### 2. Create a Group
- Navigate to **Groups** tab
- Tap **"+ Create Group"**
- Enter group name (e.g., "Trip to Goa")
- Add members from contacts or manually

#### 3. Add Money to Wallet
- Go to **Wallet** tab
- Tap **"Add Money"**
- Enter amount
- Confirm transaction

### Making a Payment

#### Option A: Item-Based Split (Recommended)

1. **Payment Tab** → **"Item-Based Split"**
2. Enter merchant name → **"Continue to Add Items"**
3. **Add Items Screen**:
   - Enter item name, price, quantity
   - Tap **+** to add
   - Repeat for all items
4. **Assign Items Screen**:
   - For each item, use **+/−** to set consumption per person
   - Tap **"Next Item"** or **"Calculate Split"**
5. **Confirmation Screen**:
   - Review breakdown
   - Tap **"Confirm & Pay via PhonePe"**
6. Complete payment in PhonePe

#### Option B: Consumption Units Split

1. **Payment Tab** → **"Scan QR Code"** or **"Enter Manually"**
2. Scan merchant QR or enter amount
3. **Select Participants**:
   - Check members who participated
   - Set consumption units (0.5, 1.0, 1.5, custom)
4. **Calculate Split** → **Confirm & Pay**

### Using TripBot

1. Navigate to **TripBot** tab (4th icon)
2. Type your query:
   ```
   Plan a 3-day trip to Goa for 4 people
   ```
3. Receive detailed breakdown with costs and tips
4. Ask follow-up questions for refinements

---

## 🔌 API Integration

### Gemini AI API

**Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`

**Configuration**:
```dart
GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: _apiKey,
  generationConfig: GenerationConfig(
    temperature: 0.7,
    topK: 40,
    topP: 0.95,
    maxOutputTokens: 2048,
  ),
  systemInstruction: Content.text(_systemPrompt),
)
```

**System Prompt**: Custom persona for travel budgeting and itinerary planning.

### PhonePe Deep Linking

**UPI Intent Format**:
```
upi://pay?pa=<UPI_ID>&pn=<MERCHANT_NAME>&am=<AMOUNT>&tn=<NOTE>
```

**Android Intent**:
```dart
AndroidIntent(
  action: 'android.intent.action.VIEW',
  data: upiLink,
  package: 'com.phonepe.app',
)
```

---

## 📂 Project Structure

```
splitspay/
├── android/                 # Android native code
├── lib/                     # Flutter source code
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   └── main.dart
├── assets/                  # Images, fonts
├── test/                    # Unit & widget tests
├── pubspec.yaml             # Dependencies
└── README.md                # This file
```

---


## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Reporting Bugs
1. Check if the issue already exists
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (if applicable)

### Suggesting Features
1. Open a feature request issue
2. Describe the feature and use case
3. Explain why it would be valuable

### Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Satvacoders

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **Google Gemini Team** for the powerful AI API
- **PhonePe** for seamless UPI integration
- **Flutter Community** for excellent packages and support
- **Open Source Contributors** for inspiration and guidance


<div align="center">

**Made with ❤️ by Satvacoders**

*Simplifying group expenses, one split at a time.*

⭐ **Star this repo if you find it useful!** ⭐

</div>
