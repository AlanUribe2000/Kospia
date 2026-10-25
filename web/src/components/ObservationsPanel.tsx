import { useCallback, useEffect, useRef, useState } from 'react'
import {
  ApiError,
  getProfessionalObservationCounts,
  getProfessionalObservations,
} from '../api/client.ts'
import type {
  ObservationCounts,
  ObservationSummary,
  ValidationStatus,
} from '../types/observations.ts'
import { STATUS_LABEL, formatDate } from '../utils/format.ts'
import SpeciesName from './SpeciesName.tsx'

interface Props {
  token: string
  filter: ValidationStatus
  onFilterChange: (filter: ValidationStatus) => void
  onSelect: (observationId: string) => void
  onSessionInvalid: (message: string) => void
}

const FILTERS: { value: ValidationStatus; label: string; empty: string }[] = [
  { value: 'pending', label: 'Pendientes', empty: 'No hay observaciones pendientes.' },
  { value: 'reviewed', label: 'Revisadas', empty: 'No hay observaciones revisadas.' },
]

// Intervalo de refresco automático en segundo plano (5 minutos).
const REFRESH_INTERVAL_MS = 300000

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
  const [refreshing, setRefreshing] = useState(false)
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null)
  const [counts, setCounts] = useState<ObservationCounts | null>(null)

  const key = `${filter}:${attempt}`
  const loading = result === null || result.key !== key

  // Refresca los contadores por estado sin bloquear la tabla; un fallo en los
  // contadores no interrumpe la lista. Las sesiones inválidas se enrutan igual.
  const refreshCounts = useCallback(
    (signal?: AbortSignal) => {
      getProfessionalObservationCounts(token, signal).then(
        ({ counts: next }) => {
          if (signal?.aborted) return
          setCounts(next)
        },
        (error: unknown) => {
          if (signal?.aborted) return

          if (
            error instanceof ApiError &&
            (error.kind === 'unauthorized' || error.kind === 'forbidden')
          ) {
            onSessionInvalid(error.message)
          }
          // Otros errores: se conservan los contadores actuales.
        },
      )
    },
    [token, onSessionInvalid],
  )

  // Carga inicial de los contadores al montar.
  useEffect(() => {
    const controller = new AbortController()
    refreshCounts(controller.signal)
    return () => controller.abort()
  }, [refreshCounts])

  // Carga en primer plano: cambia a estado "cargando" y muestra errores.
  useEffect(() => {
    const controller = new AbortController()

    getProfessionalObservations(token, filter, controller.signal).then(
      ({ observations }) => {
        if (!controller.signal.aborted) {
          setResult({ key, observations })
          setLastUpdated(new Date())
          refreshCounts(controller.signal)
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
  }, [token, filter, key, onSessionInvalid, refreshCounts])

  // Refresco silencioso: no toca el estado de carga ni la tabla hasta que
  // llegan datos nuevos, para no parpadear durante la actualización.
  const refreshInBackground = useCallback(() => {
    const controller = new AbortController()
    setRefreshing(true)

    getProfessionalObservations(token, filter, controller.signal).then(
      ({ observations }) => {
        if (controller.signal.aborted) return
        setResult({ key: `${filter}:${attempt}`, observations })
        setLastUpdated(new Date())
        setRefreshing(false)
        refreshCounts(controller.signal)
      },
      (error: unknown) => {
        if (controller.signal.aborted) return
        setRefreshing(false)

        if (
          error instanceof ApiError &&
          (error.kind === 'unauthorized' || error.kind === 'forbidden')
        ) {
          onSessionInvalid(error.message)
        }
        // Otros errores: se conserva la tabla actual sin interrumpir.
      },
    )

    return () => controller.abort()
  }, [token, filter, attempt, onSessionInvalid, refreshCounts])

  // Mantener la referencia más reciente del refresco para el intervalo.
  const refreshRef = useRef(refreshInBackground)
  useEffect(() => {
    refreshRef.current = refreshInBackground
  }, [refreshInBackground])

  // Polling automático cada 5 minutos; se reinicia al cambiar de filtro.
  useEffect(() => {
    const interval = setInterval(() => {
      refreshRef.current()
    }, REFRESH_INTERVAL_MS)

    return () => clearInterval(interval)
  }, [filter])

  const handleManualRefresh = () => {
    refreshInBackground()
  }

  const current = FILTERS.find((f) => f.value === filter)!

  return (
    <section className="observations">
      <div className="observations-header">
        <h2>Observaciones</h2>
        <div className="observations-refresh">
          {lastUpdated && !loading && (
            <span className="muted">
              Actualizado {formatDate(lastUpdated.toISOString())}
            </span>
          )}
          <button
            type="button"
            className="secondary"
            onClick={handleManualRefresh}
            disabled={loading || refreshing}
          >
            {refreshing ? 'Actualizando…' : 'Actualizar'}
          </button>
        </div>
      </div>

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
            {counts ? `${f.label} (${counts[f.value]})` : f.label}
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
                      <SpeciesName
                        species={o.proposed_species}
                        emptyLabel="Sin especie propuesta"
                      />
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
