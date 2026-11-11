# Fase B: prueba PowerSync aislada

## Reproducir

Requisitos: Docker disponible en PATH, imagenes locales `postgres:16` y
`journeyapps/powersync-service:latest`, Node.js con `fetch` (Node 18 o mayor).
Las reglas se leen directamente, en solo lectura, desde
`../../api/backend/powersync/sync-config.yaml`. No se copia ni usa la
configuracion de servicio de produccion.

```powershell
node 'C:\Users\Nico\Desktop\Kospia-4B1-integration\tool\powersync-4b3\run.js'
```

La ejecucion genera un prefijo aleatorio y una etiqueta
`org.kospia.phase-b=<prefijo>` para una red y tres contenedores propios. Solo
PowerSync publica un puerto efimero en `127.0.0.1`. La red es nueva y no se
conecta a servicios o redes existentes; no es una red `--internal`, por lo que
no debe interpretarse como una prohibicion de salida a Internet. La telemetria
de PowerSync esta desactivada. Ambas bases PostgreSQL usan tmpfs para sus datos.
No se descargan imagenes (`--pull never`). El ejecutor detiene solo sus propios
contenedores; conserva tanto esos contenedores detenidos como su red. No elimina
volumenes.

## Resultado observado, 2026-11-09

La ejecucion `kospia-phase-b-bb6f718b6510fab5` termino con codigo 0 usando
PowerSync Service y PostgreSQL 16. Todas las siguientes aserciones pasaron con
el cliente HTTP real `POST /sync/stream` y JWT ficticios:

- Insercion y replicacion de `question_options` con descripcion y de
  `question_option_photos` con opcion, orden, extension y fecha de creacion.
  Ambas filas del catalogo global fueron visibles para Alice y Bob.
- Actualizacion de la descripcion, asociacion del icono y disociacion del icono:
  cada cambio llego como `PUT` incremental desde un checkpoint.
- Borrado SQL de la foto de opcion recibido como `REMOVE` incremental desde un
  checkpoint; la opcion y su descripcion actualizada permanecieron visibles.

- Creacion y bajada de `observations.notes` y metadatos de fotos: parte de la
  planta, extension y coordenada.
- Alice y Bob recibieron sus propias observaciones, fotos y notificaciones, sin
  recibir las del otro usuario en esas tablas.
- Actualizacion de notas y metadatos de foto replicada.
- Borrado de una foto recibido como `REMOVE` incremental desde un checkpoint;
  la observacion y la foto de Bob permanecieron visibles para sus propietarios.
- Una solicitud sin JWT recibio HTTP 401.

Hallazgo: las reglas reales incluyen `observaciones` y
`fotografias_observacion` en el stream global sin filtro por usuario. Las filas
ficticias de ambas tablas fueron visibles tanto para Alice como para Bob. Si
esas tablas contienen datos privados, estas reglas los exponen a todo cliente
autenticado suscrito al stream global; comprobar su uso antes de desplegar.

## Alcance y limites

El servicio, PostgreSQL, las reglas y el protocolo HTTP son reales; el esquema,
las filas, las credenciales y los usuarios son sinteticos. El esquema no es una
replica completa del esquema productivo. Las escrituras se realizaron mediante
SQL directamente en PostgreSQL: no se probaron Flutter, el backend, las colas
CRUD, el proceso de upload, ni archivos binarios de fotos. `REMOVE` prueba una
eliminacion del lado servidor propagada a clientes, no que la app pueda subir
una eliminacion. El conector Flutter actual solo admite operaciones `put`.
No se probaron autorizacion de escritura, JWT invalidos o expirados, ni otros
casos de aislamiento distintos de los descritos arriba.

## Recursos de las ejecuciones

Los cuatro intentos anteriores utilizaron respectivamente los prefijos
`kospia-phase-b-6f75ee71c6abf400`, `kospia-phase-b-a6146d68f36432ef`,
`kospia-phase-b-3171489ad92ccb50` y `kospia-phase-b-27816d6b3b16f140`.
Sus contenedores `source`, `storage` y `powersync` quedaron detenidos; las
cuatro redes propias se retiraron. El primer intento consulto el puerto antes
de su publicacion; el segundo uso una red interna que no publicaba el puerto;
en el tercero Node salio prematuramente y se detuvieron sus recursos de forma
explicita. El cuarto termino correctamente. Los contenedores detenidos se
conservan deliberadamente y sus datos tmpfs no persisten tras detenerlos.

En esta ampliacion, el intento `kospia-phase-b-b18a0787f7935643` no paso la
comparacion inicial porque la fila HTTP incluye tambien `id` en `data`; se
corrigio la expectativa. La salida completa del intento
`kospia-phase-b-e595251263ee7846` no fue capturada, por lo que no se afirma su
resultado. El intento `kospia-phase-b-bb6f718b6510fab5` paso con codigo 0;
su salida esta en `execution-evidence.log`. Los tres contenedores `source`,
`storage` y `powersync` de cada uno de estos intentos quedaron detenidos y sus
redes propias se conservaron. No se elimino ningun volumen.