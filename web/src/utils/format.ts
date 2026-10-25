import type {
  PhotoValidationStatus,
  ValidationStatus,
} from '../types/observations.ts'

// Etiquetas a nivel OBSERVACIÓN (dos estados).
export const STATUS_LABEL: Record<ValidationStatus, string> = {
  pending: 'Pendiente',
  reviewed: 'Revisada',
}

// Etiquetas a nivel FOTO (estado por foto, distinto del de observación).
export const PHOTO_STATUS_LABEL: Record<PhotoValidationStatus, string> = {
  pending: 'Pendiente',
  validated: 'Validada',
  rejected: 'Rechazada',
}

const dateFormatter = new Intl.DateTimeFormat('es-AR', {
  dateStyle: 'medium',
  timeStyle: 'short',
})

export function formatDate(value: string | null): string {
  if (!value) return '—'
  const date = new Date(value)
  return Number.isNaN(date.getTime()) ? '—' : dateFormatter.format(date)
}

// Los numéricos pueden llegar como número o como string según la columna.
export function toNumber(value: number | string | null): number | null {
  if (value === null || value === '') return null
  const n = typeof value === 'number' ? value : Number(value)
  return Number.isFinite(n) ? n : null
}
