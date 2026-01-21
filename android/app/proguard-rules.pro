#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.common.** { *; }
-dontwarn com.google.common.**

# Squareup (used by some plugins)
-keep class com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**
-keep class com.squareup.okio.** { *; }
-dontwarn com.squareup.okio.**

# Firebase
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }

# -- Additional Rules --

# Preserve generic types for JSON serialization
-keepattributes Signature, EnclosingMethod, InnerClasses

# Crashlytics / Crash Reporting (Line numbers & Source files)
-keepattributes SourceFile, LineNumberTable

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Retrofit
-dontwarn javax.annotation.**
-keepattributes Signature
-keepattributes Exceptions

# Fix for Google Play Core missing classes
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Also add this to handle the general R8 warnings you are seeing
-ignorewarnings