<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-end">
      <button
        @click="showAddForm = !showAddForm"
        class="flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-blue-500/20"
        style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 600"
      >
        <Plus class="w-4 h-4" />
        Nouveau Cours
      </button>
    </div>

    <!-- Messages de succès et d'erreur -->
    <div v-if="saveError" class="flex items-center gap-3 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg animate-slide-down">
      <AlertCircle class="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0" />
      <p class="text-red-700 dark:text-red-300 font-medium">{{ saveError }}</p>
    </div>
    
    <div v-if="saveMessage" class="flex items-center gap-3 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg animate-slide-down">
      <CheckCircle class="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0" />
      <p class="text-green-700 dark:text-green-300 font-medium">{{ saveMessage }}</p>
    </div>

    <!-- Add Course Form -->
    <div v-if="showAddForm" class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5">
      <h3 class="text-sm mb-3 font-bold text-gray-900 dark:text-white">Ajouter un Nouveau Cours</h3>
      <form @submit.prevent="handleAddCourse" class="space-y-4">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">
              Nom du Cours
            </label>
            <input
              type="text"
              v-model="newCourse.name"
              placeholder="Ex: Mathématiques Avancées"
              class="w-full rounded-lg border bg-white dark:bg-slate-800 px-3 py-2 text-sm"
              :class="errors.name ? 'border-red-500' : 'border-gray-200 dark:border-slate-700'"
            />
            <p v-if="errors.name" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.name }}
            </p>
          </div>
          <div>
            <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">
              Code du Cours
            </label>
            <input
              type="text"
              v-model="newCourse.code"
              placeholder="Ex: MATH-301"
              class="w-full rounded-lg border bg-white dark:bg-slate-800 px-3 py-2 text-sm"
              :class="errors.code ? 'border-red-500' : 'border-gray-200 dark:border-slate-700'"
            />
            <p v-if="errors.code" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.code }}
            </p>
          </div>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">
              Semestre
            </label>
            <CustomSelect
              v-model="newCourse.semestre"
              :options="semesterOptions"
              placeholder="Choisir le semestre"
            />
            <p v-if="errors.semestre" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.semestre }}
            </p>
          </div>
          <div>
            <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">
              Crédits
            </label>
            <input
              type="number"
              v-model="newCourse.credits"
              placeholder="Ex: 3"
              class="w-full rounded-lg border bg-white dark:bg-slate-800 px-3 py-2 text-sm"
              :class="errors.credits ? 'border-red-500' : 'border-gray-200 dark:border-slate-700'"
            />
            <p v-if="errors.credits" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
              <AlertCircle class="w-3 h-3" />
              {{ errors.credits }}
            </p>
          </div>
        </div>
        <div>
          <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">
            Description
          </label>
          <textarea
            v-model="newCourse.description"
            placeholder="Description du cours..."
            class="w-full rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm"
            rows="3"
          />
        </div>

        <div class="flex gap-3 pt-2 justify-end">
          <button
            type="button"
            @click="cancelAddCourse"
            class="px-5 py-2.5 rounded-xl text-sm font-medium transition-all hover:opacity-80"
            style="background: rgba(99, 102, 241, 0.08); color: #6366f1">
            Annuler
          </button>
          <button
            type="submit"
            :disabled="loading"
           class="px-5 py-2.5 rounded-xl text-white text-sm font-semibold transition-all hover:opacity-90 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 600"
          >
            <Loader2 v-if="loading" class="w-4 h-4 animate-spin" />
            <Check v-else class="w-4 h-4" />
            {{ loading ? 'En cours...' : 'Ajouter le cours' }}
          </button>
          
        </div>
      </form>
    </div>

    <!-- Courses List -->
    <div v-if="courses.length > 0" class="space-y-6">
      <div
        v-for="course in courses"
        :key="course.id"
        class="bg-white dark:bg-slate-800 rounded-2xl border border-gray-200 dark:border-slate-700 overflow-hidden"
      >
        <!-- Course Header -->
        <div class="p-6">
          <div class="flex items-start justify-between gap-4 mb-4">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <div :class="['p-3 rounded-xl', getColorClasses(course.color)]">
                  <BookOpen class="w-6 h-6" />
                </div>
                <div>
                  <h3 class="font-bold text-gray-900 dark:text-white">{{ course.name }}</h3>
                  <p class="text-sm text-gray-500 dark:text-gray-400">{{ course.code }}</p>
                </div>
              </div>
              <div class="space-y-1 ml-12">
                <div class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                  <Users class="w-4 h-4" />
                  <span>{{ course.students }} étudiants inscrits</span>
                </div>
                <div class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                  <Calendar class="w-4 h-4" />
                  <span>{{ course.schedule }}</span>
                </div>
              </div>
            </div>

            <button
              @click="toggleCourse(course.id)"
              class="p-2 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-lg transition-colors"
            >
              <ChevronUp v-if="expandedCourse === course.id" class="w-5 h-5 text-gray-600 dark:text-gray-400" />
              <ChevronDown v-else class="w-5 h-5 text-gray-600 dark:text-gray-400" />
            </button>
          </div>

          <!-- Progress Bar -->
          <div>
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Progression</span>
              <div class="flex items-center gap-3">
                <span :class="['text-sm font-bold', getProgressTextColor(course.progress)]">
                  {{ editingProgress === course.id ? tempProgress : course.progress }}%
                </span>
                <button
                  v-if="editingProgress !== course.id"
                  @click="startEditingProgress(course)"
                  class="p-1 hover:bg-gray-100 dark:hover:bg-slate-700 rounded transition-colors text-gray-400 hover:text-blue-600"
                  title="Mettre à jour la progression"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/></svg>
                </button>
              </div>
            </div>
            
            <div v-if="editingProgress === course.id" class="space-y-3">
              <input 
                type="range" 
                v-model.number="tempProgress" 
                min="0" max="100" step="5"
                class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700 accent-blue-600"
              >
              <div class="flex justify-end gap-2">
                <button 
                  @click="cancelEditingProgress"
                  class="px-3 py-1 rounded-lg text-xs font-semibold bg-gray-100 text-gray-600 hover:bg-gray-200 dark:bg-slate-700 dark:text-gray-300 dark:hover:bg-slate-600"
                >
                  Annuler
                </button>
                <button 
                  @click="saveProgress(course)"
                  :disabled="loadingProgress"
                  class="px-3 py-1 rounded-lg text-xs font-semibold text-white transition-all disabled:opacity-50"
                  style="background: linear-gradient(135deg, #16a34a, #22c55e)"
                >
                  {{ loadingProgress ? '...' : 'Enregistrer' }}
                </button>
              </div>
            </div>
            <div v-else class="w-full bg-gray-200 dark:bg-slate-700 rounded-full h-3">
              <div
                :class="[getProgressColor(course.progress), 'h-3 rounded-full transition-all duration-500']"
                :style="{ width: `${course.progress}%` }"
              />
            </div>
          </div>
        </div>

        <!-- Details Expanded -->
        <div v-if="expandedCourse === course.id" class="border-t border-gray-200 dark:border-slate-700 bg-gray-50 dark:bg-slate-900/30 p-6 space-y-4">
          <div class="flex items-center justify-between mb-4">
            <h4 class="font-bold text-gray-900 dark:text-white text-sm uppercase tracking-wider">Détails du module</h4>
            <button
              @click="startEditingModule(course)"
              class="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold text-white transition-all hover:opacity-90"
              style="background: linear-gradient(135deg, #255fe3, #3b7af0)"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/></svg>
              Modifier
            </button>
          </div>

          <!-- Edit Module Form -->
          <div v-if="editingModule === course.id" class="bg-white dark:bg-slate-800 p-5 rounded-2xl border border-blue-100 dark:border-blue-900 shadow-md space-y-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">Semestre</label>
                <CustomSelect
                  v-model="editModuleData.semestre_module"
                  :options="semesterOptions"
                  placeholder="Choisir le semestre"
                />
                <p v-if="editErrors.semestre" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
                  <AlertCircle class="w-3 h-3" />
                  {{ editErrors.semestre }}
                </p>
              </div>
              <div>
                <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">Crédits</label>
                <input 
                  type="number" 
                  v-model.number="editModuleData.credits_module" 
                  class="w-full rounded-lg border bg-white dark:bg-slate-800 px-3 py-2 text-sm"
                  :class="editErrors.credits ? 'border-red-500' : 'border-gray-200 dark:border-slate-700'"
                >
                <p v-if="editErrors.credits" class="mt-1 text-[11px] text-red-500 flex items-center gap-1">
                  <AlertCircle class="w-3 h-3" />
                  {{ editErrors.credits }}
                </p>
              </div>
            </div>
            <div>
              <label class="block text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-2">Description</label>
              <textarea 
                v-model="editModuleData.description_module" 
                rows="3" 
                class="w-full rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm resize-none"
                placeholder="Description du module..."
              ></textarea>
            </div>
            <div class="flex justify-end gap-3 pt-2">
              <button 
                @click="cancelEditingModule" 
                class="px-5 py-2.5 rounded-xl text-sm font-medium transition-all hover:opacity-80"
                style="background: rgba(99, 102, 241, 0.08); color: #6366f1"
              >
                Annuler
              </button>
              <button 
                @click="saveModuleDetails(course)" 
                :disabled="loadingModuleUpdate" 
                class="px-5 py-2.5 rounded-xl text-white text-sm font-semibold transition-all hover:opacity-90 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
                style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 600"
              >
                <Loader2 v-if="loadingModuleUpdate" class="w-4 h-4 animate-spin" />
                <Check v-else class="w-4 h-4" />
                {{ loadingModuleUpdate ? '...' : 'Enregistrer' }}
              </button>
            </div>
          </div>

          <!-- Description -->
          <div v-else>
            <div v-if="course.description_module" class="pb-4 border-b border-gray-200 dark:border-slate-700">
              <p class="text-sm text-gray-700 dark:text-gray-300">{{ course.description_module }}</p>
            </div>

            <!-- Course Info Grid -->
            <div class="grid grid-cols-2 gap-4 text-sm mt-4 mb-4">
              <div>
                <p class="text-gray-500 dark:text-gray-400 text-xs uppercase tracking-wider font-bold mb-1">Semestre</p>
                <p class="text-gray-900 dark:text-white font-semibold">{{ course.semestre_module }}</p>
              </div>
              <div>
                <p class="text-gray-500 dark:text-gray-400 text-xs uppercase tracking-wider font-bold mb-1">Crédits</p>
                <p class="text-gray-900 dark:text-white font-semibold">{{ course.credits_module }}</p>
              </div>
            </div>
          </div>

          <!-- Chapters List -->
          <div class="border-t border-gray-200 dark:border-slate-700 pt-4">
            <div class="flex items-center justify-between mb-4">
              <h4 class="font-bold text-gray-900 dark:text-white text-sm uppercase tracking-wider">Chapitres</h4>
              <button
                @click="showAddChapterForm = showAddChapterForm === course.id ? null : course.id"
                class="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold text-white transition-all hover:opacity-90"
                style="background: linear-gradient(135deg, #255fe3, #3b7af0)"
              >
                <Plus class="w-3 h-3" />
                Ajouter
              </button>
            </div>

            <!-- Add Chapter Form -->
            <div v-if="showAddChapterForm === course.id" class="mb-4 p-4 bg-white dark:bg-slate-800 rounded-xl border border-gray-200 dark:border-slate-700">
              <form @submit.prevent="handleAddChapter(course.id)" class="space-y-3">
                <div>
                  <input
                    type="text"
                    v-model="newChapter.title"
                    placeholder="Titre du chapitre"
                    required
                    class="w-full rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm"
                  />
                </div>
                <div>
                  <input
                    type="date"
                    v-model="newChapter.date"
                    class="w-full rounded-lg border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-800 px-3 py-2 text-sm"
                  />
                </div>
                <div class="flex gap-2">
                  <button
                    type="submit"
                    :disabled="loading"
                    class="flex-1 px-3 py-2 rounded-lg text-xs font-semibold text-white transition-all hover:opacity-90 disabled:opacity-50"
                    style="background: linear-gradient(135deg, #255fe3, #3b7af0)"
                  >
                    {{ loading ? 'En cours...' : 'Ajouter' }}
                  </button>
                  <button
                    type="button"
                    @click="showAddChapterForm = null"
                    class="px-3 py-2 rounded-lg text-xs font-semibold"
                    style="background: #e5e7eb; color: #6b7280"
                  >
                    Annuler
                  </button>
                </div>
              </form>
            </div>

            <!-- Chapters List -->
            <div v-if="courseChapters[course.id]?.length > 0" class="space-y-2">
              <div
                v-for="chapter in courseChapters[course.id]"
                :key="chapter.id"
                class="flex items-center justify-between p-3 bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg"
              >
                <div>
                  <p class="font-semibold text-sm text-gray-900 dark:text-white">{{ chapter.title }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">{{ chapter.date }}</p>
                </div>
                <button
                  @click="handleDeleteChapter(chapter.id)"
                  class="p-2 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-lg transition-colors"
                >
                  <Trash2 class="w-4 h-4 text-red-600" />
                </button>
              </div>
            </div>
            <div v-else class="text-center py-4 text-gray-500 dark:text-gray-400 text-sm">
              Aucun chapitre pour le moment
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <BookOpen class="w-12 h-12 text-gray-300 dark:text-gray-700 mx-auto mb-4" />
      <p class="text-gray-500 dark:text-gray-400">Aucun cours assigné pour le moment</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { BookOpen, Users, Calendar, ChevronUp, ChevronDown, Plus, Trash2, Check, AlertCircle, Loader2, CheckCircle } from 'lucide-vue-next'
import { API_BASE, authHeaders } from '../../../composables/api'
import CustomSelect from '../../../components/CustomSelect.vue'
import { 
  professeurModulesProgress, 
  fetchChaptersForModule, 
  createChapter, 
  deleteChapter,
  updateCourseProgress
} from '../../../composables/useModules'

const courses = ref([])
const expandedCourse = ref(null)
const showAddChapterForm = ref(null)
const showAddForm = ref(false)
const courseChapters = ref({})
const loading = ref(false)
const saveError = ref('')
const saveMessage = ref('')

const editingModule = ref(null)
const editModuleData = ref({ description_module: '', semestre_module: '', credits_module: 0 })
const editErrors = ref({})
const loadingModuleUpdate = ref(false)

const editingProgress = ref(null)
const tempProgress = ref(0)
const loadingProgress = ref(false)

const newChapter = ref({
  title: '',
  date: '',
})

const newCourse = ref({
  name: '',
  code: '',
  semestre: '',
  credits: '',
  description: '',
})

const errors = ref({})

const semesterOptions = [
  { value: 'S1', label: 'Semestre 1' },
  { value: 'S2', label: 'Semestre 2' },
  { value: 'S3', label: 'Semestre 3' },
  { value: 'S4', label: 'Semestre 4' },
  { value: 'S5', label: 'Semestre 5' },
  { value: 'S6', label: 'Semestre 6' },
]

function validateCourseForm() {
  errors.value = {}
  saveError.value = ''
  
  if (!newCourse.value.name.trim()) {
    errors.value.name = 'Le nom du cours est obligatoire'
  }
  
  // Format: Lettres majuscules, un tiret, puis des chiffres
  const codeRegex = /^[A-Z]+-[0-9]+$/
  if (!newCourse.value.code.trim()) {
    errors.value.code = 'Le code du cours est obligatoire'
  } else if (!codeRegex.test(newCourse.value.code.trim())) {
    errors.value.code = 'Format invalide (Ex: MATH-1)'
  }
  
  if (!newCourse.value.semestre) {
    errors.value.semestre = 'Le semestre est obligatoire'
  }
  
  const credits = parseInt(newCourse.value.credits)
  if (newCourse.value.credits === '') {
    errors.value.credits = 'Le nombre de crédits est obligatoire'
  } else if (isNaN(credits) || credits < 1 || credits > 6) {
    errors.value.credits = 'Entre 1 et 6'
  }
  
  const isValid = Object.keys(errors.value).length === 0
  if (!isValid) {
    saveError.value = 'Veuillez corriger les erreurs dans le formulaire'
  }
  
  return isValid
}

function toggleCourse(courseId) {
  expandedCourse.value = expandedCourse.value === courseId ? null : courseId
  if (expandedCourse.value === courseId) {
    loadChaptersForCourse(courseId)
  }
}

async function handleAddCourse() {
  saveError.value = ''
  saveMessage.value = ''
  
  if (!validateCourseForm()) return

  loading.value = true
  try {
    const newCourseObj = {
      intitule_cours: newCourse.value.name,
      code_cours: newCourse.value.code,
      semestre_module: newCourse.value.semestre,
      credits_module: parseInt(newCourse.value.credits) || 0,
      description_module: newCourse.value.description,
    }

    const res = await fetch(`${API_BASE}/api/auth/professeur/modules`, {
      method: 'POST',
      headers: authHeaders(),
      body: JSON.stringify(newCourseObj),
    })

    if (res.ok) {
      const data = await res.json()
      if (data && data.data) {
        courses.value.push({
          id: data.data.id,
          name: data.data.intitule_cours,
          code: data.data.code_cours,
          students: 0,
          schedule: 'Non défini',
          color: 'indigo',
          progress: 0,
          description_module: data.data.description_module,
          semestre_module: data.data.semestre_module,
          credits_module: data.data.credits_module,
        })
      }
      saveMessage.value = 'Le cours a été ajouté avec succès !'
      cancelAddCourse()
      
      // Clear success message after 3 seconds
      setTimeout(() => {
        saveMessage.value = ''
      }, 3000)
    } else {
      const errData = await res.json().catch(() => ({}))
      saveError.value = errData.message || 'Une erreur est survenue lors de l\'ajout du cours'
    }
  } catch (e) {
    console.error('Failed to add course:', e)
    saveError.value = 'Erreur de connexion au serveur'
  } finally {
    loading.value = false
  }
}

function cancelAddCourse() {
  newCourse.value = { name: '', code: '', semestre: '', credits: '', description: '' }
  errors.value = {}
  // Note: we don't clear saveError here if it comes from validation
  showAddForm.value = false
}

async function loadChaptersForCourse(courseId) {
  try {
    const res = await fetchChaptersForModule(courseId)
    if (res && res.data) {
      courseChapters.value[courseId] = res.data
    }
  } catch (e) {
    console.error('Failed to load chapters:', e)
  }
}

async function handleAddChapter(courseId) {
  if (!newChapter.value.title) return

  loading.value = true
  try {
    const res = await createChapter(courseId, {
      title: newChapter.value.title,
      date: newChapter.value.date,
    })
    if (res && res.data) {
      if (!courseChapters.value[courseId]) {
        courseChapters.value[courseId] = []
      }
      courseChapters.value[courseId].push(res.data)
      newChapter.value = { title: '', date: '' }
      showAddChapterForm.value = null
    }
  } catch (e) {
    console.error('Failed to create chapter:', e)
  } finally {
    loading.value = false
  }
}

async function handleDeleteChapter(chapterId) {
  try {
    await deleteChapter(chapterId)
    for (const courseId in courseChapters.value) {
      courseChapters.value[courseId] = courseChapters.value[courseId].filter(ch => ch.id !== chapterId)
    }
  } catch (e) {
    console.error('Failed to delete chapter:', e)
  }
}

function getProgressColor(progress) {
  if (progress >= 80) return 'bg-green-600'
  if (progress >= 60) return 'bg-blue-600'
  if (progress >= 40) return 'bg-orange-600'
  return 'bg-red-600'
}

function getProgressTextColor(progress) {
  if (progress >= 80) return 'text-green-600'
  if (progress >= 60) return 'text-blue-600'
  if (progress >= 40) return 'text-orange-600'
  return 'text-red-600'
}

function startEditingProgress(course) {
  editingProgress.value = course.id
  tempProgress.value = course.progress
}

function cancelEditingProgress() {
  editingProgress.value = null
}

async function saveProgress(course) {
  loadingProgress.value = true
  try {
    const payload = { progress: { avancement_pourcentage: tempProgress.value } }
    const res = await updateCourseProgress(course.id, payload)
    if (res && res.data) {
      course.progress = res.data.avancement_pourcentage || tempProgress.value
    }
  } catch (e) {
    console.error('Failed to update progress', e)
    alert('Erreur lors de la mise à jour de la progression')
  } finally {
    loadingProgress.value = false
    editingProgress.value = null
  }
}

function startEditingModule(course) {
  editingModule.value = course.id
  editErrors.value = {}
  editModuleData.value = {
    description_module: course.description_module || '',
    semestre_module: course.semestre_module || '',
    credits_module: course.credits_module || 0
  }
}

function cancelEditingModule() {
  editingModule.value = null
  editErrors.value = {}
}

function validateEditForm() {
  editErrors.value = {}
  
  if (!editModuleData.value.semestre_module) {
    editErrors.value.semestre = 'Le semestre est obligatoire'
  }
  
  const credits = parseInt(editModuleData.value.credits_module)
  if (editModuleData.value.credits_module === '' || editModuleData.value.credits_module === null) {
    editErrors.value.credits = 'Le nombre de crédits est obligatoire'
  } else if (isNaN(credits) || credits < 1 || credits > 6) {
    editErrors.value.credits = 'Entre 1 et 6'
  }
  
  return Object.keys(editErrors.value).length === 0
}

async function saveModuleDetails(course) {
  if (!validateEditForm()) return

  loadingModuleUpdate.value = true
  try {
    const payload = { progress: editModuleData.value }
    const res = await updateCourseProgress(course.id, payload)
    if (res && res.data) {
      // Optimistic update
      course.description_module = res.data.description_module
      course.semestre_module = res.data.semestre_module
      course.credits_module = res.data.credits_module
    }
  } catch (e) {
    console.error('Failed to update module', e)
    alert('Erreur lors de la mise à jour du module')
  } finally {
    loadingModuleUpdate.value = false
    editingModule.value = null
  }
}

function getColorClasses(color) {
  const colors = {
    indigo: 'bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-400',
    blue: 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400',
    green: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    purple: 'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-400',
    gray: 'bg-gray-100 dark:bg-gray-900/30 text-gray-700 dark:text-gray-400',
  }
  return colors[color] || colors.indigo
}

// Load professor courses from API on mount
onMounted(async () => {
  try {
    const res = await professeurModulesProgress()
    if (res && res.data) {
      courses.value = res.data.map((row) => {
        const mod = row.module || {}
        return {
          id: mod.id,
          assignment_id: row.assignment_id,
          name: mod.intitule_cours || 'Cours',
          code: mod.code_cours || '',
          students: row.students_count || 0,
          schedule: row.date_debut_enseigner && row.date_fin_enseigner 
            ? `${row.date_debut_enseigner} - ${row.date_fin_enseigner}` 
            : 'Non défini',
          color: 'indigo',
          progress: row.avancement_pourcentage || 0,
          description_module: mod.description_module || '',
          semestre_module: mod.semestre_module || 'N/A',
          credits_module: mod.credits_module || 0,
        }
      })
    }
  } catch (e) {
    console.error('Failed to load courses:', e)
  }
})
</script>
