import { useMemo, useState } from 'react'
import ModalShell from './ModalShell.tsx'
import type { ProfessionalSpecies } from '../types/observations.ts'

const EMPTY_SPECIES: ProfessionalSpecies[] = []

interface SpeciesPickerModalProps {
  species: ProfessionalSpecies[]
  loading: boolean
  error: string | null
  onClose: () => void
  onRetry: () => void
  onSelect: (species: ProfessionalSpecies) => void
}

export function SpeciesPickerModal({
  species,
  loading,
  error,
  onClose,
  onRetry,
  onSelect,
}: SpeciesPickerModalProps) {
  const [search, setSearch] = useState('')
  const speciesList = Array.isArray(species) ? species : EMPTY_SPECIES

  const filteredSpecies = useMemo(() => {
    const query = search.trim().toLocaleLowerCase('es-AR')
    if (!query) return speciesList

    return speciesList.filter((item) =>
      [item.common_name, item.scientific_name, item.family ?? '']
        .join(' ')
        .toLocaleLowerCase('es-AR')
        .includes(query),
    )
  }, [search, speciesList])

  return (
    <ModalShell title="Seleccionar especie" busy={false} onClose={onClose}>
      <label htmlFor="species-search">Buscar especie</label>
      <input
        id="species-search"
        type="search"
        value={search}
        onChange={(event) => setSearch(event.target.value)}
        placeholder="Nombre común, científico o familia"
        autoFocus
      />

      {loading && (
        <p className="muted" role="status">
          Cargando especies…
        </p>
      )}

      {!loading && error && (
        <div className="form">
          <p className="alert" role="alert">
            {error}
          </p>
          <button type="button" onClick={onRetry}>
            Reintentar
          </button>
        </div>
      )}

      {!loading && !error && filteredSpecies.length === 0 && (
        <p className="muted" role="status">
          {speciesList.length === 0
            ? 'No hay especies disponibles.'
            : 'No se encontraron especies.'}
        </p>
      )}

      {!loading && !error && filteredSpecies.length > 0 && (
        <div className="species-picker-list" role="listbox" aria-label="Especies">
          {filteredSpecies.map((item) => (
            <button
              key={item.id}
              type="button"
              className="species-picker-item"
              role="option"
              aria-label={`${item.common_name}, ${item.scientific_name}, ${item.family ?? 'familia no disponible'}`}
              onClick={() => onSelect(item)}
            >
              <strong>{item.common_name}</strong>
              <em>{item.scientific_name}</em>
              <small>{item.family ?? 'Familia no disponible'}</small>
            </button>
          ))}
        </div>
      )}

      <div className="actions modal-actions">
        <button type="button" className="secondary" onClick={onClose}>
          Cancelar
        </button>
      </div>
    </ModalShell>
  )
}