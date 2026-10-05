import { useCallback, useEffect, useRef, useState } from 'react'
import { ApiError, updateObservationValidation } from '../api/client.ts'
import type {
  SpeciesSummary,
  ValidationPayload,
  ValidationResult,
} from '../types/observations.ts'
import RejectionModal from './RejectionModal.tsx'
import ValidationConfirmModal from './ValidationConfirmModal.tsx'

interface Props {
  token: string
  observationId: string
  species: SpeciesSummary | null
  onDecided: (result: ValidationResult) => void
  onSessionInvalid: (message: string) => void
  onBack: () => void
}

type Dialog = 'validate' | 'reject' | null

function DecisionSection({
  token,
  observationId,
  species,
  onDecided,
  onSessionInvalid,
  onBack,
}: Props) {
  const [dialog, setDialog] = useState<Dialog>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)
  // Error definitivo (404/409): no se reintenta, solo se vuelve al listado.
  const [blocked, setBlocked] = useState(false)

  const controllerRef = useRef<AbortController | null>(null)
  const busyRef = useRef(false)

  // Cancela un PATCH en curso si se abandona la observación o la sesión.
  useEffect(() => () => controllerRef.current?.abort(), [])

  const closeDialog = useCallback(() => {
    setDialog(null)
    setError(null)
    setBlocked(false)
  }, [])

  async function submit(payload: ValidationPayload) {
    if (busyRef.current) return
    busyRef.current = true

    const controller = new AbortController()
    controllerRef.current = controller

    setBusy(true)
    setError(null)

    try {
      const { observation } = await updateObservationValidation(
        token,
        observationId,
        payload,
        controller.signal,
      )
      if (controller.signal.aborted) return
      onDecided(observation)
    } catch (err) {
      if (controller.signal.aborted) return

      if (
        err instanceof ApiError &&
        (err.kind === 'unauthorized' || err.kind === 'forbidden')
      ) {
        onSessionInvalid(err.message)
        return
      }

      setBlocked(
        err instanceof ApiError &&
          (err.kind === 'notFound' || err.kind === 'conflict'),
      )
      setError(
        err instanceof ApiError ? err.message : 'Ocurrió un error inesperado.',
      )
    } finally {
      busyRef.current = false
      if (!controller.signal.aborted) setBusy(false)
    }
  }

  return (
    <section className="panel decision">
      <h3>Decisión profesional</h3>
      <p className="muted">
        {species
          ? 'Revisá los datos y las fotografías antes de tomar una decisión.'
          : 'Esta observación no tiene una especie propuesta válida. Para validarla primero deberá identificarse o corregirse la especie (función aún no disponible). Por ahora solo puede rechazarse.'}
      </p>
      <div className="actions">
        <button
          type="button"
          className="btn-validate"
          disabled={species === null}
          onClick={() => setDialog('validate')}
        >
          Validar observación
        </button>
        <button
          type="button"
          className="btn-reject-outline"
          onClick={() => setDialog('reject')}
        >
          Rechazar observación
        </button>
      </div>

      {dialog === 'validate' && species && (
        <ValidationConfirmModal
          species={species}
          busy={busy}
          error={error}
          notFound={blocked}
          onConfirm={() => void submit({ validation_status: 'validated' })}
          onCancel={closeDialog}
          onBack={onBack}
        />
      )}

      {dialog === 'reject' && (
        <RejectionModal
          busy={busy}
          error={error}
          notFound={blocked}
          onSubmit={(reason) =>
            void submit({
              validation_status: 'rejected',
              rejection_reason: reason,
            })
          }
          onCancel={closeDialog}
          onBack={onBack}
        />
      )}
    </section>
  )
}

export default DecisionSection
