import { useCallback, useEffect, useState } from 'react'
import { ApiError, decidePhotoValidation, getProfessionalObservation } from '../api/client.ts'
import AuthenticatedPhoto from './AuthenticatedPhoto.tsx'
import PhotoLightbox from './PhotoLightbox.tsx'
import DecisionSection from './DecisionSection.tsx'
import PhotoDecisionControls from './PhotoDecisionControls.tsx'
import PhotoMap from './PhotoMap.tsx'
import type { LightboxItem } from './PhotoLightbox.tsx'
import type {
  ObservationDetail,
  ObservationPhoto,
  PhotoDecisionPayload,
  SpeciesSummary,
} from '../types/observations.ts'
import { useProfessionalSpecies } from '../hooks/useProfessionalSpecies.ts'
import type { ProfessionalSpeciesState } from '../hooks/useProfessionalSpecies.ts'
import { STATUS_LABEL, formatDate, toNumber } from '../utils/format.ts'

interface Props {
  token: string
  observationId: string
  onBack: () => void
  onSessionInvalid: (message: string) => void
}

const SOURCE_LABEL: Record<string, string> = {
  camera: 'Cámara',
  gallery: 'Galería',
}

function sourceLabel(source: string): string {
  return SOURCE_LABEL[source] ?? source
}

function capitalize(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1)
}

function locationText(photo: ObservationPhoto): string {
  const lat = toNumber(photo.latitude)
  const lon = toNumber(photo.longitude)
  if (lat === null || lon === null) return 'Ubicación no disponible'
  return `${lat.toFixed(6)}, ${lon.toFixed(6)}`
}

// El resultado queda asociado a la consulta que lo produjo.
type Result =
  | { key: string; observation: ObservationDetail }
  | { key: string; error: string; notFound: boolean }

function ObservationDetailView({
  token,
  observationId,
  onBack,
  onSessionInvalid,
}: Props) {
  const [attempt, setAttempt] = useState(0)
  const [result, setResult] = useState<Result | null>(null)

  const key = `${observationId}:${attempt}`
  const loading = result === null || result.key !== key

  useEffect(() => {
    const controller = new AbortController()

    getProfessionalObservation(token, observationId, controller.signal).then(
      ({ observation }) => {
        if (!controller.signal.aborted) {
          setResult({ key, observation })
        }
      },
      (error: unknown) => {
        if (controller.signal.aborted) return

        if (
          error instanceof ApiError &&
          (error.kind === 'unauthorized' || error.kind === 'forbidden')
        ) {
          onSessionInvalid(error.message)
          return
        }

        setResult({
          key,
          notFound: error instanceof ApiError && error.kind === 'notFound',
          error:
            error instanceof ApiError
              ? error.message
              : 'Ocurrió un error inesperado.',
        })
      },
    )

    return () => controller.abort()
  }, [token, observationId, key, onSessionInvalid])

  return (
    <section className="detail">
      <button type="button" className="secondary back" onClick={onBack}>
        ← Volver a observaciones
      </button>

      {loading && (
        <p className="muted" role="status">
          Cargando observación…
        </p>
      )}

      {!loading && result && 'error' in result && (
        <div className="form">
          <p className="alert" role="alert">
            {result.error}
          </p>
          {!result.notFound && (
            <div className="actions">
              <button type="button" onClick={() => setAttempt((n) => n + 1)}>
                Reintentar
              </button>
            </div>
          )}
        </div>
      )}

      {!loading && result && 'observation' in result && (
        <DetailContent
          key={result.key}
          observation={result.observation}
          token={token}
          onSessionInvalid={onSessionInvalid}
          onBack={onBack}
        />
      )}
    </section>
  )
}

function DetailContent({
  observation: initialObservation,
  token,
  onSessionInvalid,
  onBack,
}: {
  observation: ObservationDetail
  token: string
  onSessionInvalid: (message: string) => void
  onBack: () => void
}) {
  // Se actualiza solo con lo que confirma el servidor tras el PATCH.
  const [o, setObservation] = useState(initialObservation)
  const [refreshNotice, setRefreshNotice] = useState<string | null>(null)
  const speciesState = useProfessionalSpecies(token, onSessionInvalid)

  const userName = o.user.display_name || o.user.email || 'Usuario no disponible'
  const showEmail = o.user.display_name && o.user.email

  // Tras cualquier decisión (por-foto o masiva), recarga el detalle completo
  // para reflejar estados por-foto, resumen y agregado desde el servidor.
  const reload = useCallback(
    async (signal: AbortSignal) => {
      setRefreshNotice(null)
      try {
        const response = await getProfessionalObservation(token, o.id, signal)
        if (signal.aborted) return
        setObservation(response.observation)
      } catch (error) {
        if (signal.aborted) return
        if (
          error instanceof ApiError &&
          (error.kind === 'unauthorized' || error.kind === 'forbidden')
        ) {
          onSessionInvalid(error.message)
          return
        }

        setRefreshNotice(
          'La decisión se guardó, pero no se pudo recargar el detalle. Volvé a abrir la observación para ver el estado actualizado.',
        )
      }
    },
    [onSessionInvalid, o.id, token],
  )

  const submitPhoto = useCallback(
    async (
      photoId: string,
      payload: PhotoDecisionPayload,
      signal: AbortSignal,
    ) => {
      await decidePhotoValidation(token, o.id, photoId, payload, signal)
      if (signal.aborted) return
      await reload(signal)
    },
    [o.id, reload, token],
  )

  // URLs ya cargadas por cada AuthenticatedPhoto; el visor solo las reutiliza.
  const [loadedUrls, setLoadedUrls] = useState<Record<string, string>>({})
  const [openPhotoId, setOpenPhotoId] = useState<string | null>(null)

  const handleImageChange = useCallback(
    (photoId: string, url: string | null) => {
      setLoadedUrls((prev) => {
        const next = { ...prev }
        if (url === null) {
          delete next[photoId]
        } else {
          next[photoId] = url
        }
        return next
      })
    },
    [],
  )

  const lightboxItems: LightboxItem[] = o.photos.flatMap((photo, i) =>
    loadedUrls[photo.id]
      ? [
          {
            id: photo.id,
            url: loadedUrls[photo.id],
            alt: `Fotografía ${i + 1} de la observación`,
          },
        ]
      : [],
  )
  const lightboxOpen =
    openPhotoId !== null && lightboxItems.some((item) => item.id === openPhotoId)

  const summary = o.summary

  return (
    <>
      <header className="detail-header">
        <h2>Detalle de la observación</h2>
        <span className={`badge badge-${o.validation_status}`}>
          {STATUS_LABEL[o.validation_status]}
        </span>
      </header>

      <div className="photo-summary">
        <span className="badge badge-validated">
          {summary.validated} validadas
        </span>
        <span className="badge badge-rejected">
          {summary.rejected} rechazadas
        </span>
        <span className="badge badge-pending">
          {summary.pending} pendientes
        </span>
      </div>

      {refreshNotice && (
        <p className="alert" role="alert">
          {refreshNotice}
        </p>
      )}

      <div className="detail-grid">
        <section className="panel">
          <h3>Información general</h3>
          <dl>
            <dt>Fecha de creación</dt>
            <dd>{formatDate(o.created_at)}</dd>
            <dt>Última actualización</dt>
            <dd>{formatDate(o.updated_at)}</dd>
            <dt>Sincronizada</dt>
            <dd>{formatDate(o.synced_at)}</dd>
            <dt>Usuario</dt>
            <dd>
              {userName}
              {showEmail && <em className="secondary-text">{o.user.email}</em>}
            </dd>
          </dl>
        </section>

        <section className="panel">
          <h3>Especie propuesta</h3>
          <dl>
            <dt>Nombre común</dt>
            <dd>
              {o.proposed_species ? (
                o.proposed_species.common_name || 'Especie no disponible'
              ) : (
                <span className="muted-text">Sin especie propuesta</span>
              )}
            </dd>
            <dt>Nombre científico</dt>
            <dd>{o.proposed_species?.scientific_name || '—'}</dd>
          </dl>
        </section>
      </div>

      <section className="panel">
        <h3>Notas</h3>
        <p className="notes">{o.notes?.trim() ? o.notes : 'Sin notas'}</p>
      </section>

      <section className="panel">
        <h3>Fotografías ({o.photos.length})</h3>
        {o.photos.length === 0 ? (
          <p className="muted">Esta observación no tiene fotografías.</p>
        ) : (
          <div className="photo-grid">
            {o.photos.map((photo, index) => (
              <PhotoCard
                key={photo.id}
                photo={photo}
                index={index + 1}
                token={token}
                proposedSpecies={o.proposed_species}
                speciesState={speciesState}
                submitPhoto={submitPhoto}
                onSessionInvalid={onSessionInvalid}
                onImageChange={handleImageChange}
                onOpen={() => setOpenPhotoId(photo.id)}
                onBack={onBack}
              />
            ))}
          </div>
        )}
      </section>

      {o.photos.length > 0 && (
        <DecisionSection
          token={token}
          observationId={o.id}
          species={o.proposed_species}
          speciesState={speciesState}
          onDecided={reload}
          onSessionInvalid={onSessionInvalid}
          onBack={onBack}
        />
      )}

      {lightboxOpen && openPhotoId !== null && (
        <PhotoLightbox
          items={lightboxItems}
          currentId={openPhotoId}
          onClose={() => setOpenPhotoId(null)}
          onSelect={setOpenPhotoId}
        />
      )}
    </>
  )
}

function PhotoCard({
  photo,
  index,
  token,
  proposedSpecies,
  speciesState,
  submitPhoto,
  onSessionInvalid,
  onImageChange,
  onOpen,
  onBack,
}: {
  photo: ObservationPhoto
  index: number
  token: string
  proposedSpecies: SpeciesSummary | null
  speciesState: ProfessionalSpeciesState
  submitPhoto: (
    photoId: string,
    payload: PhotoDecisionPayload,
    signal: AbortSignal,
  ) => Promise<void>
  onSessionInvalid: (message: string) => void
  onImageChange: (photoId: string, url: string | null) => void
  onOpen: () => void
  onBack: () => void
}) {
  const altitude = toNumber(photo.altitude)
  const accuracy = toNumber(photo.accuracy)
  const lat = toNumber(photo.latitude)
  const lon = toNumber(photo.longitude)

  const submit = useCallback(
    (payload: PhotoDecisionPayload, signal: AbortSignal) =>
      submitPhoto(photo.id, payload, signal),
    [photo.id, submitPhoto],
  )

  return (
    <article className="photo-card">
      <div className="photo-card-header">
        <h4>Fotografía {index}</h4>
        <span className={`badge badge-${photo.validation_status}`}>
          {STATUS_LABEL[photo.validation_status]}
        </span>
      </div>
      <AuthenticatedPhoto
        token={token}
        photoId={photo.id}
        alt={`Fotografía ${index} de la observación`}
        onSessionInvalid={onSessionInvalid}
        onImageChange={onImageChange}
        onOpen={onOpen}
        openLabel={`Ampliar fotografía ${index}`}
      />

      {lat !== null && lon !== null && (
        <PhotoMap
          latitude={lat}
          longitude={lon}
          label={`Ubicación de la fotografía ${index}`}
        />
      )}

      <dl>
        {photo.plant_part && (
          <>
            <dt>Parte</dt>
            <dd>{capitalize(photo.plant_part)}</dd>
          </>
        )}
        {photo.source && (
          <>
            <dt>Origen</dt>
            <dd>{sourceLabel(photo.source)}</dd>
          </>
        )}
        <dt>Fecha de captura</dt>
        <dd>{formatDate(photo.captured_at)}</dd>
        <dt>Ubicación</dt>
        <dd>{locationText(photo)}</dd>
        {accuracy !== null && (
          <>
            <dt>Precisión</dt>
            <dd>±{accuracy.toFixed(1)} m</dd>
          </>
        )}
        {altitude !== null && (
          <>
            <dt>Altitud</dt>
            <dd>{altitude.toFixed(1)} m</dd>
          </>
        )}
        {photo.file_extension && (
          <>
            <dt>Formato</dt>
            <dd>{photo.file_extension.toUpperCase()}</dd>
          </>
        )}
        {photo.validated_species && (
          <>
            <dt>Especie corregida</dt>
            <dd>
              {photo.validated_species.common_name || 'Especie no disponible'}
              {photo.validated_species.scientific_name && (
                <em className="secondary-text">
                  {photo.validated_species.scientific_name}
                </em>
              )}
            </dd>
          </>
        )}
      </dl>

      {photo.validation_comment && (
        <p className="photo-comment">{photo.validation_comment}</p>
      )}

      <PhotoDecisionControls
        proposedSpecies={proposedSpecies}
        scope="photo"
        speciesState={speciesState}
        submit={submit}
        onSessionInvalid={onSessionInvalid}
        onBack={onBack}
        validateLabel="Validar"
        reassignLabel="Cambiar especie"
        rejectLabel="Rechazar"
      />
    </article>
  )
}

export default ObservationDetailView
