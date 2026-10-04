import { useEffect } from 'react'
import type { ReactNode } from 'react'

interface Props {
  title: string
  busy: boolean
  onClose: () => void
  children: ReactNode
}

// Mientras `busy` es true no se puede cerrar (Escape ni fondo).
function ModalShell({ title, busy, onClose, children }: Props) {
  useEffect(() => {
    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.body.style.overflow = previousOverflow
    }
  }, [])

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape' && !busy) onClose()
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [busy, onClose])

  return (
    <div
      className="modal-backdrop"
      onClick={(event) => {
        if (event.target === event.currentTarget && !busy) onClose()
      }}
    >
      <div
        className="modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
      >
        <h3 id="modal-title">{title}</h3>
        {children}
      </div>
    </div>
  )
}

export default ModalShell
