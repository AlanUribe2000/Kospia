import { useEffect, useRef } from 'react'

export interface LightboxItem {
  id: string
  url: string
  alt: string
}

interface Props {
  items: LightboxItem[]
  currentId: string
  onClose: () => void
  onSelect: (id: string) => void
}

function PhotoLightbox({ items, currentId, onClose, onSelect }: Props) {
  const closeRef = useRef<HTMLButtonElement>(null)

  const index = items.findIndex((item) => item.id === currentId)
  const current = index >= 0 ? items[index] : null
  const hasMany = items.length > 1

  useEffect(() => {
    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    closeRef.current?.focus()

    return () => {
      document.body.style.overflow = previousOverflow
    }
  }, [])

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        onClose()
        return
      }

      if (items.length < 2 || index < 0) return

      if (event.key === 'ArrowLeft') {
        onSelect(items[(index - 1 + items.length) % items.length].id)
      } else if (event.key === 'ArrowRight') {
        onSelect(items[(index + 1) % items.length].id)
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [items, index, onClose, onSelect])

  if (!current) return null

  return (
    <div
      className="lightbox"
      role="dialog"
      aria-modal="true"
      aria-label="Visor de fotografías"
      onClick={(event) => {
        if (event.target === event.currentTarget) onClose()
      }}
    >
      <button
        ref={closeRef}
        type="button"
        className="lightbox-btn lightbox-close"
        aria-label="Cerrar visor"
        onClick={onClose}
      >
        ×
      </button>

      {hasMany && (
        <button
          type="button"
          className="lightbox-btn lightbox-prev"
          aria-label="Fotografía anterior"
          onClick={() =>
            onSelect(items[(index - 1 + items.length) % items.length].id)
          }
        >
          ←
        </button>
      )}

      <img className="lightbox-image" src={current.url} alt={current.alt} />

      {hasMany && (
        <button
          type="button"
          className="lightbox-btn lightbox-next"
          aria-label="Fotografía siguiente"
          onClick={() => onSelect(items[(index + 1) % items.length].id)}
        >
          →
        </button>
      )}

      {hasMany && (
        <p className="lightbox-counter" aria-live="polite">
          {index + 1} de {items.length}
        </p>
      )}
    </div>
  )
}

export default PhotoLightbox
