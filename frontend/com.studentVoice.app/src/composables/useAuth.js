import { ref, computed } from 'vue'
import { request, authHeaders } from './api'

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000'

const user = ref({
  id: null,
  name: null,
  email: null,
  role: null,
})

// hydrate user from localStorage if present
try {
  const raw = localStorage.getItem('user')
  if (raw) {
    const u = JSON.parse(raw)
    if (u && u.id) user.value = u
  }
} catch (e) {
  // ignore
}

import { ref as refLocal } from 'vue'

const delegateMode = refLocal(false)
const isDelegate = computed(() => {
  const r = (user.value && user.value.role) || ''
  const roleLower = r.toString().toLowerCase()
  // also accept explicit flag from profile
  const explicit = Boolean(user.value && user.value.is_delegate)
  return (
    explicit || delegateMode.value || roleLower === 'delegate' || roleLower === 'delegue' || roleLower.includes('deleg')
  )
})

const canPublish = computed(() => {
  const publishRoles = ['delegate', 'delegue', 'professeur', 'admin', 'administration']
  const r = user.value && user.value.role
  let roleName = ''
  if (!r) roleName = ''
  else if (typeof r === 'string') roleName = r
  else if (r.nom_roles) roleName = r.nom_roles
  else if (r.name) roleName = r.name
  roleName = (roleName || '').toString().toLowerCase()
  return publishRoles.includes(roleName)
})

const setUser = (newUser) => {
  user.value = newUser
}

// persist user to localStorage
const persistUser = (u) => {
  try {
    if (u && u.id) localStorage.setItem('user', JSON.stringify(u))
    else localStorage.removeItem('user')
  } catch (e) {
    // ignore
  }
}

const toggleRole = () => {
  delegateMode.value = !delegateMode.value
}

const logout = async () => {
  const token = localStorage.getItem('token')
  try {
    await fetch(`${API_BASE}/api/auth/sign_out`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
    })
  } catch (e) {
    // ignore
  }
  localStorage.removeItem('token')
  setUser({ id: null, name: null, email: null, role: null })
  persistUser(null)
  // redirect to home after logout
  try {
    window.location.href = '/home'
  } catch (e) {
    // fallback: do nothing
  }
}

async function login(email, password) {
  let res
  try {
    res = await fetch(`${API_BASE}/api/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    })
  } catch (networkErr) {
    const e = new Error('Impossible de joindre le serveur. Vérifiez votre connexion.')
    e.status = 0
    throw e
  }

  if (!res.ok) {
    let errJson = {}
    try {
      errJson = await res.json()
    } catch (e) {
      // ignore parse error
    }
    let message = ''
    if (errJson.message) message = errJson.message
    else if (errJson.error) message = errJson.error
    else if (errJson.errors) {
      if (Array.isArray(errJson.errors)) message = errJson.errors.join(', ')
      else {
        const parts = []
        for (const k in errJson.errors) {
          const v = errJson.errors[k]
          if (Array.isArray(v)) parts.push(`${k} ${v.join(', ')}`)
          else parts.push(`${k} ${v}`)
        }
        message = parts.join('; ')
      }
    } else if (res.status === 401) message = 'Email ou mot de passe incorrect'
    else message = `Erreur serveur (${res.status})`
    const err = new Error(message)
    err.status = res.status
    err.body = errJson
    throw err
  }

  const data = await res.json()
  // backend returns keys like email_utilisateurs, prenom_utilisateurs, nom_utilisateurs, role, token
  const mapped = {
    id: data.id,
    name: `${data.prenom_utilisateurs || ''} ${data.nom_utilisateurs || ''}`.trim(),
    email: data.email_utilisateurs,
    role: data.role,
  }
  localStorage.setItem('token', data.token)
  setUser(mapped)
  persistUser(mapped)
  return mapped
}

async function register(accountPayload, asRole) {
  // asRole: 'etudiant' or 'professeur'
  const endpoint = asRole === 'enseignant' || asRole === 'professeur' ? 'professeur' : 'etudiant'
  let res
  try {
    res = await fetch(`${API_BASE}/api/${endpoint}/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ account: accountPayload }),
    })
  } catch (networkErr) {
    const e = new Error('Impossible de joindre le serveur. Vérifiez votre connexion.')
    e.status = 0
    throw e
  }

  if (!res.ok) {
    let errJson = {}
    try {
      errJson = await res.json()
    } catch (e) {
      // ignore parse error
    }
    let message = ''
    if (errJson.message) message = errJson.message
    else if (errJson.error) message = errJson.error
    else if (errJson.errors) {
      if (Array.isArray(errJson.errors)) message = errJson.errors.join(', ')
      else {
        const parts = []
        for (const k in errJson.errors) {
          const v = errJson.errors[k]
          if (Array.isArray(v)) parts.push(`${k} ${v.join(', ')}`)
          else parts.push(`${k} ${v}`)
        }
        message = parts.join('; ')
      }
    } else message = `Erreur serveur (${res.status})`
    const err = new Error(message)
    err.status = res.status
    err.body = errJson
    throw err
  }

  const data = await res.json()
  const mapped = {
    id: data.id,
    name: `${data.prenom_utilisateurs || ''} ${data.nom_utilisateurs || ''}`.trim(),
    email: data.email_utilisateurs,
    role: data.role,
  }
  localStorage.setItem('token', data.token)
  setUser(mapped)
  persistUser(mapped)
  return mapped
}

// load profile from backend using stored token
async function loadProfile() {
  try {
    const res = await request('/api/auth/accounts/profile', { headers: authHeaders() })
    if (res && res.utilisateur) {
      const u = res.utilisateur
      const mapped = {
        id: u.id,
        name: `${u.prenom_utilisateurs || ''} ${u.nom_utilisateurs || ''}`.trim(),
        email: u.email_utilisateurs,
        avatar: u.avatar_utilisateurs,
        role: u.role,
        // student-specific
        is_delegate: (u.etudiant && u.etudiant.est_delegue_etudiant) || false,
        groupe: (u.etudiant && u.etudiant.groupe) || null,
        groupe_id: (u.etudiant && u.etudiant.groupe_id) || null,
        telephone: (u.etudiant && u.etudiant.telephone_etudiant) || null,
        dateNaissance: (u.etudiant && u.etudiant.date_naissance_etudiant) || null,
        // professor-specific
        professeur: (u.professeur) || null,
        grade: (u.professeur && u.professeur.grade) || null,
        specialite: (u.professeur && u.professeur.specialite) || null,
        telephoneProf: (u.professeur && u.professeur.telephone) || null,
      }
      setUser(mapped)
      persistUser(mapped)
      return mapped
    }
  } catch (e) {
    // ignore, token may be invalid
  }
  return null
}

// update profile with new data
async function updateProfile(updateData) {
  const token = localStorage.getItem('token')
  try {
    const res = await fetch(`${API_BASE}/api/auth/accounts/update`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ account: updateData }),
    })

    if (!res.ok) {
      let errJson = {}
      try {
        errJson = await res.json()
      } catch (e) {
        // ignore parse error
      }
      let message = ''
      if (errJson.message) message = errJson.message
      else if (errJson.error) message = errJson.error
      else if (errJson.errors) {
        if (Array.isArray(errJson.errors)) message = errJson.errors.join(', ')
        else {
          const parts = []
          for (const k in errJson.errors) {
            const v = errJson.errors[k]
            if (Array.isArray(v)) parts.push(`${k}: ${v.join(', ')}`)
            else parts.push(`${k}: ${v}`)
          }
          message = parts.join('; ')
        }
      } else if (res.status === 0) message = 'Erreur de connexion au serveur'
      else message = `Erreur serveur (${res.status})`
      const err = new Error(message)
      err.status = res.status
      err.body = errJson
      throw err
    }

    // Reload profile after successful update
    await loadProfile()
    return true
  } catch (e) {
    // Handle network errors (Failed to fetch)
    if (e instanceof TypeError && e.message === 'Failed to fetch') {
      throw new Error('Erreur de connexion au serveur. Vérifiez que le serveur est accessible.')
    }
    throw e
  }
}

export function useAuth() {
  return { user, isDelegate, canPublish, setUser, logout, login, register, toggleRole, loadProfile, updateProfile }
}