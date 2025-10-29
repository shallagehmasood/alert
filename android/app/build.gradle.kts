plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // ← جایگزین kotlin-android (قدیمی)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ir.masoodfx.alertx"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ← برای رفع خطای NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "ir.masoodfx.alertx" // ← منحصربه‌فرد و حرفه‌ای
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles("proguard-android.txt")
        }
    }
}

flutter {
    source = "../.."
}