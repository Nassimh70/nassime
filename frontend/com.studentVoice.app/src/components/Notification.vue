<template>
  <div class="relative" ref="wrapper">
    <!-- Bouton cloche -->
    <button
      @click="togglePanel"
      class="p-2.5 rounded-lg hover:bg-gray-100 dark:hover:bg-var(--hover) "
    >
      <Bell class="w-5 h-5 text-gray-600 dark:text-gray-400" />
      <span
        v-if="unreadCount > 0"
        class="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"
      ></span>
    </button>

    <!-- Panneau notifications -->
    <Transition name="notif">
      <div
        v-if="isOpen"
        class="fixed top-16 left-3 right-3 w-auto max-w-[calc(100vw-1.5rem)] bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-700 shadow-lg dark:shadow-2xl z-50 overflow-hidden sm:absolute sm:top-auto sm:left-auto sm:right-0 sm:mt-2 sm:w-80 sm:max-w-none"
      >
        <!-- En-tête -->
        <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100 dark:border-gray-700">
          <h3 class="text-sm font-semibold text-gray-800 dark:text-gray-100">
            Notifications
            <span
              v-if="unreadCount > 0"
              class="ml-2 text-xs bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 px-2 py-0.5 rounded-full"
            >{{ unreadCount }}</span>
          </h3>
          <button
            v-if="unreadCount > 0"
            @click="markAllRead"
            class="text-xs text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors"
          >
            Tout marquer lu
          </button>
        </div>

        <!-- Liste des notifications -->
        <div class="max-h-80 overflow-y-auto">
          <div v-if="notifications.length === 0" class="py-10 text-center text-sm text-gray-400 dark:text-gray-500">
            Aucune notification
          </div>
          <div
            v-for="notif in notifications"
            :key="notif.id"
            @click="markRead(notif.id)"
            class="flex gap-3 px-4 py-3 cursor-pointer border-b border-gray-50 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            :class="{ 'bg-blue-50 dark:bg-blue-900/20 hover:bg-blue-50 dark:hover:bg-blue-900/20': notif.unread }"
          >
            <!-- Icône -->
            <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0"
              :class="notif.iconBg">
              <component :is="notif.icon" class="w-4 h-4" :class="notif.iconColor" />
            </div>

            <!-- Contenu -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between gap-2">
                <span class="text-xs font-medium" :class="notif.typeColor">{{ notif.type }}</span>
                <span v-if="notif.unread" class="w-1.5 h-1.5 rounded-full bg-blue-500 flex-shrink-0"></span>
              </div>
              <p class="text-xs text-gray-700 dark:text-gray-300 mt-0.5 truncate">{{ notif.message }}</p>
              <p class="text-xs text-gray-400 dark:text-gray-500 mt-1">{{ notif.time }}</p>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { Bell, FileText, CheckCircle, Ticket, AlertTriangle, User, Lightbulb, Megaphone } from 'lucide-vue-next'
import { getNotifications } from '../composables/useNotifications'
import { useAuth } from '../composables/useAuth'

// Get user role
const { user } = useAuth()

// ─── État ───────────────────────────────────────────────
const isOpen = ref(false)
const wrapper = ref(null)

// ─── Données (récupérées depuis l'API) ──────────
const notifications = ref([])

// map types -> icons & colors (ajouter d'autres mappings si besoin)
const TYPE_MAP = {
  decision_ticket: { icon: CheckCircle, iconBg: 'bg-green-100', iconColor: 'text-green-600', typeColor: 'text-green-600', label: 'Décision' },
  ticket: { icon: Ticket, iconBg: 'bg-amber-100', iconColor: 'text-amber-600', typeColor: 'text-amber-600', label: 'Ticket' },
  reclamation: { icon: FileText, iconBg: 'bg-blue-100', iconColor: 'text-blue-600', typeColor: 'text-blue-600', label: 'Réclamation' },
  urgent: { icon: AlertTriangle, iconBg: 'bg-red-100', iconColor: 'text-red-600', typeColor: 'text-red-600', label: 'Urgent' },
  delegue: { icon: User, iconBg: 'bg-purple-100', iconColor: 'text-purple-600', typeColor: 'text-purple-600', label: 'Délégué' },
  nouvelle_souggestion: { icon: Lightbulb, iconBg: 'bg-purple-100', iconColor: 'text-purple-600', typeColor: 'text-purple-600', label: 'Suggestion' },
  annonce_publie: { icon: Megaphone, iconBg: 'bg-blue-100', iconColor: 'text-blue-600', typeColor: 'text-blue-600', label: 'Annonce' },
}

function humanizeTime(dateString) {
  if (!dateString) return ''
  const d = new Date(dateString)
  const diff = Math.floor((Date.now() - d.getTime()) / 1000)
  if (diff < 60) return `Il y a ${diff} s`
  const m = Math.floor(diff / 60)
  if (m < 60) return `Il y a ${m} min`
  const h = Math.floor(m / 60)
  if (h < 24) return `Il y a ${h} h`
  const days = Math.floor(h / 24)
  return `Il y a ${days} j`
}

async function loadNotifications() {
  try {
    const res = await getNotifications()
    let list = (res && res.data) || []
    
    // Get user role
    const userRole = user.value && user.value.role
    const roleLower = (userRole || '').toString().toLowerCase()
    
    // Filter out suggestion notifications for professors and admins
    if (roleLower === 'professeur' || roleLower === 'admin' || roleLower === 'administrateur') {
      list = list.filter(n => {
        const type = (n.type_notifications || '').toLowerCase()
        return type !== 'nouvelle_souggestion' && type !== 'nouvelle_suggestion'
      })
    }

    list = list.filter(n => (n.type_notifications || '').toLowerCase() !== 'decision_ticket_broadcast')

    // Récupérer les identifiants des notifications déjà lues depuis localStorage
    const readIds = JSON.parse(localStorage.getItem('read_notifications') || '[]')

    notifications.value = list.map(n => {
      const key = (n.type_notifications || '').toLowerCase()
      const map = TYPE_MAP[key] || { icon: FileText, iconBg: 'bg-gray-100', iconColor: 'text-gray-600', typeColor: 'text-gray-600', label: n.type_notifications || 'Info' }
      return {
        id: n.id,
        type: map.label,
        message: n.message_notifications || n.message || '',
        time: humanizeTime(n.inserted_at || n.cree_le_notifications),
        unread: !readIds.includes(n.id),
        icon: map.icon,
        iconBg: map.iconBg,
        iconColor: map.iconColor,
        typeColor: map.typeColor,
        raw: n,
      }
    })
  } catch (err) {
    console.error('Erreur récupération notifications', err)
    // fallback: garder liste vide
    // notifications.value = []
  }
}

// ─── Computed ──────────────────────────────────────────
const unreadCount = computed(() =>
  notifications.value.filter(n => n.unread).length
)

// ─── Actions ───────────────────────────────────────────
function togglePanel() {
  isOpen.value = !isOpen.value
}

function markRead(id) {
  const notif = notifications.value.find(n => n.id === id)
  if (notif) {
    notif.unread = false
    const readIds = JSON.parse(localStorage.getItem('read_notifications') || '[]')
    if (!readIds.includes(id)) {
      readIds.push(id)
      localStorage.setItem('read_notifications', JSON.stringify(readIds))
    }
  }
}

function markAllRead() {
  const readIds = JSON.parse(localStorage.getItem('read_notifications') || '[]')
  notifications.value.forEach(n => {
    n.unread = false
    if (!readIds.includes(n.id)) {
      readIds.push(n.id)
    }
  })
  localStorage.setItem('read_notifications', JSON.stringify(readIds))
}

// ─── Fermer en cliquant à l'extérieur ─────────────────
function handleOutsideClick(e) {
  if (wrapper.value && !wrapper.value.contains(e.target)) {
    isOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleOutsideClick)
  loadNotifications()
  
  // Poll notifications every 15 seconds
  const interval = setInterval(loadNotifications, 15000)
  
  // Listen for refresh event from tickets page
  window.addEventListener('refresh-notifications', () => {
    loadNotifications()
  })
  
  onBeforeUnmount(() => {
    clearInterval(interval)
    window.removeEventListener('refresh-notifications', loadNotifications)
  })
})
onBeforeUnmount(() => document.removeEventListener('click', handleOutsideClick))
</script>

<style scoped>
/* Animation d'entrée/sortie du panneau */
.notif-enter-active,
.notif-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}
.notif-enter-from,
.notif-leave-to {
  opacity: 0;
  transform: translateY(-6px) scale(0.98);
}
</style>