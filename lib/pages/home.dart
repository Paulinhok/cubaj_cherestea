import 'dart:io';

import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/main.dart';
import 'package:scandura/pages/info.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scandura/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, this.adSize = AdSize.banner});

  @override
  State<HomePage> createState() => _HomePageState();

  /// The requested size of the banner. Defaults to [AdSize.banner].
  final AdSize adSize;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-3940256099942544/3986624511'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/2511094791';
}

class _HomePageState extends State<HomePage> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-4079464500254319/6009254972'
      : 'ca-app-pub-4079464500254319/7276661656';

  BannerAd? _bannerAd;
  //bool isMediumNativeAdReady = false;
  //final _ad = FlutterNativeAd();

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadMediumNativeAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    //_ad.nativeAd.dispose();
  }

  void _loadMediumNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            print('$NativeAd failedToLoad: $error');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: const Color(0xfffffbed),
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.white,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.black,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5),
        backgroundColor: Color(0xFF008B8B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        // leading: ... (from left button)...
        //actions: ... from right button...
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.menu_rounded,
              color: Colors.white,
            ),
            onSelected: (result) {
              if (result == 0) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              } else if (result == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListOfCubbingPage()));
              } else if (result == 2) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListeCubaj()));
              } else if (result == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InfoPage()));
              }
            },
            //
            itemBuilder: (BuildContext bc) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.menu_open_rounded),
                    title: Text(AppLocalizations.of(context)!.home),
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    leading: const Icon(Icons.new_label_outlined),
                    title: Text(AppLocalizations.of(context)!.newCubingMenu),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(AppLocalizations.of(context)!.cubingListMenu),
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(AppLocalizations.of(context)!.info),
                  ),
                )
              ];
            },
          ),
        ],
        leading: DropdownButtonHideUnderline(
          child: DropdownButton<Locale>(
            value: Localizations.localeOf(context),
            icon: const Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.white,
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                MyApp.setLocale(context, newLocale);
              }
            },
            items: const [
              DropdownMenuItem(
                value: Locale('ro', ''),
                child: Text('RO'),
              ),
              DropdownMenuItem(
                value: Locale('en', ''),
                child: Text('EN'),
              ),
              DropdownMenuItem(
                value: Locale('fr', ''),
                child: Text('FR'),
              ),
              DropdownMenuItem(
                value: Locale('es', ''),
                child: Text('ES'),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {}, ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 5),

            if (_nativeAdIsLoaded && _nativeAd != null)
              SizedBox(
                height: screenHeight * 0.45,
                width: screenWidth * 0.99,
                child: AdWidget(ad: _nativeAd!),
              )
            else
              SizedBox(
                height: screenHeight * 0.45,
              ),
              
            // SizedBox(
            //   width: widget.adSize.width.toDouble(),
            //   height: widget.adSize.height.toDouble(),
            //   child: _bannerAd == null
            //       // Nothing to render yet.
            //       ? const SizedBox()
            //       // The actual ad.
            //       : AdWidget(ad: _bannerAd!),
            // ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ListOfCubbingPage()));
                  print('The cubbing button has press');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(screenWidth * 0.7, screenHeight * 0.08),
                  backgroundColor: const Color(0xFF008B8B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.newCubing,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    //   fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ListeCubaj()));
                  print('The list button has press');
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth * 0.7, screenHeight * 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: const Color(0xFF008B8B)),
                child: Text(
                  AppLocalizations.of(context)!.cubingList,
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
