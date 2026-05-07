<template>
  <div class="space-y-6">
    <!-- Tickets Section -->
      <!-- Header -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <button
          v-if="isDelegate"
          @click="showForm = !showForm"
 class="ml-auto flex items-center gap-1.5 px-3 py-2 rounded-xl text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-md"
        style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%); --blue: #255fe3; --blue-dark: #1f54d2; --blue-deep: #1d3f95; font-weight: 600">
          <Plus class="w-3.5 h-3.5" />
          Nouveau ticket
        </button>
        <div
          v-else
          class="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-slate-800 text-gray-500 dark:text-gray-400 rounded-lg cursor-not-allowed border border-gray-200 dark:border-slate-700"
        >
          <Lock class="w-5 h-5" />
          <span class="text-sm">Réservé aux délégués</span>
        </div>
      </div>

<!-- Formulaire d'ajout Tickets-->
      <div v-if="isDelegate && showForm" class="rounded-2xl p-5" :style="{ background: 'var(--card)', boxShadow: 'var(--shadow-neutral-soft)' }">
        <h3 class="text-sm mb-3" :style="{ color: 'var(--foreground)', fontWeight: '700' }">Nouveau Ticket</h3>
        <div class="grid grid-cols-1 gap-3 mb-3 sm:grid-cols-2">
          <!-- Destinataire -->
          <CustomSelect
            v-model="formData.ticketDestinataire"
            :options="destinataireOptions"
            placeholder="Destinataire du ticket*"
          />
          <!-- Module selector (visible only when destinataire is professeur) -->
          <CustomSelect
            v-if="formData.ticketDestinataire === 'professeur'"
            v-model="formData.ticketModuleId"
            :options="moduleOptions"
            placeholder="Sélectionner un module*"
          />
          <div v-else></div>
          <input v-model="formData.ticketSubject" placeholder="Sujet du ticket*" class="col-span-1 sm:col-span-2" />
          <CustomSelect
            v-model="formData.ticketCategory"
            :options="categoryOptions"
            placeholder="Sélectionner une catégorie"
          />
          <CustomSelect
            v-model="formData.ticketPriority"
            :options="priorityOptions"
            placeholder="Sélectionner une priorité"
          />
          <textarea v-model="formData.ticketDescription" placeholder="Description détaillée*" rows="3" class="col-span-2 resize-none"></textarea>
      </div>
      <div class="flex gap-2 justify-end">
        <button @click="showForm = false" class="px-4 py-2 rounded-xl text-sm" :style="{ background: 'var(--muted)', color: 'var(--muted-foreground)', fontWeight: '600' }">Annuler</button>
        <button 
          @click="addTicket" 
          :disabled="submitting || !formValid"
          class="px-5 py-2.5 rounded-xl text-white text-sm font-semibold transition-all hover:opacity-90 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 600"
        >
          <Loader2 v-if="submitting" class="w-4 h-4 animate-spin" />
          <Check v-else class="w-4 h-4" />
          {{ submitting ? 'Création...' : 'Créer' }}
        </button>
      </div>
      </div>

      <!-- Info for students -->
      <div v-if="!isDelegate" class="bg-orange-50 border border-orange-200 rounded-lg p-4">
        <div class="flex items-start gap-3">
          <Lock class="w-6 h-6 text-orange-600 flex-shrink-0" />
          <div>
            <h3 class="font-semibold text-orange-900">Fonctionnalité Délégué</h3>
            <p class="text-sm text-orange-700 mt-1">
              Seuls les délégués peuvent créer des tickets. Vous pouvez consulter les tickets existants.
            </p>
          </div>
        </div>
      </div>

      <!-- Stats Tickets -->
      <div class="grid grid-cols-3 gap-4">
        <div v-for="(stat, index) in ticketStats" :key="index" class="bg-white dark:bg-slate-800 rounded-lg p-4 border border-gray-200 dark:border-slate-700 shadow-sm">
          <div :class="['inline-flex p-2 rounded-lg mb-2', stat.color]">
            <component :is="stat.icon" class="w-5 h-5" />
          </div>
          <p class="text-2xl font-bold text-gray-900 dark:text-white">{{ stat.value }}</p>
          <p class="text-sm text-gray-600 dark:text-gray-400">{{ stat.label }}</p>
        </div>
      </div>

      <!-- Filters Tickets -->
      <div class="bg-white dark:bg-slate-800 rounded-lg p-4 border border-gray-200 dark:border-slate-700 shadow-sm">
        <div class="flex flex-col sm:flex-row gap-4">
          <div class="flex-1 relative">
            <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Rechercher un ticket..."
              v-model="searchTermTicket"
              class="pl-10"
            />
          </div>
          <div class="w-full sm:w-56">
            <CustomSelect
              v-model="filterStatusTicket"
              :options="statusFilterOptions"
              placeholder="Tous les statuts"
            />
          </div>
        </div>
      </div>

      <!-- Tickets List -->
      <div class="space-y-4">
        <div
          v-for="ticket in filteredTicketsData"
          :key="ticket.id"
          class="bg-white dark:bg-slate-800 rounded-lg p-6 border border-gray-200 dark:border-slate-700 hover:shadow-md transition-all"
        >
          <div class="flex items-start justify-between gap-4 mb-4">
            <div class="flex-1">
              <div class="flex items-center gap-3 mb-2">
                <TicketIcon class="w-5 h-5 text-indigo-600" />
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{{ ticket.subject }}</h3>
                <span :class="['px-2 py-0.5 rounded text-xs font-medium', priorityBadges[ticket.priority]]">
                  {{ ticket.priority === 'high' ? 'Urgent' : ticket.priority === 'medium' ? 'Moyen' : 'Faible' }}
                </span>
              </div>
              <p class="text-gray-600 dark:text-gray-400 text-sm mb-3">{{ ticket.description }}</p>
              <div class="flex flex-wrap items-center gap-3 text-sm text-gray-500 dark:text-gray-500">
                <span
                  class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded text-xs font-semibold border"
                  :class="ticket.type === 'administration'
                    ? 'bg-purple-50 text-purple-700 border-purple-200 dark:bg-purple-900/30 dark:text-purple-300 dark:border-purple-700'
                    : 'bg-teal-50 text-teal-700 border-teal-200 dark:bg-teal-900/30 dark:text-teal-300 dark:border-teal-700'"
                >
                  <component :is="ticket.type === 'administration' ? Shield : BookOpen" class="w-3.5 h-3.5" />
                  {{ ticket.type === 'administration' ? 'Administration' : 'Professeur' }}
                </span>
                <span class="px-2.5 py-0.5 bg-gray-100 dark:bg-slate-900 text-gray-700 dark:text-gray-300 rounded text-xs font-medium border border-gray-200 dark:border-slate-700">
                  {{ ticket.category }}
                </span>
                <span>•</span>
                <span>Créé le {{ ticket.createdAt }}</span>
                <span>•</span>
                <span>Ticket #{{ ticket.id }}</span>
              </div>
            </div>
            <span :class="['px-3 py-1.5 rounded-full text-sm font-medium border', statusColors[ticket.status]]">
              {{ ticket.status }}
            </span>
          </div>

          <div class="flex items-center gap-2 pt-4 border-t border-gray-100">

            <button
              v-if="isDelegate"
              @click="openCommentForm(ticket)"
              class="group flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold transition-all duration-200 text-gray-500 hover:text-indigo-600 hover:bg-indigo-50 active:scale-95"
            >
              <MessageCircleMore class="w-4 h-4 transition-transform duration-200 group-hover:rotate-12" />
              Commenter
            </button>
            <div class="flex-1"></div>
            <span class="text-xs text-gray-300 font-medium">#{{ ticket.id }}</span>
          </div>
        </div>
      </div>


    <!-- Modal Détails du Ticket -->
    <Transition name="modal">
      <div v-if="selectedTicket && showDetails" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm" @click.self="showDetails = false">
        <div class="bg-white dark:bg-slate-800 rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-hidden shadow-2xl flex flex-col modal-content border border-gray-100 dark:border-slate-700">

          <!-- Header — clean white -->
          <div class="px-7 pt-6 pb-4">
            <div class="flex items-start justify-between gap-4">
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2.5 mb-1.5 flex-wrap">
                  <span class="text-xs font-bold text-gray-400 tracking-wide">#{{ selectedTicket.id }}</span>
                  <span :class="['px-2.5 py-0.5 rounded-full text-xs font-semibold border', statusColors[selectedTicket.status]]">
                    {{ selectedTicket.status }}
                  </span>
                  <div :class="['inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold border', priorityBadges[selectedTicket.priority]]">
                    <component :is="priorityConfig[selectedTicket.priority].icon" :size="12" :stroke-width="2.5" />
                    {{ priorityConfig[selectedTicket.priority].label }}
                  </div>
                  <span
                    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold border"
                    :class="selectedTicket.type === 'administration'
                      ? 'bg-purple-50 text-purple-700 border-purple-200 dark:bg-purple-900/30 dark:text-purple-300 dark:border-purple-700'
                      : 'bg-teal-50 text-teal-700 border-teal-200 dark:bg-teal-900/30 dark:text-teal-300 dark:border-teal-700'"
                  >
                    <component :is="selectedTicket.type === 'administration' ? Shield : BookOpen" class="w-3.5 h-3.5" />
                    {{ selectedTicket.type === 'administration' ? 'Administration' : 'Professeur' }}
                  </span>
                </div>
                <h2 class="text-xl font-bold text-gray-900 dark:text-white leading-snug">{{ selectedTicket.subject }}</h2>
              </div>
              <button @click="showDetails = false" class="p-2 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-xl transition-colors text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300 flex-shrink-0">
                <X class="w-5 h-5" />
              </button>
            </div>
            <!-- Metadata chips -->
            <div class="flex flex-wrap items-center gap-2 mt-3">
              <span class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-gray-50 dark:bg-slate-900 rounded-lg text-xs text-gray-500 dark:text-gray-400 font-medium border border-gray-100 dark:border-slate-700">
                <TicketIcon class="w-3.5 h-3.5" />
                {{ selectedTicket.category }}
              </span>
              <span class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-gray-50 dark:bg-slate-900 rounded-lg text-xs text-gray-500 dark:text-gray-400 font-medium border border-gray-100 dark:border-slate-700">
                <Clock class="w-3.5 h-3.5" />
                {{ selectedTicket.createdAt }}
              </span>
              <span class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-gray-50 dark:bg-slate-900 rounded-lg text-xs text-gray-500 dark:text-gray-400 font-medium border border-gray-100 dark:border-slate-700">
                <MessageCircleMore class="w-3.5 h-3.5" />
                {{ selectedTicket.comments ? selectedTicket.comments.length : 0 }} commentaire{{ selectedTicket.comments && selectedTicket.comments.length > 1 ? 's' : '' }}
              </span>
            </div>
          </div>

          <!-- Divider -->
          <div class="h-px bg-gray-100 mx-7"></div>

          <!-- Scrollable Content -->
          <div class="overflow-y-auto flex-1 px-7 py-5 space-y-5 modal-scroll">

            <!-- Description -->
            <div class="relative pl-4">
              <div class="absolute left-0 top-0 bottom-0 w-1 rounded-full bg-indigo-400/40"></div>
              <p class="text-sm text-gray-600 dark:text-gray-300 leading-relaxed">{{ selectedTicket.description }}</p>
            </div>

            <!-- Comments Thread -->
            <div>
              <h4 class="text-sm font-bold text-gray-900 dark:text-white uppercase tracking-wider mb-4">Fil de discussion</h4>

              <div v-if="!selectedTicket.comments || selectedTicket.comments.length === 0" class="flex flex-col items-center py-10">
                <div class="w-14 h-14 rounded-2xl bg-gray-50 flex items-center justify-center mb-3">
                  <MessageCircleMore class="w-7 h-7 text-gray-300" />
                </div>
                <p class="text-sm text-gray-400 font-medium">Pas encore de commentaires</p>
                <p class="text-xs text-gray-300 mt-1">Soyez le premier à commenter</p>
              </div>

              <div v-else class="space-y-1">
                <div
                  v-for="(comment, idx) in selectedTicket.comments"
                  :key="comment.id"
                  class="flex gap-3 group"
                >
                  <!-- Avatar -->
                  <div class="flex flex-col items-center flex-shrink-0">
                    <div
                      class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white"
                      :style="{ background: commentAvatarColor(comment.author) }"
                    >
                      {{ comment.author.charAt(0) }}
                    </div>
                    <div v-if="idx < selectedTicket.comments.length - 1" class="w-0.5 flex-1 bg-gray-100 mt-1"></div>
                  </div>
                  <!-- Bubble -->
                  <div class="flex-1 pb-4">
                    <div class="flex items-baseline gap-2 mb-1">
                      <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ comment.author }}</span>
                      <span class="text-[11px] text-gray-400 dark:text-gray-500">{{ comment.date }}</span>
                    </div>
                    <div class="bg-gray-50 dark:bg-slate-900/50 rounded-xl rounded-tl-sm px-4 py-3 text-sm text-gray-600 dark:text-gray-300 leading-relaxed border border-gray-100 dark:border-slate-700 group-hover:border-indigo-200 dark:group-hover:border-indigo-800 transition-colors">
                      {{ comment.text }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Sticky Comment Input Bar (students cannot comment on administration-targeted tickets) -->
          <div v-if="canSendComment(selectedTicket)" class="border-t border-gray-100 dark:border-slate-700 px-7 py-4 bg-gray-50/50 dark:bg-slate-900/50">
            <div class="flex items-end gap-3">
              <div class="w-8 h-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                V
              </div>
              <div class="flex-1 flex items-end gap-2">
                <textarea
                  v-model="newComment"
                  placeholder="Écrire un commentaire..."
                  rows="1"
                  class="flex-1 resize-none"
                  @input="autoResize"
                  ref="commentInput"
                  style="min-height: 42px; max-height: 120px;"
                ></textarea>
                <button
                  @click="addComment"
                  :disabled="!newComment.trim()"
                  class="w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-200 flex-shrink-0"
                  :class="newComment.trim()
                    ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/30 hover:bg-indigo-700 active:scale-90'
                    : 'bg-gray-100 text-gray-300 cursor-not-allowed'"
                >
                  <Send class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          <!-- Administration-targeted ticket (comments disabled for students; show admin motif if any) -->
          <div v-else-if="!isDelegate && !isTicketLocked(selectedTicket)" class="border-t border-gray-100 px-7 py-3 bg-gray-50/50 text-center">
            <span class="text-sm text-gray-600">Vous pouvez consulter ce ticket et son statut. Les commentaires sont réservés aux délégués.</span>
          </div>

          <!-- Administration-targeted ticket (comments disabled for students; show admin motif if any) -->
          <div v-else-if="!isTicketLocked(selectedTicket) && selectedTicket.type === 'administration'" class="border-t border-gray-100 px-7 py-3 bg-gray-50/50 text-center">
            <span class="text-sm text-gray-600">Ce ticket est destiné à l'administration — vous ne pouvez pas ajouter de commentaires. Vous pouvez consulter le motif fourni par l'administration dans le fil de discussion.</span>
          </div>

          <!-- Closed ticket footer -->
          <div v-else class="border-t border-gray-100 px-7 py-3 bg-gray-50/50 text-center">
            <span class="text-xs text-gray-400 font-medium">Ce ticket est {{ selectedTicket.status.toLowerCase() }} — vous pouvez voir l'historique, mais les commentaires sont désactivés</span>
          </div>

        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { Ticket as TicketIcon, Plus, Search, Clock, AlertCircle, AlertTriangle, CheckCircle, MessageCircleMore, Lock, X, Send, Shield, BookOpen, Loader2, Check } from 'lucide-vue-next'
import { useAuth } from '../../../composables/useAuth'
import CustomSelect from '../../../components/CustomSelect.vue'
import { listTickets, createTicket, getTicket, addTicketComment, getTicketComments } from '../../../composables/useTickets'
import { studentModulesProgress } from '../../../composables/useModules'

const { isDelegate } = useAuth()

// Tickets State
const showForm = ref(false)
const searchTermTicket = ref('')
const filterStatusTicket = ref('all')
const selectedTicket = ref(null)
const showDetails = ref(false)
const newComment = ref('')
const submitting = ref(false)
let pollInterval = null
let previousTicketsState = new Map()

// Form Data
const formData = ref({
  ticketSubject: '',
  ticketDescription: '',
  ticketCategory: '',
  ticketPriority: '',
  ticketDestinataire: '',
  ticketModuleId: null,
})

// Modules list for professor destination
const modules = ref([])

const priorityConfig = {
  high:   { icon: AlertCircle,   label: 'Urgent' },
  medium: { icon: AlertTriangle, label: 'Moyen'  },
  low:    { icon: CheckCircle,   label: 'Faible' },
}

// Select Options
const priorityOptions = [
  { value: 'low', label: 'Faible', icon: CheckCircle, dot: '#6b7280' },
  { value: 'medium', label: 'Moyenne', icon: AlertTriangle, dot: '#f59e0b' },
  { value: 'high', label: 'Urgente', icon: AlertCircle, dot: '#ef4444' },
]

const destinataireOptions = [
  { value: 'administration', label: 'Administration', icon: Shield, dot: '#8b5cf6' },
  { value: 'professeur', label: 'Professeur', icon: BookOpen, dot: '#14b8a6' },
]

// Réclamations destinées aux professeurs
const teacherCategoryOptions = ref([
  { value: 'Module', label: 'Module', dot: '#10b981', gradient: 'linear-gradient(135deg, #059669 0%, #10b981 50%, #047857 100%)' },
  { value: 'Examens', label: 'Examens', dot: '#f59e0b', gradient: 'linear-gradient(135deg, #d97706 0%, #f59e0b 50%, #b45309 100%)' },
  { value: 'Absence', label: 'Absence', dot: '#ef4444', gradient: 'linear-gradient(135deg, #dc2626 0%, #ef4444 50%, #b91c1c 100%)' },
  { value: 'Comportement', label: 'Comportement', dot: '#ec4899', gradient: 'linear-gradient(135deg, #db2777 0%, #ec4899 50%, #be185d 100%)' },
  { value: 'Communication', label: 'Communication', dot: '#3b82f6', gradient: 'linear-gradient(135deg, #2563eb 0%, #3b82f6 50%, #1d4ed8 100%)' },
  { value: 'Général', label: 'Général', dot: '#64748b', gradient: 'linear-gradient(135deg, #475569 0%, #64748b 50%, #334155 100%)' },
])

// Réclamations destinées à l'administration
const administrationCategoryOptions = ref([
  { value: 'Infrastructure', label: 'Infrastructure', dot: '#f59e0b', gradient: 'linear-gradient(135deg, #d97706 0%, #f59e0b 50%, #b45309 100%)' },
  { value: 'Scolarité', label: 'Scolarité', dot: '#10b981', gradient: 'linear-gradient(135deg, #059669 0%, #10b981 50%, #047857 100%)' },
  { value: 'Services', label: 'Services', dot: '#8b5cf6', gradient: 'linear-gradient(135deg, #7c3aed 0%, #8b5cf6 50%, #6d28d9 100%)' },
  { value: 'Vie étudiante', label: 'Vie étudiante', dot: '#ec4899', gradient: 'linear-gradient(135deg, #db2777 0%, #ec4899 50%, #be185d 100%)' },
  { value: 'Paiement', label: 'Paiement', dot: '#ef4444', gradient: 'linear-gradient(135deg, #dc2626 0%, #ef4444 50%, #b91c1c 100%)' },
  { value: 'Plateforme', label: 'Plateforme', dot: '#3b82f6', gradient: 'linear-gradient(135deg, #2563eb 0%, #3b82f6 50%, #1d4ed8 100%)' },
  { value: 'Général', label: 'Général', dot: '#64748b', gradient: 'linear-gradient(135deg, #475569 0%, #64748b 50%, #334155 100%)' },
])

const categoryOptions = computed(() =>
  formData.value.ticketDestinataire === 'professeur' 
    ? teacherCategoryOptions.value 
    : administrationCategoryOptions.value
)

const moduleOptions = computed(() =>
  modules.value.map(m => ({
    value: m.id,
    label: m.name || m.intitule_cours || `Module #${m.id}`,
  }))
)

const formValid = computed(() => {
  const hasBasicFields = 
    formData.value.ticketSubject.trim() && 
    formData.value.ticketDescription.trim() && 
    formData.value.ticketCategory && 
    formData.value.ticketPriority && 
    formData.value.ticketDestinataire

  if (formData.value.ticketDestinataire === 'professeur') {
    return hasBasicFields && formData.value.ticketModuleId
  }
  return hasBasicFields
})

const statusFilterOptions = [
  { value: 'all', label: 'Tous les statuts' },
  { value: 'En attente', label: 'En attente', dot: '#3b82f6' },
  { value: 'Accepter', label: 'Accepter', dot: '#22c55e' },
  { value: 'Refuser', label: 'Refuser', dot: '#ef4444' },
]

// Tickets Data
const tickets = ref([])

// Ticket Functions
const addTicket = async () => {
  if (!formValid.value || submitting.value) return

  submitting.value = true
  try {
    const payload = {
      object_ticket: formData.value.ticketSubject,
      description_ticket: formData.value.ticketDescription,
      categorie_ticket: formData.value.ticketCategory,
      priorite_ticket: formData.value.ticketPriority,
      type_ticket: formData.value.ticketDestinataire,
    }
    // Attach module_id only when directed to a professor
    if (formData.value.ticketDestinataire === 'professeur' && formData.value.ticketModuleId) {
      payload.module_id = formData.value.ticketModuleId
    }
    const res = await createTicket({ ticket: payload })
    if (res && res.data) {
      const t = res.data
      tickets.value.unshift({
        id: t.id,
        subject: t.object_ticket,
        description: t.description_ticket,
        status: normalizeStatus(t.statut_ticket),
        priority: t.priorite_ticket || 'low',
        createdAt: t.cree_le_ticket || t.inserted_at,
        category: t.categorie_ticket || '',
        type: t.type_ticket || 'administration',
        comments: []
      })
    }
    formData.value.ticketSubject = ''
    formData.value.ticketDescription = ''
    formData.value.ticketCategory = ''
    formData.value.ticketPriority = ''
    formData.value.ticketDestinataire = ''
    formData.value.ticketModuleId = null
    showForm.value = false
  } catch (err) {
    console.error('Erreur création ticket', err)
    alert('Impossible de créer le ticket')
  } finally {
    submitting.value = false
  }
}

const openDetails = async (ticket) => {
  try {
    const res = await getTicket(ticket.id)
    if (res && res.data) {
      const t = res.data
      selectedTicket.value = {
        id: t.id,
        subject: t.object_ticket,
        description: t.description_ticket,
        status: normalizeStatus(t.statut_ticket),
        priority: t.priorite_ticket,
        createdAt: t.cree_le_ticket || t.inserted_at,
        category: t.categorie_ticket,
        type: t.type_ticket || t.type,
        comments: mapComments(t.commentaires)
      }
      showDetails.value = true
    }
  } catch (err) {
    console.error('Failed to load ticket', err)
    alert('Impossible de charger le ticket')
  }
}

const openCommentForm = async (ticket) => {
  newComment.value = ''
  // Load full ticket with comments from API
  try {
    const res = await getTicket(ticket.id)
    if (res && res.data) {
      const t = res.data
      selectedTicket.value = {
        id: t.id,
        subject: t.object_ticket,
        description: t.description_ticket,
        status: normalizeStatus(t.statut_ticket),
        priority: t.priorite_ticket,
        createdAt: t.cree_le_ticket || t.inserted_at,
        category: t.categorie_ticket,
        type: t.type_ticket || t.type,
        comments: mapComments(t.commentaires)
      }
    } else {
      selectedTicket.value = ticket
    }
  } catch (err) {
    console.error('Failed to load ticket for comment', err)
    selectedTicket.value = ticket
  }
  showDetails.value = true
} 

const addComment = async () => {
  if (!canSendComment(selectedTicket.value) || !newComment.value.trim() || !selectedTicket.value) {
    return
  }

  if (newComment.value.trim() && selectedTicket.value) {
    try {
      const res = await addTicketComment(selectedTicket.value.id, { commentaire: { contenu_commentaires: newComment.value } })
      if (res && res.data) {
        // refresh comments
        const commentsRes = await getTicketComments(selectedTicket.value.id)
        selectedTicket.value.comments = mapComments((commentsRes && commentsRes.data) || [])
        newComment.value = ''
      }
    } catch (err) {
      console.error('Failed to add comment', err)
      alert('Impossible d\'ajouter le commentaire')
    }
  }
}

// Map API comment objects to the shape expected by the template
function mapComments(commentaires) {
  if (!commentaires) return []
  return commentaires.map(c => ({
    id: c.id,
    author: c.auteur_nom || 'Utilisateur',
    text: c.contenu_commentaires || '',
    date: formatCommentDate(c.inserted_at),
    isInternal: c.interne_commentaires || false,
  }))
}

function formatCommentDate(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  const diff = Math.floor((Date.now() - d.getTime()) / 1000)
  if (diff < 60) return `Il y a ${diff}s`
  const m = Math.floor(diff / 60)
  if (m < 60) return `Il y a ${m} min`
  const h = Math.floor(m / 60)
  if (h < 24) return `Il y a ${h}h`
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' })
}

// Comment avatar colors — deterministic per author name
const avatarPalette = ['#6366f1', '#8b5cf6', '#ec4899', '#f59e0b', '#10b981', '#3b82f6', '#ef4444']
const commentAvatarColor = (name) => {
  let hash = 0
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash)
  return avatarPalette[Math.abs(hash) % avatarPalette.length]
}

// Auto-resize textarea
const commentInput = ref(null)
const autoResize = (e) => {
  const el = e.target
  el.style.height = 'auto'
  el.style.height = Math.min(el.scrollHeight, 120) + 'px'
}

// Stats Computed
const ticketStats = computed(() => [
  { label: 'Attente', value: tickets.value.filter((t) => normalizeStatus(t.status) === 'En attente').length, icon: TicketIcon, color: 'bg-blue-100 text-blue-600' },
  { label: 'Accepter', value: tickets.value.filter((t) => normalizeStatus(t.status) === 'Accepter').length, icon: Clock, color: 'bg-orange-100 text-orange-600' },
  { label: 'Refuser', value: tickets.value.filter((t) => normalizeStatus(t.status) === 'Refuser').length, icon: CheckCircle, color: 'bg-green-100 text-green-600' },
])

onMounted(async () => {
  // Load tickets
  try {
    const res = await listTickets()
    if (res && res.data) {
      tickets.value = res.data.map(t => ({
        id: t.id,
        subject: t.object_ticket,
        description: t.description_ticket,
        status: normalizeStatus(t.statut_ticket),
        priority: t.priorite_ticket,
        createdAt: t.cree_le_ticket || t.inserted_at,
        category: t.categorie_ticket,
        type: t.type_ticket || 'general',
        comments: []
      }))
    }
  } catch (err) {
    console.error('Failed to load tickets', err)
  }

  // Load modules for ticket destination selector
  try {
    const modRes = await studentModulesProgress()
    if (modRes && modRes.data) {
      modules.value = modRes.data.map(m => ({
        id: m.module?.id || m.module_id || m.id,
        name: m.module?.intitule_cours || m.intitule_cours || '',
        intitule_cours: m.module?.intitule_cours || m.intitule_cours || '',
      }))
    }
  } catch (err) {
    console.debug('Failed to load modules for ticket form', err)
  }
})

// Status Colors
const statusColors = {
  // Tickets
  'En attente': 'bg-blue-100 text-blue-700 border-blue-200',
  'Accepter': 'bg-green-100 text-green-700 border-green-200',
  'Refuser': 'bg-red-100 text-red-700 border-red-200',
}

const priorityBadges = {
  high: 'bg-red-100 text-red-700',
  medium: 'bg-yellow-100 text-yellow-700',
  low: 'bg-gray-100 text-gray-700',
}

function normalizeStatus(rawStatus) {
  if (!rawStatus) return 'En attente'

  const status = String(rawStatus).toLowerCase().trim()

  if (status.includes('en_attente') || status === 'ouvert') return 'En attente'
  if (status.includes('acceptee') || status.includes('accepter') || status.includes('resolu') || status.includes('résolu')) return 'Accepter'
  if (status.includes('refusee') || status.includes('refuser') || status === 'ferme' || status.includes('fermé')) return 'Refuser'

  return 'En attente'
}

// Filtered Results
const filteredTicketsData = computed(() => {
  const filtered = tickets.value.filter((ticket) => {
    const matchesStatus = filterStatusTicket.value === 'all' || normalizeStatus(ticket.status) === filterStatusTicket.value
    const matchesSearch =
      ticket.subject.toLowerCase().includes(searchTermTicket.value.toLowerCase()) ||
      ticket.description.toLowerCase().includes(searchTermTicket.value.toLowerCase())
    return matchesStatus && matchesSearch
  })
  return [...filtered].sort((a, b) => {
    const dateA = new Date(a.createdAt).getTime();
    const dateB = new Date(b.createdAt).getTime();
    return dateB - dateA; // Plus récent en premier
  });
})

function isTicketLocked(ticket) {
  if (!ticket) return false
  const status = normalizeStatus(ticket.status)
  return status === 'Résolu' || status === 'Accepter' || status === 'Refuser'
}

function canSendComment(ticket) {
  return Boolean(isDelegate.value && ticket && !isTicketLocked(ticket) && ticket.type !== 'administration')
}
</script>


<style scoped>
/* Animation du modal */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

/* Animation du contenu du modal */
.modal-content {
  animation: slideUp 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}
@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* Slim scrollbar for modal */
.modal-scroll::-webkit-scrollbar {
  width: 4px;
}
.modal-scroll::-webkit-scrollbar-thumb {
  background: #d1d5db;
  border-radius: 4px;
}
.modal-scroll::-webkit-scrollbar-track {
  background: transparent;
}
</style>
 