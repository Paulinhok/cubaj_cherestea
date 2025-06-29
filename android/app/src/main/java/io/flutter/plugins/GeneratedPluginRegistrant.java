package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new com.sidlatau.flutteremailsender.FlutterEmailSenderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_email_sender, com.sidlatau.flutteremailsender.FlutterEmailSenderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.mastertipsy.flutter_localization.FlutterLocalizationPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_localization, com.mastertipsy.flutter_localization.FlutterLocalizationPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.example.flutter_native_ad.FlutterNativeAdPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_native_ad, com.example.flutter_native_ad.FlutterNativeAdPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin google_mobile_ads, io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.crazecoder.openfile.OpenFilePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin open_file_android, com.crazecoder.openfile.OpenFilePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.tekartik.sqflite.SqflitePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin sqflite_android, com.tekartik.sqflite.SqflitePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new eu.simonbinder.sqlite3_flutter_libs.Sqlite3FlutterLibsPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin sqlite3_flutter_libs, eu.simonbinder.sqlite3_flutter_libs.Sqlite3FlutterLibsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.webviewflutter.WebViewFlutterPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin webview_flutter_android, io.flutter.plugins.webviewflutter.WebViewFlutterPlugin", e);
    }
  }
}
