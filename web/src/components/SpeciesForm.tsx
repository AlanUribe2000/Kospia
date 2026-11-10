import { useRef, useState } from 'react'
import type { FormEvent } from 'react'
import { ApiError } from '../api/client.ts'
import { CatalogWriteError, createCatalogSpecies, updateCatalogSpecies } from '../api/adminCatalog.ts'
import type { CatalogSpeciesDetail, SpeciesEditableField, SpeciesPayload } from '../api/adminCatalog.ts'

const textFields = [
  { key: 'common_name', label: 'Nombre común', max: 200, required: true },
  { key: 'scientific_name', label: 'Nombre científico', max: 200, required: true },
  { key: 'family', label: 'Familia', max: 200 },
  { key: 'description', label: 'Descripción', max: 5000, multiline: true },
  { key: 'habitat', label: 'Hábitat', max: 200 },
  { key: 'biological_form', label: 'Forma biológica', max: 100 },
  { key: 'approximate_height', label: 'Altura aproximada', max: 100 },
  { key: 'flower_color', label: 'Color de flor', max: 100 },
  { key: 'flower_grouping', label: 'Agrupación de flor', max: 100 },
  { key: 'flower_size', label: 'Tamaño de flor', max: 100 },
  { key: 'petal_count', label: 'Pétalos', max: 100 },
  { key: 'leaf_length', label: 'Largo de hoja', max: 100 },
  { key: 'leaf_shape', label: 'Forma de hoja', max: 100 },
  { key: 'leaf_edge', label: 'Borde de hoja', max: 100 },
  { key: 'leaf_texture', label: 'Textura de hoja', max: 100 },
  { key: 'spine_type', label: 'Tipo de espina', max: 100 },
  { key: 'fruit_shape', label: 'Forma de fruto', max: 100 },
  { key: 'fruit_color', label: 'Color de fruto', max: 100 },
  { key: 'fruit_size', label: 'Tamaño de fruto', max: 100 },
  { key: 'observations', label: 'Observaciones', max: 2000, multiline: true },
] as const satisfies readonly { key: SpeciesEditableField; label: string; max: number; required?: boolean; multiline?: boolean }[]

type TextKey = typeof textFields[number]['key']
type BoolKey = 'has_spines' | 'has_fruit'
type FormValues = Record<TextKey, string> & Record<BoolKey, 'true' | 'false' | ''>

function initialValues(species?: CatalogSpeciesDetail): FormValues {
  const values = {} as FormValues
  for (const field of textFields) values[field.key] = species?.[field.key] ?? ''
  for (const key of ['has_spines', 'has_fruit'] as const) {
    const value = species?.[key]
    values[key] = value == null ? (species ? '' : 'false') : String(value) as 'true' | 'false'
  }
  return values
}

interface Props {
  token: string
  species?: CatalogSpeciesDetail
  onCancel: () => void
  onSaved: (species: CatalogSpeciesDetail, created: boolean) => void
  onSessionInvalid: (message: string) => void
}

export default function SpeciesForm({ token, species, onCancel, onSaved, onSessionInvalid }: Props) {
  const [values, setValues] = useState<FormValues>(() => initialValues(species))
  const [initial] = useState<FormValues>(() => initialValues(species))
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const pending = useRef(false)

  function update(key: TextKey | BoolKey, value: string) {
    setValues((current) => ({ ...current, [key]: value }))
    setError(null)
    setFieldError(null)
    setNotice(null)
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (pending.current) return
    setError(null)
    setFieldError(null)
    setNotice(null)

    for (const field of textFields) {
      const value = values[field.key]
      if ('required' in field && field.required && !value.trim()) {
        setFieldError(field.key)
        setError(`${field.label} es obligatorio.`)
        return
      }
      if (value.includes('\0') || Array.from(value.trim()).length > field.max) {
        setFieldError(field.key)
        setError(`${field.label} contiene caracteres inválidos o supera ${field.max} caracteres.`)
        return
      }
    }

    const payload: SpeciesPayload = {}
    for (const field of textFields) {
      if (!species || values[field.key] !== initial[field.key]) {
        const value = values[field.key].trim()
        if (species || value || ('required' in field && field.required)) payload[field.key] = value || null
      }
    }
    for (const key of ['has_spines', 'has_fruit'] as const) {
      if ((!species || values[key] !== initial[key]) && values[key] !== '') payload[key] = values[key] === 'true'
    }
    if (species && Object.keys(payload).length === 0) {
      setNotice('No hay cambios para guardar.')
      return
    }
    if (new TextEncoder().encode(JSON.stringify(payload)).length > 64 * 1024) {
      setError('Los datos superan el tamaño permitido.')
      return
    }

    pending.current = true
    setSaving(true)
    try {
      const result = species
        ? await updateCatalogSpecies(token, species.id, payload)
        : await createCatalogSpecies(token, payload)
      onSaved(result, !species)
    } catch (caught) {
      if (caught instanceof ApiError && caught.kind === 'unauthorized') {
        onSessionInvalid(caught.message)
      } else {
        setError(caught instanceof ApiError ? caught.message : 'No se pudo guardar la planta.')
        if (caught instanceof CatalogWriteError) setFieldError(caught.field)
      }
    } finally {
      pending.current = false
      setSaving(false)
    }
  }

  return <section className="catalog-panel" aria-labelledby="species-form-title">
    <h2 id="species-form-title">{species ? 'Editar planta' : 'Nueva planta'}</h2>
    {!species && <p className="muted">La planta se creará inactiva.</p>}
    <form className="species-form" onSubmit={submit} noValidate>
      <div className="species-form-grid">
        {textFields.map((field) => <label key={field.key} className={'multiline' in field && field.multiline ? 'species-form-wide' : undefined}>
          {field.label}{'required' in field && field.required ? ' *' : ''}
          {'multiline' in field && field.multiline
            ? <textarea value={values[field.key]} maxLength={field.max} aria-invalid={fieldError === field.key} onChange={(event) => update(field.key, event.target.value)} />
            : <input type="text" value={values[field.key]} maxLength={field.max} aria-invalid={fieldError === field.key} onChange={(event) => update(field.key, event.target.value)} />}
        </label>)}
        {([['has_spines', 'Tiene espinas'], ['has_fruit', 'Tiene fruto']] as const).map(([key, label]) => <label key={key}>
          {label}
          <select value={values[key]} aria-invalid={fieldError === key} onChange={(event) => update(key, event.target.value)}>
            {species && initial[key] === '' && <option value="">Sin información</option>}
            <option value="true">Sí</option><option value="false">No</option>
          </select>
        </label>)}
      </div>
      {error && <p className="alert" role="alert">{error}</p>}
      {notice && <p role="status">{notice}</p>}
      <div className="actions"><button type="submit" disabled={saving}>{saving ? 'Guardando...' : 'Guardar planta'}</button><button type="button" className="secondary" disabled={saving} onClick={onCancel}>Cancelar</button></div>
    </form>
  </section>
}