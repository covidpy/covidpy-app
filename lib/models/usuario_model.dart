class UsuarioModel {
  
  int id;
  bool activo;
  String apellido;
  String nombre;
  String username;

  UsuarioModel({
   this.id,
   this.activo,
   this.apellido,
   this.nombre,
   this.username
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => new UsuarioModel(
    id: json['id'] as int,
    activo: json['activo'] as bool,
    apellido: json['apellido'] as String,
    nombre: json['nombre'] as String,
    username: json['username'] as String,
  );

}
