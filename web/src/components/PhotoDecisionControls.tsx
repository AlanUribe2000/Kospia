import { useCallback, useEffect, useRef, useState } from 'react'
import { ApiError } from '../api/client.ts'
import type {
  PhotoDecisionPayload,
  ProfessionalSpecies,
  SpeciesSummary,
} from '../types/observations.ts'
import type { ProfessionalSpeciesState } from '../hooks/useProfessionalSpecies.ts'
import RejectionModal from './RejectionModal.tsx'
import SpeciesConfirmModal from './SpeciesConfirmModal.tsx'
import ValidationConfirmModal from './ValidationConfirmModal.tsx'
import { SpeciesPickerModal } from './SpeciesPickerModal.tsx'

type Dialog = 'validate' | 'species' | 'confirmSpecies' | 'reject' | null

interface Props {
  // Especie propuesta para mostrar en el modal de validación (si existe).
  proposedSpecies: SpeciesSummary | null
  scope: 'photo' | 'all'
  speciesState: ProfessionalSpeciesState
  // Ejecuta el PATCH; resuelve si tuvo éxito. Lanza ApiError en caso de fallo.
  submit: (payload: PhotoDecisionPayload, signal: AbortSignal) => Promise<void>
  onSessionInvalid: (message: string) => void
  onBack: () => void
  // Etiquetas de los botones de acción.
  validateLabel: string
  reassignLabel: string
  rejectLabel: string
}

// Controles de decisión reutilizados por cada foto y por "aplicar a todas".
// Encapsula el estado de los modales y el patrón "modal abierto si falla".
function PhotoDecisionControls({
  proposedSpecies,
  scope,
  speciesState,
  submit,
  onSessionInvalid,
  onBack,
  validateLabel,
  reassignLabel,
  rejectLabel,
}: Props) {
  const [dialog, setDialog] = useState<Dialog>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [blocked, setBlocked] = useState(false)
  const [selectedSpecies, setSelectedSpecies] =
    useState<ProfessionalSpecies | null>(null)

  const controllerRef = useRef<AbortController | null>(null)
  const busyRef = useRef(false)

  useEffect(
    () => () => {
      controllerRef.current?.abort()
    },
    [],
  )

  const closeDialog = useCallback(() => {
    if (busyRef.current) return
    setDialog(null)
    setError(null)
    setBlocked(false)
    setSelectedSpecies(null)
  }, [])

  function openSpeciesPicker() {
    setDialog('species')
    speciesState.load()
  }

  const runSubmit = useCallback(
    async (payload: PhotoDecisionPayload) => {
      if (busyRef.current) return
      busyRef.current = true

      const controller = new AbortController()
      controllerRef.current = controller

      setBusy(true)
      setError(null)

      try {
        await submit(payload, controller.signal)
        if (controller.signal.aborted) return
        setDialog(null)
        setSelectedSpecies(null)
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
          err instanceof ApiError
            ? err.message
            : 'Ocurrió un error inesperado.',
        )
      } finally {
        busyRef.current = false
        if (!controller.signal.aborted) setBusy(false)
      }
    },
    [onSessionInvalid, submit],
  )

  return (
    <div className="photo-actions">
      <button
        type="button"
        className="btn-validate"
        disabled={busy}
        onClick={() => setDialog('validate')}
      >
        {validateLabel}
      </button>

      <button type="button" onClick={openSpeciesPicker} disabled={busy}>
        {reassignLabel}
      </button>

      <button
        type="button"
        className="btn-reject-outline"
        disabled={busy}
        onClick={() => setDialog('reject')}
      >
        {rejectLabel}
      </button>

      {dialog === 'validate' && (
        <ValidationConfirmModal
          species={proposedSpecies}
          busy={busy}
          error={error}
          notFound={blocked}
          scope={scope}
          onConfirm={() => void runSubmit({ action: 'validate' })}
          onCancel={closeDialog}
          onBack={onBack}
        />
      )}

      {dialog === 'species' && (
        <SpeciesPickerModal
          species={speciesState.species}
          loading={speciesState.loadState === 'loading'}
          error={speciesState.error}
          onRetry={speciesState.retry}
          onClose={closeDialog}
          onSelect={(selected) => {
            setSelectedSpecies(selected)
            setError(null)
            setBlocked(false)
            setDialog('confirmSpecies')
          }}
        />
      )}

      {dialog === 'confirmSpecies' && selectedSpecies && (
        <SpeciesConfirmModal
          species={selectedSpecies}
          busy={busy}
          error={error}
          blocked={blocked}
          scope={scope}
          onConfirm={(comment) =>
            void runSubmit({
              action: 'reassign',
              target_species_id: selectedSpecies.id,
              ...(comment ? { comment } : {}),
            })
          }
          onCancel={closeDialog}
          onBack={onBack}
        />
      )}

      {dialog === 'reject' && (
        <RejectionModal
          busy={busy}
          error={error}
          notFound={blocked}
          scope={scope}
          onSubmit={(reason) =>
            void runSubmit({ action: 'reject', comment: reason })
          }
          onCancel={closeDialog}
          onBack={onBack}
        />
      )}
    </div>
  )
}

export default PhotoDecisionControls
