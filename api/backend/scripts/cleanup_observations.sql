-- Limpia TODAS las identificaciones del esquema Kospia (public.observations).
-- NO toca el esquema legacy observaciones/fotografias_observacion.
-- El orden respeta las FKs (hijos antes que padres).
--
-- Prerequisito: la migración 005 (notifications) debe estar aplicada ANTES de
-- correr este script; de lo contrario el DELETE FROM public.notifications falla
-- porque la tabla no existe.
--
-- ADVERTENCIA: estos DELETE son IRREVERSIBLES y afectan a todos los usuarios de
-- la base. Apropiado para el entorno de Docker/tesis; NO ejecutar contra la base
-- del servidor universitario con datos reales sin respaldo.
BEGIN;

DELETE FROM public.notifications;
DELETE FROM public.observation_photos;
DELETE FROM public.observations;

COMMIT;
