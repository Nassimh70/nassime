<template>
  <div class="space-y-6">
    <!-- Messages de succès et d'erreur -->
    <div v-if="saveError" class="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg animate-slide-down">
      <AlertCircle class="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0" />
      <p class="text-red-700 dark:text-red-300 font-medium">{{ saveError }}</p>
    </div>
    
    <div v-if="saveMessage" class="flex items-center gap-3 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg animate-slide-down">
      <CheckCircle class="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0" />
      <p class="text-green-700 dark:text-green-300 font-medium">{{ saveMessage }}</p>
    </div>

    <!-- Header -->
    <div class="flex items-center justify-end">
      <div>
        <button
          @click="showAddForm = !showAddForm"
        class="flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-blue-500/20"
        style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%); --blue: #255fe3; --blue-dark: #1f54d2; --blue-deep: #1d3f95; font-weight: 600">
          <Plus class="w-4 h-4" />
          Ajouter TD/TP
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-2">Évaluations Saisies</p>
        <p class="text-3xl font-bold text-gray-900">
          {{ filteredGrades.length }}
        </p>
      </div>
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-2">Notes Validées (>= 10)</p>
        <p class="text-3xl font-bold text-gray-900">
          {{ passedGradesCount }}
        </p>
      </div>
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-2">Moyenne Générale</p>
        <p class="text-3xl font-bold text-gray-900">
          {{ averageGrade }}/20
        </p>
      </div>
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <p class="text-sm text-gray-600 mb-2">Total Notes</p>
        <p class="text-3xl font-bold text-gray-900">{{ filteredGrades.length }}</p>
      </div>
    </div>

    <!-- Add Grade Form -->
    <div v-if="showAddForm" class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
      <h3 class="text-sm mb-4" :style="{ color: 'var(--foreground)', fontWeight: '700' }">Ajouter TD/TP + Examen</h3>
      <form @submit.prevent="handleAddGrade" class="space-y-4">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider ml-1">Étudiant</label>
            <CustomSelect
              v-model="newGrade.etudiant_id"
              :options="studentOptions"
              placeholder="Sélectionner un étudiant"
            />
            <p v-if="errors.etudiant_id" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.etudiant_id }}
            </p>
          </div>
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider ml-1">Cours</label>
            <CustomSelect
              v-model="newGrade.module_id"
              :options="moduleOptions"
              placeholder="Sélectionner un cours"
            />
            <p v-if="errors.module_id" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.module_id }}
            </p>
          </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider ml-1">Note TD/TP (sur 20)</label>
            <input
              type="number"
              step="0.5"
              min="0"
              max="20"
              v-model="newGrade.note_td_tp"
              placeholder="0.0"
              class="w-full px-4 py-2 rounded-xl border bg-gray-50/50 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
              :class="errors.note_td_tp ? 'border-red-500' : 'border-gray-200'"
            />
            <p v-if="errors.note_td_tp" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.note_td_tp }}
            </p>
          </div>
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-gray-400 uppercase tracking-wider ml-1">Note Examen (sur 20)</label>
            <input
              type="number"
              step="0.5"
              min="0"
              max="20"
              v-model="newGrade.note_examen"
              placeholder="0.0"
              class="w-full px-4 py-2 rounded-xl border bg-gray-50/50 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all"
              :class="errors.note_examen ? 'border-red-500' : 'border-gray-200'"
            />
            <p v-if="errors.note_examen" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.note_examen }}
            </p>
          </div>
        </div>
        <div class="flex justify-start gap-3 pt-2">
          <button
            type="button"
            @click="showAddForm = false; errors = {}"
            class="px-5 py-2.5 rounded-xl text-sm transition-all hover:bg-gray-100" :style="{ color: 'var(--muted-foreground)', fontWeight: '600' }"
          >
            Annuler
          </button>
          <button
            type="submit"
            :disabled="loadingLocal"
            class="px-8 py-2.5 rounded-xl text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-blue-500/20 disabled:opacity-50 flex items-center gap-2" 
            style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 700">
            <Loader2 v-if="loadingLocal" class="w-4 h-4 animate-spin" />
            <Check v-else class="w-4 h-4" />
            {{ loadingLocal ? 'Enregistrement...' : 'Enregistrer les notes' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Grades Table -->
    <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
            <tr>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Étudiant</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Cours</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">TD/TP</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Examen</th>
              <th class="text-left px-6 py-4 text-sm font-semibold text-gray-900">Date</th>
            </tr>
          </thead>
          <tbody >
            <tr
              v-for="grade in filteredGrades"
              :key="grade.id"
              class="hover:bg-gray-50 dark:hover:bg-[var(--hover)]"
            >
              <td class="px-6 py-4">
                <p class="font-semibold text-gray-900">{{ grade.etudiant?.name }}</p>
              </td>
              <td class="px-6 py-4">
                <span class="text-sm text-gray-900">{{ grade.module?.name }}</span>
              </td>
              <td class="px-6 py-4">
                <span
                  :class="[
                    'inline-flex items-center px-3 py-1 rounded-full text-sm font-bold',
                    getGradeColor(grade.note_td_tp, 20)
                  ]"
                >
                  {{ grade.note_td_tp }}/20
                </span>
              </td>
              <td class="px-6 py-4">
                <span
                  :class="[
                    'inline-flex items-center px-3 py-1 rounded-full text-sm font-bold',
                    getGradeColor(grade.note_examen, 20)
                  ]"
                >
                  {{ grade.note_examen }}/20
                </span>
              </td>
              <td class="px-6 py-4">
                <span class="text-sm text-gray-600">
                  {{ formatDate(grade.inserted_at) }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Plus, User, GraduationCap, AlertCircle, CheckCircle, Loader2, Check } from 'lucide-vue-next'
import { useStudents } from '../../../composables/useStudents'
import { useGrades } from '../../../composables/useGrades'
import { professeurModulesProgress } from '../../../composables/useModules'
import CustomSelect from '../../../components/CustomSelect.vue'

const { students, fetchProfessorStudents } = useStudents()
const { grades, fetchGrades, addGrade, loading } = useGrades()

const modules = ref([])
const showAddForm = ref(false)
const loadingLocal = ref(false)
const saveError = ref('')
const saveMessage = ref('')
const errors = ref({})

const newGrade = ref({
  etudiant_id: '',
  module_id: '',
  note_td_tp: '',
  note_examen: '',
})

// Fetch data on component mount
onMounted(async () => {
  await fetchProfessorStudents()
  await fetchGrades()
  const { data: modulesData } = await professeurModulesProgress()
  modules.value = modulesData || []
})

// Dynamic student options from composable
const studentOptions = computed(() =>
  students.value.map(s => ({ 
    value: s.id, 
    label: s.name,
    icon: User
  }))
)

const moduleOptions = computed(() =>
  modules.value.map(m => ({ 
    value: m.module?.id || m.id, 
    label: m.module?.intitule_cours || m.name || 'Module',
    icon: GraduationCap,
    dot: '#818cf8'
  })) || []
)

// Filtered grades: only show grades for students who are in the official professor's student list
const filteredGrades = computed(() => {
  const studentIds = new Set(students.value.map(s => s.id))
  return grades.value.filter(g => {
    const sId = g.etudiant_id || g.etudiant?.id
    return studentIds.has(sId)
  })
})

// Compute stats from filtered grades
const passedGradesCount = computed(() =>
  filteredGrades.value.filter(g => (g.note_td_tp * 0.4 + g.note_examen * 0.6) >= 10).length
)

const averageGrade = computed(() => {
  if (filteredGrades.value.length === 0) return 0
  const total = filteredGrades.value.reduce((acc, g) => acc + (g.note_td_tp * 0.4 + g.note_examen * 0.6), 0)
  return (total / filteredGrades.value.length).toFixed(1)
})

function validateGradeForm() {
  errors.value = {}
  saveError.value = ''
  
  if (!newGrade.value.etudiant_id) {
    errors.value.etudiant_id = 'Veuillez sélectionner un étudiant'
  }
  
  if (!newGrade.value.module_id) {
    errors.value.module_id = 'Veuillez sélectionner un cours'
  }
  
  const td = parseFloat(newGrade.value.note_td_tp)
  if (newGrade.value.note_td_tp === '') {
    errors.value.note_td_tp = 'La note TD/TP est obligatoire'
  } else if (isNaN(td) || td < 0 || td > 20) {
    errors.value.note_td_tp = 'Entre 0 et 20'
  }
  
  const exam = parseFloat(newGrade.value.note_examen)
  if (newGrade.value.note_examen === '') {
    errors.value.note_examen = 'La note d\'examen est obligatoire'
  } else if (isNaN(exam) || exam < 0 || exam > 20) {
    errors.value.note_examen = 'Entre 0 et 20'
  }
  
  const isValid = Object.keys(errors.value).length === 0
  if (!isValid) {
    saveError.value = 'Veuillez corriger les erreurs dans le formulaire'
  }
  
  return isValid
}

async function handleAddGrade() {
  saveError.value = ''
  saveMessage.value = ''
  
  if (!validateGradeForm()) return

  loadingLocal.value = true
  try {
    await addGrade({
      etudiant_id: parseInt(newGrade.value.etudiant_id),
      module_id: parseInt(newGrade.value.module_id),
      note_td_tp: parseFloat(newGrade.value.note_td_tp),
      note_examen: parseFloat(newGrade.value.note_examen),
    })
    
    saveMessage.value = 'Les notes ont été enregistrées avec succès !'
    newGrade.value = { etudiant_id: '', module_id: '', note_td_tp: '', note_examen: '' }
    errors.value = {}
    showAddForm.value = false
    
    // Clear success message after 3 seconds
    setTimeout(() => {
      saveMessage.value = ''
    }, 3000)
  } catch (e) {
    console.error('Error adding grade:', e)
    saveError.value = e.message || 'Erreur lors de l\'enregistrement des notes'
  } finally {
    loadingLocal.value = false
  }
}

function getGradeColor(grade, maxGrade) {
  const percentage = (grade / maxGrade) * 100
  if (percentage >= 80) return 'text-green-600 bg-green-100'
  if (percentage >= 70) return 'text-blue-600 bg-blue-100'
  if (percentage >= 60) return 'text-orange-600 bg-orange-100'
  return 'text-red-600 bg-red-100'
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('fr-FR')
}

function getStudentName(studentId) {
  const student = students.value.find(s => s.id === studentId)
  return student?.name || 'N/A'
}

function getModuleName(moduleId) {
  const module = modules.value.find(m => m.module?.id === moduleId)
  return module?.module?.name || module?.module?.code || 'N/A'
}
</script>
