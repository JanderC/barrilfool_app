# Evita que R8 elimine las anotaciones de Error Prone
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**
