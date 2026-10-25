import { useState } from 'react'
import { MapContainer, Marker, TileLayer } from 'react-leaflet'
import L from 'leaflet'
import markerIcon from 'leaflet/dist/images/marker-icon.png'
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png'
import markerShadow from 'leaflet/dist/images/marker-shadow.png'
import ModalShell from './ModalShell.tsx'

// Vite no resuelve los PNG por defecto de Leaflet; se setean explícitamente.
// Hay que borrar _getIconUrl para que Leaflet no reconstruya la ruta rota
// (/node_modules/leaflet/dist/images/...) en vez de usar los iconos importados.
delete (L.Icon.Default.prototype as unknown as { _getIconUrl?: unknown })._getIconUrl
L.Icon.Default.mergeOptions({
  iconUrl: markerIcon,
  iconRetinaUrl: markerIcon2x,
  shadowUrl: markerShadow,
})

interface Props {
  latitude: number
  longitude: number
  label?: string
}

// Mapa por fotografía con tiles de OpenStreetMap (gratis, sin API key).
// Muestra el punto y permite expandirlo a un popup más grande e interactivo.
function PhotoMap({ latitude, longitude, label }: Props) {
  const position: [number, number] = [latitude, longitude]
  const [expanded, setExpanded] = useState(false)

  return (
    <>
      <div className="photo-map">
        <MapContainer
          center={position}
          zoom={15}
          scrollWheelZoom={false}
          style={{ height: '100%', width: '100%' }}
          aria-label={label ?? 'Mapa de la ubicación de la fotografía'}
        >
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution="&copy; OpenStreetMap contributors"
          />
          <Marker position={position} />
        </MapContainer>

        <button
          type="button"
          className="photo-map-expand"
          onClick={() => setExpanded(true)}
          aria-label="Expandir mapa"
          title="Expandir mapa"
        >
          ⤢
        </button>
      </div>

      {expanded && (
        <ModalShell
          title={label ?? 'Ubicación de la fotografía'}
          busy={false}
          onClose={() => setExpanded(false)}
        >
          <div className="photo-map-large">
            <MapContainer
              center={position}
              zoom={16}
              scrollWheelZoom
              style={{ height: '100%', width: '100%' }}
              aria-label={label ?? 'Mapa ampliado de la ubicación de la fotografía'}
            >
              <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution="&copy; OpenStreetMap contributors"
              />
              <Marker position={position} />
            </MapContainer>
          </div>
          <p className="muted photo-map-coords">
            {latitude.toFixed(6)}, {longitude.toFixed(6)}
          </p>
          <div className="actions">
            <button
              type="button"
              className="secondary"
              onClick={() => setExpanded(false)}
            >
              Cerrar
            </button>
          </div>
        </ModalShell>
      )}
    </>
  )
}

export default PhotoMap
