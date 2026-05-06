import { request, authHeaders } from './api'

export async function getAnnonces() {
  return await request('/api/auth/annonces', { headers: authHeaders() })
}

export async function getAnnonce(id) {
  return await request(`/api/auth/annonces/${id}`, { headers: authHeaders() })
}

export async function createAnnonce(payload) {
  // debug: show whether an Authorization header will be sent
  try {
    console.debug('[useAnnonces] createAnnonce headers', authHeaders())
  } catch (e) {}
  return await request('/api/auth/annonces', {
    method: 'POST',
    headers: authHeaders(),
    body: JSON.stringify(payload),
  })
}
let annoncesCache = null

export async function listAnnonces(force = false) {
  if (!force && annoncesCache) return { data: annoncesCache }
  const res = await request('/api/auth/annonces', { headers: authHeaders() })
  if (res && res.data) annoncesCache = res.data
  return res
}

export function invalidateAnnoncesCache() {
  annoncesCache = null
}

export async function updateAnnonce(id, payload) {
  return await request(`/api/auth/professeur/annonces/${id}`, {
    method: 'PUT',
    headers: authHeaders(),
    body: JSON.stringify(payload),
  })
}

export async function deleteAnnonce(id) {
  return await request(`/api/auth/professeur/annonces/${id}`, {
    method: 'DELETE',
    headers: authHeaders(),
  })
}


