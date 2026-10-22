import ModalShell from './ModalShell.tsx'
import type { SpeciesSummary } from '../types/observations.ts'

interface Props {
  species: SpeciesSummary | null
  busy: boolean
  error: string | null
  notFound: boolean
  scope?: 'photo' | 'all'
  onConfirm: () => void
  onCancel: () => void
  onBack: () => void
}

function ValidationConfirmModal({
  species,
  busy,
  error,
  notFound,
  scope = 'all',
  onConfirm,
  onCancel,
  onBack,
}: Props) {
  const question =
    scope === 'photo'
      ? '¿Confirmás que esta fotografía corresponde a la especie propuesta?'
      : '¿Confirmás que todas las fotografías corresponden a la especie propuesta?'
  const confirmLabel =
    scope === 'photo' ? 'Validar fotografía' : 'Validar todas'

  return (
    <ModalShell title="Confirmar validación" busy={busy} onClose={onCancel}>
      <p>{question}</p>
      {species && (
        <p className="modal-species">
          <strong>{species.common_name || 'Especie no disponible'}</strong>
          {species.scientific_name && (
            <em className="secondary-text">{species.scientific_name}</em>
          )}
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
            <button
              type="button"
              className="btn-validate"
              onClick={onConfirm}
              disabled={busy}
            >
              {busy ? 'Validando…' : error ? 'Reintentar' : confirmLabel}
            </button>
          </>
        )}
      </div>
    </ModalShell>
  )
}

export default ValidationConfirmModal
