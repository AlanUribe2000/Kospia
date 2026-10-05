import { useCallback, useEffect, useState } from 'react'
import { ApiError, getProfessionalObservation } from '../api/client.ts'
import AuthenticatedPhoto from './AuthenticatedPhoto.tsx'
import PhotoLightbox from './PhotoLightbox.tsx'
import DecisionSection from './DecisionSection.tsx'
import type { LightboxItem } from './PhotoLightbox.tsx'
import type {
  ObservationDetail,
  ObservationPhoto,
  ValidationResult,
} from '../types/observations.ts'
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

function locationLabel(photo: ObservationPhoto): string {
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
  const userName = o.user.display_name || o.user.email || 'Usuario no disponible'
  const showEmail = o.user.display_name && o.user.email

  const handleDecided = useCallback((result: ValidationResult) => {
    setObservation((prev) => ({
      ...prev,
      validation_status: result.validation_status,
      validated_at: result.validated_at,
      validated_by: result.validated_by,
      rejection_reason: result.rejection_reason,
      // Solo se puede resolver localmente si coincide con la propuesta ya cargada.
      confirmed_species:
        result.validated_species_id !== null &&
        prev.proposed_species?.id === result.validated_species_id
          ? prev.proposed_species
          : null,
    }))
  }, [])

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

  return (
    <>
      <header className="detail-header">
        <h2>Detalle de la observación</h2>
        <span className={`badge badge-${o.validation_status}`}>
          {STATUS_LABEL[o.validation_status]}
        </span>
      </header>

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
              {showEmail && (
                <em className="secondary-text">{o.user.email}</em>
              )}
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

        {o.validation_status !== 'rejected' && (
          <section className="panel">
            <h3>Especie confirmada</h3>
            {o.confirmed_species ? (
              <dl>
                <dt>Nombre común</dt>
                <dd>{o.confirmed_species.common_name || 'Especie no disponible'}</dd>
                <dt>Nombre científico</dt>
                <dd>{o.confirmed_species.scientific_name || '—'}</dd>
              </dl>
            ) : (
              <p className="muted-text">
                {o.validation_status === 'validated'
                  ? 'Especie confirmada no registrada'
                  : 'Aún sin confirmar'}
              </p>
            )}
          </section>
        )}
      </div>

      <section className="panel">
        <h3>Notas</h3>
        <p className="notes">{o.notes?.trim() ? o.notes : 'Sin notas'}</p>
      </section>

      {o.validation_status !== 'pending' && (
        <section className="panel">
          <h3>Decisión</h3>
          <dl>
            <dt>Estado</dt>
            <dd>{STATUS_LABEL[o.validation_status]}</dd>
            <dt>
              {o.validation_status === 'validated'
                ? 'Fecha de validación'
                : 'Fecha de decisión'}
            </dt>
            <dd>{formatDate(o.validated_at)}</dd>
            {o.validation_status === 'rejected' && (
              <>
                <dt>Motivo del rechazo</dt>
                <dd className="notes">
                  {o.rejection_reason?.trim() || 'No se registró un motivo.'}
                </dd>
              </>
            )}
          </dl>
        </section>
      )}

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
                onSessionInvalid={onSessionInvalid}
                onImageChange={handleImageChange}
                onOpen={() => setOpenPhotoId(photo.id)}
              />
            ))}
          </div>
        )}
      </section>

      {o.validation_status === 'pending' && (
        <DecisionSection
          token={token}
          observationId={o.id}
          species={o.proposed_species}
          onDecided={handleDecided}
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
  onSessionInvalid,
  onImageChange,
  onOpen,
}: {
  photo: ObservationPhoto
  index: number
  token: string
  onSessionInvalid: (message: string) => void
  onImageChange: (photoId: string, url: string | null) => void
  onOpen: () => void
}) {
  const altitude = toNumber(photo.altitude)
  const accuracy = toNumber(photo.accuracy)

  return (
    <article className="photo-card">
      <h4>Fotografía {index}</h4>
      <AuthenticatedPhoto
        token={token}
        photoId={photo.id}
        alt={`Fotografía ${index} de la observación`}
        onSessionInvalid={onSessionInvalid}
        onImageChange={onImageChange}
        onOpen={onOpen}
        openLabel={`Ampliar fotografía ${index}`}
      />
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
        <dd>{locationLabel(photo)}</dd>
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
      </dl>
    </article>
  )
}

export default ObservationDetailView
