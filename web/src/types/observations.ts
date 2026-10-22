export type ValidationStatus = 'pending' | 'validated' | 'rejected'

export type PhotoValidationStatus = 'pending' | 'validated' | 'rejected'

// Los campos de usuario y especie son null cuando el LEFT JOIN no resuelve.
export interface ObservationUser {
  id: string | null
  display_name: string | null
  email: string | null
}

// Especie resuelta contra public.species; la API devuelve null si no resuelve.
export interface SpeciesSummary {
  id: string
  common_name: string | null
  scientific_name: string | null
}

export interface ObservationSummary {
  id: string
  validation_status: ValidationStatus
  created_at: string | null
  user: ObservationUser
  proposed_species: SpeciesSummary | null
  confirmed_species: SpeciesSummary | null
  photo_count: number
}

export interface ProfessionalSpecies {
  id: string
  common_name: string
  scientific_name: string
  family: string | null
}

export interface ProfessionalObservationsResponse {
  observations: ObservationSummary[]
}

// Conteos por estado para los contadores de las pestañas de filtro.
export interface ObservationCounts {
  pending: number
  validated: number
  rejected: number
}

export interface ProfessionalObservationCountsResponse {
  counts: ObservationCounts
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
  validation_status: PhotoValidationStatus
  validation_comment: string | null
  validated_species_id: string | null
  validated_species: SpeciesSummary | null
  validated_at: string | null
  validated_by: string | null
}

export interface ObservationSummaryCounts {
  validated: number
  rejected: number
  pending: number
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
  proposed_species: SpeciesSummary | null
  confirmed_species: SpeciesSummary | null
  photos: ObservationPhoto[]
  summary: ObservationSummaryCounts
}

export interface ProfessionalObservationResponse {
  observation: ObservationDetail
}

// Decisión por-foto (y "aplicar a todas"). El servidor decide quién/cuándo.
export type PhotoDecisionPayload =
  | { action: 'validate'; comment?: string }
  | { action: 'reject'; comment: string }
  | { action: 'reassign'; target_species_id: string; comment?: string }

export interface PhotoDecisionResponse {
  photo: {
    id: string
    validation_status: PhotoValidationStatus
    validation_comment: string | null
    validated_species_id: string | null
    validated_at: string | null
    validated_by: string | null
    observation_id: string
  }
  observation: { id: string; validation_status: ValidationStatus }
}

export interface AllPhotosDecisionResponse {
  observation: {
    id: string
    validation_status: ValidationStatus
    counts: ObservationSummaryCounts
  }
}

export type ValidationDecision = 'validated' | 'rejected'

// Solo estos campos viajan en el PATCH; el servidor decide quién y cuándo.
export type ValidationPayload = {
  validation_status: 'validated' | 'rejected'
  rejection_reason?: string
  validated_species_id?: string
}

// Respuesta real de PATCH /professional/observations/<id>/validation.
export interface ValidationResult {
  id: string
  validation_status: ValidationDecision
  validated_at: string | null
  validated_by: string | null
  rejection_reason: string | null
  validated_species_id: string | null
}

export interface ValidationResponse {
  observation: ValidationResult
}
