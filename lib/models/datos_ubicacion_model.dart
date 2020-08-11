import 'dart:convert';

DatosUbicacionModel datosUbicacionModelFromJson(String str) => DatosUbicacionModel.fromJson(json.decode(str));

String datosUbicacionModelToJson(DatosUbicacionModel data) => json.encode(data.toJson());

class DatosUbicacionModel {
    String activity;
    String event;
    String fechaHora;
    double latitude;
    double longitude;
    double accuracy;
    double altitude;
    double speed;
    double altitudeAccuracy;
    int idUsuario;

    DatosUbicacionModel({
        this.activity,
        this.event,
        this.fechaHora,
        this.latitude,
        this.longitude,
        this.accuracy,
        this.altitude,
        this.speed,
        this.altitudeAccuracy,
        this.idUsuario,
    });

    factory DatosUbicacionModel.fromJson(Map<String, dynamic> json) => DatosUbicacionModel(
        activity: json["activity"],
        event: json["event"],
        fechaHora: json["fechaHora"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        accuracy: json["accuracy"],
        altitude: json["altitude"],
        speed: json["speed"],
        altitudeAccuracy: json["altitudeAccuracy"],
        idUsuario: json["idUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "activity": activity,
        "event": event,
        "fechaHora": fechaHora,
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "altitude": altitude,
        "speed": speed,
        "altitudeAccuracy": altitudeAccuracy,
        "idUsuario": idUsuario,
    };
}
