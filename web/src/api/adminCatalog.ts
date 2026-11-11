import { API_BASE_URL, ApiError } from './client.ts'

export interface CatalogSpeciesSummary {
  id: string
  common_name: string
  scientific_name: string
  family: string | null
  is_active: boolean | null
  created_at: string | null
  updated_at: string | null
}

export interface CatalogTrait {
  id: string
  question_id: string
  question_text: string
  option_id: string
  option_text: string
}

export interface CatalogQuestion {
  id: string
  question_text: string
  is_active: boolean | null
  options: { id: string; option_text: string }[]
}

export interface TraitAssignment {
  question_id: string
  option_id: string
}

export interface CatalogSpeciesDetail extends CatalogSpeciesSummary {
  description: string | null
  habitat: string | null
  biological_form: string | null
  approximate_height: string | null
  flower_color: string | null
  flower_grouping: string | null
  flower_size: string | null
  petal_count: string | null
  leaf_length: string | null
  leaf_shape: string | null
  leaf_edge: string | null
  leaf_texture: string | null
  has_spines: boolean | null
  spine_type: string | null
  has_fruit: boolean | null
  fruit_shape: string | null
  fruit_color: string | null
  fruit_size: string | null
  observations: string | null
  image_url: string | null
  traits: CatalogTrait[]
}

export interface CatalogImage {
  id: string
  file_name: string
  mime_type: string
  width: number | null
  height: number | null
  size_bytes: number
  is_primary: boolean
  sort_order: number
  status: string
  created_at: string
}

export interface CatalogList {
  species: CatalogSpeciesSummary[]
  pagination: { total: number; limit: number; offset: number }
}

export type SpeciesEditableField =
  | 'common_name' | 'scientific_name' | 'family' | 'description' | 'habitat'
  | 'flower_color' | 'biological_form' | 'approximate_height' | 'leaf_length'
  | 'leaf_shape' | 'leaf_edge' | 'leaf_texture' | 'spine_type'
  | 'flower_grouping' | 'petal_count' | 'flower_size' | 'fruit_shape'
  | 'fruit_color' | 'fruit_size' | 'observations' | 'has_spines' | 'has_fruit'

export type SpeciesPayload = Partial<Record<SpeciesEditableField, string | boolean | null>>

export class CatalogWriteError extends ApiError {
  field: string | null

  constructor(kind: ApiError['kind'], message: string, status: number | null, field: string | null = null) {
    super(kind, message, status)
    this.field = field
  }
}

async function writeCatalog<T extends { id: string }>(token: string, method: 'POST' | 'PATCH' | 'PUT', path: string, payload: SpeciesPayload | { traits: TraitAssignment[] }) {
  let response: Response
  try {
    response = await fetch(`${API_BASE_URL}${path}`, {
      method,
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
  } catch {
    throw new CatalogWriteError('network', 'No se pudo conectar con el servidor.', null)
  }
  if (!response.ok) {
    const messages: Record<number, [ApiError['kind'], string]> = {
      400: ['badRequest', 'Revisá los datos ingresados.'],
      401: ['unauthorized', 'La sesión expiró o no es válida.'],
      403: ['forbidden', 'No tenés permiso para administrar plantas.'],
      404: ['notFound', 'La especie ya no está disponible.'],
      409: ['conflict', method === 'PUT' ? 'Los datos entran en conflicto con el estado actual.' : 'Ya existe una especie con ese nombre científico.'],
      413: ['badRequest', 'Los datos superan el tamaño permitido.'],
    }
    const [kind, fallback] = messages[response.status] ?? ['server', `No se pudo guardar la planta (HTTP ${response.status}).`]
    let message = fallback
    let field: string | null = null
    if (response.status === 400 || response.status === 409) {
      try {
        const body: unknown = await response.json()
        if (typeof body === 'object' && body !== null) {
          const item = body as Record<string, unknown>
          if (typeof item.error === 'string' && item.error.trim()) message = item.error
          if (typeof item.field === 'string') field = item.field
        }
      } catch { /* use the safe fallback */ }
    }
    throw new CatalogWriteError(kind, message, response.status, field)
  }
  try {
    const body = await response.json() as { species: T }
    if (!body.species || typeof body.species.id !== 'string') throw new Error('invalid response')
    return body.species
  } catch {
    throw new CatalogWriteError('server', 'El servidor devolvió una respuesta inválida.', response.status)
  }
}

export function createCatalogSpecies(token: string, payload: SpeciesPayload) {
  return writeCatalog<CatalogSpeciesDetail>(token, 'POST', '/admin/species', payload)
}

export function updateCatalogSpecies(token: string, id: string, payload: SpeciesPayload) {
  return writeCatalog<CatalogSpeciesDetail>(token, 'PATCH', `/admin/species/${encodeURIComponent(id)}`, payload)
}

export function updateCatalogTraits(token: string, id: string, traits: TraitAssignment[]) {
  return writeCatalog<Pick<CatalogSpeciesDetail, 'id' | 'updated_at' | 'traits'>>(token, 'PUT', `/admin/species/${encodeURIComponent(id)}/traits`, { traits })
}

async function getCatalog<T>(path: string, token: string, signal?: AbortSignal): Promise<T> {
  let response: Response
  try {
    response = await fetch(`${API_BASE_URL}${path}`, {
      headers: { Authorization: `Bearer ${token}` },
      signal,
    })
  } catch (error) {
    if (signal?.aborted) throw error
    throw new ApiError('network', 'No se pudo conectar con el servidor.', null)
  }
  if (response.status === 401) throw new ApiError('unauthorized', 'La sesión expiró o no es válida.', 401)
  if (response.status === 403) throw new ApiError('forbidden', 'No tenés permiso para administrar plantas.', 403)
  if (response.status === 404) throw new ApiError('notFound', 'La especie ya no está disponible.', 404)
  if (!response.ok) throw new ApiError('server', `No se pudieron cargar los datos (HTTP ${response.status}).`, response.status)
  try {
    return await response.json() as T
  } catch {
    throw new ApiError('server', 'El servidor devolvió una respuesta inválida.', response.status)
  }
}

export function getCatalogSpecies(token: string, params: URLSearchParams, signal?: AbortSignal) {
  return getCatalog<CatalogList>(`/admin/species?${params}`, token, signal)
}

export function getCatalogDetail(token: string, id: string, signal?: AbortSignal) {
  return getCatalog<{ species: CatalogSpeciesDetail }>(`/admin/species/${encodeURIComponent(id)}`, token, signal)
}

export function getCatalogImages(token: string, id: string, signal?: AbortSignal) {
  return getCatalog<{ images: CatalogImage[] }>(`/admin/species/${encodeURIComponent(id)}/images`, token, signal)
}

export function getCatalogQuestions(token: string, signal?: AbortSignal) {
  return getCatalog<{ questions: CatalogQuestion[] }>('/admin/questions', token, signal)
}