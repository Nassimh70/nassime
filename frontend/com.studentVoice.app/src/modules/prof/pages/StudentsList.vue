<template>
  <div class="space-y-6">
    <!-- Toast notification -->
    <Transition name="toast">
      <div
        v-if="toast.show"
        class="fixed top-6 right-6 z-50 flex items-center gap-3 px-5 py-3 rounded-xl shadow-2xl text-sm font-medium"
        :style="{
          background: toast.type === 'success' ? 'linear-gradient(135deg, #10b981, #059669)' : 'linear-gradient(135deg, #ef4444, #dc2626)',
          color: '#fff'
        }"
      >
        <CheckCircle v-if="toast.type === 'success'" class="w-5 h-5" />
        <AlertCircle v-else class="w-5 h-5" />
        <span>{{ toast.message }}</span>
      </div>
    </Transition>

    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <p class="text-gray-500 mt-1">{{ students.length }} étudiants au total</p>
      </div>
    </div>
    <p v-if="errorMessage" class="text-sm text-red-600">{{ errorMessage }}</p>

    <!-- Search & Attach Existing Student -->
    <div class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5">
      <h3 class="text-sm mb-3 font-bold text-gray-900 dark:text-white">Ajouter un Étudiant Existant</h3>
      <form @submit.prevent="handleSearchStudent" class="space-y-4">
        <div class="flex gap-2">
          <input
            type="text"
            v-model="searchStudentEmail"
            placeholder="Rechercher par email ou nom..."
            class="flex-1 rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm"
          />
          <button
            type="submit"
            :disabled="searchLoading"
            class="px-4 py-2 rounded-lg text-white text-sm transition-all hover:opacity-90 disabled:opacity-50"
            style="background: linear-gradient(135deg, #255fe3, #3b7af0)"
          >
            {{ searchLoading ? 'Recherche...' : 'Chercher' }}
          </button>
        </div>
        
        <div v-if="searchResult" class="p-4 border border-green-200 bg-green-50 dark:bg-green-900/20 dark:border-green-800 rounded-lg space-y-3">
          <p class="text-sm text-green-800 dark:text-green-400">
            <strong>{{ searchResult.name }}</strong> ({{ searchResult.email }})
          </p>
          <div class="flex flex-col gap-2">
            <label class="text-xs font-semibold text-gray-700 dark:text-gray-300">Sélectionner le module :</label>
            <CustomSelect
              v-model="selectedAttachModuleId"
              :options="profModulesOptions"
              placeholder="Choisissez un module"
            />
          </div>
          <button
            type="button"
            @click="handleAttachStudent"
            :disabled="attachLoading || !selectedAttachModuleId"
            class="px-4 py-2 rounded-lg text-white text-sm transition-all hover:opacity-90 disabled:opacity-50"
            style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 600"
          >
            {{ attachLoading ? 'Rattachement...' : 'Rattacher au groupe' }}
          </button>
        </div>

        <div v-if="searchNotFound" class="p-4 border border-orange-200 bg-orange-50 dark:bg-orange-900/20 dark:border-orange-800 rounded-lg">
          <p class="text-sm text-orange-800 dark:text-orange-400">
            Aucun étudiant trouvé avec cette adresse email. Veuillez vérifier l'email ou utiliser le formulaire ci-dessous pour créer un nouveau compte.
          </p>
        </div>
      </form>
    </div>
    <div class="bg-white rounded-2xl p-6 border border-gray-200">
      <div class="flex flex-col md:flex-row gap-4">
        <!-- Search -->
        <div class="flex-1 relative">
          <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            v-model="searchTerm"
            placeholder="Rechercher un étudiant..."
            class="pl-12"
          />
        </div>

        <!-- Course Filter -->
        <div class="flex items-center gap-2">
          <div class="min-w-[200px]">
            <CustomSelect
              v-model="selectedCourse"
              :options="courseFilterOptions"
              placeholder="Tous les groupes"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Students Table -->
    <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
            <tr>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Étudiant</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Contact</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Cours</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Moyenne</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Statut</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr
              v-for="student in filteredStudents"
              :key="student.id"
            >
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center">
                    <span class="font-semibold text-indigo-600">
                      {{ student.name.charAt(0) }}
                    </span>
                  </div>
                  <div>
                    <p class="font-semibold text-gray-900">{{ student.name }}</p>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4">
                <div class="space-y-1">
                  <div class="flex items-center gap-2 text-sm text-gray-600">
                    <Mail class="w-4 h-4" />
                    <span>{{ student.email }}</span>
                  </div>
                  <div class="flex items-center gap-2 text-sm text-gray-600">
                    <Phone class="w-4 h-4" />
                    <span>{{ student.phone }}</span>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4">
                <span class="text-sm text-gray-900">{{ student.course }}</span>
              </td>
              <td class="px-6 py-4">
                <span
                  :class="[
                    'inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold',
                    getAverageColor(student.average)
                  ]"
                >
                  {{ student.average.toFixed(1) }}/20
                </span>
              </td>
              <td class="px-6 py-4">
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold bg-green-100 text-green-700">
                  {{ student.status }}
                </span>
              </td>
              <td class="px-6 py-4">
                <button 
                  @click="confirmDeleteStudent(student.id)"
                  class="inline-flex items-center gap-2 px-4 py-2 text-white rounded-lg hover:bg-gray-300 transition-colors"
                  style="background: linear-gradient(135deg, #c41e1e 0%, #DC2626 50%, #a51b1b 100%)">
                  Supprimer
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="filteredStudents.length === 0" class="text-center py-12">
        <p class="text-gray-500">Aucun étudiant trouvé</p>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <Transition name="modal">
      <div v-if="showDeleteModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="bg-white dark:bg-slate-800 rounded-2xl p-6 shadow-2xl max-w-sm w-full mx-4">
          <h3 class="text-lg font-semibold text-slate-900 dark:text-white mb-2">Supprimer l'étudiant</h3>
          <p class="text-slate-600 dark:text-slate-300 text-sm mb-6">Êtes-vous sûr de vouloir supprimer cet étudiant de votre module ? Cette action est irréversible.</p>
          <div class="flex gap-3 justify-end">
            <button
              @click="showDeleteModal = false"
              class="px-4 py-2 rounded-lg text-sm font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
            >
              Annuler
            </button>
            <button
              @click="executeDelete"
              class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-red-600 hover:bg-red-700 active:scale-95 transition-all shadow-md shadow-red-500/20"
            >
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Search, Mail, Phone, Plus, CheckCircle, AlertCircle } from 'lucide-vue-next'
import { useStudents } from '../../../composables/useStudents'
import { useGrades } from '../../../composables/useGrades'
import CustomSelect from '../../../components/CustomSelect.vue'

const { students, fetchProfessorStudents, createProfessorStudent, deleteStudent: removeStudent, searchAllStudents, attachStudentToModule } = useStudents()
const { grades, fetchGrades } = useGrades()

const searchTerm = ref('')
const selectedCourse = ref('all')
const showAddForm = ref(false)
const errorMessage = ref('')
const searchStudentEmail = ref('')
const searchResult = ref(null)
const searchNotFound = ref(false)
const searchLoading = ref(false)
const attachLoading = ref(false)
const profModules = ref([])
const selectedAttachModuleId = ref('')
const profModulesOptions = computed(() => {
  return profModules.value.map(mod => ({
    value: mod.id,
    label: `${mod.code_cours} - ${mod.intitule_cours}`
  }))
})

// Toast
const toast = ref({ show: false, message: '', type: 'success' })
function showToast(message, type = 'success') {
  toast.value = { show: true, message, type }
  setTimeout(() => { toast.value.show = false }, 3000)
}

// Delete Modal state
const showDeleteModal = ref(false)
const studentToDelete = ref(null)

function confirmDeleteStudent(id) {
  studentToDelete.value = id
  showDeleteModal.value = true
}

async function executeDelete() {
  if (studentToDelete.value) {
    try {
      await removeStudent(studentToDelete.value)
      showToast('Étudiant supprimé avec succès !', 'success')
      await fetchProfessorStudents()
    } catch (e) {
      console.error(e)
      showToast('Erreur lors de la suppression de l\'étudiant.', 'error')
    }
  }
  showDeleteModal.value = false
  studentToDelete.value = null
}

const newStudent = ref({
  name: '',
  email: '',
  phone: '',
  course: '',
})

// Fetch professor's students on component mount
onMounted(async () => {
  await fetchProfessorStudents()
  await fetchGrades()
  try {
    const modulesRes = await fetch('http://localhost:4000/api/auth/professeur/modules/progress', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
      },
    })
    const modulesData = await modulesRes.json()
    if (modulesData && modulesData.data) {
      // API returns an array of assignment rows, each with `.module`
      profModules.value = modulesData.data.map(item => item.module)
    }
  } catch (e) {
    console.error('Failed to load modules:', e)
  }
})

const courseFilterOptions = computed(() => {
  const groups = Array.from(
    new Set(students.value.map((student) => (student.course || '').trim()).filter(Boolean))
  )
  return [{ value: 'all', label: 'Tous les groupes' }, ...groups.map((g) => ({ value: g, label: g }))]
})

const filteredStudents = computed(() => {
  return students.value.filter((student) => {
    const matchesSearch =
      student.name.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
      student.email.toLowerCase().includes(searchTerm.value.toLowerCase())
    const matchesCourse =
      selectedCourse.value === 'all' || student.course === selectedCourse.value
    return matchesSearch && matchesCourse
  }).map((student) => {
    const studentGrades = grades.value.filter(g => g.etudiant_id === student.id || (g.etudiant && g.etudiant.id === student.id))
    let average = 0
    if (studentGrades.length > 0) {
      const sum = studentGrades.reduce((acc, g) => acc + (g.note_td_tp * 0.4 + g.note_examen * 0.6), 0)
      average = sum / studentGrades.length
    }
    return { ...student, average }
  })
})

async function handleAddStudent() {
  errorMessage.value = ''

  if (!newStudent.value.name || !newStudent.value.email || !newStudent.value.phone || !newStudent.value.course) {
    errorMessage.value = 'Veuillez remplir tous les champs.'
    return
  }

  if (!newStudent.value.email.toLowerCase().endsWith('univ-bejaia.dz')) {
    errorMessage.value = 'Utilisez un email universitaire (univ-bejaia.dz).'
    return
  }

  try {
    await createProfessorStudent(newStudent.value)
    newStudent.value = { name: '', email: '', phone: '', course: '' }
    showAddForm.value = false
  } catch (e) {
    const details = []
    if (e && e.errors && typeof e.errors === 'object') {
      for (const [field, msgs] of Object.entries(e.errors)) {
        if (Array.isArray(msgs)) details.push(`${field}: ${msgs.join(', ')}`)
        else if (msgs) details.push(`${field}: ${msgs}`)
      }
    }
    const backendMessage =
      (e && (e.message || e.error || (typeof e === 'string' ? e : ''))) || ''
    errorMessage.value = details.length
      ? `Erreur validation: ${details.join(' | ')}`
      : backendMessage || "Impossible d'ajouter l'étudiant."
  }
}

async function deleteStudent(id) {
  errorMessage.value = ''

  const student = students.value.find(s => s.id === id)
  const studentName = student ? student.name : 'cet étudiant'
  const studentCourse = student && student.course ? student.course : ''

  const confirmMsg = studentCourse
    ? `Voulez-vous vraiment supprimer "${studentName}" ?\n\nIl sera détaché du cours "${studentCourse}" et toutes ses notes seront supprimées.`
    : `Voulez-vous vraiment supprimer "${studentName}" de votre liste ?\n\nToutes ses notes seront également supprimées.`

  if (!confirm(confirmMsg)) return

  try {
    await removeStudent(id)
  } catch (e) {
    const details = []
    if (e && e.errors && typeof e.errors === 'object') {
      for (const [field, msgs] of Object.entries(e.errors)) {
        if (Array.isArray(msgs)) details.push(`${field}: ${msgs.join(', ')}`)
        else if (msgs) details.push(`${field}: ${msgs}`)
      }
    }
    const backendMessage =
      (e && (e.message || e.error || (typeof e === 'string' ? e : ''))) || ''
    errorMessage.value = details.length
      ? `Erreur validation: ${details.join(' | ')}`
      : backendMessage || "Impossible de supprimer l'étudiant."
  }
}

async function handleSearchStudent() {
  searchResult.value = null
  searchNotFound.value = false
  
  if (!searchStudentEmail.value) {
    return
  }

  searchLoading.value = true
  try {
    const results = await searchAllStudents(searchStudentEmail.value)
    if (results && results.length > 0) {
      searchResult.value = results[0]
      // Try to select first module automatically if available
      if (profModules.value.length > 0) {
        selectedAttachModuleId.value = profModules.value[0].id
      }
    } else {
      searchNotFound.value = true
    }
  } catch (e) {
    console.error('Search failed:', e)
    searchNotFound.value = true
  } finally {
    searchLoading.value = false
  }
}

async function handleAttachStudent() {
  if (!searchResult.value || !searchResult.value.id || !selectedAttachModuleId.value) {
    return
  }

  attachLoading.value = true
  try {
    await attachStudentToModule(searchResult.value.id, selectedAttachModuleId.value)
    searchResult.value = null
    searchStudentEmail.value = ''
    await fetchProfessorStudents()
  } catch (e) {
    console.error('Failed to attach student:', e)
  } finally {
    attachLoading.value = false
  }
}

function getAverageColor(average) {
  if (average >= 16) return 'text-green-600 bg-green-100'
  if (average >= 14) return 'text-blue-600 bg-blue-100';
  if (average >= 12) return 'text-orange-600 bg-orange-100';
  return 'text-red-600 bg-red-100';
}
</script>

<style scoped>
/* Toast transition */
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}
.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(-20px) scale(0.9);
}

/* Modal transition */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
.modal-enter-active .bg-white,
.modal-leave-active .bg-white {
  transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.modal-enter-from .bg-white,
.modal-leave-to .bg-white {
  transform: scale(0.95) translateY(10px);
}
</style>
