import 'dart:io';

import 'package:scandura/SQLite/cubaj_masuratori.dart';
import 'package:scandura/SQLite/database_helper.dart';
import 'package:scandura/SQLite/liste_cubaj.dart';
import 'package:scandura/SQLite/measuring.dart';
import 'package:scandura/pages/home.dart';
import 'package:scandura/pages/list_of_cubbing.dart';
import 'package:scandura/utils/cubajUtils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scandura/l10n/app_localizations.dart';
class EditCubaj extends StatefulWidget {
  final CubajMasuratori masuratori;
  final int index;

  EditCubaj({super.key, required this.masuratori, required this.index});

  AdSize get adSize => AdSize.banner;

  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ca-app-pub-4079464500254319/5817683283'
      // ... or this one on iOS.
      : 'ca-app-pub-4079464500254319/6909011906';

  @override
  _EditCubajPageState createState() => _EditCubajPageState();
}

class _EditCubajPageState extends State<EditCubaj> {
  late TextEditingController numarController;
  late TextEditingController bucatiController;
  late TextEditingController lungimeController;
  late TextEditingController latimeController;
  late TextEditingController grosimeController;
  late TextEditingController cubajBucataController;

  BannerAd? _bannerAd;

  @override
  void initState() {
    // updateCubaj();
    _loadAd();
    super.initState();

    numarController = TextEditingController(text: widget.index.toString());
    bucatiController =
        TextEditingController(text: widget.masuratori.bucati.toString());
    lungimeController =
        TextEditingController(text: widget.masuratori.lungime.toString());
    latimeController =
        TextEditingController(text: widget.masuratori.latime.toString());
    grosimeController =
        TextEditingController(text: widget.masuratori.grosime.toString());
    cubajBucataController =
        TextEditingController(text: widget.masuratori.cubajBucata.toString());
  }

  @override
  void dispose() {
    numarController.dispose();
    bucatiController.dispose();
    lungimeController.dispose();
    latimeController.dispose();
    grosimeController.dispose();
    cubajBucataController.dispose();

    _bannerAd?.dispose();

    super.dispose();
  }

  Future<void> updateCubaj() async {
    final bucati = int.parse(bucatiController.text);
    final lungime = double.parse(lungimeController.text);
    final latime = double.parse(latimeController.text);
    final grosime = double.parse(grosimeController.text);

    final cubajBucata = CubajUtils.cubajScandura(lungime, latime, grosime);
    final db = await DatabaseHelper().initDB();

    final existingRows = await db.query(
      'cubaj_masuratori',
      where:
          'nume_lista = ? AND lungime = ? AND latime = ? AND grosime = ? AND cubaj_bucata = ? AND id != ?',
      whereArgs: [
        widget.masuratori.numeLista,
        lungime,
        latime,
        grosime,
        cubajBucata,
        widget.masuratori.id
      ],
    );

    if (existingRows.isNotEmpty) {
      final existing = existingRows.first;
      final newBuc = (existing['bucati'] as int) + bucati;

      await db.update(
        'cubaj_masuratori',
        {'bucati': newBuc},
        where: 'id = ?',
        whereArgs: [existing['id']],
      );

      await db.delete(
        'cubaj_masuratori',
        where: 'id = ?',
        whereArgs: [widget.masuratori.id],
      );
    } else {
      await db.update(
        'cubaj_masuratori',
        {
          'bucati': bucati,
          'lungime': lungime,
          'latime': latime,
          'grosime': grosime,
          'cubaj_bucata': cubajBucata,
        },
        where: 'id = ?',
        whereArgs: [widget.masuratori.id],
      );
    }
    if (bucati <= 0 || lungime <= 0 || latime <= 0 || grosime <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.valuesUnder0),
      ));
      return;
    }

    await DatabaseHelper().updateCubaj(widget.masuratori.numeLista!);
    final pretTotal =
        await DatabaseHelper().getPretTotal(widget.masuratori.numeLista!);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.cubingAdd),
    ));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => CubajMasuratoriPage(
                numeLista: widget.masuratori.numeLista!,
                pretTotal: pretTotal)));
  }

  Future<void> deteleCubaj() async {
    await DatabaseHelper().deteleCubaj(widget.masuratori.id!);

    double pretTotal =
        await DatabaseHelper().getPretTotal(widget.masuratori.numeLista!);

    await DatabaseHelper().updateCubaj(widget.masuratori.numeLista!);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.cubingDelete),
    ));

    setState(() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => CubajMasuratoriPage(
                  numeLista: widget.masuratori.numeLista!,
                  pretTotal: pretTotal)));
    });
  }

  /// Loads a banner ad.
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
        title: Text(AppLocalizations.of(context)!.editPageTitle),
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
              }
            },
            // print(value);
            //   setState(() {
            //     selectedIndex = value.toString();
            //   });
            //   Navigator.pushNamed(context, value.toString());
            // },
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
                    leading: Icon(Icons.new_label_outlined),
                    title: Text(AppLocalizations.of(context)!.newCubingMenu),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text(AppLocalizations.of(context)!.cubingListMenu),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: widget.adSize.width.toDouble(),
              height: widget.adSize.height.toDouble(),
              child: _bannerAd == null
                  // Nothing to render yet.
                  ? const SizedBox()
                  // The actual ad.
                  : AdWidget(ad: _bannerAd!),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.numberEdit,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                SizedBox(width: screenWidth * 0.2),
                SizedBox(
                  width: 100,
                  child: Text(
                    widget.index.toString(),
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.piecesEdit,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: screenWidth * 0.2,
                ),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: TextField(
                    controller: bucatiController,
                    keyboardType:
                        TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.thichnessEdit,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: screenWidth * 0.15),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: TextField(
                    controller: grosimeController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Înlocuiește virgula cu punct
                      grosimeController.text = value.replaceAll(',', '.');
                      grosimeController.selection = TextSelection.fromPosition(
                        TextPosition(offset: grosimeController.text.length),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.lengthEdit,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: screenWidth * 0.15),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: TextField(
                    controller: lungimeController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Înlocuiește virgula cu punct
                      lungimeController.text = value.replaceAll(',', '.');
                      lungimeController.selection = TextSelection.fromPosition(
                        TextPosition(offset: lungimeController.text.length),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.widthEdit,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: screenWidth * 0.2),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: TextField(
                    controller: latimeController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Înlocuiește virgula cu punct
                      latimeController.text = value.replaceAll(',', '.');
                      latimeController.selection = TextSelection.fromPosition(
                        TextPosition(offset: latimeController.text.length),
                      );
                    },
                  ),
                ),
              ],
            ),
            // SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  // border: Border(top: BorderSide())
                  ),
              child: ElevatedButton(
                onPressed: () {
                  updateCubaj();
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth * 0.6, screenHeight * 0.05),
                    backgroundColor: Color(0xFF008B8B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Text(
                  AppLocalizations.of(context)!.editCubing,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                  AppLocalizations.of(context)!.cubing,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                SizedBox(width: 85),
                SizedBox(
                  width: 100,
                  child: Text(
                  '${(widget.masuratori.cubajBucata! * widget.masuratori.bucati!).toStringAsFixed(3)} m³',
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border(top: BorderSide())
                  ),
              child: ElevatedButton(
                onPressed: () async {
                  deteleCubaj();
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth * 0.6, screenHeight * 0.05),
                    backgroundColor: Colors.red[600],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Text(
                  AppLocalizations.of(context)!.deleteCubing,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
