import type {
  GoogleLoginResponse,
  ProfessionalMeResponse,
} from '../types/auth.ts'
import type {
  ProfessionalObservationResponse,
  ProfessionalObservationsResponse,
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
    throw new ApiError(
      'network',
      'No se pudo conectar con el servidor. Verificá que el backend esté activo.',
    )
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
    if (signal?.aborted) {
      throw error
    }
    throw new ApiError(
      'network',
      'No se pudo conectar con el servidor. Verificá que el backend esté activo.',
    )
  }

  if (response.status === 401) {
    throw new ApiError('unauthorized', 'La sesión expiró o no es válida.', 401)
  }

  if (response.status === 403) {
    throw new ApiError(
      'forbidden',
      'Esta cuenta ya no tiene acceso al panel profesional.',
      403,
    )
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
    if (signal?.aborted) {
      throw error
    }
    throw new ApiError(
      'network',
      'No se pudo conectar con el servidor. Verificá que el backend esté activo.',
    )
  }

  if (response.status === 401) {
    throw new ApiError('unauthorized', 'La sesión expiró o no es válida.', 401)
  }

  if (response.status === 403) {
    throw new ApiError(
      'forbidden',
      'Esta cuenta ya no tiene acceso al panel profesional.',
      403,
    )
  }

  if (response.status === 404) {
    throw new ApiError(
      'notFound',
      'La observación ya no está disponible.',
      404,
    )
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
    if (signal?.aborted) {
      throw error
    }
    throw new ApiError(
      'network',
      'No se pudo conectar con el servidor. Verificá que el backend esté activo.',
    )
  }

  if (response.status === 401) {
    throw new ApiError('unauthorized', 'La sesión expiró o no es válida.', 401)
  }

  if (response.status === 403) {
    throw new ApiError(
      'forbidden',
      'Esta cuenta ya no tiene acceso al panel profesional.',
      403,
    )
  }

  // 404: sin metadata o sin archivo físico. 400: extensión no válida en la base.
  if (response.status === 404 || response.status === 400) {
    throw new ApiError(
      'notFound',
      'Fotografía no disponible',
      response.status,
    )
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
    if (signal?.aborted) {
      throw error
    }
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
    if (signal?.aborted) {
      throw error
    }
    throw new ApiError(
      'network',
      'No se pudo conectar con el servidor. Verificá que el backend esté activo.',
    )
  }

  if (response.status === 401) {
    throw new ApiError('unauthorized', 'La sesión expiró o no es válida.', 401)
  }

  if (response.status === 403) {
    throw new ApiError(
      'forbidden',
      'Esta cuenta ya no tiene acceso al panel profesional.',
      403,
    )
  }

  if (response.status === 404) {
    throw new ApiError(
      'notFound',
      'La observación ya no está disponible.',
      404,
    )
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

export async function getProfessionalMe(
  token: string,
): Promise<ProfessionalMeResponse> {
  let response: Response

  try {
    response = await fetch(`${API_BASE_URL}/professional/me`, {
      headers: { Authorization: `Bearer ${token}` },
    })
  } catch {
    throw new ApiError(
      'network',
      'No se pudo conectar con el servidor. Verificá que el backend esté activo.',
    )
  }

  if (response.status === 401) {
    throw new ApiError('unauthorized', 'La sesión expiró o no es válida.', 401)
  }

  if (response.status === 403) {
    throw new ApiError(
      'forbidden',
      'Esta cuenta no tiene acceso al panel profesional.',
      403,
    )
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
