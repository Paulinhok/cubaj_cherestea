class CubajMasuratori {
  int? id;
  int? bucati;
  double? lungime;
  double? latime;
  double? grosime;
  double? cubajBucata;
  String? numeLista;

  CubajMasuratori({
    this.id,
    this.bucati,
    this.lungime,
    this.latime,
    this.grosime,
    this.cubajBucata,
    this.numeLista,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bucati': bucati,
      'lungime': lungime,
      'latime': latime,
      'grosime': grosime,
      'cubaj_bucata': cubajBucata,
      'nume_lista': numeLista,
    };
  }

  factory CubajMasuratori.fromMap(Map<String, dynamic> map) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      throw FormatException('Invalid type for double: ${value.runtimeType}');
    }

    return CubajMasuratori(
      id: map['id'] as int?,
      bucati: map['bucati'] as int?,
      lungime: parseDouble(map['lungime']),
      latime: parseDouble(map['latime']),
      grosime: parseDouble(map['grosime']),
      cubajBucata: parseDouble(map['cubaj_bucata']),
      numeLista: map['nume_lista'] as String?,
    );
  }
}
