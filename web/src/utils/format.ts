import type { ValidationStatus } from '../types/observations.ts'

export const STATUS_LABEL: Record<ValidationStatus, string> = {
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
