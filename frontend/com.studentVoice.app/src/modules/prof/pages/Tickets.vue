<template>
  <div class="flex flex-col gap-4">
    <!-- Stats Row -->
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3">
      <div
        v-for="stat in stats"
        :key="stat.label"
        class="rounded-2xl p-4 flex items-center gap-3 cursor-pointer transition-all hover:shadow-md bg-white dark:bg-slate-800 border border-transparent dark:border-slate-700"
        style="box-shadow: 0 2px 12px rgba(0,0,0,0.06)"
      >
        <div class="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" :style="{ background: stat.bg }">
          <component :is="stat.icon" class="w-4 h-4" :style="{ color: stat.color }" />
        </div>
        <div>
          <p class="text-xl font-bold leading-none text-slate-800 dark:text-white">{{ stat.value }}</p>
          <p class="text-xs text-slate-400 dark:text-slate-500 mt-1">{{ stat.label }}</p>
        </div>
      </div>
    </div>

    <!-- Ticket Detail Modal -->
    <div v-if="selectedTicket" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
      <div class="bg-card dark:bg-slate-800 rounded-3xl w-full max-w-2xl max-h-[90vh] flex flex-col shadow-2xl border border-border/50 overflow-hidden">
        <!-- Header -->
        <div class="flex items-center justify-between p-6 border-b border-border">
          <div>
            <h3 class="text-lg font-bold text-foreground">{{ selectedTicket.titre }}</h3>
            <p class="text-xs font-mono text-muted-foreground mt-0.5">{{ selectedTicket.id }}</p>
          </div>
          <button @click="selectedTicket = null" class="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors text-muted-foreground hover:text-foreground">✕</button>
        </div>

        <!-- Ticket Info -->
        <div class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-6 text-sm">
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Expéditeur</p>
              <p class="text-foreground font-semibold">{{ selectedTicket.expediteur }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Cours</p>
              <p class="text-foreground font-semibold line-clamp-1">{{ selectedTicket.cours }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Ouvert le</p>
              <p class="text-foreground font-semibold">{{ selectedTicket.date }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Statut</p>
              <span
                class="inline-flex text-[10px] px-2 py-0.5 rounded-full font-bold uppercase tracking-wider ring-1 ring-inset"
                :style="{ background: statusStyle[selectedTicket.status].bg, color: statusStyle[selectedTicket.status].color, '--tw-ring-color': statusStyle[selectedTicket.status].color + '30' }"
              >
                {{ selectedTicket.status }}
              </span>
            </div>
          </div>

          <div class="mt-6 rounded-2xl border border-slate-100 dark:border-slate-700 bg-slate-50 dark:bg-slate-900/50 p-4">
            <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-2">Description</p>
            <p class="text-sm leading-relaxed text-foreground/80 whitespace-pre-line">
              {{ selectedTicket.description || 'Aucune description disponible.' }}
            </p>
          </div>
        </div>

        <!-- Messages Section (styled like student thread) -->
        <div class="flex-1 overflow-y-auto p-6 space-y-5">
          <h4 class="text-sm font-bold text-gray-900 dark:text-white uppercase tracking-wider mb-4">Fil de discussion</h4>

          <div v-if="!selectedTicket.responses || selectedTicket.responses.length === 0" class="flex flex-col items-center py-10">
            <div class="w-14 h-14 rounded-2xl bg-gray-50 flex items-center justify-center mb-3">
              <MessageSquare class="w-7 h-7 text-gray-300" />
            </div>
            <p class="text-sm text-gray-400 font-medium">Pas encore de commentaires</p>
            <p class="text-xs text-gray-300 mt-1">Soyez le premier à répondre</p>
          </div>

          <div v-else class="space-y-1">
            <div
              v-for="(msg, idx) in selectedTicket.responses"
              :key="idx"
              class="flex gap-3 group"
            >
              <!-- Avatar + timeline -->
              <div class="flex flex-col items-center flex-shrink-0">
                <div
                  class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white"
                  :style="{ background: commentAvatarColor(msg.name || msg.expediteur || 'U') }"
                >
                  {{ (msg.name || msg.expediteur || 'U').charAt(0).toUpperCase() }}
                </div>
                <div v-if="idx < selectedTicket.responses.length - 1" class="w-0.5 flex-1 bg-gray-100 mt-1"></div>
              </div>

              <!-- Bubble -->
              <div class="flex-1 pb-4">
                <div class="flex items-baseline gap-2 mb-1">
                  <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ msg.name || msg.expediteur }}</span>
                  <span class="text-[11px] text-gray-400 dark:text-gray-500">{{ msg.time }}</span>
                </div>
                <div class="bg-gray-50 dark:bg-slate-900/50 rounded-xl rounded-tl-sm px-4 py-3 text-sm text-gray-600 dark:text-gray-300 leading-relaxed border border-gray-100 dark:border-slate-700 group-hover:border-indigo-200 dark:group-hover:border-indigo-800 transition-colors">
                  {{ msg.content }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Response Form -->
        <div class="p-6 border-t border-border bg-card/50">
          <textarea
            v-model="responseText"
            placeholder="Écrire une réponse..."
            :disabled="selectedTicket && selectedTicket.status === 'Accepter'"
            class="w-full p-4 rounded-2xl border border-border bg-slate-50 dark:bg-slate-900/50 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 transition-all resize-none"
            rows="3"
          ></textarea>
          <div class="flex gap-3 mt-4">
            <button
              @click="sendResponse"
              :disabled="selectedTicket && selectedTicket.status === 'Accepter'"
              :class="[{ 'opacity-50 pointer-events-none': selectedTicket && selectedTicket.status === 'Accepter' }, 'flex-1 px-4 py-3 rounded-xl font-bold text-white text-sm transition-all active:scale-95 shadow-lg shadow-blue-500/20']"
              style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%)"
            >
              Envoyer la réponse
            </button>
            <button
              @click="selectedTicket = null"
              class="px-6 py-3 rounded-xl font-bold text-xs uppercase tracking-wider text-muted-foreground bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all"
            >
              Fermer
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Ticket Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-4">
      <div
        v-for="ticket in tickets"
        :key="ticket.id"
        @click="openTicket(ticket.id)"
        class="group relative bg-white dark:bg-slate-800 rounded-3xl p-5 border border-slate-200 dark:border-slate-700 transition-all duration-300 hover:shadow-xl hover:shadow-slate-200/50 dark:hover:shadow-black/50 flex flex-col h-full cursor-pointer hover:border-blue-300 dark:hover:border-blue-600/50"
      >
        <!-- Status & Badge -->
        <div class="flex items-center justify-between mb-4">
          <span class="text-[10px] px-2 py-0.5 rounded-md font-mono font-bold bg-slate-100 dark:bg-slate-900 text-muted-foreground ring-1 ring-slate-200 dark:ring-slate-700">{{ ticket.id }}</span>
          <span
            class="text-[10px] px-2.5 py-1 rounded-lg font-bold uppercase tracking-wider ring-1 ring-inset"
            :style="{ background: statusStyle[ticket.status].bg, color: statusStyle[ticket.status].color, '--tw-ring-color': statusStyle[ticket.status].color + '30' }"
          >
            {{ ticket.status }}
          </span>
        </div>

        <!-- Title -->
        <h3 class="text-base font-bold text-slate-800 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors mb-3 line-clamp-2">
          {{ ticket.titre }}
        </h3>

        <!-- Meta Info -->
        <div class="space-y-2.5 mb-6 flex-grow">
          <div class="flex items-center gap-2.5 text-sm text-slate-600 dark:text-slate-400">
            <div class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-900 flex items-center justify-center border border-slate-100 dark:border-slate-800">
              <UserCheck class="w-3.5 h-3.5" />
            </div>
            <div class="flex flex-col min-w-0">
               <span class="truncate font-semibold text-slate-700 dark:text-slate-300">{{ ticket.expediteur }}</span>
               <span class="text-[10px] font-bold uppercase" :style="{ color: roleColors[ticket.role] }">{{ ticket.role }}</span>
            </div>
          </div>
          <div class="flex items-center gap-2.5 text-sm text-slate-600 dark:text-slate-400">
            <div class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-900 flex items-center justify-center border border-slate-100 dark:border-slate-800">
              <BookOpen class="w-3.5 h-3.5" />
            </div>
            <span class="truncate font-medium">{{ ticket.cours }}</span>
          </div>
        </div>

        <!-- Footer -->
        <div class="pt-4 border-t border-slate-100 dark:border-slate-700/50 flex items-center justify-between">
          <div class="flex gap-4">
             <div class="flex flex-col">
               <span class="text-[10px] text-slate-400 uppercase font-bold tracking-wider mb-0.5">Réponses</span>
               <div class="flex items-center gap-1.5 text-sm font-semibold text-slate-700 dark:text-slate-300">
                 <MessageSquare class="w-3.5 h-3.5 text-blue-500" />
                 {{ ticket.responses.length }}
               </div>
             </div>
             <div class="flex flex-col">
               <span class="text-[10px] text-slate-400 uppercase font-bold tracking-wider mb-0.5">Date</span>
               <div class="text-[11px] font-bold text-slate-500 dark:text-slate-400 mt-0.5">
                 {{ ticket.date }}
               </div>
             </div>
          </div>

          <div class="flex gap-2">
            <button
              v-if="ticket.status !== 'Accepter' && ticket.status !== 'Refuser' && !ticket.locked"
              @click.stop="acceptTicket(ticket.id)"
              class="px-4 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider text-white transition-all hover:brightness-110 active:scale-95 shadow-md shadow-green-500/20"
              style="background: linear-gradient(135deg, #16A34A 0%, #15803D 50%, #166534 100%)"
            >
              Accepter
            </button>
            <button
              v-if="ticket.status !== 'Refuser' && ticket.status !== 'Accepter' && !ticket.locked"
              @click.stop="refuseTicket(ticket.id)"
              class="px-4 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider text-white transition-all hover:brightness-110 active:scale-95 shadow-md shadow-red-500/20"
              style="background: linear-gradient(135deg, #EF4444 0%, #DC2626 50%, #B91C1C 100%)"
            >
              Refuser
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { Send, Clock, CheckCircle, MessageSquare, Ticket as TicketIcon, UserCheck, BookOpen } from 'lucide-vue-next';
import { listTicketsForProf, getTicket, addTicketComment, updateTicket } from '../../../composables/useTickets'

const tickets = ref([])

const selectedTicket = ref(null);
const responseText = ref('');

onMounted(async () => {
  try {
    const res = await listTicketsForProf()
    if (res && res.data) {
      tickets.value = res.data.map(t => mapTicket(t))
    }
  } catch (e) {
    console.debug('listTicketsForProf error', e)
  }
})

const statusStyle = {
  'Ouvert': { bg: '#DBEAFE', color: '#1D4ED8' },
  'En cours': { bg: '#FEF9C3', color: '#CA8A04' },
  'Accepter': { bg: '#DCFCE7', color: '#16A34A' },
  'Refuser': { bg: '#FEE2E2', color: '#DC2626' },
  'Résolu': { bg: '#DCFCE7', color: '#16A34A' },
};

const roleColors = {
  'Délégué': '#818CF8',
  'Professeur': '#F59E0B',
};

const stats = computed(() => [
  { label: 'Total Tickets', value: tickets.value.length, color: '#4F5CF5', bg: 'rgba(79, 92, 245, 0.1)', icon: TicketIcon },
  { label: 'Attente', value: tickets.value.filter(t => t.status === 'Ouvert').length, color: '#1D4ED8', bg: 'rgba(29, 78, 216, 0.1)', icon: Send },
  { label: 'En cours', value: tickets.value.filter(t => t.status === 'En cours').length, color: '#CA8A04', bg: 'rgba(202, 138, 4, 0.1)', icon: Clock },
  { label: 'Acceptés', value: tickets.value.filter(t => t.status === 'Accepter').length, color: '#16A34A', bg: 'rgba(22, 163, 74, 0.1)', icon: CheckCircle },
]);

// Map a raw API ticket object to the shape expected by the template
function mapTicket(t) {
  const moduleName = t.module?.intitule_cours || t.module?.code_cours || t.cours || t.module_name || ''

  return {
    id: t.id,
    titre: t.object_ticket || t.titre || '',
    expediteur: t.expediteur || 'Étudiant',
    role: t.role || 'Délégué',
    cours: moduleName,
    description: t.description_ticket || t.description || '',
    date: t.cree_le_ticket || t.inserted_at || t.date || '',
    // calculer le statut et verrouiller si finalisé
    status: formatStatus(t.statut_ticket || t.status || 'Ouvert'),
    statut_ticket: t.statut_ticket,
    // locked indique que le ticket est finalisé (empêche changements ultérieurs)
    locked: (function(s){ return ['Accepter','Refuser','Résolu'].includes(s)})(formatStatus(t.statut_ticket || t.status || 'Ouvert')),
    responses: mapResponses(t.commentaires),
  }
}

function mapResponses(commentaires) {
  if (!commentaires || !Array.isArray(commentaires)) return []
  return commentaires.map(c => ({
    name: c.auteur_nom || 'Utilisateur',
    content: c.contenu_commentaires || '',
    time: formatTime(c.inserted_at),
    isProf: c.interne_commentaires || false,
  }))
}

// Avatar palette and deterministic color by name (copied from student Tickets design)
const avatarPalette = ['#6366f1', '#8b5cf6', '#ec4899', '#f59e0b', '#10b981', '#3b82f6', '#ef4444']
const commentAvatarColor = (name) => {
  const n = String(name || '')
  let hash = 0
  for (let i = 0; i < n.length; i++) hash = n.charCodeAt(i) + ((hash << 5) - hash)
  return avatarPalette[Math.abs(hash) % avatarPalette.length]
}

function formatStatus(raw) {
  if (!raw) return 'Ouvert'
  const s = raw.toString().toLowerCase()
  if (s.includes('en_attente') || s.includes('ouvert')) return 'Ouvert'
  if (s.includes('en_cours')) return 'En cours'
  if (s.includes('acceptee') || s.includes('accepter')) return 'Accepter'
  if (s.includes('refusee') || s.includes('refuser') || s.includes('rejetee') || s.includes('rejeter')) return 'Refuser'
  return raw
}

function formatTime(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  const diff = Math.floor((Date.now() - d.getTime()) / 1000)
  if (diff < 60) return `Il y a ${diff}s`
  const m = Math.floor(diff / 60)
  if (m < 60) return `Il y a ${m} min`
  const h = Math.floor(m / 60)
  if (h < 24) return `Il y a ${h}h`
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}

function openTicket(ticketId) {
  responseText.value = '';
  getTicket(ticketId).then((res) => {
    if (res && res.data) {
      selectedTicket.value = mapTicket(res.data)
    } else {
      selectedTicket.value = tickets.value.find(t => t.id === ticketId)
    }
  }).catch((e) => {
    selectedTicket.value = tickets.value.find(t => t.id === ticketId)
    console.debug('getTicket failed', e)
  })
}

function sendResponse() {
  if (selectedTicket.value && responseText.value.trim()) {
    const commentPayload = { commentaire: { contenu_commentaires: responseText.value, interne_commentaires: true } }
    addTicketComment(selectedTicket.value.id, commentPayload).then(() => {
      // reload ticket to get fresh comments
      getTicket(selectedTicket.value.id).then((tres) => {
        if (tres && tres.data) {
          selectedTicket.value = mapTicket(tres.data)
        }
      })
    }).catch((e) => console.debug('addTicketComment failed', e))

    // mark as pending if was in progress
    if (selectedTicket.value.status === 'En cours' || selectedTicket.value.statut_ticket === 'en_cours') {
      updateTicket(selectedTicket.value.id, { ticket: { statut_ticket: 'en_attente' } }).catch(() => {})
    }

    responseText.value = '';
  }
}

function acceptTicket(ticketId) {
  const ticket = tickets.value.find(t => t.id === ticketId)
  if (ticket) {
    // refuse/locked tickets cannot be accepted
    if (ticket.locked || ticket.status === 'Refuser') return

    ticket.status = 'Accepter'
    ticket.locked = true
    // Persist to backend
    updateTicket(ticketId, { ticket: { statut_ticket: 'acceptee' } }).catch((e) => {
      console.debug('acceptTicket API failed', e)
    })
  }
}

function refuseTicket(ticketId) {
  const ticket = tickets.value.find(t => t.id === ticketId)
  if (ticket) {
    ticket.status = 'Refuser'
    ticket.locked = true
    updateTicket(ticketId, { ticket: { statut_ticket: 'refusee' } }).catch((e) => {
      console.debug('refuseTicket API failed', e)
    })
  }
}
</script>
