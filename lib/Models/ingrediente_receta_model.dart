class IngredienteRecetaModel {
  final String idIngReceta;
  final String idReceta;
  final String idIngrediente;
  final double cantidadNecesaria;
  final String unidad;
  final bool opcional;

  IngredienteRecetaModel({
    required this.idIngReceta,
    required this.idReceta,
    required this.idIngrediente,
    required this.cantidadNecesaria,
    required this.unidad,
    required this.opcional,
  });

  factory IngredienteRecetaModel.fromJson(Map<String, dynamic> json) =>
      IngredienteRecetaModel(
        idIngReceta: json['id_ing_receta'],
        idReceta: json['id_receta'],
        idIngrediente: json['id_ingrediente'],
        cantidadNecesaria: (json['cantidad_necesaria'] as num).toDouble(),
        unidad: json['unidad'],
        opcional: json['opcional'],
      );

  Map<String, dynamic> toJson() => {
        'id_ing_receta': idIngReceta,
        'id_receta': idReceta,
        'id_ingrediente': idIngrediente,
        'cantidad_necesaria': cantidadNecesaria,
        'unidad': unidad,
        'opcional': opcional,
      };
}