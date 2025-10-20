class ItemListaModel {
  final String idItemLista;
  final String idLista;
  final String idIngrediente;
  final double cantidad;
  final String unidad;
  final bool comprado;

  ItemListaModel({
    required this.idItemLista,
    required this.idLista,
    required this.idIngrediente,
    required this.cantidad,
    required this.unidad,
    required this.comprado,
  });

  factory ItemListaModel.fromJson(Map<String, dynamic> json) => ItemListaModel(
        idItemLista: json['id_item_lista'],
        idLista: json['id_lista'],
        idIngrediente: json['id_ingrediente'],
        cantidad: (json['cantidad'] as num).toDouble(),
        unidad: json['unidad'],
        comprado: json['comprado'],
      );

  Map<String, dynamic> toJson() => {
        'id_item_lista': idItemLista,
        'id_lista': idLista,
        'id_ingrediente': idIngrediente,
        'cantidad': cantidad,
        'unidad': unidad,
        'comprado': comprado,
      };
}
