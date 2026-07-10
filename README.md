# RehaUnified Doctor App

A Flutter telehealth app built for the RehaUnified Private Limited developer assignment.

## Features

- **Doctor Login** — Email/password authentication with form validation
- **Dashboard** — Welcomes the doctor, shows appointment summary and quick actions
- **Appointment Screen** — Full patient details with status-driven actions (Start Call / Cancel)
- **WebRTC Video Call** — Local + remote video, mic toggle, camera toggle, end call
- **Session Notes** — Add, view, and delete notes per patient (persisted via SharedPreferences)

---

## How to Run

### Prerequisites
- Flutter SDK `>=3.11.0`
- Android Studio / Xcode for device/emulator
- A physical device is recommended for camera/mic access

### Steps

```bash
git clone https://github.com/Rupha001/rehabunified-doctor-app.git
cd rehabunified-doctor-app
flutter pub get
flutter run
```

### Demo Credentials

| Field    | Value                         |
|----------|-------------------------------|
| Email    | `doctor@rehabunified.com`     |
| Password | `Doctor@123`                  |

---

## WebRTC SDK Used

**Package:** [`flutter_webrtc`](https://pub.dev/packages/flutter_webrtc) `^0.12.7`

- Industry-standard WebRTC bindings for Flutter (iOS, Android, Web, Desktop)
- Supports camera, mic, peer connections, ICE negotiation, and video rendering via `RTCVideoView`

---

## How to Test Video Calling

> Because this app does not include a signaling server, the video call screen demonstrates the **full WebRTC setup** (local stream, peer connection, ICE, offer/answer) on a single device.

### Single-device demo
1. Log in with the demo credentials.
2. The appointment status is set to **Confirmed** by default.
3. Tap **Start Video Call** on the Appointment screen.
4. Your local camera feed appears in the picture-in-picture overlay (top-right).
5. The main screen shows a "Waiting for patient..." placeholder (remote video area).
6. Use the mic/camera toggle buttons and the End Call button.

### Two-device testing (with signaling)
To test a real peer-to-peer call between two devices, a signaling server is needed to exchange SDP offer/answer and ICE candidates. This is the standard next step for production. The `WebRTCProvider` has hooks (`onIceCandidate`, `onTrack`) ready for signaling integration.

---

## What is Mocked

| Item | Status |
|------|--------|
| Authentication | Mocked — hardcoded credentials, no real backend |
| Patient data | Mocked — single hardcoded appointment |
| Signaling server | Not included — WebRTC peer connection is initialized locally |
| Remote video stream | Placeholder — no second peer connected without signaling |

---

## State Management

**Provider** (`provider ^6.1.2`) — three providers:
- `AuthProvider` — login/logout state
- `AppointmentProvider` — appointment data and status mutations
- `NotesProvider` — CRUD for session notes with `SharedPreferences` persistence

---

## Folder Structure

```
lib/
├── main.dart
├── models/
│   ├── appointment.dart
│   └── session_note.dart
├── providers/
│   ├── auth_provider.dart
│   ├── appointment_provider.dart
│   ├── notes_provider.dart
│   └── webrtc_provider.dart
└── screens/
    ├── login_screen.dart
    ├── dashboard_screen.dart
    ├── appointment_screen.dart
    ├── video_call_screen.dart
    └── notes_screen.dart
```

---

## What Can Be Improved

- **Real authentication** — integrate Firebase Auth or a REST API
- **Signaling server** — add WebSocket/Firebase Realtime DB signaling for true P2P calls
- **Multiple appointments** — list view with filters by date/status
- **Push notifications** — notify doctor when patient joins the call
- **Recording / screen share** — supported by `flutter_webrtc`
- **Unit & widget tests** — add full test coverage
- **Dark mode** — theme switching support
