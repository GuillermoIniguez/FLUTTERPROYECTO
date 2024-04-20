class Interest {
  final int id;
  final String nombre;
  final String categoria;

  Interest({
    required this.id,
    required this.nombre,
    required this.categoria,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      nombre: json['Nombre'],
      categoria: json['Categoria'],
    );
  }
}
