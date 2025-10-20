class FavoritoModel {
  final String idFavorito;
  final String idUsuario;
  final String idReceta;
  final DateTime fechaGuardado;

  FavoritoModel({
    required this.idFavorito,
    required this.idUsuario,
    required this.idReceta,
    required this.fechaGuardado,
  });

  factory FavoritoModel.fromJson(Map<String, dynamic> json) => FavoritoModel(
        idFavorito: json['id_favorito'],
        idUsuario: json['id_usuario'],
        idReceta: json['id_receta'],
        fechaGuardado: DateTime.parse(json['fecha_guardado']),
      );

  Map<String, dynamic> toJson() => {
        'id_favorito': idFavorito,
        'id_usuario': idUsuario,
        'id_receta': idReceta,
        'fecha_guardado': fechaGuardado.toIso8601String(),
      };
}
