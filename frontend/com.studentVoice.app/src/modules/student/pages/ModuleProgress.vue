<template>
  <div class="space-y-6">

    <!-- Info Message -->
    <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
      <div class="flex items-start gap-3">
        <BookOpen class="w-6 h-6 text-blue-600 flex-shrink-0" />
        <div>
          <h3 class="font-semibold text-blue-900">Suivi Pédagogique</h3>
          <p class="text-sm text-blue-700 mt-1">
            La progression est mise à jour par vos professeurs au fur et à mesure de l'avancement des cours.
          </p>
        </div>
      </div>
    </div>

    <!-- Overall Progress Summary -->
    <div class="bg-white rounded-lg p-6 border border-gray-200">
      <h2 class="text-lg font-semibold text-gray-900 mb-4">Progression globale</h2>
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div v-for="module in modules" :key="module.id" class="text-center">
          <div class="relative w-20 h-20 mx-auto mb-2">
            <svg class="transform -rotate-90 w-20 h-20">
              <circle cx="40" cy="40" r="36" stroke="currentColor" stroke-width="8" fill="none" class="text-gray-200" />
              <circle
                cx="40"
                cy="40"
                r="36"
                stroke="currentColor"
                stroke-width="8"
                fill="none"
                :stroke-dasharray="`${2 * Math.PI * 36}`"
                :stroke-dashoffset="`${2 * Math.PI * 36 * (1 - module.progress / 100)}`"
                :class="getProgressTextColor(module.progress)"
              />
            </svg>
            <div class="absolute inset-0 flex items-center justify-center">
              <span :class="['text-lg font-bold', getProgressTextColor(module.progress)]">
                {{ module.progress }}%
              </span>
            </div>
          </div>
          <p class="text-sm font-medium text-gray-900">{{ module.code }}</p>
        </div>
      </div>
    </div>

    <!-- Modules List -->
    <div class="space-y-4">
      <div
        v-for="module in modules"
        :key="module.id"
        class="bg-white rounded-lg border border-gray-200 overflow-hidden"
      >
        <!-- Module Header -->
        <div class="p-6">
          <div class="flex items-start justify-between gap-4 mb-4">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <BookOpen class="w-6 h-6 text-indigo-600" />
                <h3 class="text-xl font-semibold text-gray-900">{{ module.name }}</h3>
                <span class="px-2.5 py-0.5 bg-gray-100 text-gray-700 rounded text-sm font-medium">
                  {{ module.code }}
                </span>
              </div>
              <p class="text-sm text-gray-600 mb-2">{{ module.professor }}</p>
              </div>

            <div class="flex items-center gap-3">
              <button
                @click="toggleModule(module.id)"
                class="p-2 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <ChevronUp v-if="expandedModule === module.id" class="w-5 h-5 text-gray-600" />
                <ChevronDown v-else class="w-5 h-5 text-gray-600" />
              </button>
            </div>
          </div>

          <!-- Progress Bar -->
          <div class="mb-2">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Progression</span>
              <span :class="['text-sm font-bold', getProgressTextColor(module.progress)]">
                {{ module.progress }}%
              </span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3">
              <div
                :class="[getProgressColor(module.progress), 'h-3 rounded-full transition-all duration-500']"
                :style="{ width: `${module.progress}%` }"
              />
            </div>
          </div>

          <p class="text-sm text-gray-600">
            {{ module.chapters.filter((c) => c.completed).length }} / {{ module.chapters.length }} chapitres complétés
          </p>
        </div>

        <!-- Chapters List -->
        <div v-if="expandedModule === module.id" class="border-t border-gray-200 bg-gray-50 p-6">
          <h4 class="font-semibold text-gray-900 mb-4">Chapitres du cours</h4>
          <div class="space-y-3">
            <div
              v-for="chapter in module.chapters"
              :key="chapter.id"
              :class="[
                'flex items-center gap-4 p-4 rounded-lg',
                chapter.completed ? 'bg-green-50 border border-green-200' : 'bg-white border border-gray-200',
              ]"
            >
              <CheckCircle v-if="chapter.completed" class="w-5 h-5 text-green-600 flex-shrink-0" />
              <Circle v-else class="w-5 h-5 text-gray-400 flex-shrink-0" />
              <div class="flex-1">
                <p :class="['font-medium', chapter.completed ? 'text-green-900' : 'text-gray-900']">
                  {{ chapter.title }}
                </p>
                <p class="text-sm text-gray-600">{{ chapter.date }}</p>
              </div>
              <span
                v-if="chapter.completed"
                class="px-2.5 py-0.5 bg-green-100 text-green-700 rounded-full text-xs font-medium"
              >
                Complété
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { BookOpen, ChevronDown, ChevronUp, CheckCircle, Circle } from 'lucide-vue-next'
import { studentModulesProgress } from '../../../composables/useModules'

const expandedModule = ref(null)
const modules = ref([])

const toggleModule = (moduleId) => {
  expandedModule.value = expandedModule.value === moduleId ? null : moduleId
}

const getProgressColor = (progress) => {
  if (progress >= 80) return 'bg-green-600'
  if (progress >= 60) return 'bg-blue-600'
  if (progress >= 40) return 'bg-orange-600'
  return 'bg-red-600'
}

const getProgressTextColor = (progress) => {
  if (progress >= 80) return 'text-green-600'
  if (progress >= 60) return 'text-blue-600'
  if (progress >= 40) return 'text-orange-600'
  return 'text-red-600'
}

onMounted(async () => {
  try {
    const res = await studentModulesProgress()
    if (res && res.data) {
      modules.value = res.data.map(m => ({
        id: m.id,
        name: m.intitule_cours || m.code_cours,
        code: m.code_cours,
        professor: m.professor || '',
        progress: m.avancement_pourcentage || 0,
        nextClass: m.nextClass ? formatDate(m.nextClass) : 'À déterminer',
        chapters: (m.chapters || []).map(ch => ({
          id: ch.id,
          title: ch.title,
          date: ch.date ? formatDate(ch.date) : '',
          completed: ch.completed || false
        }))
      }))
    }
  } catch (err) {
    console.error('Erreur chargement modules', err)
  }
})

const formatDate = (dateStr) => {
  if (!dateStr) return 'À déterminer'
  try {
    const date = new Date(dateStr)
    return date.toLocaleDateString('fr-FR', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    })
  } catch {
    return dateStr
  }
}
</script>