<template>
  <div class="flex flex-col lg:flex-row gap-6 h-full" style="--blue: #255fe3; --blue-dark: #1f54d2; --blue-deep: #1d3f95">
    <!-- Left Column -->
    <div class="flex-1 flex flex-col gap-6 min-w-0">
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div
          v-for="(stat, index) in stats"
          :key="index"
          :class="[
            'relative rounded-2xl p-6',
            stat.color === 'indigo'
              ? 'text-white shadow-xl shadow-indigo-600/30 total-reclamations-bg'
              : 'bg-white border border-gray-200'
          ]"
        >
          <div class="flex items-start justify-between mb-4">
            <div
              :class="[
                'p-3 rounded-xl',
                stat.color === 'indigo' ? 'bg-white/10' : 'bg-gray-100'
              ]"
            >
              <component
                :is="stat.icon"
                :class="[
                  'w-6 h-6',
                  stat.color === 'indigo' ? 'text-white' : 'text-gray-600'
                ]"
              />
            </div>
            <span
              :class="[
                'px-3 py-1 rounded-full text-xs font-semibold',
                stat.changeType === 'positive'
                  ? 'bg-green-500 text-white'
                  : 'bg-red-500 text-white'
              ]"
            >
              {{ stat.change }}
            </span>
          </div>

          <div>
            <p
              :class="[
                'text-sm font-medium mb-2',
                stat.color === 'indigo' ? 'text-white/80' : 'text-gray-600'
              ]"
            >
              {{ stat.title }}
            </p>
            <h3
              :class="[
                'text-3xl font-bold mb-1',
                stat.color === 'indigo' ? 'text-white' : 'text-gray-900'
              ]"
            >
              {{ stat.value }}
            </h3>
            <p
              :class="[
                'text-xs',
                stat.color === 'indigo' ? 'text-white/60' : 'text-gray-500'
              ]"
            >
              {{ stat.subtitle }}
            </p>
          </div>
        </div>
      </div>

 
      <!-- Recent Tickets -->
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
          <div>
            <h2 class="text-xl font-bold text-gray-900">Tickets Récents</h2>
            <p class="text-sm text-gray-500 mt-1">Questions et demandes des étudiants</p>
          </div>

          <RouterLink
            to="/prof/tickets"
            class="px-4 py-2 text-white rounded-lg text-sm hover:bg-gray-100 dark:hover:bg-var(--hover) "
            style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%); --blue: #255fe3; --blue-dark: #1f54d2; --blue-deep: #1d3f95; font-weight: 600"
          >
            Voir tout
          </RouterLink>
        </div>

        <div class="space-y-3">
          <div
            v-for="ticket in tickets"
            :key="ticket.id"
            :class="[
              'p-4 rounded-xl border-l-4 bg-gray-50 hover:bg-gray-100 transition-colors cursor-pointer',
              getPriorityColor(ticket.priority)
            ]"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-2">
                  <span class="text-xs font-semibold text-indigo-600">{{ ticket.referance_ticket || ticket.id }}</span>
                  <span class="text-xs text-gray-400">•</span>
                  <span class="text-xs text-gray-600">{{ ticket.expediteur }}</span>
                  <span class="text-xs text-gray-400">•</span>
                  <span class="text-xs text-gray-500 line-clamp-1">{{ ticket.module?.intitule_cours || ticket.module?.code_cours }}</span>
                </div>
                <h4 class="font-semibold text-gray-900 mb-2">{{ ticket.object_ticket || ticket.titre }}</h4>
                <div class="flex items-center gap-2">
                  <span
                    :class="[
                      'inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium',
                      getStatusColor(ticket.statut_ticket || ticket.status)
                    ]"
                  >
                    <component :is="getStatusIcon(ticket.statut_ticket || ticket.status)" class="w-3 h-3" />
                    <span class="capitalize">{{ (ticket.statut_ticket || ticket.status || 'Ouvert').replace('_', ' ') }}</span>
                  </span>
                  <span class="text-xs text-gray-500">Il y a {{ formatTime(ticket.cree_le_ticket || ticket.date) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Column -->
    <div class="w-full lg:w-[380px] flex-shrink-0 flex flex-col gap-6">
      <!-- Course Progress -->
      <div class="bg-white rounded-2xl p-6 border border-gray-200">
        <div class="text-center mb-6">
          <h2 class="text-xl font-bold text-gray-900">Statistiques des Réclamations</h2>
          <p class="text-sm text-gray-500 mt-1">États de traitement</p>
        </div>

        <div class="flex flex-col items-center mb-4">
          <div class="px-4 py-2 bg-indigo-50 rounded-full border border-indigo-100 flex items-center gap-2 shadow-sm">
            <span class="text-xs text-indigo-700 uppercase tracking-widest font-bold">Total Réclamations</span>
            <span class="text-xl font-black text-indigo-600">{{ tickets.length }}</span>
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
              <linearGradient id="blueGradient2" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" style="stop-color: #3b82f6; stop-opacity:1" />
                <stop offset="100%" style="stop-color: #2563eb; stop-opacity:1" />
              </linearGradient>
              <linearGradient id="orangeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" style="stop-color: #f97316; stop-opacity:1" />
                <stop offset="100%" style="stop-color: #ea580c; stop-opacity:1" />
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
              :stroke-dashoffset="getDashOffset(85, getTicketPercentage('acceptee', 'resolu', 'accepte'))"
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
              :stroke-dashoffset="getDashOffset(70, getTicketPercentage('refusee', 'rejete', 'refuse'))"
              stroke-linecap="round"
            />
          </svg>

          <div class="absolute inset-0 flex flex-col items-center justify-center">
            <span class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-semibold mb-1">
              {{ getTicketPercentage('acceptee', 'resolu', 'accepte') }}% Acc.
            </span>
            <span class="px-2 py-0.5 bg-red-100 text-red-700 rounded-full text-[10px] font-semibold">
              {{ getTicketPercentage('refusee', 'rejete', 'refuse') }}% Ref.
            </span>
          </div>
        </div>

        <div class="space-y-3">
          <div class="flex items-center justify-between p-2 rounded-lg hover:bg-gray-50 transition-colors">
            <div class="flex items-center gap-3">
              <div class="w-3 h-3 rounded-full bg-green-500"></div>
              <span class="text-sm font-medium text-gray-900">Acceptés / Résolus</span>
            </div>
            <span class="text-lg font-bold text-gray-900">{{ getTicketCount('acceptee', 'resolu', 'accepte') }}</span>
          </div>
          
          <div class="flex items-center justify-between p-2 rounded-lg hover:bg-gray-50 transition-colors">
            <div class="flex items-center gap-3">
              <div class="w-3 h-3 rounded-full bg-red-500"></div>
              <span class="text-sm font-medium text-gray-900">Refusés / Rejetés</span>
            </div>
            <span class="text-lg font-bold text-gray-900">{{ getTicketCount('refusee', 'rejete', 'refuse') }}</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import {
  Users,
  BookOpen,
  FileCheck,
  TrendingUp,
  MessageSquare,
  Clock,
  CheckCircle,
  AlertCircle,
} from 'lucide-vue-next'
import { onMounted, ref } from 'vue'
import { professeurModulesProgress } from '../../../composables/useModules'
import { listTicketsForProf, ticketsStats } from '../../../composables/useTickets'

import { RouterLink } from 'vue-router'




const stats = ref([])

const tickets = ref([])

function getStatusColor(status) {
  if (!status) return 'bg-gray-100 text-gray-700'
  const s = status.toString().toLowerCase()
  if (s.includes('attente') || s.includes('ouvert')) return 'bg-orange-100 text-orange-700'
  if (s.includes('cours')) return 'bg-blue-100 text-blue-700'
  if (s.includes('accepte') || s.includes('resolu')) return 'bg-green-100 text-green-700'
  if (s.includes('refuse') || s.includes('rejete')) return 'bg-red-100 text-red-700'
  return 'bg-gray-100 text-gray-700'
}

function getStatusIcon(status) {
  if (!status) return MessageSquare
  const s = status.toString().toLowerCase()
  if (s.includes('attente') || s.includes('ouvert')) return AlertCircle
  if (s.includes('cours')) return Clock
  if (s.includes('accepte') || s.includes('resolu')) return CheckCircle
  return MessageSquare
}

function formatTime(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  const diff = Math.floor((Date.now() - d.getTime()) / 1000)
  if (diff < 60) return `${diff}s`
  const m = Math.floor(diff / 60)
  if (m < 60) return `${m} min`
  const h = Math.floor(m / 60)
  if (h < 24) return `${h}h`
  return d.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}

function getTicketCount(...statusList) {
  return tickets.value.filter(t => {
    const s = (t.statut_ticket || t.status || '').toLowerCase()
    return statusList.some(status => s.includes(status))
  }).length
}

function getTicketPercentage(...statusList) {
  const total = tickets.value.length
  if (total === 0) return 0
  const count = getTicketCount(...statusList)
  return Math.round((count / total) * 100)
}

function getDashOffset(radius, percentage) {
  const circumference = 2 * Math.PI * radius
  return circumference - (percentage / 100) * circumference
}

function getPriorityColor(priority) {
  switch (priority) {
    case 'haute':
      return 'border-l-red-500'
    case 'moyenne':
      return 'border-l-yellow-500'
    case 'basse':
      return 'border-l-green-500'
    default:
      return 'border-l-gray-300'
  }
}

const courses = ref([])

onMounted(async () => {
  try {
    const mres = await professeurModulesProgress()
    if (mres && mres.data) {
      courses.value = mres.data.map((r) => ({ name: (r.module && r.module.intitule_cours) || 'Cours', students: r.students_count || 0, change: '', trend: r.avancement_pourcentage >= 50 ? 'up' : 'down', color: 'indigo' }))
    }
  } catch (e) {
    console.debug('professeurModulesProgress error', e)
  }

  try {
    const tres = await listTicketsForProf()
    if (tres && tres.data) tickets.value = tres.data
  } catch (e) {
    console.debug('listTicketsForProf failed', e)
  }

  try {
    const sres = await ticketsStats()
    if (sres && sres.data) {
      stats.value = [
        { icon: Users, title: 'Total Tickets', value: sres.data.total || 0, change: '', changeType: 'positive', subtitle: 'Tickets', color: 'indigo' },
        { icon: BookOpen, title: 'En attente', value: sres.data.en_attente || 0, change: '', changeType: 'positive', subtitle: '', color: 'white' },
        { icon: TrendingUp, title: 'En cours', value: sres.data.en_cours || 0, change: '', changeType: 'negative', subtitle: '', color: 'white' },
        { icon: FileCheck, title: 'Résolus', value: sres.data.acceptee || 0, change: '', changeType: 'positive', subtitle: '', color: 'white' },
      ]
    }
  } catch (e) {
    console.debug('ticketsStats failed', e)
    // keep default empty stats
  }
})
</script>

<style scoped>
.total-reclamations-bg {
  background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%);
}

.legend-resolues {
  background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%);
}
</style>

