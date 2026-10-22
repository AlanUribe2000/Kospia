import { useCallback, useEffect, useRef, useState } from 'react'
import { ApiError, getProfessionalSpecies } from '../api/client.ts'
import type { ProfessionalSpecies } from '../types/observations.ts'

export type SpeciesLoadState = 'idle' | 'loading' | 'loaded' | 'error'

export interface ProfessionalSpeciesState {
  species: ProfessionalSpecies[]
  loadState: SpeciesLoadState
  error: string | null
  load: () => void
  retry: () => void
}

// Carga perezosa de la lista de especies, compartida por los flujos de
// reasignación por-foto y "aplicar a todas". Mantiene el patrón ApiError.
export function useProfessionalSpecies(
  token: string,
  onSessionInvalid: (message: string) => void,
): ProfessionalSpeciesState {
  const [species, setSpecies] = useState<ProfessionalSpecies[]>([])
  const [loadState, setLoadState] = useState<SpeciesLoadState>('idle')
  const [error, setError] = useState<string | null>(null)
  const controllerRef = useRef<AbortController | null>(null)

  useEffect(
    () => () => {
      controllerRef.current?.abort()
    },
    [],
  )

  const load = useCallback(async () => {
    if (loadState === 'loading' || loadState === 'loaded') return
    if (controllerRef.current && !controllerRef.current.signal.aborted) return

    const controller = new AbortController()
    controllerRef.current = controller
    setLoadState('loading')
    setError(null)

    try {
      const list = await getProfessionalSpecies(token, controller.signal)
      if (controller.signal.aborted) return
      setSpecies(list)
      setLoadState('loaded')
    } catch (err) {
      if (controller.signal.aborted) return

      if (
        err instanceof ApiError &&
        (err.kind === 'unauthorized' || err.kind === 'forbidden')
      ) {
        onSessionInvalid(err.message)
        return
      }

      setLoadState('error')
      setError(
        err instanceof ApiError
          ? err.message
          : 'No se pudieron cargar las especies.',
      )
    } finally {
      if (controllerRef.current === controller) {
        controllerRef.current = null
      }
    }
  }, [loadState, onSessionInvalid, token])

  const retry = useCallback(() => {
    setLoadState('idle')
    void load()
  }, [load])

  return {
    species,
    loadState,
    error,
    load: () => void load(),
    retry,
  }
}
