<template>
  <div class="flex flex-col 2xl:flex-row gap-6 h-full" style="--blue: #255fe3; --blue-dark: #1f54d2; --blue-deep: #1d3f95">
    <!-- Left Column -->
    <div class="flex-1 flex flex-col gap-6 min-w-0">
      <!-- Stats Cards - 4 columns -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <!-- Total Réclamations (blue) -->
        <div
          class="relative rounded-2xl p-6 text-white shadow-xl shadow-indigo-600/30 total-reclamations-bg"
        >
          <!-- Icon & Badge -->
          <div class="flex items-start justify-between mb-4">
            <div class="p-3 rounded-xl bg-white/10">
              <FileText class="w-6 h-6 text-white" /> 
            </div>
            <span class="px-3 py-1 rounded-full text-xs font-semibold bg-green-500 text-white">{{ stats[0].change }}</span>
          </div>
          <!-- Content -->
          <div>
            <p class="text-sm font-medium mb-2 text-white/80">{{ stats[0].title }}</p>
            <h3 class="text-3xl font-bold mb-1 text-white">{{ stats[0].value }}</h3>
            <p class="text-xs text-white/60">{{ stats[0].subtitle }}</p>
          </div>
        </div>

        <!-- Réclamations Résolues -->
        <div class="relative rounded-2xl p-6 bg-white border border-gray-200">
          <!-- Icon & Badge -->
          <div class="flex items-start justify-between mb-4">
            <div class="p-3 rounded-xl bg-gray-100">
              <CheckCircle class="w-6 h-6 text-gray-600" />
            </div>
            <span class="px-3 py-1 rounded-full text-xs font-semibold bg-green-500 text-white">{{ stats[1].change }}</span>
          </div>
          <!-- Content -->
          <div>
            <p class="text-sm font-medium mb-2 text-gray-600">{{ stats[1].title }}</p>
            <h3 class="text-3xl font-bold mb-1 text-gray-900">{{ stats[1].value }}</h3>
            <p class="text-xs text-gray-500">{{ stats[1].subtitle }}</p>
          </div>
        </div>

        <!-- Étudiants Actifs -->
        <div class="relative rounded-2xl p-6 bg-white border border-gray-200">
          <!-- Icon & Badge -->
          <div class="flex items-start justify-between mb-4">
            <div class="p-3 rounded-xl bg-gray-100">
              <Users class="w-6 h-6 text-gray-600" />
            </div>
            <span class="px-3 py-1 rounded-full text-xs font-semibold bg-red-500 text-white">{{ stats[2].change }}</span>
          </div>
          <!-- Content -->
          <div>
            <p class="text-sm font-medium mb-2 text-gray-600">{{ stats[2].title }}</p>
            <h3 class="text-3xl font-bold mb-1 text-gray-900">{{ stats[2].value }}</h3>
            <p class="text-xs text-gray-500">{{ stats[2].subtitle }}</p>
          </div>
        </div>

        <!-- Tickets Soumis -->
        <div class="relative rounded-2xl p-6 bg-white border border-gray-200">
          <!-- Icon & Badge -->
          <div class="flex items-start justify-between mb-4">
            <div class="p-3 rounded-xl bg-gray-100">
              <Ticket class="w-6 h-6 text-gray-600" />
            </div>
            <span class="px-3 py-1 rounded-full text-xs font-semibold bg-green-500 text-white">{{ stats[3].change }}</span>
          </div>
          <!-- Content -->
          <div>
            <p class="text-sm font-medium mb-2 text-gray-600">{{ stats[3].title }}</p>
            <h3 class="text-3xl font-bold mb-1 text-gray-900">{{ stats[3].value }}</h3>
            <p class="text-xs text-gray-500">{{ stats[3].subtitle }}</p>
          </div>
        </div>
      </div>

      <!-- Bubble / Category Distribution Card -->
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
          <div>
            <h2 class="text-xl font-bold text-gray-900">Répartition par Catégorie</h2>
            <p class="text-sm text-gray-500 mt-1">Réclamations par catégorie</p>
          </div>
        </div>

        <!-- Bubble Chart -->
        <div v-if="complaintsByCategory.length" class="flex flex-col sm:flex-row items-center gap-6">
          <!-- SVG Bubbles -->
          <div class="flex-shrink-0">
            <svg width="240" height="200" viewBox="0 0 240 200">
              <!-- Informatique -->
              <circle cx="130" cy="75" r="55" :fill="getCategoryColor(complaintsByCategory[0].category)" opacity="0.9" />
              <text x="130" y="70" text-anchor="middle" fill="white" font-size="13" font-weight="700">{{ complaintsByCategory[0].count }}</text>
              <text x="130" y="86" text-anchor="middle" fill="rgba(255,255,255,0.8)" font-size="10">{{ complaintsByCategory[0].category }}</text>

              <!-- Mathématiques -->
              <circle cx="65" cy="125" r="50" :fill="getCategoryColor(complaintsByCategory[1].category)" opacity="0.85" />
              <text x="65" y="120" text-anchor="middle" fill="white" font-size="12" font-weight="700">{{ complaintsByCategory[1].count }}</text>
              <text x="65" y="135" text-anchor="middle" fill="rgba(255,255,255,0.8)" font-size="10">{{ complaintsByCategory[1].category }}</text>

              <!-- Sciences -->
              <circle cx="185" cy="135" r="38" :fill="getCategoryColor(complaintsByCategory[2].category)" opacity="0.85" />
              <text x="185" y="130" text-anchor="middle" fill="white" font-size="11" font-weight="700">{{ complaintsByCategory[2].count }}</text>
              <text x="185" y="144" text-anchor="middle" fill="rgba(255,255,255,0.8)" font-size="9">{{ complaintsByCategory[2].category }}</text>
            </svg>
          </div>

          <!-- Legend -->
          <div class="flex flex-col gap-4">
            <div
              v-for="item in complaintsByCategory"
              :key="item.category"
              class="flex items-center gap-3"
            >
              <div class="flex flex-col gap-1">
                <span class="text-sm font-medium text-gray-900">{{ item.category }}</span>
                <div class="h-1 rounded-full" :style="{ backgroundColor: getCategoryColor(item.category), width: '40px' }" />
              </div>
            </div>
          </div>
        </div>
        <div v-else class="py-8 text-center text-sm text-gray-500">
          Aucune donnée de catégorie disponible.
        </div>
      </div>
    </div>

    <!-- Right Column -->
    <div class="w-full lg:w-[380px] flex-shrink-0 flex flex-col gap-6">
      <!-- Status Pie Chart -->
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <div class="text-center mb-6">
          <h2 class="text-xl font-bold text-gray-900">Statistiques des Réclamations</h2>
          <p class="text-sm text-gray-500 mt-1">États de traitement</p>
        </div>

        <div class="flex flex-col items-center mb-4">
          <div class="px-4 py-2 bg-indigo-50 rounded-full border border-indigo-100 flex items-center gap-2 shadow-sm">
            <span class="text-xs text-indigo-700 uppercase tracking-widest font-bold">Total Réclamations</span>
            <span class="text-xl font-black text-indigo-600">{{ totalComplaints }}</span>
          </div>
        </div>

        <div class="flex items-center justify-center mb-8 relative h-[220px]">
          <svg width="200" height="200" viewBox="0 0 200 200" class="transform -rotate-90">
            <defs>
              <linearGradient id="greenGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" style="stop-color: #22c55e; stop-opacity:1" />
                <stop offset="100%" style="stop-color: #16a34a; stop-opacity:1" />
              </linearGradient>
              <linearGradient id="redGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" style="stop-color: #ef4444; stop-opacity:1" />
                <stop offset="100%" style="stop-color: #dc2626; stop-opacity:1" />
              </linearGradient>
            </defs>
            <!-- Background circles -->
            <circle cx="100" cy="100" r="85" fill="none" stroke="#f3f4f6" stroke-width="12" />
            <circle cx="100" cy="100" r="70" fill="none" stroke="#f3f4f6" stroke-width="12" />
            
            <!-- Data circles -->
            <circle
              cx="100"
              cy="100"
              r="85"
              fill="none"
              stroke="url(#greenGradient)"
              stroke-width="12"
              stroke-dasharray="534"
              :stroke-dashoffset="getDashOffset(85, getTicketPercentage('Accept', 'Résolu'))"
              stroke-linecap="round"
            />
            <circle
              cx="100"
              cy="100"
              r="70"
              fill="none"
              stroke="url(#redGradient)"
              stroke-width="12"
              stroke-dasharray="440"
              :stroke-dashoffset="getDashOffset(70, getTicketPercentage('Refus', 'Rejet'))"
              stroke-linecap="round"
            />
          </svg>

          <div class="absolute inset-0 flex flex-col items-center justify-center">
            <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold mb-1">
              {{ getTicketPercentage('Accept', 'Résolu') }}% Acc.
            </span>
            <span class="px-2 py-0.5 bg-red-100 text-red-700 rounded-full text-[10px] font-semibold">
              {{ getTicketPercentage('Refus', 'Rejet') }}% Ref.
            </span>
          </div>
        </div>

        <div class="space-y-3">
          <div class="flex items-center justify-between p-2 rounded-lg hover:bg-gray-50 transition-colors">
            <div class="flex items-center gap-3">
              <div class="w-3 h-3 rounded-full bg-green-500"></div>
              <span class="text-sm font-medium text-gray-900">Acceptés / Résolus</span>
            </div>
            <span class="text-lg font-bold text-gray-900">{{ getTicketCount('Accept', 'Résolu') }}</span>
          </div>
          
          <div class="flex items-center justify-between p-2 rounded-lg hover:bg-gray-50 transition-colors">
            <div class="flex items-center gap-3">
              <div class="w-3 h-3 rounded-full bg-red-500"></div>
              <span class="text-sm font-medium text-gray-900">Refusés / Rejetés</span>
            </div>
            <span class="text-lg font-bold text-gray-900">{{ getTicketCount('Refus', 'Rejet') }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  FileText,
  CheckCircle,
  Users,
  Ticket,
} from 'lucide-vue-next'
import { ticketsStats, listTickets } from '../composables/useTickets'
import { adminTicketsStats } from '../composables/useAdmin'
import { listUsers } from '../composables/useAdmin'
import { useAuth } from '../composables/useAuth'

const stats = ref([
  { title: 'Total Réclamations', value: '—', subtitle: 'ce mois dernier', change: '—' },
  { title: 'Réclamations Résolues', value: '—', subtitle: 'résolues ce mois', change: '—' },
  { title: 'Étudiants Actifs', value: '—', subtitle: 'utilisateurs actifs', change: '—' },
  { title: 'Tickets Soumis', value: '—', subtitle: 'tickets ce mois', change: '—' },
])

const complaintsByStatus = ref([
  { status: 'Acceptées', count: 0, color: 'bg-indigo-600', percentage: 0 },
  { status: 'Refusées', count: 0, color: 'bg-red-500', percentage: 0 },
  { status: 'En attente', count: 0, color: 'bg-gray-300', percentage: 0 },
])

const complaintsByCategory = ref([])

const totalComplaints = computed(() => complaintsByStatus.value.reduce((sum, item) => sum + (item.count || 0), 0))

const circumference = 2 * Math.PI * 70

const getCategoryColor = (category) => {
  const colors = {
    'Informatique': '#1d3f95',
    'Mathématiques': '#1f54d2',
    'Sciences': '#255fe3',
  }
  return colors[category] || '#255fe3'
}

async function loadData() {
  try {
    // Get current user role
    const { user } = useAuth()
    const r = user && user.value && user.value.role
    let role = ''
    if (!r) role = ''
    else if (typeof r === 'string') role = r
    else if (r.nom_roles) role = r.nom_roles
    else if (r.name) role = r.name
    role = (role || '').toString().toLowerCase()

    console.debug('[Dashboard] detected role:', role)
    
    // Load tickets for everyone
    try {
      const ticketsRes = await listTickets()
      if (ticketsRes && ticketsRes.data) {
        const tickets = ticketsRes.data
        complaints.value = tickets
        
        // Count total tickets
        const totalCount = tickets.length
        stats.value[0].value = totalCount
        stats.value[3].value = totalCount
        
        // Count by status
        let accepteeCount = 0
        let refuseeCount = 0
        let enAttenteCount = 0
        
        tickets.forEach((t) => {
          const status = (t.statut_ticket || '').toLowerCase()
          if (status.includes('accept') || status.includes('résolu')) accepteeCount++
          else if (status.includes('refus') || status.includes('rejet')) refuseeCount++
          else enAttenteCount++
        })
        
        stats.value[1].value = accepteeCount
        
        complaintsByStatus.value = [
          { status: 'Acceptées', count: accepteeCount, color: 'bg-indigo-600', percentage: 0 },
          { status: 'Refusées', count: refuseeCount, color: 'bg-red-500', percentage: 0 },
          { status: 'En attente', count: enAttenteCount, color: 'bg-gray-300', percentage: 0 },
        ]
        
        // Compute percentages
        const total = complaintsByStatus.value.reduce((m, it) => m + it.count, 0) || 1
        complaintsByStatus.value.forEach((it) => (it.percentage = Math.round((it.count / total) * 100)))
        
        // Categories
        const byCat = {}
        tickets.forEach((t) => {
          const cat = t.categorie_ticket || 'Autre'
          byCat[cat] = (byCat[cat] || 0) + 1
        })
        complaintsByCategory.value = Object.entries(byCat).map(([category, count]) => ({ category, count }))
        
        // Ensure at least 3 entries
        while (complaintsByCategory.value.length < 3) {
          complaintsByCategory.value.push({ category: 'Autre', count: 0 })
        }
      }
    } catch (e) {
      console.warn('Failed to load tickets', e)
    }
    
    // Admin-specific stats
    if (role === 'admin' || role === 'administration') {
      try {
        const usersRes = await listUsers()
        if (usersRes && usersRes.data) {
          stats.value[2].value = usersRes.data.length
        }
      } catch (e) {
        console.warn('Failed to load users for dashboard', e)
      }
    }
  } catch (err) {
    console.error('Failed to load dashboard data', err)
  }
}

const complaints = ref([])

function getTicketCount(...statusList) {
  if (!complaints.value) return 0
  return complaints.value.filter(t => {
    const s = (t.statut_ticket || '').toLowerCase()
    return statusList.some(status => s.includes(status.toLowerCase()))
  }).length
}

function getTicketPercentage(...statusList) {
  if (!complaints.value) return 0
  const total = complaints.value.length
  if (total === 0) return 0
  const count = getTicketCount(...statusList)
  return Math.round((count / total) * 100)
}

function getDashOffset(radius, percentage) {
  const circumference = 2 * Math.PI * radius
  return circumference - (percentage / 100) * circumference
}

onMounted(() => {
  loadData()
})

// template reactive variables are declared above and filled by loadData
</script>

<style scoped>
.total-reclamations-bg {
  background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%);
}

.legend-resolues {
  background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%);
}
</style>