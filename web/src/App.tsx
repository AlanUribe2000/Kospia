import { useCallback, useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { GoogleLogin } from '@react-oauth/google'
import type { CredentialResponse } from '@react-oauth/google'
import { ApiError, getProfessionalMe, loginWithGoogle } from './api/client.ts'
import ObservationsPanel from './components/ObservationsPanel.tsx'
import ObservationDetailView from './components/ObservationDetail.tsx'
import HelpCardsAdmin from './components/HelpCardsAdmin.tsx'
import type { ProfessionalUser } from './types/auth.ts'
import type { ValidationStatus } from './types/observations.ts'

const TOKEN_KEY = 'kospia.access_token'

type Session =
  | { status: 'anonymous' }
  | { status: 'loading' }
  | { status: 'active'; user: ProfessionalUser; token: string }
  | { status: 'error'; message: string }

function readToken(): string | null {
  return sessionStorage.getItem(TOKEN_KEY)
}

function App() {
  const [session, setSession] = useState<Session>(() =>
    readToken() ? { status: 'loading' } : { status: 'anonymous' },
  )
  const [notice, setNotice] = useState<string | null>(null)
  const [tokenInput, setTokenInput] = useState('')
  const [filter, setFilter] = useState<ValidationStatus>('pending')
  const [selectedObservationId, setSelectedObservationId] = useState<
    string | null
  >(null)
  // Sección activa del panel (solo relevante para rol admin).
  const [adminSection, setAdminSection] = useState<'observations' | 'helpCards'>(
    'observations',
  )

  const fetchSession = useCallback(async (token: string) => {
    try {
      const { user } = await getProfessionalMe(token)
      setNotice(null)
      setSession({ status: 'active', user, token })
    } catch (error) {
      if (
        error instanceof ApiError &&
        (error.kind === 'unauthorized' || error.kind === 'forbidden')
      ) {
        sessionStorage.removeItem(TOKEN_KEY)
        setNotice(error.message)
        setSession({ status: 'anonymous' })
        return
      }

      setSession({
        status: 'error',
        message:
          error instanceof ApiError
            ? error.message
            : 'Ocurrió un error inesperado.',
      })
    }
  }, [])

  const loadSession = useCallback(() => {
    const token = readToken()
    if (!token) {
      setSession({ status: 'anonymous' })
      return
    }

    setSession({ status: 'loading' })
    void fetchSession(token)
  }, [fetchSession])

  useEffect(() => {
    const token = readToken()
    if (token) {
      void fetchSession(token)
    }
  }, [fetchSession])

  const handleSessionInvalid = useCallback((message: string) => {
    sessionStorage.removeItem(TOKEN_KEY)
    setNotice(message)
    setSelectedObservationId(null)
    setFilter('pending')
    setAdminSection('observations')
    setSession({ status: 'anonymous' })
  }, [])

  async function handleGoogleSuccess(credentialResponse: CredentialResponse) {
    const idToken = credentialResponse.credential

    if (!idToken) {
      setNotice('Google no devolvió una credencial válida.')
      return
    }

    setNotice(null)
    setSession({ status: 'loading' })

    try {
      const { access_token } = await loginWithGoogle(idToken)
      sessionStorage.setItem(TOKEN_KEY, access_token)
      await fetchSession(access_token)
    } catch (error) {
      setNotice(
        error instanceof ApiError
          ? error.message
          : 'Ocurrió un error inesperado al iniciar sesión.',
      )
      setSession({ status: 'anonymous' })
    }
  }

  // Solo desarrollo: permite pegar un JWT Kospia a mano.
  function handleDevLogin(event: FormEvent) {
    event.preventDefault()
    const token = tokenInput.trim()

    if (!token) {
      setNotice('Pegá un JWT Kospia para ingresar.')
      return
    }

    sessionStorage.setItem(TOKEN_KEY, token)
    setTokenInput('')
    setNotice(null)
    loadSession()
  }

  function handleLogout() {
    sessionStorage.removeItem(TOKEN_KEY)
    setNotice(null)
    setSelectedObservationId(null)
    setFilter('pending')
    setAdminSection('observations')
    setSession({ status: 'anonymous' })
  }

  if (session.status === 'active') {
    const { user } = session
    // La sección "Fichas de ayuda" la gestiona el rol professional (no existe
    // un rol admin en producción); se incluye admin por compatibilidad.
    const canManageHelpCards =
      user.role === 'professional' || user.role === 'admin'

    return (
      <div className="dashboard">
        <header className="topbar">
          <div>
            <p className="eyebrow">Kospia</p>
            <h1>Panel profesional</h1>
            {canManageHelpCards && (
              <nav
                className="admin-nav"
                role="tablist"
                aria-label="Secciones de administración"
              >
                <button
                  type="button"
                  role="tab"
                  aria-selected={adminSection === 'observations'}
                  className={
                    adminSection === 'observations' ? 'filter active' : 'filter'
                  }
                  onClick={() => setAdminSection('observations')}
                >
                  Panel profesional
                </button>
                <button
                  type="button"
                  role="tab"
                  aria-selected={adminSection === 'helpCards'}
                  className={
                    adminSection === 'helpCards' ? 'filter active' : 'filter'
                  }
                  onClick={() => setAdminSection('helpCards')}
                >
                  Fichas de ayuda
                </button>
              </nav>
            )}
          </div>
          <div className="session-info">
            {user.photo_url && (
              <img
                className="avatar small"
                src={user.photo_url}
                alt=""
                referrerPolicy="no-referrer"
              />
            )}
            <div className="session-text">
              <span>{user.display_name ?? user.email ?? '—'}</span>
              <span className="muted">{user.role}</span>
            </div>
            <button type="button" className="secondary" onClick={handleLogout}>
              Cerrar sesión
            </button>
          </div>
        </header>

        {canManageHelpCards && adminSection === 'helpCards' ? (
          <HelpCardsAdmin
            token={session.token}
            onSessionInvalid={handleSessionInvalid}
          />
        ) : selectedObservationId === null ? (
          <ObservationsPanel
            token={session.token}
            filter={filter}
            onFilterChange={setFilter}
            onSelect={setSelectedObservationId}
            onSessionInvalid={handleSessionInvalid}
          />
        ) : (
          <ObservationDetailView
            token={session.token}
            observationId={selectedObservationId}
            onBack={() => setSelectedObservationId(null)}
            onSessionInvalid={handleSessionInvalid}
          />
        )}
      </div>
    )
  }

  return (
    <main className="page">
      <section className="card">
        <p className="eyebrow">Kospia</p>
        <h1>Kospia — Panel profesional</h1>

        {session.status === 'loading' && (
          <p className="muted" role="status">
            Verificando sesión…
          </p>
        )}

        {session.status === 'anonymous' && (
          <div className="form">
            <p className="muted">
              Ingresá con tu cuenta de Google autorizada.
            </p>
            {notice && (
              <p className="alert" role="alert">
                {notice}
              </p>
            )}
            <div className="google-button">
              <GoogleLogin
                onSuccess={(response) => void handleGoogleSuccess(response)}
                onError={() =>
                  setNotice('No se pudo completar el inicio de sesión con Google.')
                }
              />
            </div>

            {import.meta.env.DEV && (
              <details className="dev-access">
                <summary>Acceso de desarrollo</summary>
                <form onSubmit={handleDevLogin} className="form">
                  <label htmlFor="token">JWT Kospia</label>
                  <input
                    id="token"
                    type="password"
                    autoComplete="off"
                    value={tokenInput}
                    onChange={(e) => setTokenInput(e.target.value)}
                  />
                  <button type="submit" className="secondary">
                    Ingresar
                  </button>
                </form>
              </details>
            )}
          </div>
        )}

        {session.status === 'error' && (
          <div className="form">
            <p className="alert" role="alert">
              {session.message}
            </p>
            <div className="actions">
              <button type="button" onClick={loadSession}>
                Reintentar
              </button>
              <button type="button" className="secondary" onClick={handleLogout}>
                Cerrar sesión
              </button>
            </div>
          </div>
        )}
      </section>
    </main>
  )
}

export default App
