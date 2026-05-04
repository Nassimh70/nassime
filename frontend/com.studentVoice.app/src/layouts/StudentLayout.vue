<template>
  <div class="min-h-screen flex flex-col bg-gray-50"
    style="--blue: #255fe3; --blue-dark: #1f54d2; --blue-deep: #1d3f95">
    <div class="flex w-full h-full overflow-hidden bg-gray-50">
      <!-- Sidebar -->
      <aside :class="[
        'fixed inset-y-0 left-0 z-30 transform bg-white border-r border-gray-200 flex flex-col w-72 transition-transform duration-300 ease-in-out',
        isSidebarOpen ? 'translate-x-0' : '-translate-x-full',
        'md:static md:translate-x-0 md:w-[280px] md:flex'
      ]">
        <div class="flex items-center justify-between p-6 border-b border-gray-200 md:hidden">
          <div class="flex items-center gap-3">
            <div
              class="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center text-white font-bold">
              SV</div>
            <span class="font-bold text-xl text-gray-900">StudentVoice</span>
          </div>
          <button @click="closeSidebar"
            class="inline-flex items-center justify-center w-10 h-10 rounded-xl bg-gray-100 text-gray-600 hover:bg-gray-200">
            <X class="w-5 h-5" />
          </button>
        </div>
         <div class="hidden md:block p-6 mb-2">
          <div class="flex items-center gap-3">
            <img :src="studentFavicon" alt="StudentVoice Logo" class="w-10 h-10" />
            <span class="font-bold text-xl text-gray-900">StudentVoice</span>
          </div>
        </div>



        <div class="px-4 mb-4">
          <div
            class="w-full rounded-2xl p-[1px]"
            style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%); box-shadow: 0 4px 20px rgba(37,95,227,0.35);">
            <div class="rounded-2xl px-4 py-3 flex items-center justify-between"
              style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%);">
              <!-- Left -->
              <div class="flex items-center gap-3">
                <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0"
                  style="background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.18);">
                  <User2 class="w-4 h-4 text-white/90" />
                </div>
                <div class="flex flex-col items-start gap-0.5">
                  <span class="text-[10px] uppercase tracking-widest text-white/50">Rôle actuel</span>
                  <span class="text-sm font-medium text-white">{{ isDelegate ? 'Délégué' : 'Étudiant' }}</span>
                </div>
              </div>

              <!-- Right: status indicator only -->
              <div class="flex items-center gap-2">
                <span class="w-1.5 h-1.5 rounded-full flex-shrink-0"
                  :class="isDelegate ? 'bg-yellow-400 shadow-[0_0_0_2px_rgba(250,204,21,0.3)]' : 'bg-green-400 shadow-[0_0_0_2px_rgba(74,222,128,0.3)]'"></span>
              </div>
            </div>
          </div>
        </div>


        <!-- Menu Items -->
        <nav class="flex-1 p-4 overflow-y-auto relative" ref="navContainer">
          <!-- Sliding Indicator -->
          <div
            class="absolute left-4 right-4 rounded-xl transition-all duration-300 ease-in-out top-0 pointer-events-none"
            :style="indicatorStyle"
            style="background: linear-gradient(135deg, var(--blue-dark) 0%, var(--blue) 50%, var(--blue-deep) 100%); box-shadow: 0 10px 15px -3px rgb(79 70 229 / 0.3);">
          </div>

          <div v-for="section in navSections" :key="section.section" class="mb-6 relative z-10">
            <p class="text-xs font-semibold text-gray-400 mb-3 px-3 uppercase tracking-wider">{{ section.section }}</p>
            <div class="space-y-1">
              <RouterLink v-for="item in section.items" :key="item.path" :to="item.path" :data-name="item.path"
                @click="closeSidebar"
                class="w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-colors duration-300" :class="{
                  'text-white': route.path === item.path,
                  'text-gray-600 hover:bg-gray-100 dark:hover:bg-[var(--hover)]': route.path !== item.path,
                }">
                <component :is="item.icon" class="w-5 h-5" />
                <span class="font-medium">{{ item.label }}</span>
              </RouterLink>
              <!-- Logout button in OUTILS section -->
              <button v-if="section.section === 'OUTILS'" @click="logout"
                class="w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-colors duration-300 text-red-600 hover:bg-red-50 0 dark:hover:bg-red-900">
                
                <LogOut class="w-5 h-5" />
                <span class="font-medium">Se déconnecter</span>
              </button>
            </div>
          </div>
        </nav>
      </aside>

      <!-- Main Content -->
      <main class="flex-1 flex flex-col min-w-0">
        <!-- Header -->
        <header class="bg-white border-b border-gray-200 px-4 py-3 md:px-8">
          <div class="flex items-center justify-between gap-4">
            <div class="flex items-center gap-3">
              <button @click="toggleSidebar"
                class="inline-flex items-center justify-center rounded-xl border border-gray-200 bg-white p-2 text-gray-700 shadow-sm transition hover:bg-gray-50 md:hidden"
                aria-label="Ouvrir le menu">
                <Menu class="w-5 h-5" />
              </button>
              <div>
                <h1 class="font-bold text-xl text-gray-900">{{ pageTitle.title }}</h1>
                <p class="text-sm text-gray-500" v-if="pageTitle.subtitle">{{ pageTitle.subtitle }}</p>
              </div>
            </div>

            <!-- Right: Notifications & Profile -->
            <div class="flex items-center gap-4">
              <ThemeToggle />
              <Notification />

              <RouterLink to="/student/profile" class="flex items-center gap-3 ml-2 hover:opacity-80 transition-opacity">
                <div
                  class="w-10 h-10 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0"
                  style="background: #4F5CF5">
                  {{ (user.name || '').split(' ').map(n => n ? n[0] : '').join('') }}
                </div>
                <div class="text-right">
                  <p class="font-semibold text-gray-900 dark:text-white">{{ user.name }}</p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">{{ isDelegate ? 'Délégué' : 'Étudiant' }}</p>
                </div>
              </RouterLink>
            </div>
          </div>
        </header>

        <div v-if="isSidebarOpen" class="fixed inset-0 z-20 bg-black/30 md:hidden" @click="closeSidebar"></div>

        <!-- Page Content -->
        <main class="flex-1 overflow-auto p-4 md:p-6">
          <div class="mx-auto w-full max-w-[1440px]">
            <RouterView v-slot="{ Component }">
              <transition name="page" mode="out-in">
                  <component v-if="Component" :is="Component" :key="$route.fullPath || $route.path" />
                </transition>
            </RouterView>
          </div>
        </main>
      </main>
    </div>
  </div>
</template>

<script setup>
import Notification from '../components/Notification.vue';
import ThemeToggle from '../components/ThemeToggle.vue';
import { ref, computed, watch, nextTick, onMounted, onUnmounted } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'
import {
  LayoutDashboard,
  Shield,
  User2,
  User,
  Ticket,
  ArrowUpDown,
  BookOpen,
  MessageSquare,
  Lightbulb,
  Megaphone,
  LogOut,
  Menu,
  X,
  HelpCircle,
} from 'lucide-vue-next'
import { useAuth } from '../composables/useAuth'
import studentFavicon from '../Asset/Logo_Sv.png';

const route = useRoute()
const navContainer = ref(null)
const { user, isDelegate, toggleRole, logout } = useAuth()

const isSidebarOpen = ref(false)
const indicatorStyle = ref({ opacity: 0, transform: 'translateY(0px)', height: '0px' })

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value
}

const closeSidebar = () => {
  isSidebarOpen.value = false
}

const updateIndicator = () => {
  nextTick(() => {
    if (!navContainer.value) return
    if (!route.path) {
      indicatorStyle.value = { ...indicatorStyle.value, opacity: 0 }
      return
    }
    const activeEl = navContainer.value.querySelector(`[data-name="${route.path}"]`)

    if (activeEl) {
      const containerRect = navContainer.value.getBoundingClientRect()
      const elRect = activeEl.getBoundingClientRect()
      const top = elRect.top - containerRect.top + navContainer.value.scrollTop

      indicatorStyle.value = {
        opacity: 1,
        transform: `translateY(${top}px)`,
        height: `${elRect.height}px`,
      }
    } else {
      indicatorStyle.value = { ...indicatorStyle.value, opacity: 0 }
    }
  })
}

watch(
  () => route.path,
  () => {
    updateIndicator()
    if (window.innerWidth < 768) {
      closeSidebar()
    }
  },
  { immediate: true }
)

onMounted(() => {
  window.addEventListener('resize', updateIndicator)
  setTimeout(updateIndicator, 150)
})

onUnmounted(() => {
  window.removeEventListener('resize', updateIndicator)
})

const navSections = [
  {
    section: 'MENU',
    items: [
      { label: 'Tableau de bord', icon: LayoutDashboard, path: '/student/dashboard' },
      { label: 'Réclamations & Tickets', icon: Ticket, path: '/student/tickets' },
      { label: 'Suggestions', icon: Lightbulb, path: '/student/suggestions' },
      { label: 'Annonces', icon: Megaphone, path: '/student/announcements' },
      { label: 'Progression Cours', icon: BookOpen, path: '/student/modules' },
    ],
  },
  {
    section: 'OUTILS',
    items: [
      { label: 'Profil', icon: User, path: '/student/profile' },
      { label: 'Aide', icon: HelpCircle, path: '/student/help' }
    ],
  },
]

const pageTitle = computed(() => {
  const path = route.path
  if (path === '/student' || path === '/student/' || path === '/student/dashboard') {
    const date = new Date()
    const weekDays = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    const today = `${weekDays[date.getDay()]}, ${date.getDate()} ${months[date.getMonth()]} ${date.getFullYear()}`
    return { title: 'Rapport Global', subtitle: today }
  }
  if (path === '/student/complaints') return { title: 'Réclamations & Tickets', subtitle: 'Gérez vos réclamations et demandes d\'assistance' };
  if (path === '/student/suggestions') return { title: 'Suggestions', subtitle: 'Votez et proposez des améliorations' };
  if (path === '/student/announcements') return { title: 'Annonces', subtitle: 'Publications pédagogiques' };
  if (path === '/student/modules') return { title: 'Progression Cours', subtitle: 'Suivez votre avancement pédagogique' };
  if (path === '/student/tickets') return { title: 'Réclamations & Tickets', subtitle: 'Gérez vos réclamations et demandes d\'assistance' };
  if (path === '/student/profile') return { title: 'Profil', subtitle: 'Gérez vos informations personnelles' };
  if (path === '/student/help') return { title: 'Aide', subtitle: 'Besoin d\'aide ?' };
  return { title: 'StudentVoice', subtitle: '' };
})
</script>

<style scoped>
.page-enter-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.page-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateY(12px);
}

.page-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>