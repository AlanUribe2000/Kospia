export type ProfessionalRole = 'professional' | 'admin'

export interface ProfessionalUser {
  id: string
  email: string | null
  display_name: string | null
  photo_url: string | null
  role: ProfessionalRole
}

export interface ProfessionalMeResponse {
  user: ProfessionalUser
}

// Respuesta real de POST /auth/google: no incluye el rol.
export interface GoogleLoginUser {
  id: string
  email: string | null
  display_name: string | null
  photo_url: string | null
}

export interface GoogleLoginResponse {
  access_token: string
  user: GoogleLoginUser
}
