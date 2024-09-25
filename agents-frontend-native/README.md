# COOL Flutter Application

COOL Flutter application.

## Getting Started

To setup the Flutter local development environment, follow these
instructions https://docs.flutter.dev/get-started/install.

## Install the app

Before starting, make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code

## Setup Instructions

1. Open the terminal and navigate to the root project folder,
2. Create `.env` file,
3. Enter `.env` file, and add the next parameters:
   ```bash
   LIVEKIT_API_KEY='YourLivekitApiKey'
   LIVEKIT_API_SECRET='YourLivekitApiSecret'
   LIVEKIT_URL='LivekitRoomUrl'
   IDENTITY='Identity'
   NAME='YourName'
   ```
4. Make sure that the Flutter version is the latest by running:
   ```bash
   flutter upgrade
   ```
5. Get Flutter dependencies by running the next command:
   ```bash
   flutter pub get
   ```
6. Run the application via the terminal with the command (if multiple devices/simulators are attached, choose the wanted one in the terminal):
   ```bash
   flutter run
   ```

> **_NOTE:_**
> The application can also be run via Android Studio by clicking on the green play button and selecting the device/simulator on which the application should appear.
