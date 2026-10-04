import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { GoogleOAuthProvider } from '@react-oauth/google'
import './index.css'
import App from './App.tsx'

const googleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID as
  | string
  | undefined

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    {googleClientId ? (
      <GoogleOAuthProvider clientId={googleClientId}>
        <App />
      </GoogleOAuthProvider>
    ) : (
      <main className="page">
        <section className="card">
          <p className="eyebrow">Kospia</p>
          <h1>Kospia — Panel profesional</h1>
          <p className="alert" role="alert">
            Falta configurar VITE_GOOGLE_CLIENT_ID. Copiá .env.example a .env,
            completá el Client ID de Google y reiniciá Vite.
          </p>
        </section>
      </main>
    )}
  </StrictMode>,
)
