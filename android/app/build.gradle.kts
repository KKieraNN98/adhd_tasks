plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.adhd_todo"

    // Compile/target Android 16 (API 36) to satisfy latest plugins (e.g., path_provider_android)
    // and keep runtime behavior aligned with modern platform changes.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.adhd_todo"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        // Use Java 17 per AGP 8.x requirements
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Match Java toolchain
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            // Debug signing so `flutter run --release` works during development
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Single universal APK (no ABI splits) so we always copy one file.
    splits {
        abi { isEnable = false }
    }

    // Ensure bundled JNI libs are packaged in the APK in a way JNI can find them.
    // (Works fine with Flutter; keeps behavior explicit.)
    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring for newer Java APIs on older Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")
}

/**
 * Copy the module APK to the folder that `flutter run` scans:
 * <flutter project root>/build/app/outputs/flutter-apk/app-debug.apk
 *
 * NOTE: From :app, Gradle's `rootProject` points at the `android/` dir.
 * The Flutter project root is `rootProject.projectDir.parentFile`.
 */
val copyDebugApkToFlutterDir = tasks.register<Copy>("copyDebugApkToFlutterDir") {
    // Always run this copy (avoid UP-TO-DATE skip)
    outputs.upToDateWhen { false }

    // Source: AGP output in the :app module
    val apkDir = layout.buildDirectory.dir("outputs/apk/debug")
    from(apkDir) { include("*.apk") }

    // Destination: parent of android/ (the Flutter project root)
    val flutterProjectRoot = rootProject.projectDir.parentFile!!
    val dest = flutterProjectRoot.resolve("build/app/outputs/flutter-apk")
    into(dest)

    // Normalize the name so Flutter finds it
    rename { "app-debug.apk" }

    doFirst {
        logger.lifecycle("Copying debug APK to: ${dest.absolutePath}")
    }
}

// Run the copy after assembling debug
tasks.matching { it.name.equals("assembleDebug", ignoreCase = true) }
    .configureEach { finalizedBy(copyDebugApkToFlutterDir) }
