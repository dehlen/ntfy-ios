# ntfy

An iOS client for the [ntfy.sh](https://ntfy.sh) service.

## Features

- Subscribe to topics
- Show notifications for topics
- Support for both the official ntfy.sh server as well as self hosted servers
- Manages users and securely stores them in the Keychain 
- Send test notifications
- Push notification handling
- Shows actions, priority, emojis, etc. for notifications
- Swift 6, Approchable concurrency
- No dependencies, with the exception of Firebase for push notification handling
- Adds an "All notifications" items similar to the web implementation

## Todos / Enhancements

- Add support for "http" actions
- Test Firebase remote notifications
- Make sure whether we want to target a lower iOS SDK (currently iOS 26 for ease of implementation)
- Add fastlane configuration to make deploying the application to the App Store straightforward
- Unit Tests
- Add local `.aps` payloads and write documentation on how to test notification handling locally

## Demo

This demo video shows the current state of the application:

![Demo Video](./demo.mov)

## Notes

The required `GoogleService-Info.plist` is not part of this repository as it includes secrets and will not be commited. To build this project a valid `GoogleService-Info.plist` should be added to the project.