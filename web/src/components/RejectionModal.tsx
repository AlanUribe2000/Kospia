import { useState } from 'react'
import type { FormEvent } from 'react'
import ModalShell from './ModalShell.tsx'

interface Props {
  busy: boolean
  error: string | null
  notFound: boolean
  onSubmit: (reason: string) => void
  onCancel: () => void
  onBack: () => void
}

// El texto vive aquí y se conserva si el PATCH falla (el modal sigue abierto).
function RejectionModal({
  busy,
  error,
  notFound,
  onSubmit,
  onCancel,
  onBack,
}: Props) {
  const [reason, setReason] = useState('')
  const [reasonError, setReasonError] = useState<string | null>(null)

  function handleSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return

    const trimmed = reason.trim()
    if (!trimmed) {
      setReasonError('Indicá el motivo del rechazo.')
      return
    }

    setReasonError(null)
    onSubmit(trimmed)
  }

  return (
    <ModalShell title="Rechazar observación" busy={busy} onClose={onCancel}>
      <form onSubmit={handleSubmit} className="form">
        <label htmlFor="rejection-reason">Motivo del rechazo</label>
        <textarea
          id="rejection-reason"
          rows={5}
          value={reason}
          disabled={busy || notFound}
          onChange={(e) => setReason(e.target.value)}
        />

        {reasonError && (
          <p className="alert" role="alert">
            {reasonError}
          </p>
        )}
        {error && (
          <p className="alert" role="alert">
            {error}
          </p>
        )}

        <div className="actions modal-actions">
          {notFound ? (
            <button type="button" onClick={onBack}>
              Volver a observaciones
            </button>
          ) : (
            <>
              <button
                type="button"
                className="secondary"
                onClick={onCancel}
                disabled={busy}
              >
                Cancelar
              </button>
              <button type="submit" className="btn-reject" disabled={busy}>
                {busy
                  ? 'Rechazando…'
                  : error
                    ? 'Reintentar'
                    : 'Rechazar observación'}
              </button>
            </>
          )}
        </div>
      </form>
    </ModalShell>
  )
}

export default RejectionModal
