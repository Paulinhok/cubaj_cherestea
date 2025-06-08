import 'package:intl/intl.dart';

class Cubaj {
  final int? id;
  final String? nume;
  final double? cubajTotal;
  final double? pretTotal;
  final double? pretunitar;
  final int? datacreare;
  final String? cale;

  Cubaj(
      {required this.id,
      this.nume,
      this.cubajTotal,
      this.pretTotal,
      this.pretunitar,
      this.datacreare,
      this.cale});

  double getPretTotal() {
    return pretTotal!;
  }

  double getPretUnitar() {
    return pretunitar!;
  }

  String get formattedDate {
    if (datacreare == null) return 'N/A';
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(datacreare! * 1000);
    final dateFormatter = DateFormat('dd.MM.yyyy');
    return dateFormatter.format(dateTime);
  }

  // DateTime now = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nume_lista': nume,
      'cubaj_total': cubajTotal,
      'pret_total': pretTotal,
      'pret_unitar': pretunitar,
      'data_creare': datacreare,
      'cale': cale,
    };
  }

  factory Cubaj.fromMap(Map<String, dynamic> map) {
    return Cubaj(
      id: map['id'],
      nume: map['nume_lista'],
      cubajTotal: map['cubaj_total'],
      pretTotal: map['pret_total'],
      pretunitar: map['pret_unitar'],
      datacreare: map['data_creare'],
      cale: map['cale'],
    );
  }
}
