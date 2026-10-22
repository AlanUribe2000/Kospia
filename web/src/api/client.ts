import type {
  GoogleLoginResponse,
  ProfessionalMeResponse,
} from '../types/auth.ts'
import type {
  AllPhotosDecisionResponse,
  PhotoDecisionPayload,
  PhotoDecisionResponse,
  ProfessionalObservationCountsResponse,
  ProfessionalObservationResponse,
  ProfessionalObservationsResponse,
  ProfessionalSpecies,
  ValidationPayload,
  ValidationResponse,
  ValidationStatus,
} from '../types/observations.ts'

export const API_BASE_URL: string =
  import.meta.env.VITE_API_BASE_URL ?? 'http://127.0.0.1:5000'

export type ApiErrorKind =
  | 'unauthorized'
  | 'forbidden'
  | 'notFound'
  | 'badRequest'
  | 'conflict'
  | 'server'
  | 'network'

export class ApiError extends Error {
  kind: ApiErrorKind
  status: number | null

  constructor(kind: ApiErrorKind, message: string, status: number | null = null) {
    super(message)
    this.name = 'ApiError'
    this.kind = kind
    this.status = status
  }
}

function networkError(): ApiError {
  return new ApiError(
    'network',
    'No se pudo conectar con el servidor. Verificá que el backend esté activo.',
  )
}

function sessionError(status: 401 | 403): ApiError {
  if (status === 401) {
    return new ApiError('unauthorized', 'La sesión expiró o no es válida.', 401)
  }

  return new ApiError(
    'forbidden',
    'Esta cuenta ya no tiene acceso al panel profesional.',
    403,
  )
}

function isProfessionalSpecies(value: unknown): value is ProfessionalSpecies {
  if (typeof value !== 'object' || value === null) return false

  const item = value as Record<string, unknown>
  return (
    typeof item.id === 'string' &&
    typeof item.common_name === 'string' &&
    typeof item.scientific_name === 'string' &&
    (typeof item.family === 'string' || item.family === null)
  )
}

export async function loginWithGoogle(
  idToken: string,
): Promise<GoogleLoginResponse> {
  let response: Response

  try {
    response = await fetch(`${API_BASE_URL}/auth/google`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id_token: idToken }),
    })
  } catch {
    throw networkError()
  }

  if (response.status === 401) {
    throw new ApiError(
      'unauthorized',
      'No se pudo verificar la cuenta de Google. Intentá de nuevo.',
      401,
    )
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as GoogleLoginResponse
}

export async function getProfessionalObservations(
  token: string,
  status: ValidationStatus,
  signal?: AbortSignal,
): Promise<ProfessionalObservationsResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/professional/observations?status=${encodeURIComponent(status)}`,
      { headers: { Authorization: `Bearer ${token}` }, signal },
    )
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  if (response.status === 401 || response.status === 403) {
    throw sessionError(response.status)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as ProfessionalObservationsResponse
}

export async function getProfessionalObservationCounts(
  token: string,
  signal?: AbortSignal,
): Promise<ProfessionalObservationCountsResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/professional/observations/counts`,
      { headers: { Authorization: `Bearer ${token}` }, signal },
    )
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  if (response.status === 401 || response.status === 403) {
    throw sessionError(response.status)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as ProfessionalObservationCountsResponse
}

export async function getProfessionalSpecies(
  accessToken: string,
  signal?: AbortSignal,
): Promise<ProfessionalSpecies[]> {
  let response: Response

  try {
    response = await fetch(`${API_BASE_URL}/professional/species`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      signal,
    })
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  if (response.status === 401 || response.status === 403) {
    throw sessionError(response.status)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  let data: unknown
  try {
    data = await response.json()
  } catch {
    throw new ApiError('server', 'El servidor devolvió una respuesta inválida.')
  }

if (
  typeof data !== 'object' ||
  data === null ||
  !('species' in data) ||
  !Array.isArray(data.species)
) {
  throw new ApiError(
    'server',
    'El servidor devolvió especies en un formato inesperado.',
  )
}

const species: ProfessionalSpecies[] = []
const entries: unknown[] = data.species
  for (const item of entries) {
    if (!isProfessionalSpecies(item)) {
      throw new ApiError(
        'server',
        'El servidor devolvió una especie con un formato inesperado.',
      )
    }
    species.push(item)
  }

  return species
}

export async function getProfessionalObservation(
  token: string,
  observationId: string,
  signal?: AbortSignal,
): Promise<ProfessionalObservationResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/professional/observations/${encodeURIComponent(observationId)}`,
      { headers: { Authorization: `Bearer ${token}` }, signal },
    )
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  if (response.status === 401 || response.status === 403) {
    throw sessionError(response.status)
  }

  if (response.status === 404) {
    throw new ApiError('notFound', 'La observación ya no está disponible.', 404)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as ProfessionalObservationResponse
}

export async function getAttachmentBlob(
  token: string,
  photoId: string,
  signal?: AbortSignal,
): Promise<Blob> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/attachments/${encodeURIComponent(photoId)}`,
      { headers: { Authorization: `Bearer ${token}` }, signal },
    )
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  if (response.status === 401 || response.status === 403) {
    throw sessionError(response.status)
  }

  if (response.status === 404 || response.status === 400) {
    throw new ApiError('notFound', 'Fotografía no disponible', response.status)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  try {
    return await response.blob()
  } catch (error) {
    if (signal?.aborted) throw error
    throw new ApiError('network', 'No se pudo descargar la fotografía.')
  }
}

export async function updateObservationValidation(
  token: string,
  observationId: string,
  payload: ValidationPayload,
  signal?: AbortSignal,
): Promise<ValidationResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/professional/observations/${encodeURIComponent(observationId)}/validation`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
        signal,
      },
    )
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  if (response.status === 401 || response.status === 403) {
    throw sessionError(response.status)
  }

  if (response.status === 404) {
    throw new ApiError('notFound', 'La observación ya no está disponible.', 404)
  }

  if (response.status === 409) {
    throw new ApiError(
      'conflict',
      'Esta observación ya fue decidida por otro profesional.',
      409,
    )
  }

  if (response.status === 400) {
    let message = 'No se pudo completar la decisión.'
    try {
      const body = (await response.json()) as { error?: unknown }
      if (typeof body.error === 'string' && body.error.trim()) {
        message = body.error
      }
    } catch {
      // Se mantiene el mensaje genérico.
    }
    throw new ApiError('badRequest', message, 400)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as ValidationResponse
}

// Mapea los códigos HTTP de los endpoints por-foto al mismo patrón ApiError.
function mapPhotoDecisionStatus(response: Response): ApiError | null {
  if (response.status === 401 || response.status === 403) {
    return sessionError(response.status)
  }

  if (response.status === 404) {
    return new ApiError('notFound', 'La fotografía ya no está disponible.', 404)
  }

  if (response.status === 409) {
    return new ApiError(
      'conflict',
      'Esta fotografía ya fue decidida por otro profesional.',
      409,
    )
  }

  return null
}

async function badRequestError(response: Response): Promise<ApiError> {
  let message = 'No se pudo completar la decisión.'
  try {
    const body = (await response.json()) as { error?: unknown }
    if (typeof body.error === 'string' && body.error.trim()) {
      message = body.error
    }
  } catch {
    // Se mantiene el mensaje genérico.
  }
  return new ApiError('badRequest', message, 400)
}

export async function decidePhotoValidation(
  token: string,
  observationId: string,
  photoId: string,
  payload: PhotoDecisionPayload,
  signal?: AbortSignal,
): Promise<PhotoDecisionResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/professional/observations/${encodeURIComponent(observationId)}/photos/${encodeURIComponent(photoId)}/validation`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
        signal,
      },
    )
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  const mapped = mapPhotoDecisionStatus(response)
  if (mapped) throw mapped

  if (response.status === 400) {
    throw await badRequestError(response)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as PhotoDecisionResponse
}

export async function decideAllPhotosValidation(
  token: string,
  observationId: string,
  payload: PhotoDecisionPayload,
  signal?: AbortSignal,
): Promise<AllPhotosDecisionResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/professional/observations/${encodeURIComponent(observationId)}/photos/validation`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
        signal,
      },
    )
  } catch (error) {
    if (signal?.aborted) throw error
    throw networkError()
  }

  const mapped = mapPhotoDecisionStatus(response)
  if (mapped) throw mapped

  if (response.status === 400) {
    throw await badRequestError(response)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as AllPhotosDecisionResponse
}

export async function getProfessionalMe(
  token: string,
): Promise<ProfessionalMeResponse> {
  let response: Response

  try {
    response = await fetch(`${API_BASE_URL}/professional/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })
  } catch {
    throw networkError()
  }

  if (response.status === 401 || response.status === 403) {
    throw sessionError(response.status)
  }

  if (!response.ok) {
    throw new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return (await response.json()) as ProfessionalMeResponse
}