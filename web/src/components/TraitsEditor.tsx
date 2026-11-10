import { useEffect, useRef, useState } from 'react'
import type { FormEvent } from 'react'
import { ApiError } from '../api/client.ts'
import { getCatalogDetail, getCatalogQuestions, updateCatalogTraits } from '../api/adminCatalog.ts'
import type { CatalogQuestion, CatalogSpeciesDetail, TraitAssignment } from '../api/adminCatalog.ts'

interface Props {
  token: string
  species: CatalogSpeciesDetail
  onCancel: () => void
  onSaved: (result: Pick<CatalogSpeciesDetail, 'id' | 'updated_at' | 'traits'>) => void
  onSessionInvalid: (message: string) => void
}

function key(pair: TraitAssignment) {
  return JSON.stringify([pair.question_id, pair.option_id])
}

function keys(traits: TraitAssignment[]) {
  return traits.map(key).sort()
}

function sameTraits(left: TraitAssignment[], right: TraitAssignment[]) {
  return JSON.stringify(keys(left)) === JSON.stringify(keys(right))
}

export default function TraitsEditor({ token, species, onCancel, onSaved, onSessionInvalid }: Props) {
  const [questions, setQuestions] = useState<CatalogQuestion[] | null>(null)
  const [selection, setSelection] = useState<TraitAssignment[]>(() => species.traits.map(({ question_id, option_id }) => ({ question_id, option_id })))
  const [error, setError] = useState<string | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)
  const [attempt, setAttempt] = useState(0)
  const pending = useRef(false)

  useEffect(() => {
    const controller = new AbortController()
    getCatalogQuestions(token, controller.signal).then(
      (result) => { if (!controller.signal.aborted) setQuestions(result.questions) },
      (caught: unknown) => {
        if (controller.signal.aborted) return
        if (caught instanceof ApiError && caught.kind === 'unauthorized') onSessionInvalid(caught.message)
        else setError(caught instanceof ApiError ? caught.message : 'No se pudieron cargar las preguntas.')
      },
    )
    return () => controller.abort()
  }, [token, attempt, onSessionInvalid])

  const initial = species.traits
  const selected = new Set(selection.map(key))
  const invalidExisting = questions !== null && (
    new Set(initial.map(key)).size !== initial.length ||
    initial.some((trait) => !questions.some((question) => question.id === trait.question_id && question.is_active === true && question.options.some((option) => option.id === trait.option_id)))
  )

  function toggle(pair: TraitAssignment, checked: boolean) {
    setSelection((current) => checked ? (current.some((item) => key(item) === key(pair)) ? current : [...current, pair]) : current.filter((item) => key(item) !== key(pair)))
    setError(null)
    setNotice(null)
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (pending.current || !questions || invalidExisting) return
    setError(null)
    setNotice(null)
    if (sameTraits(initial, selection)) {
      setNotice('No hay cambios para guardar.')
      return
    }
    const removed = initial.filter((trait) => !selected.has(key(trait)))
    if (removed.length && !window.confirm(`Se eliminarán ${removed.length} asignaciones existentes. ¿Querés continuar?`)) return
    pending.current = true
    setSaving(true)
    try {
      const latest = await getCatalogDetail(token, species.id)
      if (!sameTraits(initial, latest.species.traits)) {
        setError('Las asignaciones cambiaron desde que abriste el editor. Cancelá y volvé a abrirlo para revisar los datos actuales.')
        return
      }
      const result = await updateCatalogTraits(token, species.id, selection)
      if (!Array.isArray(result.traits)) throw new Error('Respuesta inválida')
      onSaved(result)
    } catch (caught) {
      if (caught instanceof ApiError && caught.kind === 'unauthorized') onSessionInvalid(caught.message)
      else setError(caught instanceof ApiError ? caught.message : 'No se pudieron guardar los rasgos.')
    } finally {
      pending.current = false
      setSaving(false)
    }
  }

  return <section aria-labelledby="traits-editor-title">
    <h3 id="traits-editor-title">Configurar identificación</h3>
    {questions === null && !error && <p role="status">Cargando preguntas...</p>}
    {error && <div className="catalog-message"><p className="alert" role="alert">{error}</p>{questions === null && <button type="button" onClick={() => { setError(null); setAttempt((value) => value + 1) }}>Reintentar</button>}</div>}
    {invalidExisting && <p className="alert" role="alert">Hay asignaciones duplicadas o correspondientes a preguntas u opciones no editables. No se puede guardar para evitar pérdidas; revisá los datos antes de continuar.</p>}
    {questions !== null && <form onSubmit={submit}>
      {questions.filter((question) => question.is_active === true).map((question) => <fieldset className="traits-question" key={question.id} disabled={saving || invalidExisting}>
        <legend>{question.question_text}</legend>
        {question.options.length === 0 ? <p className="muted">Sin opciones disponibles.</p> : question.options.map((option) => {
          const pair = { question_id: question.id, option_id: option.id }
          return <label key={option.id} className="traits-option"><input type="checkbox" checked={selected.has(key(pair))} onChange={(event) => toggle(pair, event.target.checked)} />{option.option_text}</label>
        })}
        {!selection.some((pair) => pair.question_id === question.id) && <p className="muted">Rasgos sin definir.</p>}
      </fieldset>)}
      {notice && <p role="status">{notice}</p>}
      <div className="actions"><button type="submit" disabled={saving || invalidExisting}>{saving ? 'Guardando...' : 'Guardar identificación'}</button><button type="button" className="secondary" disabled={saving} onClick={onCancel}>Cancelar</button></div>
    </form>}
    {questions === null && <button type="button" className="secondary" onClick={onCancel}>Cancelar</button>}
  </section>
}