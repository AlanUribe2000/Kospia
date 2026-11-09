// Tipos del contrato de FEAT-001 (fichas de ayuda). Nombres de columna EXACTOS
// a los de la API/BD (ver powersync_schema.dart / tables.dart).

export interface Question {
  id: string
  question_text: string
  field_name: string
  required_part: string
  order_index: number
}

export interface OptionPhoto {
  id: string
  option_id: string
  order_index: number
  file_extension: string | null
  created_at?: string | null
}

export interface Option {
  id: string
  question_id: string
  option_text: string
  value_key: string
  description: string | null
  icon_attachment_id: string | null
  icon_extension: string | null
  order_index: number
  photos: OptionPhoto[]
}

// Formas de respuesta de los GET de FEAT-001.
export interface QuestionsResponse {
  questions: Question[]
}

export interface OptionsResponse {
  options: Option[]
}

// POST /questions/<id>/options -> { id }
export interface CreateOptionResponse {
  id: string
}

// POST /options/<id>/photos -> { id, file_extension }
export interface AddPhotoResponse {
  id: string
  file_extension: string | null
}

// DELETE /options/<id> -> fotos + icono previos para limpiar archivos.
export interface DeleteOptionResponse {
  deleted_photos: { id: string; file_extension: string | null }[]
  icon_attachment_id: string | null
  icon_extension: string | null
}

// DELETE /options/<id>/icon -> valores previos para limpiar archivo.
export interface DeleteIconResponse {
  icon_attachment_id: string | null
  icon_extension: string | null
}

// DELETE /photos/<id> -> extension para limpiar archivo.
export interface DeletePhotoResponse {
  file_extension: string | null
}

export interface CreateOptionPayload {
  option_text: string
  value_key: string
  description: string | null
  order_index?: number
}

export interface UpdateOptionPayload {
  option_text: string
  value_key: string
  description: string | null
}
