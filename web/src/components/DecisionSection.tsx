import { useCallback } from 'react'
import { decideAllPhotosValidation } from '../api/client.ts'
import type {
  PhotoDecisionPayload,
  SpeciesSummary,
} from '../types/observations.ts'
import type { ProfessionalSpeciesState } from '../hooks/useProfessionalSpecies.ts'
import PhotoDecisionControls from './PhotoDecisionControls.tsx'

interface Props {
  token: string
  observationId: string
  species: SpeciesSummary | null
  speciesState: ProfessionalSpeciesState
  onDecided: (signal: AbortSignal) => Promise<void>
  onSessionInvalid: (message: string) => void
  onBack: () => void
}

// Acción rápida: aplica una misma decisión a TODAS las fotografías a la vez.
// Se conserva por pedido explícito del usuario para el caso "las 5 están bien".
function DecisionSection({
  token,
  observationId,
  species,
  speciesState,
  onDecided,
  onSessionInvalid,
  onBack,
}: Props) {
  const submit = useCallback(
    async (payload: PhotoDecisionPayload, signal: AbortSignal) => {
      await decideAllPhotosValidation(token, observationId, payload, signal)
      if (signal.aborted) return
      await onDecided(signal)
    },
    [observationId, onDecided, token],
  )

  return (
    <section className="panel decision">
      <h3>Acción rápida — aplicar a todas las fotos</h3>
      <p className="muted">
        {species
          ? 'Aplicá la misma decisión a todas las fotografías de la observación: validar la especie propuesta, corregirla o rechazarlas.'
          : 'Esta observación no tiene una especie propuesta válida. Podés reasignar todas las fotografías a una especie o rechazarlas.'}
      </p>
      <PhotoDecisionControls
        proposedSpecies={species}
        scope="all"
        speciesState={speciesState}
        submit={submit}
        onSessionInvalid={onSessionInvalid}
        onBack={onBack}
        validateLabel="Validar todas"
        reassignLabel={species ? 'Corregir especie de todas' : 'Identificar especie'}
        rejectLabel="Rechazar todas"
      />
    </section>
  )
}

export default DecisionSection
