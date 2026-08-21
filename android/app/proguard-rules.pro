# Flutter / Dart
-keep class io.flutter.** { *; }

# Play Core split-install classes are referenced by Flutter's deferred-component
# support, which this app does not use. Silence R8's missing-class errors.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# flutter_local_notifications uses Gson for serializing scheduled-notification data.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keepattributes Signature
-keepattributes *Annotation*

# Keep generic type information used by Gson via reflection.
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# sqlite3 native bindings
-keep class org.sqlite.** { *; }
