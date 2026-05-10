<template>
  <div class="space-y-6">
    <!-- Messages de succès et d'erreur -->
    <div v-if="saveError" class="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg animate-slide-down">
      <AlertCircle class="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0" />
      <p class="text-red-700 dark:text-red-300">{{ saveError }}</p>
    </div>
    
    <div v-if="saveMessage" class="flex items-center gap-3 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg animate-slide-down">
      <CheckCircle class="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0" />
      <p class="text-green-700 dark:text-green-300">{{ saveMessage }}</p>
    </div>

    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-end gap-4">
      <div v-if="!isEditing">
        <button
          @click="isEditing = true"
          class="flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-blue-500/20"
          style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%); --blue: #255fe3; --blue-dark: #1f54d2; --blue-deep: #1d3f95; font-weight: 600">
          <Edit2 class="w-5 h-5" />
          Modifier le profil
        </button>
      </div>
      <div v-else class="flex gap-3">
        <button
          @click="handleSave"
          :disabled="isSaving"
          class="flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-blue-500/20 disabled:opacity-50 disabled:cursor-not-allowed"
          style="background: linear-gradient(135deg, #128c3e 0%, #16A34A 50%, #0f7a35 100%)">
          <Save class="w-5 h-5" />
          {{ isSaving ? 'Enregistrement...' : 'Enregistrer' }}
        </button>
        <button
          @click="handleCancel"
          :disabled="isSaving"
          class="inline-flex items-center gap-2 px-4 py-2 text-white rounded-lg hover:bg-gray-300 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          style="background: linear-gradient(135deg, #c41e1e 0%, #DC2626 50%, #a51b1b 100%)">
          <X class="w-5 h-5" />
          Annuler
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Profile Card -->
      <div class="lg:col-span-1">
        <div class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
          <div class="w-32 h-32 mx-auto mb-4 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-full flex items-center justify-center">
            <User class="w-16 h-16 text-white" />
          </div>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">{{ user?.name || 'Utilisateur' }}</h2>
          <p class="text-gray-600 mb-4">{{ user?.email || '-' }}</p>

          <div class="mt-6 pt-6 border-t border-gray-200 space-y-3 text-left">
            <!-- Prof: Grade + Spécialité -->
            <template v-if="user?.professeur">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Grade</label>
                <div v-if="!isEditing" class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <Star class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.grade || 'N/A' }}</span>
                </div>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Spécialité</label>
                <div v-if="!isEditing" class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <BookOpen class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.specialite || 'N/A' }}</span>
                </div>
              </div>
            </template>
            <!-- Étudiant: Groupe + Département -->
            <template v-else-if="!isAdmin">
              <div class="flex items-center gap-3 text-sm">
                <BookOpen class="w-5 h-5 text-gray-400" />
                <div>
                  <p class="text-gray-500">Groupe</p>
                  <p class="font-medium text-gray-900">{{ formData.class || 'N/A' }}</p>
                </div>
              </div>
              <div class="flex items-center gap-3 text-sm">
                <MapPin class="w-5 h-5 text-gray-400" />
                <div>
                  <p class="text-gray-500">Département</p>
                  <p class="font-medium text-gray-900">{{ user?.department || 'Informatique' }}</p>
                </div>
              </div>
            </template>
          </div>
        </div>
      </div>

      <!-- Information Form -->
      <div class="lg:col-span-2 space-y-6">

        <!-- ========== PROFESSEUR ========== -->
        <template v-if="user?.professeur">
          <div class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
            <h3 class="text-xl font-semibold text-gray-900 mb-6">Informations personnelles</h3>

            <div class="space-y-4">
              <!-- Nom + Prénom -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Nom</label>
                  <input v-if="isEditing" type="text" v-model="formData.lastName" class="w-full px-4 py-2 border rounded-lg" :class="errors.lastName ? 'border-red-500' : 'border-gray-300'" />
                  <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                    <UserIcon class="w-5 h-5 text-gray-400" />
                    <span class="text-gray-900">{{ formData.lastName }}</span>
                  </div>
                  <p v-if="isEditing && errors.lastName" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                    <AlertCircle class="w-4 h-4" />
                    {{ errors.lastName }}
                  </p>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Prénom</label>
                  <input v-if="isEditing" type="text" v-model="formData.firstName" class="w-full px-4 py-2 border rounded-lg" :class="errors.firstName ? 'border-red-500' : 'border-gray-300'" />
                  <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                    <UserIcon class="w-5 h-5 text-gray-400" />
                    <span class="text-gray-900">{{ formData.firstName }}</span>
                  </div>
                  <p v-if="isEditing && errors.firstName" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                    <AlertCircle class="w-4 h-4" />
                    {{ errors.firstName }}
                  </p>
                </div>
              </div>

              <!-- Email -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input v-if="isEditing" type="email" v-model="formData.email" readonly class="w-full px-4 py-2 border rounded-lg bg-gray-100 text-gray-500 cursor-not-allowed" />
                <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <Mail class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.email }}</span>
                </div>
                <p v-if="isEditing" class="mt-1 text-xs text-gray-500">
                  L'email ne peut pas être modifié depuis le profil.
                </p>
              </div>

              <!-- Téléphone -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Téléphone</label>
                <input v-if="isEditing" type="tel" v-model="formData.telephoneProf" class="w-full px-4 py-2 border rounded-lg" :class="errors.telephoneProf ? 'border-red-500' : 'border-gray-300'" />
                <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <Phone class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.telephoneProf || 'N/A' }}</span>
                </div>
                <p v-if="isEditing && errors.telephoneProf" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                  <AlertCircle class="w-4 h-4" />
                  {{ errors.telephoneProf }}
                </p>
              </div>
            </div>
          </div>
        </template>

        <!-- ========== ÉTUDIANT ========== -->
        <template v-else-if="!isAdmin">
          <div class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
            <h3 class="text-xl font-semibold text-gray-900 mb-6">Informations personnelles</h3>

            <div class="space-y-4">
              <!-- Nom + Prénom -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Nom</label>
                  <input v-if="isEditing" type="text" v-model="formData.lastName" class="w-full px-4 py-2 border rounded-lg" :class="errors.lastName ? 'border-red-500' : 'border-gray-300'" />
                  <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                    <UserIcon class="w-5 h-5 text-gray-400" />
                    <span class="text-gray-900">{{ formData.lastName }}</span>
                  </div>
                  <p v-if="isEditing && errors.lastName" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                    <AlertCircle class="w-4 h-4" />
                    {{ errors.lastName }}
                  </p>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Prénom</label>
                  <input v-if="isEditing" type="text" v-model="formData.firstName" class="w-full px-4 py-2 border rounded-lg" :class="errors.firstName ? 'border-red-500' : 'border-gray-300'" />
                  <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                    <UserIcon class="w-5 h-5 text-gray-400" />
                    <span class="text-gray-900">{{ formData.firstName }}</span>
                  </div>
                  <p v-if="isEditing && errors.firstName" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                    <AlertCircle class="w-4 h-4" />
                    {{ errors.firstName }}
                  </p>
                </div>
              </div>

              <!-- Email -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input v-if="isEditing" type="email" v-model="formData.email" readonly class="w-full px-4 py-2 border rounded-lg bg-gray-100 text-gray-500 cursor-not-allowed" />
                <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <Mail class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.email }}</span>
                </div>
                <p v-if="isEditing" class="mt-1 text-xs text-gray-500">
                  L'email ne peut pas être modifié depuis le profil.
                </p>
              </div>

              <!-- Groupe -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Groupe</label>
                <div class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <BookOpen class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.class || 'N/A' }}</span>
                </div>
              </div>

              <!-- Date de naissance -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Date de naissance</label>
                <input v-if="isEditing" type="date" v-model="formData.dateOfBirth" class="w-full px-4 py-2 border rounded-lg" :class="errors.dateOfBirth ? 'border-red-500' : 'border-gray-300'" />
                <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <Calendar class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.dateOfBirth || 'N/A' }}</span>
                </div>
                <p v-if="isEditing && errors.dateOfBirth" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                  <AlertCircle class="w-4 h-4" />
                  {{ errors.dateOfBirth }}
                </p>
              </div>

            </div>
          </div>
        </template>

        <!-- ========== ADMINISTRATEUR ========== -->
        <template v-else-if="isAdmin">
          <div class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
            <h3 class="text-xl font-semibold text-gray-900 mb-6">Informations personnelles</h3>

            <div class="space-y-4">
              <!-- Nom + Prénom -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Nom</label>
                  <input v-if="isEditing" type="text" v-model="formData.lastName" class="w-full px-4 py-2 border rounded-lg" :class="errors.lastName ? 'border-red-500' : 'border-gray-300'" />
                  <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                    <UserIcon class="w-5 h-5 text-gray-400" />
                    <span class="text-gray-900">{{ formData.lastName }}</span>
                  </div>
                  <p v-if="isEditing && errors.lastName" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                    <AlertCircle class="w-4 h-4" />
                    {{ errors.lastName }}
                  </p>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Prénom</label>
                  <input v-if="isEditing" type="text" v-model="formData.firstName" class="w-full px-4 py-2 border rounded-lg" :class="errors.firstName ? 'border-red-500' : 'border-gray-300'" />
                  <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                    <UserIcon class="w-5 h-5 text-gray-400" />
                    <span class="text-gray-900">{{ formData.firstName }}</span>
                  </div>
                  <p v-if="isEditing && errors.firstName" class="mt-1 text-sm text-red-500 flex items-center gap-1">
                    <AlertCircle class="w-4 h-4" />
                    {{ errors.firstName }}
                  </p>
                </div>
              </div>

              <!-- Email -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                <input v-if="isEditing" type="email" v-model="formData.email" readonly class="w-full px-4 py-2 border rounded-lg bg-gray-100 text-gray-500 cursor-not-allowed" />
                <div v-else class="flex items-center gap-2 px-4 py-2 bg-gray-50 rounded-lg">
                  <Mail class="w-5 h-5 text-gray-400" />
                  <span class="text-gray-900">{{ formData.email }}</span>
                </div>
                <p v-if="isEditing" class="mt-1 text-xs text-gray-500">
                  L'email ne peut pas être modifié depuis le profil.
                </p>
              </div>
            </div>
          </div>
        </template>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'

import { User, Mail, Phone, MapPin, Calendar, BookOpen, Edit2, Save, X, Star, AlertCircle, CheckCircle } from 'lucide-vue-next'
import { useAuth } from '../composables/useAuth'

const UserIcon = User

const { user, loadProfile, updateProfile } = useAuth()

const isEditing = ref(false)
const isSaving = ref(false)
const saveMessage = ref('')
const saveError = ref('')
const errors = ref({})

const userRoleName = computed(() => {
  const r = user.value && user.value.role
  let roleName = ''
  if (!r) roleName = ''
  else if (typeof r === 'string') roleName = r
  else if (r.nom_roles) roleName = r.nom_roles
  else if (r.name) roleName = r.name
  return (roleName || '').toString().toLowerCase()
})

const isAdmin = computed(() => userRoleName.value === 'admin' || userRoleName.value === 'administration')

const formData = ref({
  firstName: '',
  lastName: '',
  name: '',
  email: '',
  phone: '',
  dateOfBirth: '',
  class: '',
  department: '',
  groupe: '',
  filiere: '',
  niveau: '',
  is_delegate: false,
  // professor fields
  grade: '',
  specialite: '',
  telephoneProf: '',
  adresseProf: '',
})

const applyUserToForm = (u) => {
  if (!u) return
  // Split name into firstName / lastName if possible
  const parts = (u.name || '').trim().split(' ')
  formData.value.firstName = parts[0] || ''
  formData.value.lastName = parts.slice(1).join(' ') || ''
  formData.value.name = u.name || ''
  formData.value.email = u.email || ''

  if (u.professeur) {
    formData.value.telephoneProf = u.telephoneProf || ''
    formData.value.adresseProf = u.adresseProf || ''
  } else {
    formData.value.phone = u.telephone || ''
  }

  formData.value.dateOfBirth = u.dateNaissance || ''

  if (u.groupe) {
    // Use libele (display name) first, fall back to code, then id
    const groupeLabel = u.groupe.libele || u.groupe.code || u.groupe.libele_groupes || u.groupe.code_groupes || String(u.groupe.id || '')
    formData.value.groupe = groupeLabel
    formData.value.class  = groupeLabel
    formData.value.filiere = u.groupe.filiere || u.groupe.filier_groupe || ''
    formData.value.niveau  = u.groupe.niveau  || u.groupe.niveau_groupe  || ''
  } else if (u.groupe_id) {
    // groupe_id is set but the group object wasn't preloaded — show a readable fallback
    formData.value.class  = `Groupe #${u.groupe_id}`
    formData.value.groupe = `Groupe #${u.groupe_id}`
  } else {
    formData.value.class  = ''
    formData.value.groupe = ''
  }

  formData.value.is_delegate = u.is_delegate || false
  formData.value.grade = u.grade || ''
  formData.value.specialite = u.specialite || ''
}

const validateForm = () => {
  errors.value = {}
  
  if (!formData.value.firstName || !formData.value.firstName.trim()) {
    errors.value.firstName = 'Le prénom est obligatoire'
  }
  if (!formData.value.lastName || !formData.value.lastName.trim()) {
    errors.value.lastName = 'Le nom est obligatoire'
  }
  if (!formData.value.email || !formData.value.email.trim()) {
    errors.value.email = 'L\'email est obligatoire'
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.value.email)) {
    errors.value.email = 'L\'email n\'est pas valide'
  } else if (!user.value?.professeur && !isAdmin.value && !formData.value.email.endsWith('@se.univ-bejaia.dz')) {
    // Student must use se.univ-bejaia.dz
    errors.value.email = 'L\'email étudiant doit être au domaine se.univ-bejaia.dz'
  } else if ((user.value?.professeur || isAdmin.value) && !formData.value.email.endsWith('@univ-bejaia.dz')) {
    errors.value.email = 'L\'email doit être de l\'université (univ-bejaia.dz)'
  }
  
  if (user.value?.professeur) {
    if (formData.value.grade && formData.value.grade.trim().length === 0) {
      errors.value.grade = 'Veuillez entrer un grade valide'
    }
  }
  
  return Object.keys(errors.value).length === 0
}

watch(user, (newVal) => {
  applyUserToForm(newVal)
}, { immediate: true })

onMounted(async () => {
  try {
    await loadProfile()
  } catch (e) {
    // ignore
  }
  applyUserToForm(user.value)
})

const handleSave = async () => {
  saveError.value = ''
  saveMessage.value = ''
  
  if (!validateForm()) {
    saveError.value = 'Veuillez corriger les erreurs dans le formulaire'
    return
  }

  isSaving.value = true
  try {
    // Reconstruct full name before saving
    const fullName = `${formData.value.firstName} ${formData.value.lastName}`.trim()
    
    const updateData = {
      id: user.value?.id,
      prenom_utilisateurs: formData.value.firstName,
      nom_utilisateurs: formData.value.lastName,
      email_utilisateurs: user.value?.email || formData.value.email,
    }

    if (user.value?.professeur) {
      updateData.professeur = {
        grade: formData.value.grade,
        specialite: formData.value.specialite,
        telephone: formData.value.telephoneProf,
        adresse: formData.value.adresseProf,
      }
    } else if (!user.value?.administration) {
      updateData.etudiant = {
        telephone_etudiant: formData.value.phone,
        date_naissance_etudiant: formData.value.dateOfBirth,
      }
    }

    await updateProfile(updateData)
    saveMessage.value = 'Profil mise à jour avec succès!'
    isEditing.value = false
    
    // Clear message after 3 seconds
    setTimeout(() => {
      saveMessage.value = ''
    }, 3000)
  } catch (e) {
    saveError.value = e.message || 'Erreur lors de la mise à jour du profil'
    console.error('Error updating profile:', e)
  } finally {
    isSaving.value = false
  }
}

const handleCancel = () => {
  applyUserToForm(user.value)
  isEditing.value = false
  errors.value = {}
  saveError.value = ''
  saveMessage.value = ''
}
</script>