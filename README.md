# بلوچ دیزاین | Baloch Design

برنامه مستقل و آفلاین طراحی مدل‌ها و قطعات برای Windows 10 و Windows 11.

## بیلد خودکار با GitHub Actions
پس از قراردادن سورس در مخزن `baloch-design`، ورک‌فلو با هر push به شاخه `main` یا اجرای دستی از بخش Actions اجرا می‌شود و خروجی ویندوز را به‌صورت Artifact تحویل می‌دهد.

## اجرای محلی
نیازمندی‌ها: Flutter stable و Visual Studio 2022 با Desktop development with C++.

```bash
flutter create --platforms=windows .
flutter pub get
flutter run -d windows
```

## بیلد محلی
```bash
flutter build windows --release
```

خروجی: `build/windows/x64/runner/Release/`

## وضعیت نسخه
این نسخه پایه اولیه است: داشبورد فارسی، ثبت محلی مدل‌ها و قطعات، بوم آزمایشی و ذخیره طرح‌ها در SQLite. ابزارهای تخصصی طراحی، هندسه و کاتالوگ کامل قطعات هنوز باید تکمیل و آزمایش شوند.
