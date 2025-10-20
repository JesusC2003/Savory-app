class IngredienteModel {
  final String idIngrediente;
  final String nombre;
  final String categoria;
  final String unidadBase;
  final List<String>? sinonimos;

  IngredienteModel({
    required this.idIngrediente,
    required this.nombre,
    required this.categoria,
    required this.unidadBase,
    this.sinonimos,
  });

  factory IngredienteModel.fromJson(Map<String, dynamic> json) =>
      IngredienteModel(
        idIngrediente: json['id_ingrediente'],
        nombre: json['nombre'],
        categoria: json['categoria'],
        unidadBase: json['unidad_base'],
        sinonimos: json['sinonimos'] != null
            ? List<String>.from(json['sinonimos'])
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id_ingrediente': idIngrediente,
        'nombre': nombre,
        'categoria': categoria,
        'unidad_base': unidadBase,
        'sinonimos': sinonimos,
      };
}
