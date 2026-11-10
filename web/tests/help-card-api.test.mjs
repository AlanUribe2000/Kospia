import assert from 'node:assert/strict'
import { after, test } from 'node:test'
import { fileURLToPath } from 'node:url'
import React from 'react'
import { renderToStaticMarkup } from 'react-dom/server'
import { createServer } from 'vite'

const root = fileURLToPath(new URL('../', import.meta.url))
const server = await createServer({ root, server: { middlewareMode: true }, appType: 'custom' })
const { ApiError, replaceOptionIcon, updateOptionHelp } = await server.ssrLoadModule('/src/api/client.ts')
const { OptionCard } = await server.ssrLoadModule('/src/components/HelpCardsAdmin.tsx')
const originalFetch = globalThis.fetch

after(async () => {
  globalThis.fetch = originalFetch
  await server.close()
})

test('professional description update sends only description to the help endpoint', async () => {
  let request
  globalThis.fetch = async (url, options) => {
    request = { url, options }
    return new Response(null, { status: 204 })
  }

  await updateOptionHelp('token', 'id/with space', 'description')
  assert.match(request.url, /\/options\/id%2Fwith%20space\/help$/)
  assert.equal(request.options.method, 'PATCH')
  assert.equal(request.options.headers.Authorization, 'Bearer token')
  assert.equal(request.options.headers['Content-Type'], 'application/json')
  assert.deepEqual(JSON.parse(request.options.body), { description: 'description' })
})

test('description can be cleared and backend validation errors propagate', async () => {
  globalThis.fetch = async (_url, options) => {
    assert.deepEqual(JSON.parse(options.body), { description: null })
    return Response.json({ error: 'Descripcion invalida' }, { status: 400 })
  }

  await assert.rejects(updateOptionHelp('token', 'option', null), (error) => {
    assert.ok(error instanceof ApiError)
    assert.equal(error.kind, 'badRequest')
    assert.equal(error.message, 'Descripcion invalida')
    return true
  })
})

test('two icon replacements upload and associate distinct immutable IDs', async () => {
  const uploads = []
  const associations = []
  globalThis.fetch = async (url, options) => {
    const parsed = new URL(url)
    if (parsed.pathname.startsWith('/option-images/')) {
      uploads.push({ id: decodeURIComponent(parsed.pathname.split('/').pop()), extension: parsed.searchParams.get('extension'), body: await options.body.text() })
    } else {
      assert.equal(parsed.pathname, '/options/option-1/icon')
      associations.push(JSON.parse(options.body))
    }
    return new Response(null, { status: 200 })
  }

  await replaceOptionIcon('token', 'option-1', 'png', new Blob(['first']))
  await replaceOptionIcon('token', 'option-1', 'png', new Blob(['second']))

  assert.equal(uploads.length, 2)
  assert.match(uploads[0].id, /^icon-[0-9a-f]{32}$/)
  assert.notEqual(uploads[0].id, uploads[1].id)
  assert.deepEqual(uploads.map((upload) => upload.body), ['first', 'second'])
  assert.deepEqual(associations, uploads.map((upload) => ({ icon_attachment_id: upload.id, icon_extension: upload.extension })))
})

test('an ID collision preserves the previous image and stops association', async (context) => {
  context.mock.method(globalThis.crypto, 'getRandomValues', (bytes) => bytes.fill(1))
  const files = new Map()
  const associations = []
  globalThis.fetch = async (url, options) => {
    const parsed = new URL(url)
    if (parsed.pathname.startsWith('/option-images/')) {
      if (files.has(parsed.pathname)) return Response.json({ error: 'exists' }, { status: 409 })
      files.set(parsed.pathname, await options.body.text())
    } else {
      associations.push(JSON.parse(options.body))
    }
    return new Response(null, { status: 200 })
  }

  await replaceOptionIcon('token', 'option-1', 'png', new Blob(['original']))
  await assert.rejects(replaceOptionIcon('token', 'option-1', 'png', new Blob(['replacement'])), (error) => {
    assert.ok(error instanceof ApiError)
    assert.equal(error.kind, 'conflict')
    return true
  })
  assert.deepEqual([...files.values()], ['original'])
  assert.equal(associations.length, 1)
})

test('a failed association never deletes the uploaded or previous image', async () => {
  const methods = []
  globalThis.fetch = async (url, options) => {
    methods.push(options.method)
    if (new URL(url).pathname.startsWith('/options/')) {
      return Response.json({ error: 'unavailable' }, { status: 500 })
    }
    return new Response(null, { status: 200 })
  }

  await assert.rejects(replaceOptionIcon('token', 'option-1', 'png', new Blob(['image'])), (error) => {
    assert.ok(error instanceof ApiError)
    assert.equal(error.kind, 'server')
    return true
  })
  assert.deepEqual(methods, ['PUT', 'PUT'])
})

test('only admins see option deletion and reordering controls', () => {
  const props = {
    token: 'token',
    option: { id: 'option', option_text: 'Opcion', value_key: 'key', description: null, icon_attachment_id: null, photos: [] },
    index: 0,
    total: 1,
    busy: false,
    onSessionInvalid() {},
    onEdit() {},
    onDelete() {},
    onMove() {},
    onIconUpload() {},
    onIconDelete() {},
    onGalleryUpload() {},
    onPhotoDelete() {},
    onPhotoMove() {},
  }
  const professional = renderToStaticMarkup(React.createElement(OptionCard, { ...props, isAdmin: false }))
  const admin = renderToStaticMarkup(React.createElement(OptionCard, { ...props, isAdmin: true }))

  assert.doesNotMatch(professional, /Mover arriba|Mover abajo|>Borrar</)
  assert.match(professional, />Editar</)
  assert.match(professional, />Subir icono</)
  assert.match(professional, />Subir fotos</)
  assert.match(admin, /Mover arriba/)
  assert.match(admin, /Mover abajo/)
  assert.match(admin, />Borrar</)
})