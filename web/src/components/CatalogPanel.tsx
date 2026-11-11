import { useCallback, useEffect, useState } from 'react'
import { ApiError } from '../api/client.ts'
import { getCatalogDetail, getCatalogImages, getCatalogSpecies } from '../api/adminCatalog.ts'
import type { CatalogImage, CatalogList, CatalogSpeciesDetail } from '../api/adminCatalog.ts'
import SpeciesForm from './SpeciesForm.tsx'
import TraitsEditor from './TraitsEditor.tsx'

interface Props {
  token: string
  onSessionInvalid: (message: string) => void
}

type State<T> = { status: 'loading' } | { status: 'error'; message: string } | { status: 'loaded'; data: T }
const PAGE_SIZE = 25

function display(value: string | boolean | null): string {
  if (value === null || value === '') return 'Sin información'
  if (typeof value === 'boolean') return value ? 'Sí' : 'No'
  return value
}

function handleError(error: unknown, onSessionInvalid: (message: string) => void): string {
  if (error instanceof ApiError) {
    if (error.kind === 'unauthorized') onSessionInvalid(error.message)
    return error.message
  }
  return 'Ocurrió un error inesperado.'
}

function SpeciesDetail({ token, id, onBack, onEdit, editOnLoad, notice, onSessionInvalid }: Props & { id: string; onBack: () => void; onEdit: (species: CatalogSpeciesDetail) => void; editOnLoad: boolean; notice: string | null }) {
  const [detail, setDetail] = useState<State<CatalogSpeciesDetail>>({ status: 'loading' })
  const [images, setImages] = useState<State<CatalogImage[]>>({ status: 'loading' })
  const [attempt, setAttempt] = useState(0)
  const [editingTraits, setEditingTraits] = useState(false)
  const [traitsNotice, setTraitsNotice] = useState<string | null>(null)

  useEffect(() => {
    const controller = new AbortController()
    getCatalogDetail(token, id, controller.signal).then(
      ({ species }) => { if (!controller.signal.aborted) { if (editOnLoad) onEdit(species); else setDetail({ status: 'loaded', data: species }) } },
      (error: unknown) => { if (!controller.signal.aborted) setDetail({ status: 'error', message: handleError(error, onSessionInvalid) }) },
    )
    getCatalogImages(token, id, controller.signal).then(
      (response) => { if (!controller.signal.aborted) setImages({ status: 'loaded', data: response.images }) },
      (error: unknown) => { if (!controller.signal.aborted) setImages({ status: 'error', message: handleError(error, onSessionInvalid) }) },
    )
    return () => controller.abort()
  }, [token, id, attempt, editOnLoad, onEdit, onSessionInvalid])

  function retry() {
    setDetail({ status: 'loading' })
    setImages({ status: 'loading' })
    setAttempt((value) => value + 1)
  }

  const fields: { label: string; key: keyof CatalogSpeciesDetail }[] = [
    { label: 'Familia', key: 'family' }, { label: 'Hábitat', key: 'habitat' },
    { label: 'Forma biológica', key: 'biological_form' }, { label: 'Altura aproximada', key: 'approximate_height' },
    { label: 'Color de flor', key: 'flower_color' }, { label: 'Agrupación de flor', key: 'flower_grouping' },
    { label: 'Tamaño de flor', key: 'flower_size' }, { label: 'Pétalos', key: 'petal_count' },
    { label: 'Largo de hoja', key: 'leaf_length' }, { label: 'Forma de hoja', key: 'leaf_shape' },
    { label: 'Borde de hoja', key: 'leaf_edge' }, { label: 'Textura de hoja', key: 'leaf_texture' },
    { label: 'Espinas', key: 'has_spines' }, { label: 'Tipo de espina', key: 'spine_type' },
    { label: 'Fruto visible', key: 'has_fruit' }, { label: 'Forma de fruto', key: 'fruit_shape' },
    { label: 'Color de fruto', key: 'fruit_color' }, { label: 'Tamaño de fruto', key: 'fruit_size' },
    { label: 'Observaciones', key: 'observations' },
  ]

  return <section className="catalog-panel" aria-labelledby="catalog-detail-title">
    <button className="secondary" type="button" onClick={onBack}>Volver al listado</button>
    {notice && <p className="success" role="status">{notice}</p>}
    {detail.status === 'loading' && <p role="status">Cargando especie...</p>}
    {detail.status === 'error' && <div className="catalog-message"><p className="alert" role="alert">{detail.message}</p><button type="button" onClick={retry}>Reintentar</button></div>}
    {detail.status === 'loaded' && <>
      <header className="catalog-heading">
        <div><h2 id="catalog-detail-title">{detail.data.common_name}</h2><p className="catalog-scientific">{detail.data.scientific_name}</p></div>
        <span className="catalog-status">{detail.data.is_active === true ? 'Activa' : detail.data.is_active === false ? 'Inactiva' : 'Sin estado'}</span>
      </header>
      <button type="button" className="secondary" onClick={() => onEdit(detail.data)}>Editar planta</button>
      <p className="muted">ID: {detail.data.id}</p>
      <p>{display(detail.data.description)}</p>
      <h3>Características botánicas</h3>
      <dl className="catalog-properties">{fields.map(({ label, key }) => <div key={key}><dt>{label}</dt><dd>{display(detail.data[key] as string | boolean | null)}</dd></div>)}</dl>
      <h3>Rasgos asignados</h3>
      {detail.data.traits.length === 0 ? <p className="muted">Sin rasgos asignados.</p> : <div className="catalog-table-wrap"><table className="catalog-table"><thead><tr><th>Pregunta</th><th>Respuesta</th></tr></thead><tbody>{detail.data.traits.map((trait) => <tr key={trait.id}><td>{trait.question_text}</td><td>{trait.option_text}</td></tr>)}</tbody></table></div>}
      {traitsNotice && <p className="success" role="status">{traitsNotice}</p>}
      {editingTraits ? <TraitsEditor token={token} species={detail.data} onSessionInvalid={onSessionInvalid} onCancel={() => { setEditingTraits(false); retry() }} onSaved={(result) => { setDetail({ status: 'loaded', data: { ...detail.data, traits: result.traits, updated_at: result.updated_at } }); setEditingTraits(false); setTraitsNotice('Identificación actualizada correctamente.') }} /> : <button type="button" className="secondary" onClick={() => { setTraitsNotice(null); setEditingTraits(true) }}>Configurar identificación</button>}
      <h3>Fotografías oficiales</h3>
      {images.status === 'loading' && <p role="status">Cargando fotografías...</p>}
      {images.status === 'error' && <div className="catalog-message"><p className="alert" role="alert">{images.message}</p><button type="button" onClick={retry}>Reintentar</button></div>}
      {images.status === 'loaded' && (images.data.length === 0 ? <p className="muted">Sin fotografías oficiales.</p> : <div className="catalog-table-wrap"><table className="catalog-table"><thead><tr><th>Archivo</th><th>ID</th><th>Estado</th><th>Orden</th><th>Tipo</th><th>Dimensiones</th><th>Tamaño</th><th>Creada</th></tr></thead><tbody>{images.data.map((image) => <tr key={image.id}><td>{image.file_name}{image.is_primary && ' (principal)'}</td><td>{image.id}</td><td>{image.status === 'active' ? 'Activa' : image.status === 'hidden' ? 'Oculta' : image.status}</td><td>{image.sort_order}</td><td>{image.mime_type}</td><td>{image.width && image.height ? `${image.width} × ${image.height}` : 'Sin información'}</td><td>{image.size_bytes.toLocaleString('es-AR')} bytes</td><td>{image.created_at}</td></tr>)}</tbody></table></div>)}
    </>}
  </section>
}

export default function CatalogPanel({ token, onSessionInvalid }: Props) {
  const [search, setSearch] = useState('')
  const [query, setQuery] = useState('')
  const [status, setStatus] = useState('all')
  const [sort, setSort] = useState('common_name')
  const [order, setOrder] = useState('asc')
  const [offset, setOffset] = useState(0)
  const [selected, setSelected] = useState<string | null>(null)
  const [editOnLoad, setEditOnLoad] = useState(false)
  const [form, setForm] = useState<{ mode: 'create' } | { mode: 'edit'; species: CatalogSpeciesDetail } | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [attempt, setAttempt] = useState(0)
  const [result, setResult] = useState<State<CatalogList>>({ status: 'loading' })

  const openEdit = useCallback((species: CatalogSpeciesDetail) => {
    setNotice(null)
    setEditOnLoad(false)
    setForm({ mode: 'edit', species })
  }, [])

  useEffect(() => {
    const controller = new AbortController()
    const params = new URLSearchParams({ q: query, status, sort, order, limit: String(PAGE_SIZE), offset: String(offset) })
    getCatalogSpecies(token, params, controller.signal).then(
      (data) => { if (!controller.signal.aborted) setResult({ status: 'loaded', data }) },
      (error: unknown) => { if (!controller.signal.aborted) setResult({ status: 'error', message: handleError(error, onSessionInvalid) }) },
    )
    return () => controller.abort()
  }, [token, query, status, sort, order, offset, attempt, onSessionInvalid])

  function reload() { setResult({ status: 'loading' }); setAttempt((value) => value + 1) }
  if (form !== null) return <SpeciesForm
    key={form.mode === 'edit' ? form.species.id : 'create'}
    token={token}
    species={form.mode === 'edit' ? form.species : undefined}
    onCancel={() => setForm(null)}
    onSessionInvalid={onSessionInvalid}
    onSaved={(species, created) => {
      setForm(null)
      setSelected(species.id)
      setNotice(created ? 'Planta creada correctamente. Está inactiva.' : 'Planta actualizada correctamente.')
      if (created) { setSearch(''); setQuery(''); setStatus('all'); setOffset(0) }
      reload()
    }}
  />
  if (selected !== null) return <SpeciesDetail token={token} id={selected} notice={notice} onEdit={openEdit} editOnLoad={editOnLoad} onBack={() => { setSelected(null); setEditOnLoad(false); setNotice(null) }} onSessionInvalid={onSessionInvalid} />
  return <section className="catalog-panel" aria-labelledby="catalog-title">
    <div className="catalog-heading"><h2 id="catalog-title">Administración de plantas</h2><button type="button" onClick={() => { setNotice(null); setForm({ mode: 'create' }) }}>Nueva planta</button></div>
    <form className="catalog-controls" onSubmit={(event) => { event.preventDefault(); setOffset(0); setResult({ status: 'loading' }); if (query === search.trim()) reload(); else setQuery(search.trim()) }}>
      <label>Buscar especie<input type="search" value={search} maxLength={100} onChange={(event) => setSearch(event.target.value)} placeholder="Nombre común o científico" /></label>
      <button type="submit">Buscar</button>
      <label>Estado<select value={status} onChange={(event) => { setResult({ status: 'loading' }); setStatus(event.target.value); setOffset(0) }}><option value="all">Todas</option><option value="active">Activas</option><option value="inactive">Inactivas</option></select></label>
      <label>Ordenar por<select value={sort} onChange={(event) => { setResult({ status: 'loading' }); setSort(event.target.value); setOffset(0) }}><option value="common_name">Nombre común</option><option value="scientific_name">Nombre científico</option></select></label>
      <label>Dirección<select value={order} onChange={(event) => { setResult({ status: 'loading' }); setOrder(event.target.value); setOffset(0) }}><option value="asc">Ascendente</option><option value="desc">Descendente</option></select></label>
    </form>
    {result.status === 'loading' && <p role="status">Cargando especies...</p>}
    {result.status === 'error' && <div className="catalog-message"><p className="alert" role="alert">{result.message}</p><button type="button" onClick={reload}>Reintentar</button></div>}
    {result.status === 'loaded' && <>
      <p className="muted">{result.data.pagination.total} especies encontradas</p>
      {result.data.species.length === 0 ? <p>No se encontraron especies.</p> : <div className="catalog-table-wrap"><table className="catalog-table"><thead><tr><th>Nombre común</th><th>Nombre científico</th><th>Familia</th><th>Estado</th><th><span className="sr-only">Acciones</span></th></tr></thead><tbody>{result.data.species.map((species) => <tr key={species.id}><td>{species.common_name}</td><td><em>{species.scientific_name}</em></td><td>{display(species.family)}</td><td>{species.is_active === true ? 'Activa' : species.is_active === false ? 'Inactiva' : 'Sin estado'}</td><td><button type="button" className="secondary" onClick={() => setSelected(species.id)}>Ver detalle<span className="sr-only"> de {species.common_name}</span></button> <button type="button" className="secondary" onClick={() => { setEditOnLoad(true); setSelected(species.id) }}>Editar<span className="sr-only"> {species.common_name}</span></button></td></tr>)}</tbody></table></div>}
      <div className="catalog-pagination"><button type="button" className="secondary" disabled={offset === 0} onClick={() => { setResult({ status: 'loading' }); setOffset(Math.max(0, offset - PAGE_SIZE)) }}>Anterior</button><span>{result.data.pagination.total === 0 ? '0' : `${offset + 1}–${Math.min(offset + PAGE_SIZE, result.data.pagination.total)}`} de {result.data.pagination.total}</span><button type="button" className="secondary" disabled={offset + PAGE_SIZE >= result.data.pagination.total} onClick={() => { setResult({ status: 'loading' }); setOffset(offset + PAGE_SIZE) }}>Siguiente</button></div>
    </>}
  </section>
}