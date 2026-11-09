import { useCallback, useEffect, useRef, useState } from 'react'
import type { FormEvent } from 'react'
import {
  ApiError,
  addOptionPhoto,
  createOption,
  deleteOption,
  deleteOptionIcon,
  deleteOptionPhoto,
  getHelpQuestions,
  getQuestionOptions,
  reorderOptionPhotos,
  reorderOptions,
  setOptionIcon,
  updateOption,
  uploadOptionImage,
} from '../api/client.ts'
import type { Option, Question } from '../types/helpCards.ts'
import AuthenticatedPhoto from './AuthenticatedPhoto.tsx'
import ModalShell from './ModalShell.tsx'

interface Props {
  token: string
  onSessionInvalid: (message: string) => void
}

// Extensiones permitidas por el backend (ver FEAT-001).
const ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'webp']

// Deriva la extensión (sin punto, en minúsculas) desde el nombre del archivo.
function fileExtension(file: File): string | null {
  const match = /\.([a-z0-9]+)$/i.exec(file.name)
  if (!match) return null
  const ext = match[1].toLowerCase()
  return ALLOWED_EXTENSIONS.includes(ext) ? ext : null
}

// Mensaje uniforme ante errores de API; enruta sesiones inválidas.
function describeError(error: unknown): string {
  if (error instanceof ApiError) return error.message
  return 'Ocurrió un error inesperado.'
}

type OptionFormState =
  | { mode: 'create' }
  | { mode: 'edit'; option: Option }

function HelpCardsAdmin({ token, onSessionInvalid }: Props) {
  const [questions, setQuestions] = useState<Question[] | null>(null)
  const [questionsError, setQuestionsError] = useState<string | null>(null)
  const [selectedQuestionId, setSelectedQuestionId] = useState<string | null>(
    null,
  )

  // Las opciones quedan asociadas a su questionId para descartar respuestas
  // obsoletas si se cambia de pregunta durante la carga.
  const [optionsData, setOptionsData] = useState<{
    questionId: string
    options: Option[]
  } | null>(null)
  const [optionsError, setOptionsError] = useState<string | null>(null)
  const [optionsLoading, setOptionsLoading] = useState(false)

  const options =
    optionsData !== null && optionsData.questionId === selectedQuestionId
      ? optionsData.options
      : null

  const [notice, setNotice] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  // Formulario de crear/editar opción (modal).
  const [optionForm, setOptionForm] = useState<OptionFormState | null>(null)
  // Opción pendiente de confirmación de borrado (modal).
  const [optionToDelete, setOptionToDelete] = useState<Option | null>(null)

  // Enruta sesiones inválidas; devuelve true si consumió el error.
  const handleApiError = useCallback(
    (error: unknown): boolean => {
      if (
        error instanceof ApiError &&
        (error.kind === 'unauthorized' || error.kind === 'forbidden')
      ) {
        onSessionInvalid(error.message)
        return true
      }
      return false
    },
    [onSessionInvalid],
  )

  // Carga las 8 preguntas al montar.
  useEffect(() => {
    let active = true
    getHelpQuestions(token).then(
      (list) => {
        if (!active) return
        setQuestions(list)
        setQuestionsError(null)
        if (list.length > 0) setSelectedQuestionId((prev) => prev ?? list[0].id)
      },
      (error: unknown) => {
        if (!active) return
        if (handleApiError(error)) return
        setQuestionsError(describeError(error))
      },
    )
    return () => {
      active = false
    }
  }, [token, handleApiError])

  const loadOptions = useCallback(
    (questionId: string) => {
      setOptionsLoading(true)
      setOptionsError(null)
      getQuestionOptions(token, questionId).then(
        (list) => {
          setOptionsData({ questionId, options: list })
          setOptionsLoading(false)
        },
        (error: unknown) => {
          setOptionsLoading(false)
          if (handleApiError(error)) return
          setOptionsError(describeError(error))
        },
      )
    },
    [token, handleApiError],
  )

  // Recarga las opciones al cambiar de pregunta. Cada carga queda asociada a
  // su questionId, de modo que las opciones mostradas siempre corresponden a
  // la pregunta seleccionada (sin resetear estado de forma síncrona).
  useEffect(() => {
    if (selectedQuestionId === null) return
    loadOptions(selectedQuestionId)
  }, [selectedQuestionId, loadOptions])

  const selectedQuestion =
    questions?.find((q) => q.id === selectedQuestionId) ?? null

  // Reutiliza el manejo de errores + recarga tras una mutación correcta.
  const afterMutation = useCallback(
    (message: string) => {
      setNotice(message)
      if (selectedQuestionId !== null) loadOptions(selectedQuestionId)
    },
    [selectedQuestionId, loadOptions],
  )

  async function handleSubmitOption(
    event: FormEvent<HTMLFormElement>,
    form: OptionFormState,
  ) {
    event.preventDefault()
    if (selectedQuestionId === null) return

    const data = new FormData(event.currentTarget)
    const optionText = String(data.get('option_text') ?? '').trim()
    const valueKey = String(data.get('value_key') ?? '').trim()
    const descriptionRaw = String(data.get('description') ?? '').trim()
    const description = descriptionRaw === '' ? null : descriptionRaw

    if (!optionText) {
      setNotice('El nombre de la opción es obligatorio.')
      return
    }

    setBusy(true)
    try {
      if (form.mode === 'create') {
        await createOption(token, selectedQuestionId, {
          option_text: optionText,
          value_key: valueKey,
          description,
          order_index: options?.length ?? 0,
        })
      } else {
        await updateOption(token, form.option.id, {
          option_text: optionText,
          value_key: valueKey,
          description,
        })
      }
      setOptionForm(null)
      afterMutation(
        form.mode === 'create' ? 'Opción creada.' : 'Opción actualizada.',
      )
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  async function handleConfirmDelete(option: Option) {
    setBusy(true)
    try {
      const result = await deleteOption(token, option.id)
      // Limpieza best-effort de los archivos físicos (icono + galería).
      await cleanupOptionFiles(token, result)
      setOptionToDelete(null)
      afterMutation('Opción eliminada.')
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  async function handleMoveOption(index: number, direction: -1 | 1) {
    if (options === null || selectedQuestionId === null) return
    const target = index + direction
    if (target < 0 || target >= options.length) return

    const reordered = [...options]
    const [moved] = reordered.splice(index, 1)
    reordered.splice(target, 0, moved)

    setBusy(true)
    try {
      await reorderOptions(
        token,
        selectedQuestionId,
        reordered.map((o) => o.id),
      )
      afterMutation('Orden actualizado.')
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  // --- Icono ------------------------------------------------------------
  async function handleIconUpload(option: Option, file: File) {
    const ext = fileExtension(file)
    if (!ext) {
      setNotice('Formato de imagen no permitido (usa jpg, png o webp).')
      return
    }

    const imageId = `icon-${option.id}`
    setBusy(true)
    try {
      await uploadOptionImage(token, imageId, ext, file)
      await setOptionIcon(token, option.id, imageId, ext)
      afterMutation('Icono actualizado.')
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  async function handleIconDelete(option: Option) {
    setBusy(true)
    try {
      await deleteOptionIcon(token, option.id)
      afterMutation('Icono eliminado.')
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  // --- Galería ----------------------------------------------------------
  async function handleGalleryUpload(option: Option, files: FileList) {
    const valid: { file: File; ext: string }[] = []
    for (const file of Array.from(files)) {
      const ext = fileExtension(file)
      if (ext) valid.push({ file, ext })
    }

    if (valid.length === 0) {
      setNotice('Ningún archivo tiene un formato permitido (jpg, png, webp).')
      return
    }

    setBusy(true)
    try {
      let order = option.photos.length
      for (const { file, ext } of valid) {
        const created = await addOptionPhoto(token, option.id, ext, order)
        await uploadOptionImage(token, created.id, ext, file)
        order += 1
      }
      afterMutation(
        valid.length === 1 ? 'Foto agregada.' : `${valid.length} fotos agregadas.`,
      )
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  async function handlePhotoDelete(photoId: string) {
    setBusy(true)
    try {
      await deleteOptionPhoto(token, photoId)
      afterMutation('Foto eliminada.')
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  async function handleMovePhoto(
    option: Option,
    index: number,
    direction: -1 | 1,
  ) {
    const target = index + direction
    if (target < 0 || target >= option.photos.length) return

    const reordered = [...option.photos]
    const [moved] = reordered.splice(index, 1)
    reordered.splice(target, 0, moved)

    setBusy(true)
    try {
      await reorderOptionPhotos(
        token,
        option.id,
        reordered.map((p) => p.id),
      )
      afterMutation('Orden de fotos actualizado.')
    } catch (error) {
      if (!handleApiError(error)) setNotice(describeError(error))
    } finally {
      setBusy(false)
    }
  }

  return (
    <section className="help-cards">
      <div className="help-cards-header">
        <h2>Fichas de ayuda</h2>
        {notice && (
          <p className="muted" role="status">
            {notice}
          </p>
        )}
      </div>

      {questionsError && (
        <p className="alert" role="alert">
          {questionsError}
        </p>
      )}

      {questions === null && !questionsError && (
        <p className="muted" role="status">
          Cargando preguntas…
        </p>
      )}

      {questions !== null && (
        <div className="help-cards-layout">
          <nav className="help-cards-questions" aria-label="Preguntas">
            {questions.map((q) => (
              <button
                key={q.id}
                type="button"
                className={
                  q.id === selectedQuestionId
                    ? 'help-question active'
                    : 'help-question'
                }
                aria-pressed={q.id === selectedQuestionId}
                onClick={() => setSelectedQuestionId(q.id)}
              >
                {q.question_text}
              </button>
            ))}
          </nav>

          <div className="help-cards-options">
            {selectedQuestion && (
              <div className="help-options-header">
                <h3>{selectedQuestion.question_text}</h3>
                <button
                  type="button"
                  className="secondary"
                  disabled={busy}
                  onClick={() => setOptionForm({ mode: 'create' })}
                >
                  Agregar opción
                </button>
              </div>
            )}

            {optionsLoading && (
              <p className="muted" role="status">
                Cargando opciones…
              </p>
            )}

            {optionsError && (
              <div className="form">
                <p className="alert" role="alert">
                  {optionsError}
                </p>
                <div className="actions">
                  <button
                    type="button"
                    onClick={() =>
                      selectedQuestionId && loadOptions(selectedQuestionId)
                    }
                  >
                    Reintentar
                  </button>
                </div>
              </div>
            )}

            {!optionsLoading &&
              !optionsError &&
              options !== null &&
              options.length === 0 && (
                <p className="muted">Esta pregunta todavía no tiene opciones.</p>
              )}

            {!optionsLoading &&
              !optionsError &&
              options !== null &&
              options.map((option, index) => (
                <OptionCard
                  key={option.id}
                  token={token}
                  option={option}
                  index={index}
                  total={options.length}
                  busy={busy}
                  onSessionInvalid={onSessionInvalid}
                  onEdit={() => setOptionForm({ mode: 'edit', option })}
                  onDelete={() => setOptionToDelete(option)}
                  onMove={(dir) => void handleMoveOption(index, dir)}
                  onIconUpload={(file) => void handleIconUpload(option, file)}
                  onIconDelete={() => void handleIconDelete(option)}
                  onGalleryUpload={(files) =>
                    void handleGalleryUpload(option, files)
                  }
                  onPhotoDelete={(photoId) => void handlePhotoDelete(photoId)}
                  onPhotoMove={(photoIndex, dir) =>
                    void handleMovePhoto(option, photoIndex, dir)
                  }
                />
              ))}
          </div>
        </div>
      )}

      {optionForm && (
        <ModalShell
          title={optionForm.mode === 'create' ? 'Nueva opción' : 'Editar opción'}
          busy={busy}
          onClose={() => setOptionForm(null)}
        >
          <form
            className="form"
            onSubmit={(event) => void handleSubmitOption(event, optionForm)}
          >
            <label htmlFor="option_text">Nombre de la opción</label>
            <input
              id="option_text"
              name="option_text"
              type="text"
              defaultValue={
                optionForm.mode === 'edit' ? optionForm.option.option_text : ''
              }
              autoFocus
            />

            <label htmlFor="value_key">Clave (value_key)</label>
            <input
              id="value_key"
              name="value_key"
              type="text"
              defaultValue={
                optionForm.mode === 'edit' ? optionForm.option.value_key : ''
              }
            />

            <label htmlFor="description">Texto descriptivo</label>
            <textarea
              id="description"
              name="description"
              rows={4}
              defaultValue={
                optionForm.mode === 'edit'
                  ? (optionForm.option.description ?? '')
                  : ''
              }
            />

            <div className="actions modal-actions">
              <button
                type="button"
                className="secondary"
                disabled={busy}
                onClick={() => setOptionForm(null)}
              >
                Cancelar
              </button>
              <button type="submit" disabled={busy}>
                {busy ? 'Guardando…' : 'Guardar'}
              </button>
            </div>
          </form>
        </ModalShell>
      )}

      {optionToDelete && (
        <ModalShell
          title="Eliminar opción"
          busy={busy}
          onClose={() => setOptionToDelete(null)}
        >
          <p className="modal-species">
            ¿Eliminar la opción «{optionToDelete.option_text}»? Se borrarán su
            icono y todas sus fotos de galería. Esta acción no se puede deshacer.
          </p>
          <div className="actions modal-actions">
            <button
              type="button"
              className="secondary"
              disabled={busy}
              onClick={() => setOptionToDelete(null)}
            >
              Cancelar
            </button>
            <button
              type="button"
              className="btn-reject"
              disabled={busy}
              onClick={() => void handleConfirmDelete(optionToDelete)}
            >
              {busy ? 'Eliminando…' : 'Eliminar'}
            </button>
          </div>
        </ModalShell>
      )}
    </section>
  )
}

// Borra en el servidor los archivos físicos devueltos por DELETE /options/<id>.
// El backend ya removió las filas; esto limpia uploads/opciones/. Best-effort:
// un fallo acá no debe romper el flujo de borrado de la opción.
async function cleanupOptionFiles(
  token: string,
  result: {
    deleted_photos: { id: string; file_extension: string | null }[]
    icon_attachment_id: string | null
    icon_extension: string | null
  },
): Promise<void> {
  const ids: string[] = []
  if (result.icon_attachment_id) ids.push(result.icon_attachment_id)
  for (const photo of result.deleted_photos) ids.push(photo.id)

  await Promise.allSettled(
    ids.map((id) =>
      fetch(
        `${deleteImageBase()}/option-images/${encodeURIComponent(id)}`,
        { method: 'DELETE', headers: { Authorization: `Bearer ${token}` } },
      ).catch(() => undefined),
    ),
  )
}

// Evita importar API_BASE_URL solo para la limpieza best-effort.
function deleteImageBase(): string {
  return import.meta.env.VITE_API_BASE_URL ?? 'http://127.0.0.1:5000'
}

interface OptionCardProps {
  token: string
  option: Option
  index: number
  total: number
  busy: boolean
  onSessionInvalid: (message: string) => void
  onEdit: () => void
  onDelete: () => void
  onMove: (direction: -1 | 1) => void
  onIconUpload: (file: File) => void
  onIconDelete: () => void
  onGalleryUpload: (files: FileList) => void
  onPhotoDelete: (photoId: string) => void
  onPhotoMove: (photoIndex: number, direction: -1 | 1) => void
}

function OptionCard({
  token,
  option,
  index,
  total,
  busy,
  onSessionInvalid,
  onEdit,
  onDelete,
  onMove,
  onIconUpload,
  onIconDelete,
  onGalleryUpload,
  onPhotoDelete,
  onPhotoMove,
}: OptionCardProps) {
  const iconInputRef = useRef<HTMLInputElement>(null)
  const galleryInputRef = useRef<HTMLInputElement>(null)

  return (
    <article className="help-option-card">
      <div className="help-option-top">
        <div className="help-option-reorder">
          <button
            type="button"
            className="secondary"
            aria-label="Mover arriba"
            disabled={busy || index === 0}
            onClick={() => onMove(-1)}
          >
            ↑
          </button>
          <button
            type="button"
            className="secondary"
            aria-label="Mover abajo"
            disabled={busy || index === total - 1}
            onClick={() => onMove(1)}
          >
            ↓
          </button>
        </div>

        <div className="help-option-info">
          <strong>{option.option_text}</strong>
          {option.value_key && (
            <span className="badge badge-reviewed">{option.value_key}</span>
          )}
          {option.description ? (
            <p className="muted help-option-desc">{option.description}</p>
          ) : (
            <p className="muted-text">Sin texto descriptivo</p>
          )}
        </div>

        <div className="help-option-actions">
          <button
            type="button"
            className="secondary"
            disabled={busy}
            onClick={onEdit}
          >
            Editar
          </button>
          <button
            type="button"
            className="btn-reject"
            disabled={busy}
            onClick={onDelete}
          >
            Borrar
          </button>
        </div>
      </div>

      <div className="help-option-media">
        <div className="help-option-icon">
          <h4>Icono</h4>
          <div className="help-icon-frame">
            {option.icon_attachment_id ? (
              <AuthenticatedPhoto
                token={token}
                photoId={option.icon_attachment_id}
                alt={`Icono de ${option.option_text}`}
                source="option-image"
                onSessionInvalid={onSessionInvalid}
              />
            ) : (
              <div className="photo-frame photo-placeholder">
                <span>Sin icono</span>
              </div>
            )}
          </div>
          <div className="actions">
            <input
              ref={iconInputRef}
              type="file"
              accept="image/jpeg,image/png,image/webp"
              className="visually-hidden"
              onChange={(event) => {
                const file = event.target.files?.[0]
                if (file) onIconUpload(file)
                event.target.value = ''
              }}
            />
            <button
              type="button"
              className="secondary"
              disabled={busy}
              onClick={() => iconInputRef.current?.click()}
            >
              {option.icon_attachment_id ? 'Cambiar icono' : 'Subir icono'}
            </button>
            {option.icon_attachment_id && (
              <button
                type="button"
                className="btn-reject"
                disabled={busy}
                onClick={onIconDelete}
              >
                Quitar
              </button>
            )}
          </div>
        </div>

        <div className="help-option-gallery">
          <div className="help-gallery-header">
            <h4>Galería</h4>
            <input
              ref={galleryInputRef}
              type="file"
              accept="image/jpeg,image/png,image/webp"
              multiple
              className="visually-hidden"
              onChange={(event) => {
                const files = event.target.files
                if (files && files.length > 0) onGalleryUpload(files)
                event.target.value = ''
              }}
            />
            <button
              type="button"
              className="secondary"
              disabled={busy}
              onClick={() => galleryInputRef.current?.click()}
            >
              Subir fotos
            </button>
          </div>

          {option.photos.length === 0 ? (
            <p className="muted">Sin fotos todavía.</p>
          ) : (
            <div className="help-gallery-grid">
              {option.photos.map((photo, photoIndex) => (
                <div key={photo.id} className="help-gallery-item">
                  <AuthenticatedPhoto
                    token={token}
                    photoId={photo.id}
                    alt={`Foto ${photoIndex + 1} de ${option.option_text}`}
                    source="option-image"
                    onSessionInvalid={onSessionInvalid}
                  />
                  <div className="actions help-gallery-actions">
                    <button
                      type="button"
                      className="secondary"
                      aria-label="Mover foto a la izquierda"
                      disabled={busy || photoIndex === 0}
                      onClick={() => onPhotoMove(photoIndex, -1)}
                    >
                      ←
                    </button>
                    <button
                      type="button"
                      className="secondary"
                      aria-label="Mover foto a la derecha"
                      disabled={busy || photoIndex === option.photos.length - 1}
                      onClick={() => onPhotoMove(photoIndex, 1)}
                    >
                      →
                    </button>
                    <button
                      type="button"
                      className="btn-reject"
                      disabled={busy}
                      onClick={() => onPhotoDelete(photo.id)}
                    >
                      Borrar
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </article>
  )
}

export default HelpCardsAdmin
