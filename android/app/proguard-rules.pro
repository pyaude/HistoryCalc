# Flutter-specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep shared_preferences
-keep class androidx.lifecycle.** { *; }

# Keep Riverpod
-keep class org.reactivestreams.** { *; }

# Ignore missing Play Core classes for deferred components
-dontwarn com.google.android.play.core.**
