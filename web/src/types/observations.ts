export type ValidationStatus = 'pending' | 'validated' | 'rejected'

// Los campos de usuario y especie son null cuando el LEFT JOIN no resuelve.
export interface ObservationUser {
  id: string | null
  display_name: string | null
  email: string | null
}

export interface ProposedSpecies {
  id: string | null
  common_name: string | null
  scientific_name: string | null
}

export interface ObservationSummary {
  id: string
  validation_status: ValidationStatus
  created_at: string | null
  user: ObservationUser
  proposed_species: ProposedSpecies
  photo_count: number
}

export interface ProfessionalObservationsResponse {
  observations: ObservationSummary[]
}

// Contrato real de GET /professional/observations/<id>.
// Los numéricos pueden serializarse como string (columnas NUMERIC).
export interface ObservationPhoto {
  id: string
  photo_path: string | null
  plant_part: string | null
  latitude: number | string | null
  longitude: number | string | null
  altitude: number | string | null
  accuracy: number | string | null
  source: string | null
  sync_status: string | null
  captured_at: string | null
  file_extension: string | null
}

export interface ObservationDetail {
  id: string
  notes: string | null
  sync_status: string | null
  validation_status: ValidationStatus
  created_at: string | null
  updated_at: string | null
  synced_at: string | null
  validated_at: string | null
  validated_by: string | null
  rejection_reason: string | null
  user: ObservationUser
  proposed_species: ProposedSpecies
  photos: ObservationPhoto[]
}

export interface ProfessionalObservationResponse {
  observation: ObservationDetail
}

export type ValidationDecision = 'validated' | 'rejected'

// Solo estos campos viajan en el PATCH; el servidor decide quién y cuándo.
export type ValidationPayload =
  | { validation_status: 'validated' }
  | { validation_status: 'rejected'; rejection_reason: string }

// Respuesta real de PATCH /professional/observations/<id>/validation.
export interface ValidationResult {
  id: string
  validation_status: ValidationDecision
  validated_at: string | null
  validated_by: string | null
  rejection_reason: string | null
}

export interface ValidationResponse {
  observation: ValidationResult
}
