# Preparacion de PowerSync y rotacion de JWT

La plantilla `service.portable.example.yaml` usa `!env` para claves y tokens.
La imagen instalada admite ese tag solo con variables cuyo nombre empieza por
`PS_`; una variable ausente provoca un error de configuracion. La plantilla se
valido con el parser y el esquema de esa imagen, pero no se ha probado su
arranque completo con PostgreSQL ni se ha puesto en servicio.

La configuracion actualmente versionada `service.yaml` y el enlace `cli.yaml`
no estan saneados. No deben compartirse como si fueran una configuracion segura.
Cambiar la plantilla no modifica el contenedor existente: el servicio activo
monta archivos de otro worktree. No editar ese worktree ni reiniciar servicios
sin autorizacion de sus responsables.

## Variables

Usar `docker/.env.example` solo como referencia para crear `docker/.env` local,
ignorado por Git. Sustituir todos los marcadores por valores privados; los
marcadores no son credenciales validas. `PS_DATA_SOURCE_URI` y
`PS_STORAGE_SOURCE_URI` contienen credenciales de PostgreSQL y tambien son
secretos. TLS esta deshabilitado en la plantilla, como en la configuracion
actual; antes de un despliegue no local debe revisarse su seguridad.

Flask usa `POWERSYNC_JWT_SECRET`, `POWERSYNC_JWT_KID` y
`POWERSYNC_JWT_AUDIENCE`. Sus equivalentes PowerSync son `PS_JWT_SECRET`,
`PS_JWT_KID` y `PS_JWT_AUDIENCE`. La clave es base64url de bytes aleatorios,
no una contrasena ni su hash. Flask decodifica ese valor antes de firmar HS256;
el campo JWK `k` debe contener la misma codificacion base64url. El `kid` y la
audiencia deben coincidir entre ambos servicios. `KOSPIA_JWT_SECRET` es otra
clave distinta y no debe reutilizarse.

`PS_ADMIN_API_TOKEN` es el token administrativo configurado en el servicio.
El CLI acepta `PS_ADMIN_TOKEN` en el proceso que ejecuta `powersync link
self-hosted`; no se debe poner un token real en el `cli.yaml` versionado.
El comando `link` escribe `cli.yaml`: usar un directorio de trabajo separado
e ignorado, con permisos restringidos, y verificar su contenido y la politica
del CLI antes de compartirlo. La ayuda del CLI no garantiza que el token quede
fuera del archivo generado.

Los archivos `.env` reales estan ignorados por Git. El ejemplo de Flask en
`../.env.example` no contiene credenciales utilizables. No registrar valores
de variables, comandos con secretos, respuestas de autenticacion ni trazas que
pudieran contenerlos.

## Validacion aislada pendiente

Antes de sustituir `service.yaml` en el worktree actualizado, levantar una
instancia de prueba separada con datos ficticios, almacenamiento propio y
puertos no utilizados, sin montar bases ni volumenes existentes. Verificar el
arranque, el stream de sincronizacion, acceso de administrador y JWT validos,
invalidos y vencidos. La prueba de parser realizada no verifica estos flujos.
No apuntar la prueba al PostgreSQL principal ni ejecutar sus migraciones.

Despues de probar, retirar los valores literales del archivo versionado y
configurar Compose para aportar las variables necesarias mediante un `.env`
local. Suministrar el token de administracion sin almacenarlo en `cli.yaml`
versionado. Verificar exclusiones y revisar el diff completo antes de commit.
La sustitucion debe planificarse de forma que quien use este worktree prepare
su `.env` antes de iniciar el servicio.

## Rotacion coordinada propuesta

Requiere autorizacion previa y una ventana acordada; no se ejecuto en esta
etapa. El servicio actualmente acepta una clave y Flask firma con un solo `kid`.

1. Verificar respaldo y capacidad de rollback de configuracion; identificar
   todos los emisores y clientes, sin copiar secretos al repositorio.
2. Generar en un entorno seguro una clave aleatoria independiente y un `kid`
   nuevo. Preparar por canales privados la nueva clave para PowerSync y Flask,
   y un nuevo token de administracion. No modificar `KOSPIA_JWT_SECRET` como
   parte de esta rotacion sin un plan separado.
3. En una instancia aislada validar una configuracion que acepte las claves
   antigua y nueva con `kid` distintos; confirmar que el servicio instalado
   valida ambos JWT, rechaza firmas incorrectas y respeta la audiencia.
4. Con autorizacion, desplegar primero PowerSync aceptando ambas claves. El
   mecanismo de aplicacion y un posible reinicio deben acordarse y probarse;
   no se ha verificado una recarga en caliente. Mantener Flask firmando con la
   clave antigua hasta confirmar el servicio.
5. Cambiar Flask para firmar tokens PowerSync con la clave nueva y su `kid`;
   verificar la emision y sincronizacion con clientes de prueba. Un reinicio
   de Flask puede interrumpir peticiones activas.
6. Mantener ambas claves al menos 15 minutos, mas un margen acordado para
   diferencias de reloj y conexiones existentes. El JWT PowerSync emitido por
   Flask dura 15 minutos; confirmar la renovacion y reconexion de los clientes
   antes de retirar la clave antigua. Si se retira demasiado pronto, pueden
   fallar autenticaciones o sincronizaciones; conservar la base offline.
7. Retirar la clave antigua solo tras verificar clientes y logs. Rotar aparte
   los tokens administrativos y actualizar los operadores autorizados. Si
   falla la transicion, usar el plan de rollback aprobado, sin borrar datos.

## Historial Git

La clave versionada coincide con la configurada en el entorno activo y debe
considerarse expuesta. Rotarla no elimina las copias anteriores del historial,
clones, backups o logs. Informar a los colaboradores, inventariar exposicion
y decidir una estrategia con los responsables del repositorio. Reescribir
historial, limpiar copias o revocar credenciales requiere plan y autorizacion;
no se realizo aqui.