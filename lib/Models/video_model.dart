class VideoModel {
  final String idVideo;
  final String titulo;
  final String descripcion;
  final String urlVideo;
  final int duracionSegundos;
  final String tipoVideo;
  final String proveedor;
  final bool activo;

  VideoModel({
    required this.idVideo,
    required this.titulo,
    required this.descripcion,
    required this.urlVideo,
    required this.duracionSegundos,
    required this.tipoVideo,
    required this.proveedor,
    required this.activo,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        idVideo: json['id_video'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        urlVideo: json['url_video'],
        duracionSegundos: json['duracion_segundos'],
        tipoVideo: json['tipo_video'],
        proveedor: json['proveedor'],
        activo: json['activo'],
      );

  Map<String, dynamic> toJson() => {
        'id_video': idVideo,
        'titulo': titulo,
        'descripcion': descripcion,
        'url_video': urlVideo,
        'duracion_segundos': duracionSegundos,
        'tipo_video': tipoVideo,
        'proveedor': proveedor,
        'activo': activo,
      };
}
