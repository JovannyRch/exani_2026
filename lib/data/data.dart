import 'package:examen_vial_edomex_app_2025/models/option.dart';

final List<Question> questions = [
  Question(
    id: 1,
    text: 'Las señales de tránsito se clasifican en: ',
    options: [
      Option(
        id: 1,
        text:
            "Preventivas (Amarillas): Advierten peligro [br][br]Restrictivas (Rojas con negro): Limitan o prohíben, tienen el objeto de regular el tránsito. [br][br]Informativas (Azules): Tienen por objeto servir de guía para localizar o identificar calles o carreteras, así como nombres de poblaciones y lugares de interés, con servicios existentes",
      ),
      Option(id: 2, text: 'De seguridad, de emergencia y de advertencia'),
      Option(id: 3, text: 'Primarias, secundarias y terciarias'),
      Option(id: 4, text: 'Obligatorias, voluntarias y opcionales'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 2,
    text: '¿Cuántos pasajeros pueden viajar dentro de un vehículo?',
    options: [
      Option(id: 1, text: 'Los indicados en la tarjeta de circulación'),
      Option(id: 2, text: 'Un máximo de 5 pasajeros'),
      Option(id: 3, text: 'El número que el conductor considere seguro'),
      Option(id: 4, text: 'Hasta 7 personas incluyendo al conductor'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 3,
    text:
        'Por conducir sin licencia, se hace acreedor a una multa consiste en:',
    options: [
      Option(id: 1, text: '20 UMAs'),
      Option(id: 2, text: '5 salarios mínimos'),
      Option(id: 3, text: '50 pesos'),
      Option(id: 4, text: '10 UMAs'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 4,
    text:
        '¿Quién está obligado a utilizar el cinturón de seguridad dentro de un vehículo?',
    options: [
      Option(id: 1, text: 'Todos los pasajeros del vehículo'),
      Option(id: 2, text: 'Solo el conductor'),
      Option(id: 3, text: 'Solo los pasajeros delanteros'),
      Option(id: 4, text: 'Nadie está obligado'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 5,
    text:
        'En centros educativos, oficinas públicas hospitales o cualquier otro lugar de reunión ¿Cuál es el límite de velocidad permitido para circular?',
    options: [
      Option(id: 1, text: '20 kilómetros por hora'),
      Option(id: 2, text: '10 kilómetros por hora'),
      Option(id: 3, text: '30 kilómetros por hora'),
      Option(id: 4, text: '40 kilómetros por hora'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 6,
    text: '¿Bajo qué circunstancias es permitida la vuelta a la derecha?',
    options: [
      Option(id: 1, text: 'En ningún caso'),
      Option(id: 2, text: 'Cuando el semáforo esté en verde'),
      Option(id: 3, text: 'Cuando no vengan peatones'),
      Option(id: 4, text: 'En carreteras rurales'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 7,
    text:
        '¿En qué lugares está prohibido el estacionamiento de cualquier tipo de vehículo?',
    options: [
      Option(
        id: 1,
        text:
            'Camellones, frente a rampas especiales de acceso a la banqueta para minusválidos, en más de una fila, andadores y otras vías reservadas a los peatones',
      ),
      Option(id: 2, text: 'En estacionamientos públicos'),
      Option(id: 3, text: 'En calles residenciales'),
      Option(id: 4, text: 'En avenidas principales con línea discontinua'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 8,
    text:
        '¿En qué caso a un vehículo matriculado fuera del Estado de México se le podrá retirar la placa de matrícula?',
    options: [
      Option(
        id: 1,
        text:
            'Cuando se detecte con adeudos por infracciones al Reglamento de Tránsito',
      ),
      Option(id: 2, text: 'Cuando circule con vidrios polarizados'),
      Option(id: 3, text: 'Cuando transporte más de 5 pasajeros'),
      Option(id: 4, text: 'Cuando circule de noche sin luces prendidas'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 9,
    text:
        '¿En qué caso pueden circular los vehículos de servicio público por los carriles centrales de las vías primarias?',
    options: [
      Option(id: 1, text: 'En ningún caso'),
      Option(id: 2, text: 'Cuando vayan sin pasajeros'),
      Option(id: 3, text: 'Cuando lo permita el semáforo'),
      Option(id: 4, text: 'Cuando se trate de un taxi'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 10,
    text:
        'Si un pasajero arroja basura hacia el exterior del vehículo; ¿Quién es el responsable y por lo tanto acreedor de la sanción?',
    options: [
      Option(id: 1, text: 'El conductor del vehículo'),
      Option(id: 2, text: 'El pasajero que tiró la basura'),
      Option(id: 3, text: 'El propietario del vehículo'),
      Option(id: 4, text: 'Ambos, conductor y pasajero'),
    ],
    correctOptionId: 1,
  ),

  Question(
    id: 11,
    text:
        '¿Qué tipos de vehículos podrán circular con los vidrios polarizados?',
    options: [
      Option(
        id: 1,
        text:
            'Los vehículos que vengan instalados con vidrios polarizados desde la fábrica',
      ),
      Option(id: 2, text: 'Todos los vehículos particulares'),
      Option(id: 3, text: 'Solo los vehículos con placas federales'),
      Option(id: 4, text: 'Los taxis y transporte público'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 12,
    text: '¿En las glorietas sin semáforos; ¿Quién tiene la preferencia?',
    options: [
      Option(
        id: 1,
        text: 'Los vehículos que ya se encuentren circulando en ella',
      ),
      Option(id: 2, text: 'Los vehículos que intentan entrar a la glorieta'),
      Option(id: 3, text: 'Los peatones que cruzan cerca de la glorieta'),
      Option(id: 4, text: 'Los ciclistas sin importar la dirección'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 13,
    text:
        'En caso de que el vehículo produzca un ruido excesivo generado por el claxon o válvulas de escape; ¿Cuál será la sanción?',
    options: [
      Option(id: 1, text: 'Multa de 5 UMAs'),
      Option(id: 2, text: 'Arresto administrativo de 12 horas'),
      Option(id: 3, text: 'Amonestación verbal'),
      Option(id: 4, text: 'Retiro de la placa por 30 días'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 14,
    text: '¿Qué casos están prohibidos realizar en la vía pública?',
    options: [
      Option(
        id: 1,
        text:
            'Efectuar carreras o “arrancones” o situar cualquier otro objeto que obstaculice o afecte la vialidad',
      ),
      Option(id: 2, text: 'Circular en horarios nocturnos'),
      Option(id: 3, text: 'Usar luces intermitentes en zonas escolares'),
      Option(id: 4, text: 'Rebasar en avenidas principales'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 15,
    text: 'Es una regla para los motociclistas y su acompañante:',
    options: [
      Option(id: 1, text: 'El uso de casco y anteojos protectores'),
      Option(id: 2, text: 'Solo usar casco en carretera'),
      Option(id: 3, text: 'Solo el conductor debe usar casco'),
      Option(id: 4, text: 'No es obligatorio usar casco dentro de la ciudad'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 16,
    text:
        '¿Cuándo deben de ir acompañados por una persona mayor, los menores de edad con un permiso provisional de práctica?',
    options: [
      Option(
        id: 1,
        text: 'Siempre y el acompañante deberá portar una licencia vigente',
      ),
      Option(id: 2, text: 'Solo en autopistas y carreteras'),
      Option(id: 3, text: 'Cuando manejen de noche'),
      Option(id: 4, text: 'Cuando conduzcan motocicletas'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 17,
    text:
        'Todos los vehículos automotores de uso particular deberán contar con:',
    options: [
      Option(
        id: 1,
        text:
            'Póliza de seguro de responsabilidad civil vigente que ampare al menos daños a terceros en su persona y en su patrimonio',
      ),
      Option(id: 2, text: 'Un extintor y botiquín de primeros auxilios'),
      Option(id: 3, text: 'Engomado de verificación ambiental'),
      Option(id: 4, text: 'Revisión mecánica semestral obligatoria'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 18,
    text: 'Son causas de cancelación de la licencia:',
    options: [
      Option(
        id: 1,
        text:
            'Manejar bajo los efectos de drogas enervantes o psicotrópicos, así como, conducir en estado de ebriedad.',
      ),
      Option(id: 2, text: 'No pagar la tenencia a tiempo'),
      Option(id: 3, text: 'Circular con vidrios polarizados'),
      Option(id: 4, text: 'No portar el cinturón de seguridad'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 19,
    text:
        '¿Qué deben de hacer los conductores cuando el semáforo se encuentra en luz roja?',
    options: [
      Option(
        id: 1,
        text:
            'Detener su vehículo en la línea de “alto”, sin invadir la zona para cruce de los peatones',
      ),
      Option(id: 2, text: 'Acelerar para pasar antes de que cambie a verde'),
      Option(id: 3, text: 'Tocar el claxon para avanzar'),
      Option(id: 4, text: 'Dar vuelta en U si no vienen coches'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 20,
    text:
        '¿Está permitido realizar llamadas por el celular mientras conduce un vehículo?',
    options: [
      Option(id: 1, text: 'No está permitido'),
      Option(id: 2, text: 'Sí, pero solo con altavoz'),
      Option(id: 3, text: 'Sí, si el tráfico es lento'),
      Option(id: 4, text: 'Solo en carreteras federales'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 21,
    text:
        '¿En qué casos pueden circular los conductores de motocicletas por las banquetas y áreas reservadas a los peatones?',
    options: [
      Option(id: 1, text: 'En ningún caso'),
      Option(id: 2, text: 'Cuando no haya peatones'),
      Option(id: 3, text: 'Solo en emergencias'),
      Option(id: 4, text: 'Cuando el tránsito esté detenido'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 22,
    text:
        '¿Cuánto como máximo, puede sobresalir la carga de las dimensiones laterales de un vehículo?',
    options: [
      Option(id: 1, text: '1 metro'),
      Option(id: 2, text: '50 centímetros'),
      Option(id: 3, text: '2 metros'),
      Option(id: 4, text: 'No hay límite'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 23,
    text:
        '¿Cuál es la sanción cuando un conductor no acata las restricciones de circulación de los programas ambientales?',
    options: [
      Option(id: 1, text: 'Multa de 20 UMAs y retención del vehículo'),
      Option(id: 2, text: 'Multa de 5 UMAs'),
      Option(id: 3, text: 'Retiro de licencia por un mes'),
      Option(id: 4, text: 'Solo una amonestación verbal'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 24,
    text:
        '¿Cuál es la sanción o multa por conducir un automotor, abrazado a una persona o a un objeto?',
    options: [
      Option(id: 1, text: 'Multa de 20 UMAs'),
      Option(id: 2, text: 'Arresto administrativo por 12 horas'),
      Option(id: 3, text: 'Retiro de placas de circulación'),
      Option(id: 4, text: 'Suspensión de la licencia por un año'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 25,
    text: '¿Qué tipo de vehículos podrán circular en carriles de contraflujo?',
    options: [
      Option(
        id: 1,
        text: 'Vehículos de emergencia, patrullas, ambulancias y bomberos',
      ),
      Option(id: 2, text: 'Vehículos particulares con prisa'),
      Option(id: 3, text: 'Solo transporte público'),
      Option(id: 4, text: 'Motocicletas con permiso especial'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 26,
    text:
        '¿Qué sanción se aplica cuándo los datos de la placa no coinciden con los del engomado, la calcomanía o la tarjeta de circulación?',
    options: [
      Option(id: 1, text: 'Multa de 20 UMAs y retención del vehículo'),
      Option(id: 2, text: 'Amonestación verbal'),
      Option(id: 3, text: 'Multa de 5 UMAs sin retención'),
      Option(id: 4, text: 'Arresto administrativo de 24 horas'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 27,
    text:
        '¿En qué casos deberán ser presentados ante las autoridades competentes, las personas y vehículos involucrados en un accidente?',
    options: [
      Option(
        id: 1,
        text:
            'Cuando las partes no estén de acuerdo en la reparación de los daños',
      ),
      Option(id: 2, text: 'Siempre, en todos los accidentes'),
      Option(id: 3, text: 'Solo si hay lesionados'),
      Option(id: 4, text: 'Cuando uno de los vehículos es extranjero'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 28,
    text:
        'Los conductores que violen lo dispuesto en el Reglamento de Tránsito y muestren síntomas de conducir en estado de ebriedad serán:',
    options: [
      Option(
        id: 1,
        text: 'Presentados ante el Oficial calificador o autoridad competente',
      ),
      Option(id: 2, text: 'Suspendidos solo por 24 horas'),
      Option(id: 3, text: 'Multados con 5 UMAs sin detención'),
      Option(id: 4, text: 'Exentos si son conductores de servicio público'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 29,
    text:
        '¿Es una obligación de los agentes de tránsito auxiliar de manera inmediata a todos aquellos conductores en caso de descompostura del vehículo?',
    options: [
      Option(id: 1, text: 'Sí, es su obligación'),
      Option(id: 2, text: 'No, es opcional'),
      Option(id: 3, text: 'Solo si el conductor lo solicita'),
      Option(id: 4, text: 'Únicamente en horario laboral'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 30,
    text:
        'Cuando solo existan daños materiales en un accidente, el agente de tránsito está obligado a:',
    options: [
      Option(
        id: 1,
        text:
            'Exhortar a los afectados, a fin de que lleguen a un arreglo inmediato para evitar el entorpecimiento de la circulación',
      ),
      Option(
        id: 2,
        text: 'Retirar ambos vehículos de circulación inmediatamente',
      ),
      Option(id: 3, text: 'Multar a los conductores involucrados'),
      Option(id: 4, text: 'Esperar a que llegue una grúa oficial'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 31,
    text:
        '¿Cuál es el límite de alcohol espirado para los operadores de transportes de sustancias peligrosas, de carga o de transportes de pasajeros?',
    options: [
      Option(
        id: 1,
        text: 'Ninguna cantidad de alcohol en la sangre o en aire espirado',
      ),
      Option(id: 2, text: 'Hasta 0.8 gramos por litro de sangre'),
      Option(id: 3, text: 'Hasta 0.4 gramos por litro de sangre'),
      Option(id: 4, text: 'Una copa de vino como máximo'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 32,
    text:
        '¿Qué procede cuando su vehículo tiene instaladas torretas, faros rojos, o dispositivos usados en vehículos de emergencia o patrullas? ',
    options: [
      Option(id: 1, text: 'Multa de 20 UMAs'),
      Option(id: 2, text: 'Retiro del vehículo de circulación por 30 días'),
      Option(id: 3, text: 'Suspensión de la licencia de conducir'),
      Option(id: 4, text: 'Multa de 5 UMAs sin retención'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 33,
    text: '¿De qué color deberán ser las luces delanteras de los vehículos?',
    options: [
      Option(id: 1, text: 'Blanco'),
      Option(id: 2, text: 'Amarillo intermitente'),
      Option(id: 3, text: 'Azul'),
      Option(id: 4, text: 'Rojo'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 34,
    text:
        '¿Los vehículos no deberán portar en la parte trasera faros de qué color?',
    options: [
      Option(id: 1, text: 'Blanco'),
      Option(id: 2, text: 'Rojo'),
      Option(id: 3, text: 'Ámbar'),
      Option(id: 4, text: 'Verde'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 35,
    text:
        'Cuando un conductor, transite con un vehículo con llantas lisas o en mal estado, se procederá a:',
    options: [
      Option(id: 1, text: 'Multa de 5 UMAs'),
      Option(id: 2, text: 'Retención de la licencia por 15 días'),
      Option(id: 3, text: 'Amonestación verbal'),
      Option(id: 4, text: 'Retiro inmediato del vehículo'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 36,
    text:
        'El Reglamento de Tránsito prevé disposiciones que deberán obedecer los peatones, en caso contrario será susceptible de ser: ',
    options: [
      Option(id: 1, text: 'Amonestado'),
      Option(id: 2, text: 'Multado con 20 UMAs'),
      Option(id: 3, text: 'Detenido por 24 horas'),
      Option(id: 4, text: 'Retirado de la vía pública por grúa'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 37,
    text:
        '¿Bajo qué circunstancias el conductor de un vehículo puede pasarse un semáforo en rojo?',
    options: [
      Option(id: 1, text: 'Solo si un oficial de tránsito lo indica'),
      Option(id: 2, text: 'Cuando no hay peatones cruzando'),
      Option(id: 3, text: 'Cuando el tránsito está congestionado'),
      Option(id: 4, text: 'Si el semáforo tarda más de 2 minutos'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 38,
    text: '¿Para qué sirven las rayas longitudinales en el pavimento?',
    options: [
      Option(
        id: 1,
        text:
            'Delimitan los carriles de circulación y guían a los conductores dentro de los mismos',
      ),
      Option(id: 2, text: 'Señalan zonas de estacionamiento'),
      Option(id: 3, text: 'Indican áreas de cruce peatonal'),
      Option(id: 4, text: 'Son decorativas y no tienen función'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 39,
    text: '¿Para qué sirven las rayas transversales en el pavimento?',
    options: [
      Option(
        id: 1,
        text:
            'Indican el límite de parada de los vehículos y delimitan la zona de cruce de peatones',
      ),
      Option(id: 2, text: 'Marcan los carriles de alta velocidad'),
      Option(id: 3, text: 'Indican zonas de carga y descarga'),
      Option(id: 4, text: 'Son únicamente para decoración vial'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 40,
    text:
        'Si el vehículo que conduce carece de direccionales o en su caso no funcionan y requiere cambiar de dirección, deberá:',
    options: [
      Option(
        id: 1,
        text:
            'Hacer la señal respectiva con el brazo izquierdo extendido hacia arriba, si el cambio es a la derecha y extendiéndolo hacia abajo, si va a hacerlo hacia la izquierda',
      ),
      Option(id: 2, text: 'Encender las luces intermitentes'),
      Option(id: 3, text: 'Pitar el claxon para avisar a los demás'),
      Option(id: 4, text: 'Reducir la velocidad y girar sin señalización'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 41,
    text:
        'El conductor que se aproxime a un crucero de ferrocarril deberá hacer alto total a una distancia mínima de:',
    options: [
      Option(
        id: 1,
        text: '5 metros del riel más cercano del cruce del ferrocarril',
      ),
      Option(id: 2, text: '2 metros del riel más cercano'),
      Option(id: 3, text: '10 metros del riel más cercano'),
      Option(id: 4, text: 'No es necesario detenerse si no viene el tren'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 42,
    text: '¿Qué función tienen los fantasmas o indicadores de alumbrado?',
    options: [
      Option(id: 1, text: 'Delimitan la orilla de los acotamientos'),
      Option(id: 2, text: 'Marcan la ubicación de los semáforos'),
      Option(id: 3, text: 'Sirven como decoración vial'),
      Option(id: 4, text: 'Señalan el inicio de las zonas escolares'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 43,
    text: '¿Cuál es el objeto de las señales restrictivas?',
    options: [
      Option(
        id: 1,
        text:
            'Indicar determinadas limitaciones o prohibiciones que regulen el tránsito',
      ),
      Option(id: 2, text: 'Orientar al conductor hacia un destino'),
      Option(id: 3, text: 'Advertir un peligro en el camino'),
      Option(id: 4, text: 'Mostrar información turística'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 44,
    text:
        '¿En qué caso se permite efectuar carreras o arrancones en la vía pública?',
    options: [
      Option(id: 1, text: 'No están permitidos'),
      Option(id: 2, text: 'Cuando sea en horarios nocturnos'),
      Option(id: 3, text: 'Cuando no haya tránsito'),
      Option(id: 4, text: 'Con autorización verbal de un policía'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 45,
    text:
        '¿En qué condiciones se permite la instalación y el uso de sistemas antirradares o detector de radares de velocidad?',
    options: [
      Option(id: 1, text: 'Bajo ninguna condición'),
      Option(id: 2, text: 'Solo en carreteras federales'),
      Option(id: 3, text: 'En vehículos particulares únicamente'),
      Option(id: 4, text: 'Con permiso especial de tránsito'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 46,
    text:
        '¿Sería una causa por la cual no se expida o reexpida una licencia y/o permiso para conducir?',
    options: [
      Option(
        id: 1,
        text:
            'Cuando la documentación exhibida sea falsa o proporcionen informes falsos en la solicitud correspondiente',
      ),
      Option(id: 2, text: 'Cuando el solicitante no tenga experiencia'),
      Option(id: 3, text: 'Cuando el solicitante nunca haya manejado'),
      Option(
        id: 4,
        text: 'Si no presenta comprobante de domicilio actualizado',
      ),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 47,
    text:
        'Las ambulancias, patrullas de policía y los vehículos de bomberos tienen preferencia de paso, siempre y cuando:',
    options: [
      Option(
        id: 1,
        text: 'Circulen con la sirena o con la torreta luminosa y encendida',
      ),
      Option(id: 2, text: 'Circulen a exceso de velocidad'),
      Option(id: 3, text: 'Se trate de un día de emergencia nacional'),
      Option(id: 4, text: 'Siempre, sin importar las condiciones'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 48,
    text:
        '¿Qué se debe hacer cuando los conductores pretendan incorporarse a una vía primaria?',
    options: [
      Option(
        id: 1,
        text: 'Ceder el paso a los vehículos que circulen por la misma',
      ),
      Option(id: 2, text: 'Acelerar para entrar primero'),
      Option(id: 3, text: 'Pitar el claxon para que los dejen pasar'),
      Option(id: 4, text: 'Ingresar sin detenerse'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 49,
    text: '¿Por dónde queda prohibido rebasar a otro vehículo?',
    options: [
      Option(id: 1, text: 'Por el acotamiento'),
      Option(id: 2, text: 'Por el carril de la izquierda'),
      Option(id: 3, text: 'Por un carril de tránsito continuo'),
      Option(id: 4, text: 'Por una carretera de doble sentido'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 50,
    text:
        '¿Cómo deben de actuar los conductores de vehículos implicados en accidentes donde resulten personas lesionadas o fallecidas?',
    options: [
      Option(
        id: 1,
        text:
            'Permanecer en el lugar del accidente para prestar o facilitar asistencia al lesionado o lesionados, procurando que se dé aviso al personal de auxilio y autoridad competente',
      ),
      Option(id: 2, text: 'Abandonar el lugar para evitar sanciones'),
      Option(id: 3, text: 'Esperar a que llegue un familiar'),
      Option(id: 4, text: 'Mover el vehículo inmediatamente'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 51,
    text: '¿Cuál es el objeto de las señales preventivas?',
    options: [
      Option(
        id: 1,
        text:
            'Advertir la existencia y naturaleza de un peligro o cambio de situación en la vía pública',
      ),
      Option(id: 2, text: 'Informar sobre los servicios disponibles'),
      Option(id: 3, text: 'Reglamentar el tránsito vehicular'),
      Option(id: 4, text: 'Indicar el nombre de las calles'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 52,
    text: '¿En qué caso se permite estacionarse en segunda fila?',
    options: [
      Option(id: 1, text: 'En ningún caso'),
      Option(id: 2, text: 'Cuando sea solo por unos minutos'),
      Option(id: 3, text: 'Cuando no haya tránsito'),
      Option(id: 4, text: 'En zonas escolares con autorización'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 53,
    text:
        'Indique cuál es la condición para que los vehículos puedan realizar el ascenso y descenso de pasajeros',
    options: [
      Option(id: 1, text: 'Que el vehículo esté sin movimiento.'),
      Option(id: 2, text: 'Que el vehículo use luces intermitentes'),
      Option(id: 3, text: 'Que el vehículo se detenga solo parcialmente'),
      Option(id: 4, text: 'Que el conductor lo indique con la mano'),
    ],
    correctOptionId: 1,
  ),
  Question(
    id: 54,
    text: '¿Cuál es el objeto de las señales informativas?',
    options: [
      Option(
        id: 1,
        text:
            'Servir de guía para localizar o identificar calles, carreteras, nombres de poblaciones y lugares de interés con servicios existentes',
      ),
      Option(id: 2, text: 'Informar sobre los límites de velocidad'),
      Option(id: 3, text: 'Restringir el tránsito de vehículos'),
      Option(id: 4, text: 'Advertir sobre zonas escolares'),
    ],
    correctOptionId: 1,
  ),
];
