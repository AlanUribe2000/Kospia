import ModalShell from './ModalShell.tsx'
import type { ProposedSpecies } from '../types/observations.ts'

interface Props {
  species: ProposedSpecies
  busy: boolean
  error: string | null
  notFound: boolean
  onConfirm: () => void
  onCancel: () => void
  onBack: () => void
}

function ValidationConfirmModal({
  species,
  busy,
  error,
  notFound,
  onConfirm,
  onCancel,
  onBack,
}: Props) {
  return (
    <ModalShell title="Confirmar validación" busy={busy} onClose={onCancel}>
      <p>¿Confirmás que esta observación corresponde a la especie propuesta?</p>
      <p className="modal-species">
        <strong>{species.common_name || 'Especie no disponible'}</strong>
        {species.scientific_name && (
          <em className="secondary-text">{species.scientific_name}</em>
        )}
      </p>

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
            <button
              type="button"
              className="btn-validate"
              onClick={onConfirm}
              disabled={busy}
            >
              {busy
                ? 'Validando…'
                : error
                  ? 'Reintentar'
                  : 'Confirmar validación'}
            </button>
          </>
        )}
      </div>
    </ModalShell>
  )
}

export default ValidationConfirmModal
