# Character Shooter

لعبة شوتر بالشخصيات الثلاث (Fighter / Girl / Bear) مبنية بـ **Flutter + Flame**.

## تشغيل محلي
```bash
flutter pub get
flutter run
```

## بناء APK
```bash
flutter build apk --release
```
الـ APK يطلع في:
`build/app/outputs/flutter-apk/app-release.apk`

## Auto Build
كل push على `main` يشغل GitHub Actions ويبني الـ APK ويرفعه كـ Artifact.
روح Actions → آخر run → Artifacts → حمل الـ APK.
