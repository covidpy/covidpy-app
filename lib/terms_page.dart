import 'package:flutter/material.dart';
import 'package:location/location.dart';

class TermsPage extends StatefulWidget {
  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> with SingleTickerProviderStateMixin {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _usernameCtrl = TextEditingController();
  final _passwrodCtrl = TextEditingController();
  final focus = FocusNode();
  Location location = new Location();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwrodCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // primary: false,
      appBar: AppBar(
        title: Text('Términos y Condiciones'),
        backgroundColor: Color(0xFF0a2052),
        elevation: 0.0,
      ),
      body: _termsView(context),
    );
  }

  Widget _termsView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              //_header(),
              _content(),
            ],
          ),
        ),
       _footer(),
      ],
    );
  }

  /*Widget _header() {
    return SafeArea(
      top: true,
      child: Stack(
        children: <Widget>[
          Container(
            height: 100.0,
            width: double.infinity,
            color: Color(0xFF0a2052),
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: 35.0,
              ),
              Image.asset(
                'assets/images/gobierno_nacional.png',
                width: 220.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                child: Container(
                  color: Colors.indigo[50],
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Covid-19 Paraguay",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26.0,
                            color: Colors.indigo[900]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        "Esta es una aplicación del Ministerio de Salud Pública y Bienestar Social para el seguimiento de Casos",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }*/

  Widget _footer() {
    return new Container(
        height: 65.0,
        color: Color(0xFF0a2052),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/quedate_en_casa.png',
              width: 140.0,
            ),
            SizedBox(
              width: 40.0,
            ),
            Image.asset(
              'assets/images/paraguay_de_la_gente.png',
              width: 140.0,
            ),
          ],
        ),
      );
  }

  Widget _content() {
    return Container(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 26.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                      text: '1. Aceptación de Términos \n\n',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Al registrarse a la plataforma, el Usuario acepta plenamente y sin reservas el contenido de los términos y condiciones de uso. Estos términos consisten en un acuerdo colaborativo entre el Usuario y la plataforma para seguimiento del estado de las personas en relación con el COVID-19 (en adelante “la Plataforma”), que abarca todo su acceso y uso, lo que incluye el uso de toda la información, datos, herramientas, productos, servicios y otro contenido disponible mediante la Plataforma para el control establecido por el MSPBS en el marco de la pandemia de COVID-19, conforme a lo dispuesto en el Capítulo III del Código Sanitario y las disposiciones emitidas por la Autoridad Sanitaria. Al utilizar esta Plataforma, usted confirma que comprende y está de acuerdo con las siguientes condiciones:\n\n',
                    ),
                    TextSpan(
                      text: '2. Restricciones de Uso: \n\n',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'La utilización de la Plataforma está permitida solamente para personas mayores de 14 (catorce) años.\n\n',
                    ),
                    TextSpan(
                      text: '3. Responsabilidad del Usuario: \n\n',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'El Usuario está obligado a proporcionar personalmente información veraz y a mantenerla actualizada conforme a lo dispuesto en el art. 1 de la Resolución 112 de fecha 24 de marzo de 2020 del Ministerio de Salud Pública y Bienestar Social (en adelante el “MSPBS”). El incumplimiento de tal obligación por parte del Usuario, lo hace responsable por las consecuencias civiles y penales que de ella resulten.\n\n Las informaciones proporcionadas por el Usuario en la Plataforma tendrán carácter de declaración jurada, conforme al art. 2 de la Resolución MSPBS N° 112 de fecha 24 de marzo de 2020, siendo las declaraciones falsas pasibles de multas o hasta 5 años de pena privativa de libertad, conforme a lo dispuesto en el Art. 243 del Código Penal. \n\n En tal carácter, las credenciales de acceso (usuario/contraseña) son de uso personal y no deben ser compartidas con ninguna persona. Las credenciales entregadas son equivalentes a una Firma Electrónica conforme a las disposiciones de la Ley N˚4017/10, por lo que los mensajes de datos que se transmitan en uso de estas credenciales surtirán los efectos jurídicos que la legislación atribuye, reputándose realizados y provenientes del Usuario que los remite. El Usuario es responsable por el contenido que los individuos no autorizados produzcan al usar esta Plataforma utilizando con su permiso, su perfil registrado. Esta regla no se aplica a los casos de violación u otros problemas de seguridad de la Plataforma. \n\n El usuario está de acuerdo que al usar la Plataforma no publicará, enviará, distribuirá ni divulgará contenido o información de carácter difamatorio, obsceno o ilícito, inclusive información de propiedad exclusiva perteneciente a otras personas o instituciones, así como marcas registradas o información protegida por derechos de autor, sin la expresa autorización del propietario de esos derechos. \n\n El Usuario no está autorizado a manipular los parámetros de seguridad ni evadir los controles implementados en el sistema de la Plataforma. En caso de hacerlo será pasible de las sanciones establecidas en el Art. 175 del Código Penal.\n\n',
                    ),
                    TextSpan(
                      text: '4. Responsabilidad del MITIC \n\n',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'El Ministerio de Tecnologías de la Información y de la Comunicación (“MITIC”) no será responsable de la exactitud, veracidad, contenido o cualquier error en la información proporcionada por el Usuario o las instituciones públicas.\n\n',
                    ),
                    TextSpan(
                      text: '5. Acceso a Base de Datos \n\n',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Los datos personales (nombre, número de cédula, teléfono, dirección y su ubicación georeferencial) proporcionados por el Usuario formarán parte de una base de datos a la que podrán acceder las autoridades nacionales competentes. Los datos de salud serán considerados datos sensibles y su acceso será restringido, teniendo en cuenta las medidas de seguridad para el tratamiento de dichos datos. Además, el uso de los datos médicos tendrá carácter confidencial, conforme a lo dispuesto en el art. 2 de la Resolución MSPBS N° 112 de fecha 24 de marzo de 2020.Todos estos datos podrán ser utilizados con fines estadísticos y serán conservados mientras sea necesario para la aplicación de las medidas declaradas en la emergencia sanitaria.\n\n',
                    ),
                    TextSpan(
                      text: '6. Leyes, derechos y deberes \n\n',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Es política del equipo del MITIC responsable de la programación de la Plataforma, cumplir todas las leyes y resoluciones aplicables y vigentes. Estos Términos de Uso y el uso de la Plataforma son y serán regidos e interpretados de acuerdo con las leyes internas de la República del Paraguay. En caso de cualquier conflicto entre las leyes, decretos y resoluciones extranjeras y de la República del Paraguay deberán prevalecer la legislación nacional. La Plataforma prevé un sistema de control de acceso a cualquiera de sus áreas donde los usuarios transmiten información, pudiendo retirar el acceso a cualesquiera de estas informaciones o comunicaciones. Si usted tiene alguna duda en relación a la Plataforma, no dude en contactarnos mediante el e-mail: soporte@mspbs.gov.py \n\n El MITIC se reserva, en todos los sentidos, el derecho de actualizar y modificar en cualquier momento y de cualquier forma, de manera unilateral y sin previo aviso, las presentes condiciones de uso, políticas de privacidad y los contenidos de la Plataforma.\n\n',
                    ),
                  ])),
              _boton(),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boton() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0,
      color: Color(0xFFfa6980),
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(),
              Center(
                child: Text(
                  "VOLVER",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}
