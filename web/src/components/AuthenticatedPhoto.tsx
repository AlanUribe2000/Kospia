import { useEffect, useState } from 'react'
import { ApiError, getAttachmentBlob } from '../api/client.ts'

interface Props {
  token: string
  photoId: string
  alt: string
  onSessionInvalid: (message: string) => void
  // Informa la URL disponible (o null al liberarla); el dueño sigue siendo este componente.
  onImageChange?: (photoId: string, url: string | null) => void
  onOpen?: () => void
  openLabel?: string
}

// El resultado queda asociado a la carga que lo produjo.
type Result =
  | { key: string; url: string }
  | { key: string; unavailable: boolean }

function AuthenticatedPhoto({
  token,
  photoId,
  alt,
  onSessionInvalid,
  onImageChange,
  onOpen,
  openLabel,
}: Props) {
  const [attempt, setAttempt] = useState(0)
  const [result, setResult] = useState<Result | null>(null)

  const key = `${photoId}:${attempt}`
  const current = result !== null && result.key === key ? result : null

  useEffect(() => {
    const controller = new AbortController()
    let objectUrl: string | null = null

    getAttachmentBlob(token, photoId, controller.signal).then(
      (blob) => {
        if (controller.signal.aborted) return
        objectUrl = URL.createObjectURL(blob)
        setResult({ key, url: objectUrl })
        onImageChange?.(photoId, objectUrl)
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
          unavailable: error instanceof ApiError && error.kind === 'notFound',
        })
      },
    )

    // Se revoca al cambiar de foto/token, reintentar o desmontar.
    return () => {
      controller.abort()
      if (objectUrl) {
        onImageChange?.(photoId, null)
        URL.revokeObjectURL(objectUrl)
      }
    }
  }, [token, photoId, key, onSessionInvalid, onImageChange])

  if (current === null) {
    return (
      <div className="photo-frame photo-placeholder" role="status">
        Cargando fotografía…
      </div>
    )
  }

  if ('url' in current) {
    return (
      <div className="photo-frame">
        {onOpen ? (
          <button
            type="button"
            className="photo-open"
            aria-label={openLabel ?? 'Ampliar fotografía'}
            onClick={onOpen}
          >
            <img src={current.url} alt={alt} />
          </button>
        ) : (
          <img src={current.url} alt={alt} />
        )}
      </div>
    )
  }

  return (
    <div className="photo-frame photo-placeholder">
      {current.unavailable ? (
        <span>Fotografía no disponible</span>
      ) : (
        <>
          <span>No se pudo cargar la fotografía</span>
          <button
            type="button"
            className="secondary"
            onClick={() => setAttempt((n) => n + 1)}
          >
            Reintentar
          </button>
        </>
      )}
    </div>
  )
}

export default AuthenticatedPhoto
