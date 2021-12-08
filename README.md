# backcountry_plan

## Building for iOS

## Testflight

1. Update version in pubspec.yaml
2. Update version in xcode:
```
In Xcode, open Runner.xcworkspace in your app’s ios folder.
Select Runner in the Xcode project navigator, then select the Runner target in the settings view sidebar.
In the Identity section, update the Version to the user-facing version number you wish to publish.
In the Identity section, update the Build identifier to a unique build number used to track this build on App Store Connect. Each upload requires a unique build number.
```
3. Build a new build archive:
```
flutter build ipa
```
4. Open build/ios/archive/MyApp.xcarchive in Xcode.
5. (Optional) Click the Validate App button
6. Click "Distribute App", follow wizard for uploading to App Store Connect


## Building for Android

```
flutter build apk --split-abi
flutter install
```