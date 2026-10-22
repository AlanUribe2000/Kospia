import { useState } from 'react'
import ModalShell from './ModalShell.tsx'
import type { ProfessionalSpecies } from '../types/observations.ts'

interface Props {
  species: ProfessionalSpecies
  busy: boolean
  error: string | null
  blocked: boolean
  scope?: 'photo' | 'all'
  onConfirm: (comment: string) => void
  onCancel: () => void
  onBack: () => void
}

function SpeciesConfirmModal({
  species,
  busy,
  error,
  blocked,
  scope = 'all',
  onConfirm,
  onCancel,
  onBack,
}: Props) {
  const [comment, setComment] = useState('')

  const intro =
    scope === 'photo'
      ? 'La fotografía será reasignada y validada como:'
      : 'Todas las fotografías serán reasignadas y validadas como:'

  return (
    <ModalShell title="Confirmar especie" busy={busy} onClose={onCancel}>
      <p>{intro}</p>
      <p className="modal-species">
        <strong>{species.common_name}</strong>
        <em className="secondary-text">{species.scientific_name}</em>
        <small>{species.family ?? 'Familia no disponible'}</small>
      </p>

      <div className="form">
        <label htmlFor="species-comment">Comentario (opcional)</label>
        <textarea
          id="species-comment"
          rows={3}
          value={comment}
          disabled={busy || blocked}
          onChange={(e) => setComment(e.target.value)}
          placeholder="Ej.: La fotografía pertenece a la especie correcta, corregido y validado."
        />
      </div>

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
              onClick={() => onConfirm(comment.trim())}
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
