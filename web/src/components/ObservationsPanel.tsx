import { useEffect, useState } from 'react'
import { ApiError, getProfessionalObservations } from '../api/client.ts'
import type {
  ObservationSummary,
  ValidationStatus,
} from '../types/observations.ts'
import { STATUS_LABEL, formatDate } from '../utils/format.ts'

interface Props {
  token: string
  filter: ValidationStatus
  onFilterChange: (filter: ValidationStatus) => void
  onSelect: (observationId: string) => void
  onSessionInvalid: (message: string) => void
}

const FILTERS: { value: ValidationStatus; label: string; empty: string }[] = [
  { value: 'pending', label: 'Pendientes', empty: 'No hay observaciones pendientes.' },
  { value: 'validated', label: 'Validadas', empty: 'No hay observaciones validadas.' },
  { value: 'rejected', label: 'Rechazadas', empty: 'No hay observaciones rechazadas.' },
]

function userLabel(observation: ObservationSummary): string {
  return (
    observation.user.display_name ||
    observation.user.email ||
    'Usuario no disponible'
  )
}

// El resultado queda asociado a la consulta que lo produjo.
type Result =
  | { key: string; observations: ObservationSummary[] }
  | { key: string; error: string }

function ObservationsPanel({
  token,
  filter,
  onFilterChange,
  onSelect,
  onSessionInvalid,
}: Props) {
  const [attempt, setAttempt] = useState(0)
  const [result, setResult] = useState<Result | null>(null)

  const key = `${filter}:${attempt}`
  const loading = result === null || result.key !== key

  useEffect(() => {
    const controller = new AbortController()

    getProfessionalObservations(token, filter, controller.signal).then(
      ({ observations }) => {
        if (!controller.signal.aborted) {
          setResult({ key, observations })
        }
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
          error:
            error instanceof ApiError
              ? error.message
              : 'Ocurrió un error inesperado.',
        })
      },
    )

    return () => controller.abort()
  }, [token, filter, key, onSessionInvalid])

  const current = FILTERS.find((f) => f.value === filter)!

  return (
    <section className="observations">
      <h2>Observaciones</h2>

      <div className="filters" role="tablist" aria-label="Filtrar por estado">
        {FILTERS.map((f) => (
          <button
            key={f.value}
            type="button"
            role="tab"
            aria-selected={filter === f.value}
            className={filter === f.value ? 'filter active' : 'filter'}
            onClick={() => onFilterChange(f.value)}
          >
            {f.label}
          </button>
        ))}
      </div>

      {loading && (
        <p className="muted" role="status">
          Cargando observaciones…
        </p>
      )}

      {!loading && result && 'error' in result && (
        <div className="form">
          <p className="alert" role="alert">
            {result.error}
          </p>
          <div className="actions">
            <button type="button" onClick={() => setAttempt((n) => n + 1)}>
              Reintentar
            </button>
          </div>
        </div>
      )}

      {!loading && result && 'observations' in result && (
        result.observations.length === 0 ? (
          <p className="muted">{current.empty}</p>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Fecha</th>
                  <th>Usuario</th>
                  <th>Especie propuesta</th>
                  <th>Fotos</th>
                  <th>Estado</th>
                  <th>
                    <span className="visually-hidden">Acciones</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {result.observations.map((o) => (
                  <tr key={o.id}>
                    <td data-label="Fecha">{formatDate(o.created_at)}</td>
                    <td data-label="Usuario">{userLabel(o)}</td>
                    <td data-label="Especie propuesta">
                      <span>
                        {o.proposed_species.common_name ||
                          'Especie no disponible'}
                      </span>
                      {o.proposed_species.scientific_name && (
                        <em className="secondary-text">
                          {o.proposed_species.scientific_name}
                        </em>
                      )}
                    </td>
                    <td data-label="Fotos">{o.photo_count}</td>
                    <td data-label="Estado">
                      <span className={`badge badge-${o.validation_status}`}>
                        {STATUS_LABEL[o.validation_status]}
                      </span>
                    </td>
                    <td data-label="">
                      <button
                        type="button"
                        className="secondary"
                        onClick={() => onSelect(o.id)}
                      >
                        Ver detalle
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}
    </section>
  )
}

export default ObservationsPanel
