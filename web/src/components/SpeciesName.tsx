import type { SpeciesSummary } from '../types/observations.ts'

interface Props {
  species: SpeciesSummary | null
  emptyLabel: string
}

function SpeciesName({ species, emptyLabel }: Props) {
  if (!species) {
    return <span className="muted-text">{emptyLabel}</span>
  }

  return (
    <>
      <span>
        {species.common_name || species.scientific_name || 'Especie no disponible'}
      </span>
      {species.common_name && species.scientific_name && (
        <em className="secondary-text">{species.scientific_name}</em>
      )}
    </>
  )
}

export default SpeciesName
