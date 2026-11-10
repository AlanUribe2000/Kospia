import type {
  GoogleLoginResponse,
  ProfessionalMeResponse,
} from '../types/auth.ts'
import type {
  AddPhotoResponse,
  CreateOptionPayload,
  CreateOptionResponse,
  DeleteIconResponse,
  DeleteOptionResponse,
  DeletePhotoResponse,
  Option,
  OptionsResponse,
  Question,
  QuestionsResponse,
  UpdateOptionPayload,
} from '../types/helpCards.ts'
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

// Igual que getAttachmentBlob pero contra /option-images/<id> (iconos y
// galería de fichas de ayuda); la extensión la resuelve el backend.
export async function getOptionImageBlob(
  token: string,
  imageId: string,
  signal?: AbortSignal,
): Promise<Blob> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/option-images/${encodeURIComponent(imageId)}`,
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
    throw new ApiError('notFound', 'Imagen no disponible', response.status)
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
    throw new ApiError('network', 'No se pudo descargar la imagen.')
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

// ---------------------------------------------------------------------------
// Fichas de ayuda (FEAT-001 contrato). Escritura solo-admin en el backend;
// aquí se mapean los códigos HTTP al mismo patrón ApiError que el resto.
// ---------------------------------------------------------------------------

// Traduce 401/403/404/400/409/5xx a ApiError. Devuelve null si la respuesta es
// correcta (ok) para que el llamador siga con el parseo.
function mapHelpCardsStatus(response: Response): ApiError | null {
  if (response.status === 401 || response.status === 403) {
    return sessionError(response.status)
  }

  if (response.status === 404) {
    return new ApiError('notFound', 'El recurso ya no está disponible.', 404)
  }

  if (response.status === 409) {
    return new ApiError(
      'conflict',
      'El recurso fue modificado por otra persona.',
      409,
    )
  }

  if (response.status === 400) {
    return new ApiError('badRequest', 'La solicitud no es válida.', 400)
  }

  if (!response.ok) {
    return new ApiError(
      'server',
      `El servidor respondió con un error (HTTP ${response.status}).`,
      response.status,
    )
  }

  return null
}

// 400 con cuerpo { error }: usa el mensaje del backend si viene.
async function helpCardsError(response: Response): Promise<ApiError> {
  const mapped = mapHelpCardsStatus(response)
  if (!mapped) {
    return new ApiError('server', 'El servidor devolvió una respuesta inesperada.')
  }

  if (response.status === 400) {
    try {
      const body = (await response.json()) as { error?: unknown }
      if (typeof body.error === 'string' && body.error.trim()) {
        return new ApiError('badRequest', body.error, 400)
      }
    } catch {
      // Se mantiene el mensaje genérico.
    }
  }

  return mapped
}

export async function getHelpQuestions(token: string): Promise<Question[]> {
  let response: Response

  try {
    response = await fetch(`${API_BASE_URL}/questions`, {
      headers: { Authorization: `Bearer ${token}` },
    })
  } catch {
    throw networkError()
  }

  const mapped = mapHelpCardsStatus(response)
  if (mapped) throw mapped

  const data = (await response.json()) as QuestionsResponse
  return data.questions
}

export async function getQuestionOptions(
  token: string,
  questionId: string,
): Promise<Option[]> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/questions/${encodeURIComponent(questionId)}/options`,
      { headers: { Authorization: `Bearer ${token}` } },
    )
  } catch {
    throw networkError()
  }

  const mapped = mapHelpCardsStatus(response)
  if (mapped) throw mapped

  const data = (await response.json()) as OptionsResponse
  return data.options
}

export async function createOption(
  token: string,
  questionId: string,
  payload: CreateOptionPayload,
): Promise<CreateOptionResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/questions/${encodeURIComponent(questionId)}/options`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)

  return (await response.json()) as CreateOptionResponse
}

export async function updateOption(
  token: string,
  optionId: string,
  payload: UpdateOptionPayload,
): Promise<void> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/options/${encodeURIComponent(optionId)}`,
      {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)
}

export async function updateOptionHelp(
  token: string,
  optionId: string,
  description: string | null,
): Promise<void> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/options/${encodeURIComponent(optionId)}/help`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ description }),
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)
}

export async function deleteOption(
  token: string,
  optionId: string,
): Promise<DeleteOptionResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/options/${encodeURIComponent(optionId)}`,
      {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` },
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)

  return (await response.json()) as DeleteOptionResponse
}

// El reorder de OPCIONES vive bajo /questions/<question_id>/options/reorder
// (el id del path es el question_id). Ver contrato de FEAT-001.
export async function reorderOptions(
  token: string,
  questionId: string,
  optionIds: string[],
): Promise<void> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/questions/${encodeURIComponent(questionId)}/options/reorder`,
      {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ option_ids: optionIds }),
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)
}

// Sube el binario crudo de una imagen (icono o foto de galería), igual que la
// app: PUT /option-images/<id>?extension=<ext> con el body como bytes.
export async function uploadOptionImage(
  token: string,
  imageId: string,
  extension: string,
  data: Blob,
): Promise<void> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/option-images/${encodeURIComponent(imageId)}?extension=${encodeURIComponent(extension)}`,
      {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/octet-stream',
        },
        body: data,
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)
}

export async function setOptionIcon(
  token: string,
  optionId: string,
  iconAttachmentId: string,
  iconExtension: string,
): Promise<void> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/options/${encodeURIComponent(optionId)}/icon`,
      {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          icon_attachment_id: iconAttachmentId,
          icon_extension: iconExtension,
        }),
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)
}

export async function replaceOptionIcon(
  token: string,
  optionId: string,
  extension: string,
  data: Blob,
): Promise<void> {
  const imageId = `icon-${Array.from(crypto.getRandomValues(new Uint8Array(16)), (byte) => byte.toString(16).padStart(2, '0')).join('')}`
  await uploadOptionImage(token, imageId, extension, data)
  await setOptionIcon(token, optionId, imageId, extension)
}

export async function deleteOptionIcon(
  token: string,
  optionId: string,
): Promise<DeleteIconResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/options/${encodeURIComponent(optionId)}/icon`,
      {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` },
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)

  return (await response.json()) as DeleteIconResponse
}

// Crea la fila de galería y devuelve el id con el que luego se sube el binario.
export async function addOptionPhoto(
  token: string,
  optionId: string,
  fileExtension: string,
  orderIndex?: number,
): Promise<AddPhotoResponse> {
  let response: Response

  const body: { file_extension: string; order_index?: number } = {
    file_extension: fileExtension,
  }
  if (orderIndex !== undefined) body.order_index = orderIndex

  try {
    response = await fetch(
      `${API_BASE_URL}/options/${encodeURIComponent(optionId)}/photos`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)

  return (await response.json()) as AddPhotoResponse
}

export async function deleteOptionPhoto(
  token: string,
  photoId: string,
): Promise<DeletePhotoResponse> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/photos/${encodeURIComponent(photoId)}`,
      {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` },
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)

  return (await response.json()) as DeletePhotoResponse
}

export async function reorderOptionPhotos(
  token: string,
  optionId: string,
  photoIds: string[],
): Promise<void> {
  let response: Response

  try {
    response = await fetch(
      `${API_BASE_URL}/options/${encodeURIComponent(optionId)}/photos/reorder`,
      {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ photo_ids: photoIds }),
      },
    )
  } catch {
    throw networkError()
  }

  if (!response.ok) throw await helpCardsError(response)
}