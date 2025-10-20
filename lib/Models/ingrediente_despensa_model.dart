class IngredienteDespensaModel {
  final String idIngDespensa;
  final String idDespensa;
  final String idIngrediente;
  final double cantidad;
  final String unidad;
  final DateTime fechaVencimiento;
  final String estado;

  IngredienteDespensaModel({
    required this.idIngDespensa,
    required this.idDespensa,
    required this.idIngrediente,
    required this.cantidad,
    required this.unidad,
    required this.fechaVencimiento,
    required this.estado,
  });

  factory IngredienteDespensaModel.fromJson(Map<String, dynamic> json) =>
      IngredienteDespensaModel(
        idIngDespensa: json['id_ing_despensa'],
        idDespensa: json['id_despensa'],
        idIngrediente: json['id_ingrediente'],
        cantidad: (json['cantidad'] as num).toDouble(),
        unidad: json['unidad'],
        fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'id_ing_despensa': idIngDespensa,
        'id_despensa': idDespensa,
        'id_ingrediente': idIngrediente,
        'cantidad': cantidad,
        'unidad': unidad,
        'fecha_vencimiento': fechaVencimiento.toIso8601String(),
        'estado': estado,
      };
}
