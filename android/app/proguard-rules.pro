# ==========================
# TensorFlow Lite rules
# ==========================
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.nnapi.** { *; }
-dontwarn org.tensorflow.lite.nnapi.**

# Prevent obfuscation for JNI (native interface)
-keepclassmembers class * {
    native <methods>;
}

# ==========================
# Flutter rules
# ==========================
-keep class io.flutter.plugins.GeneratedPluginRegistrant { public *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# ==========================
# SmartAuth rules
# ==========================
-keep class fman.ge.smart_auth.** { *; }

# ==========================
# Google Play Services rules
# ==========================
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.**

# ==========================
# Firebase rules
# ==========================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ==========================
# Parcelable & Serializable
# ==========================
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    private void readObjectNoData();
}

# ==========================
# Keep annotations
# ==========================
-keepattributes *Annotation*
