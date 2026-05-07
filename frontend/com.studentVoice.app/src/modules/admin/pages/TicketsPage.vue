<template>
  <div class="flex flex-col gap-4">
    <!-- Summary Chips -->
    <div class="flex gap-2 flex-wrap">
      <button
        v-for="chip in chips"
        :key="chip.label"
        @click="filter = chip.filter"
        class="inline-flex items-center gap-1.5 px-2.5 py-1.5 sm:px-4 sm:py-2 rounded-xl transition-all text-xs sm:text-sm"
        :style="{
          background: filter === chip.filter ? chip.gradient : chip.bg,
          color: filter === chip.filter ? '#fff' : chip.color,
          fontWeight: 600,
          boxShadow: filter === chip.filter ? chip.shadow : 'none',
        }"
      >
        <span style="font-weight: 700">{{ chip.value }}</span>
        <span class="hidden sm:inline">{{ chip.label }}</span>
      </button>
    </div>

    <!-- Ticket Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-4">
      <div
        v-for="r in sortedFiltered"
        :key="r.id"
        @click="openDetail(r)"
        class="group relative bg-white dark:bg-slate-800 rounded-3xl p-5 border border-slate-200 dark:border-slate-700 transition-all duration-300 hover:shadow-xl hover:shadow-slate-200/50 dark:hover:shadow-black/50 flex flex-col h-full cursor-pointer hover:border-blue-300 dark:hover:border-blue-600/50"
      >
        <!-- Header: ticket number + title -->
        <div class="flex items-center justify-between mb-4">
          <div class="min-w-0 pr-2">
            <p class="text-[10px] px-2 py-0.5 inline-flex rounded-md font-mono font-bold bg-slate-100 dark:bg-slate-900 text-muted-foreground ring-1 ring-slate-200 dark:ring-slate-700">Ticket #{{ r.id }}</p>
            <h3 class="text-base font-bold text-slate-800 dark:text-white group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors mt-2 line-clamp-2">
              {{ r.objet }}
            </h3>
          </div>
          <span
            class="text-[10px] px-2.5 py-1 rounded-lg font-bold uppercase tracking-wider ring-1 ring-inset"
            :style="{ background: (statusConfig[r.status] && statusConfig[r.status].bg) || '#E6E7E9', color: (statusConfig[r.status] && statusConfig[r.status].color) || '#374151', '--tw-ring-color': (statusConfig[r.status] && statusConfig[r.status].color) ? statusConfig[r.status].color + '30' : '#37415130' }"
          >
            {{ r.status || 'Inconnu' }}
          </span>
        </div>

        <!-- Meta Info -->
        <div class="space-y-2.5 mb-6 flex-grow">
          <div class="flex items-center gap-2.5 text-sm text-slate-600 dark:text-slate-400">
            <div class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-900 flex items-center justify-center border border-slate-100 dark:border-slate-800">
              <User class="w-3.5 h-3.5" />
            </div>
            <div>
              <p class="text-xs text-slate-400 dark:text-slate-500">Délégué</p>
              <span class="truncate font-semibold text-slate-700 dark:text-slate-300">{{ r.delegue || 'Aucun délégué' }}</span>
            </div>
          </div>
          <div class="flex items-center gap-2.5 text-sm text-slate-600 dark:text-slate-400">
            <div class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-900 flex items-center justify-center border border-slate-100 dark:border-slate-800">
              <Users class="w-3.5 h-3.5" />
            </div>
            <div>
              <p class="text-xs text-slate-400 dark:text-slate-500">Groupe</p>
              <span class="truncate font-medium">{{ r.filiere || 'Non renseigné' }}</span>
            </div>
          </div>
          <div class="flex items-center gap-2.5 text-sm text-slate-600 dark:text-slate-400">
            <div class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-900 flex items-center justify-center border border-slate-100 dark:border-slate-800">
              <Clock class="w-3.5 h-3.5" />
            </div>
            <div>
              <p class="text-xs text-slate-400 dark:text-slate-500">Date</p>
              <span class="truncate font-medium">{{ r.date }}</span>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="pt-4 border-t border-slate-100 dark:border-slate-700/50 flex items-center justify-between">

          <div class="flex gap-2">
            <button
              @click.stop="openDetail(r)"
              class="px-4 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider text-white transition-all hover:brightness-110 active:scale-95 shadow-md shadow-blue-500/20"
              style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%)"
            >
              Voir
            </button>
            <button
              v-if="r.status === 'En attente'"
              @click.stop="openDetail(r, 'Acceptée')"
              class="px-4 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider text-white transition-all hover:brightness-110 active:scale-95 shadow-md shadow-green-500/20"
              style="background: linear-gradient(135deg, #16A34A 0%, #15803D 50%, #166534 100%)"
            >
              Accepter
            </button>
            <button
              v-if="r.status === 'En attente'"
              @click.stop="openDetail(r, 'Refusée')"
              class="px-4 py-2 rounded-xl text-[10px] font-bold uppercase tracking-wider text-white transition-all hover:brightness-110 active:scale-95 shadow-md shadow-red-500/20"
              style="background: linear-gradient(135deg, #EF4444 0%, #DC2626 50%, #B91C1C 100%)"
            >
              Refuser
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Detail Modal -->
    <div
      v-if="showModal && selected"
      class="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4"
      style="background: rgba(0,0,0,0.4)"
      @click="showModal = false; selected = null; pendingAction = null"
    >
      <div
        class="bg-card dark:bg-slate-800 rounded-3xl w-full max-w-2xl max-h-[90vh] flex flex-col shadow-2xl border border-border/50 overflow-hidden"
        @click.stop
      >
        <div class="flex items-center justify-between p-6 border-b border-border">
          <div>
            <h3 class="text-lg font-bold text-foreground">{{ selected.objet }}</h3>
            <p class="text-xs font-mono text-muted-foreground mt-0.5">{{ selected.id }}</p>
          </div>
          <button @click="showModal = false; selected = null; pendingAction = null" class="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors text-muted-foreground hover:text-foreground">✕</button>
        </div>

        <div class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-6 text-sm">
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Étudiant</p>
              <p class="text-foreground font-semibold">{{ selected.etudiant }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Filière</p>
              <p class="text-foreground font-semibold line-clamp-1">{{ selected.filiere }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Délégué</p>
              <p class="text-foreground font-semibold line-clamp-1">{{ selected.delegue || 'Aucun' }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-1">Statut</p>
              <span
                class="inline-flex text-[10px] px-2 py-0.5 rounded-full font-bold uppercase tracking-wider ring-1 ring-inset"
                :style="{ background: (statusConfig[selected.status] && statusConfig[selected.status].bg) || '#E6E7E9', color: (statusConfig[selected.status] && statusConfig[selected.status].color) || '#374151', '--tw-ring-color': (statusConfig[selected.status] && statusConfig[selected.status].color) ? statusConfig[selected.status].color + '30' : '#37415130' }"
              >
                {{ selected.status || 'Inconnu' }}
              </span>
            </div>
          </div>

          <div class="mt-6 rounded-2xl border border-slate-100 dark:border-slate-700 bg-slate-50 dark:bg-slate-900/50 p-4">
            <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-wider mb-2">Description</p>
            <p class="text-sm leading-relaxed text-foreground/80 whitespace-pre-line">
              {{ selected.description || 'Aucune description disponible.' }}
            </p>
          </div>
        </div>

        <div class="flex-1 overflow-y-auto p-6 space-y-5">
          <h4 class="text-sm font-bold text-gray-900 dark:text-white uppercase tracking-wider mb-4">Motif de décision</h4>

          <div v-if="selected.status === 'En attente'" class="rounded-2xl border border-gray-100 dark:border-slate-700 bg-gray-50/60 dark:bg-slate-900/50 p-4">
            <textarea
              v-model="motif"
              placeholder="Expliquez brièvement la raison de votre décision..."
              class="w-full p-4 rounded-2xl border border-border bg-slate-50 dark:bg-slate-900/50 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500/50 transition-all resize-none"
              rows="4"
            />
          </div>

          <div v-else class="flex flex-col items-center py-10">
            <div class="w-14 h-14 rounded-2xl bg-gray-50 flex items-center justify-center mb-3">
              <CheckCircle class="w-7 h-7 text-gray-300" />
            </div>
            <p class="text-sm text-gray-400 font-medium">Ticket déjà traité</p>
            <p class="text-xs text-gray-300 mt-1">Les actions sont désactivées</p>
          </div>
        </div>

        <div class="p-6 border-t border-border bg-card/50">
          <div class="flex gap-3">
            <button
              v-if="selected.status === 'En attente' && pendingAction === 'Acceptée'"
              @click="handleAction(selected.id, pendingAction)"
              class="flex-1 px-4 py-3 rounded-xl font-bold text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-green-500/20"
              style="background: linear-gradient(135deg, #16A34A 0%, #15803D 50%, #166534 100%)"
            >
              Confirmer l'acceptation
            </button>
            <button
              v-if="selected.status === 'En attente' && pendingAction === 'Refusée'"
              @click="handleAction(selected.id, pendingAction)"
              class="flex-1 px-4 py-3 rounded-xl font-bold text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-red-500/20"
              style="background: linear-gradient(135deg, #EF4444 0%, #DC2626 50%, #B91C1C 100%)"
            >
              Confirmer le refus
            </button>
            <button
              v-if="selected.status === 'En attente' && !pendingAction"
              @click="pendingAction = 'Acceptée'"
              class="flex-1 px-4 py-3 rounded-xl font-bold text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-green-500/20"
              style="background: linear-gradient(135deg, #16A34A 0%, #15803D 50%, #166534 100%)"
            >
              Accepter
            </button>
            <button
              v-if="selected.status === 'En attente' && !pendingAction"
              @click="pendingAction = 'Refusée'"
              class="flex-1 px-4 py-3 rounded-xl font-bold text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg shadow-red-500/20"
              style="background: linear-gradient(135deg, #EF4444 0%, #DC2626 50%, #B91C1C 100%)"
            >
              Refuser
            </button>
            <button
              v-if="selected.status === 'En attente' && pendingAction"
              @click="pendingAction = null"
              class="px-6 py-3 rounded-xl font-bold text-xs uppercase tracking-wider text-muted-foreground bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all"
            >
              Annuler choix
            </button>
            <button
              @click="showModal = false; selected = null; pendingAction = null"
              class="px-6 py-3 rounded-xl font-bold text-xs uppercase tracking-wider text-muted-foreground bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 transition-all"
            >
              Fermer
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { CheckCircle, XCircle, Clock , User, Users } from 'lucide-vue-next';
import { listTickets } from '../../../composables/useTickets'
import { decideTicket, listUsers } from '../../../composables/useAdmin'

const statusConfig = {
  'En attente': { bg: '#FEF9C3', color: '#CA8A04', icon: Clock },
  'Acceptée': { bg: '#DCFCE7', color: '#16A34A', icon: CheckCircle },
  'Refusée': { bg: '#FEE2E2', color: '#DC2626', icon: XCircle },
};

const reclamations = ref([]);

function mapTicketWithUser(t, usersById = {}) {
  const user = usersById[t.utilisateur_id]
  const delegueName =
    user?.nom ||
    user?.name ||
    user?.email ||
    t.delegue ||
    t.etudiant_nom ||
    'Délégué inconnu'

  const groupName =
    user?.filiere ||
    t.filiere ||
    t.filiere_ticket ||
    t.groupe ||
    t.groupe_nom ||
    ''

  return {
    id: t.id,
    etudiant: delegueName,
    filiere: groupName,
    objet: t.object_ticket || t.object || t.objet || '',
    date: t.cree_le_ticket || t.inserted_at || '',
    status: formatStatus(t.statut_ticket || t.status || 'en_attente'),
    description: t.description_ticket || t.description || '',
    delegue: delegueName,
  }
}

// Load tickets from backend
onMounted(async () => {
  try {
    const [ticketsRes, usersRes] = await Promise.all([listTickets(), listUsers()])
    const users = (usersRes && usersRes.data) ? usersRes.data : []
    const usersById = users.reduce((acc, u) => {
      acc[u.id] = u
      return acc
    }, {})

    if (ticketsRes && ticketsRes.data) {
      // Only show tickets destined for administration
      reclamations.value = ticketsRes.data
        .filter(t => (t.type_ticket || '').toLowerCase() === 'administration')
        .map(t => mapTicketWithUser(t, usersById))
    }
  } catch (err) {
    console.error('Failed to load admin tickets', err)
  }
})

const filter = ref('Toutes');
const selected = ref(null);
const showModal = ref(false);
const motif = ref('');
const pendingAction = ref(null);

const filtered = computed(() =>
  filter.value === 'Toutes' ? reclamations.value : reclamations.value.filter(r => r.status === filter.value)
);

const sortedFiltered = computed(() => {
  return [...filtered.value].sort((a, b) => {
    const dateA = new Date(a.date).getTime();
    const dateB = new Date(b.date).getTime();
    return dateB - dateA; // Plus récent en premier
  });
});

const chips = computed(() => [
  { label: 'Total', value: reclamations.value.length, color: '#255fe3', bg: '#DEE2F0', gradient: 'linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%)', shadow: '0 2px 8px rgba(37,95,227,0.35)', filter: 'Toutes', icon: CheckCircle },
  { label: 'En attente', value: reclamations.value.filter(r => r.status === 'En attente').length, color: '#CA8A04', bg: '#FEF9C3', gradient: 'linear-gradient(135deg, #b47d04 0%, #CA8A04 50%, #a16e03 100%)', shadow: '0 2px 8px rgba(202,138,4,0.35)', filter: 'En attente', icon: Clock },
  { label: 'Acceptées', value: reclamations.value.filter(r => r.status === 'Acceptée').length, color: '#16A34A', bg: '#DCFCE7', gradient: 'linear-gradient(135deg, #128c3e 0%, #16A34A 50%, #0f7a35 100%)', shadow: '0 2px 8px rgba(22,163,74,0.35)', filter: 'Acceptée', icon: CheckCircle },
  { label: 'Refusées', value: reclamations.value.filter(r => r.status === 'Refusée').length, color: '#DC2626', bg: '#FEE2E2', gradient: 'linear-gradient(135deg, #c41e1e 0%, #DC2626 50%, #a51b1b 100%)', shadow: '0 2px 8px rgba(220,38,38,0.35)', filter: 'Refusée', icon: XCircle },
]);

const handleAction = async (id, action) => {
  const r = reclamations.value.find(r => r.id === id);
  const actionKey = (action === 'Acceptée') ? 'accepter' : (action === 'Refusée') ? 'refuser' : null
  if (!actionKey) return

  // Optimistic UI
  if (r) r.status = action

  try {
    // call admin decide endpoint to ensure backend normalizes status and sends notifications
    await decideTicket(id, { decision: { action: actionKey, motif: motif.value || '' } })
    // reload list to get authoritative statuses
    const [ticketsRes, usersRes] = await Promise.all([listTickets(true), listUsers(true)])
    const users = (usersRes && usersRes.data) ? usersRes.data : []
    const usersById = users.reduce((acc, u) => {
      acc[u.id] = u
      return acc
    }, {})

    if (ticketsRes && ticketsRes.data) {
      reclamations.value = ticketsRes.data
        .filter(t => (t.type_ticket || '').toLowerCase() === 'administration')
        .map(t => mapTicketWithUser(t, usersById))
    }
  } catch (err) {
    console.error('Failed to update ticket status', err)
  }

  showModal.value = false;
  motif.value = '';
  selected.value = null;
  pendingAction.value = null;
};

function formatStatus(raw) {
  if (!raw) return 'En attente'
  const s = raw.toString().toLowerCase()
  if (s.includes('en_attente') || s.includes('en attente') || s === 'en_attente' || s === 'en attente') return 'En attente'
  if (s.includes('accep') || s.includes('acceptee') || s.includes('accep té')) return 'Acceptée'
  if (s.includes('refus') || s.includes('refusee')) return 'Refusée'
  // fallback: replace underscores and capitalize
  const human = raw.toString().replace(/_/g, ' ')
  return human.charAt(0).toUpperCase() + human.slice(1)
}

const openDetail = (r, action = null) => {
  selected.value = r;
  showModal.value = true;
  motif.value = '';
  pendingAction.value = action;
};
</script>
