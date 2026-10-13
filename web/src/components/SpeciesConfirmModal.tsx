import ModalShell from './ModalShell.tsx'
import type { ProfessionalSpecies } from '../types/observations.ts'

interface Props {
  species: ProfessionalSpecies
  busy: boolean
  error: string | null
  blocked: boolean
  onConfirm: () => void
  onCancel: () => void
  onBack: () => void
}

function SpeciesConfirmModal({
  species,
  busy,
  error,
  blocked,
  onConfirm,
  onCancel,
  onBack,
}: Props) {
  return (
    <ModalShell title="Confirmar especie" busy={busy} onClose={onCancel}>
      <p>La observación será validada como:</p>
      <p className="modal-species">
        <strong>{species.common_name}</strong>
        <em className="secondary-text">{species.scientific_name}</em>
        <small>{species.family ?? 'Familia no disponible'}</small>
      </p>

      {error && (
        <p className="alert" role="alert">
          {error}
        </p>
      )}

      <div className="actions modal-actions">
        {blocked ? (
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
            <button
              type="button"
              className="btn-validate"
              onClick={onConfirm}
              disabled={busy}
            >
              {busy
                ? 'Confirmando…'
                : error
                  ? 'Reintentar'
                  : 'Confirmar especie'}
            </button>
          </>
        )}
      </div>
    </ModalShell>
  )
}

export default SpeciesConfirmModal
