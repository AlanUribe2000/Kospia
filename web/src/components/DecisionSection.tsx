import { useCallback, useEffect, useRef, useState } from 'react'
import {
  ApiError,
  getProfessionalSpecies,
  updateObservationValidation,
} from '../api/client.ts'
import type {
  ProfessionalSpecies,
  SpeciesSummary,
  ValidationPayload,
  ValidationResult,
} from '../types/observations.ts'
import RejectionModal from './RejectionModal.tsx'
import SpeciesConfirmModal from './SpeciesConfirmModal.tsx'
import ValidationConfirmModal from './ValidationConfirmModal.tsx'
import { SpeciesPickerModal } from './SpeciesPickerModal.tsx'

interface Props {
  token: string
  observationId: string
  species: SpeciesSummary | null
  onDecided: (result: ValidationResult, signal: AbortSignal) => Promise<void>
  onSessionInvalid: (message: string) => void
  onBack: () => void
}

type Dialog = 'validate' | 'species' | 'confirmSpecies' | 'reject' | null
type SpeciesLoadState = 'idle' | 'loading' | 'loaded' | 'error'

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
  const [blocked, setBlocked] = useState(false)
  const [availableSpecies, setAvailableSpecies] = useState<ProfessionalSpecies[]>([])
  const [speciesLoadState, setSpeciesLoadState] = useState<SpeciesLoadState>('idle')
  const [speciesError, setSpeciesError] = useState<string | null>(null)
  const [selectedSpecies, setSelectedSpecies] = useState<ProfessionalSpecies | null>(null)

  const controllerRef = useRef<AbortController | null>(null)
  const speciesControllerRef = useRef<AbortController | null>(null)
  const busyRef = useRef(false)

  useEffect(
    () => () => {
      controllerRef.current?.abort()
      speciesControllerRef.current?.abort()
    },
    [],
  )

  const closeDialog = useCallback(() => {
    setDialog(null)
    setError(null)
    setBlocked(false)
    setSelectedSpecies(null)
  }, [])

  const loadSpecies = useCallback(async () => {
    if (speciesLoadState === 'loading' || speciesLoadState === 'loaded') return
    if (speciesControllerRef.current && !speciesControllerRef.current.signal.aborted) {
      return
    }

    const controller = new AbortController()
    speciesControllerRef.current = controller
    setSpeciesLoadState('loading')
    setSpeciesError(null)

    try {
      const speciesList = await getProfessionalSpecies(token, controller.signal)
      if (controller.signal.aborted) return
      setAvailableSpecies(speciesList)
      setSpeciesLoadState('loaded')
    } catch (err) {
      if (controller.signal.aborted) return

      if (
        err instanceof ApiError &&
        (err.kind === 'unauthorized' || err.kind === 'forbidden')
      ) {
        onSessionInvalid(err.message)
        return
      }

      setSpeciesLoadState('error')
      setSpeciesError(
        err instanceof ApiError
          ? err.message
          : 'No se pudieron cargar las especies.',
      )
    } finally {
      if (speciesControllerRef.current === controller) {
        speciesControllerRef.current = null
      }
    }
  }, [onSessionInvalid, speciesLoadState, token])

  function openSpeciesPicker() {
    setDialog('species')
    void loadSpecies()
  }

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
      await onDecided(observation, controller.signal)
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
          ? 'Revisá los datos y las fotografías. Podés validar la especie propuesta, corregirla o rechazar la observación.'
          : 'Esta observación no tiene una especie propuesta válida. Podés identificar la especie o rechazar la observación.'}
      </p>
      <div className="actions">
        {species && (
          <button
            type="button"
            className="btn-validate"
            disabled={busy}
            onClick={() => setDialog('validate')}
          >
            Validar propuesta
          </button>
        )}

        <button type="button" onClick={openSpeciesPicker} disabled={busy}>
          {species ? 'Corregir especie' : 'Identificar especie'}
        </button>

        <button
          type="button"
          className="btn-reject-outline"
          onClick={() => setDialog('reject')}
          disabled={busy}
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

      {dialog === 'species' && (
        <SpeciesPickerModal
          species={availableSpecies}
          loading={speciesLoadState === 'loading'}
          error={speciesError}
          onRetry={() => {
            setSpeciesLoadState('idle')
            void loadSpecies()
          }}
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
          onConfirm={() =>
            void submit({
              validation_status: 'validated',
              validated_species_id: selectedSpecies.id,
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
