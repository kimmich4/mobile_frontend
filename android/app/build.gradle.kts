plugins {
    id("com.android.application")
    id("kotlin-android")
    // the flutter gradle plugin must be applied after the android and kotlin gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // add the google services gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.mobile_frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // todo: specify your own unique application id (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.mobile_frontend"
        // you can update the following values to match your application needs.
        // for more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 // firebase needs at least 21 or 23 for bom/some features
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // todo: add your own signing config for the release build.
            // signing with the debug keys for now, so flutter run --release works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
  // import the firebase bom
  implementation(platform("com.google.firebase:firebase-bom:34.9.0"))

  // todo: add the dependencies for firebase products you want to use
  // when using the bom, don't specify versions in firebase dependencies
  implementation("com.google.firebase:firebase-analytics")

  // add the dependencies for any other desired firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
}

