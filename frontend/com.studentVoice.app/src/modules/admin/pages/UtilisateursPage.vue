<template>
  <div class="flex flex-col gap-4">
    <!-- Toast notification -->
    <Transition name="toast">
      <div
        v-if="toast.show"
        class="fixed top-6 right-6 z-50 flex items-center gap-3 px-5 py-3 rounded-xl shadow-2xl text-sm font-medium"
        :style="{
          background: toast.type === 'success' ? 'linear-gradient(135deg, #10b981, #059669)' : 'linear-gradient(135deg, #ef4444, #dc2626)',
          color: '#fff'
        }"
      >
        <CheckCircle v-if="toast.type === 'success'" class="w-5 h-5" />
        <AlertCircle v-else class="w-5 h-5" />
        <span>{{ toast.message }}</span>
      </div>
    </Transition>

    <!-- Role Summary -->
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3">
      <div v-for="[role, cfg] in Object.entries(roleConfig)" :key="role"
        class="rounded-2xl p-4 flex items-center gap-3 cursor-pointer transition-all hover:shadow-md bg-white dark:bg-slate-800 border border-transparent dark:border-slate-700"
        style="box-shadow: 0 2px 12px rgba(0,0,0,0.06)" @click="roleFilter = role">
        <div class="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" :style="{ background: cfg.bg }">
          <component :is="cfg.icon" class="w-4 h-4" :style="{ color: cfg.color }" />
        </div>
        <div>
          <p class="text-xl font-bold leading-none text-slate-800 dark:text-white">{{ usersArray.filter(u => u.role === role).length }}</p>
          <p class="text-xs text-slate-400 dark:text-slate-500 mt-1">{{ role }}s</p>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="rounded-2xl overflow-hidden bg-white dark:bg-slate-800 shadow-sm border border-gray-100 dark:border-slate-700">
      <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100 dark:border-slate-700 gap-3">
        <h3 class="text-base font-bold text-gray-900 dark:text-white">Utilisateurs du Système</h3>
        <div class="flex flex-col gap-3 sm:flex-row sm:items-center">
          <div class="relative w-full sm:w-64">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input v-model="search" placeholder="Rechercher..." class="pl-10" />
          </div>
          <div class="w-full sm:w-auto min-w-[180px]">
            <CustomSelect v-model="roleFilter" :options="roleFilterOptions" placeholder="Tous les rôles" />
          </div>
        </div>
      </div>

      <div class="space-y-3 p-4">
        <div v-for="u in filtered" :key="u.id"
          class="rounded-2xl border border-gray-200 dark:border-slate-700 bg-white dark:bg-slate-900/50 p-4 transition-colors hover:bg-gray-50 dark:hover:bg-slate-800">
          <div class="flex flex-col gap-3 sm:flex-row sm:items-start">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-full flex items-center justify-center text-white text-sm flex-shrink-0"
                :style="{ background: avatarColors[(usersArray.indexOf(u)) % 5], fontWeight: 700 }">
                {{ u.nom.charAt(0) }}
              </div>
              <div class="min-w-0 flex-1">
                <p class="text-sm font-semibold text-gray-900 dark:text-white">{{ u.nom }}</p>
                <p class="text-xs text-gray-500 dark:text-gray-400">{{ u.email }}</p>
              </div>
            </div>
            <div class="flex-1 grid grid-cols-2 gap-2 sm:flex sm:flex-wrap sm:gap-3 sm:justify-end">
              <div>
                <p class="text-xs text-gray-500">Rôle</p>
                <div class="mt-1 inline-flex items-center gap-1 rounded-full px-2 py-1 text-xs font-semibold"
                  :style="{ background: (roleConfig[u.role] || {}).bg, color: (roleConfig[u.role] || {}).color }">
                  <component :is="(roleConfig[u.role] || {}).icon" class="w-3 h-3" />
                  <span class="hidden sm:inline">{{ u.role }}</span>
                </div>
              </div>
              <div v-if="u.role !== 'Admin'">
                <p class="text-xs text-gray-500 dark:text-gray-400">{{ u.role === 'Professeur' ? 'Grade' : 'Groupe' }}</p>
                <p class="mt-1 text-sm text-gray-900 dark:text-white">{{ u.role === 'Professeur' ? (u.grade || 'N/A') : (u.filiere || 'N/A') }}</p>
              </div>
              <div v-if="u.role !== 'Admin' && u.role !== 'Professeur'">
                <p class="text-xs text-gray-500 dark:text-gray-400">Réclamations</p>
                <p class="mt-1 text-sm font-semibold text-gray-900 dark:text-white">{{ u.reclamations }}</p>
              </div>
              <div>
                <p class="text-xs text-gray-500 dark:text-gray-400">Statut</p>
                <span class="mt-1 inline-block text-xs px-2 py-1 rounded-full font-bold"
                  :style="{ background: u.status === 'Actif' ? 'rgba(22, 163, 74, 0.1)' : 'rgba(158, 163, 176, 0.1)', color: u.status === 'Actif' ? '#16A34A' : '#9EA3B0' }">
                  {{ u.status }}
                </span>
              </div>
              <div class="flex items-center justify-end">
                <button @click="promptDeleteUser(u.id)" class="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-xl transition-colors" title="Supprimer l'utilisateur">
                  <Trash2 class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <Transition name="modal">
      <div v-if="showDeleteModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div class="bg-white dark:bg-slate-800 rounded-2xl p-6 shadow-2xl max-w-sm w-full mx-4">
          <h3 class="text-lg font-semibold text-slate-900 dark:text-white mb-2">Supprimer l'utilisateur</h3>
          <p class="text-slate-600 dark:text-slate-300 text-sm mb-6">Êtes-vous sûr de vouloir supprimer cet utilisateur ? Cette action est irréversible et supprimera toutes ses données.</p>
          <div class="flex gap-3 justify-end">
            <button
              @click="showDeleteModal = false; userToDelete = null"
              class="px-4 py-2 rounded-lg text-sm font-semibold text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700 transition-colors"
            >
              Annuler
            </button>
            <button
              @click="confirmDelete"
              class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-red-600 hover:bg-red-700 active:scale-95 transition-all shadow-md shadow-red-500/20"
            >
              Supprimer
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watchEffect } from 'vue';
import { onBeforeRouteUpdate } from 'vue-router'
import { Users, UserCheck, BookOpen, GraduationCap, Search, Trash2, CheckCircle, AlertCircle } from 'lucide-vue-next';
import CustomSelect from '../../../components/CustomSelect.vue'
import { listUsers, deleteUser } from '../../../composables/useAdmin'

const toast = ref({ show: false, message: '', type: 'success' })

function showToast(message, type = 'success') {
  toast.value = { show: true, message, type }
  setTimeout(() => { toast.value.show = false }, 3000)
}

const avatarColors = ['#4F5CF5', '#818CF8', '#10B981', '#F59E0B', '#EF4444'];

const roleConfig = {
  'Admin': { bg: '#FEE2E2', color: '#DC2626', icon: Users },
  'Professeur': { bg: '#FEF9C3', color: '#CA8A04', icon: BookOpen },
  'Délégué': { bg: '#EEF2FF', color: '#4F5CF5', icon: UserCheck },
  'Étudiant': { bg: '#DCFCE7', color: '#16A34A', icon: GraduationCap },
};

const users = ref([])
const usersArray = computed(() => users.value || [])

async function loadUsers(force = true) {
  try {
    const res = await listUsers(force)
    console.debug('[UtilisateursPage] listUsers result:', res)
    if (res && res.data) {
      users.value = res.data.map(u => {
        // normalize role from backend (may be string or object with nom_roles)
        const rawRole = (u.role && (u.role.nom_roles || u.role)) || ''
        const roleNorm = rawRole.toString().normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase()
        let roleDisplay = rawRole
        if (roleNorm.includes('deleg')) roleDisplay = 'Délégué'
        else if (roleNorm.includes('prof')) roleDisplay = 'Professeur'
        else if (roleNorm.includes('admin')) roleDisplay = 'Admin'
        else if (roleNorm.includes('etu') || roleNorm.includes('student')) roleDisplay = 'Étudiant'
        else roleDisplay = (rawRole || '').toString()

        return {
          id: u.id,
          nom: u.nom || `${u.prenom_utilisateurs || ''} ${u.nom_utilisateurs || ''}`.trim() || '',
          email: u.email || u.email_utilisateurs || '',
          role: roleDisplay,
          filiere: u.filiere || '',
          grade: u.grade || '',
          status: u.status || 'Actif',
          reclamations: u.reclamations || 0
        }
      })
    }
  } catch (err) {
    console.error('Failed to load users', err)
  }
}

onMounted(() => loadUsers(true))
onBeforeRouteUpdate((to, from) => {
  loadUsers(true)
})

// Defensive: ensure `users` is always an array to avoid template runtime errors
watchEffect(() => {
  if (!Array.isArray(users.value)) {
    console.warn('[UtilisateursPage] users was not an array, resetting', users.value)
    users.value = []
  }
})

const showDeleteModal = ref(false)
const userToDelete = ref(null)

function promptDeleteUser(id) {
  userToDelete.value = id
  showDeleteModal.value = true
}

async function confirmDelete() {
  if (!userToDelete.value) return
  try {
    await deleteUser(userToDelete.value)
    await loadUsers(true)
    showDeleteModal.value = false
    userToDelete.value = null
    showToast("L'utilisateur a été supprimé avec succès.", "error") // error type draws it in red locally
  } catch (e) {
    console.error('Failed to delete user', e)
    showToast("Erreur lors de la suppression de l'utilisateur.", "error")
    showDeleteModal.value = false
    userToDelete.value = null
  }
}

const search = ref('');
const roleFilter = ref('Tous');

const roleFilterOptions = computed(() => [
  { value: 'Tous', label: 'Tous les rôles' },
  ...Object.keys(roleConfig).map(r => ({
    value: r,
    label: r,
    dot: roleConfig[r].color,
  }))
]);

const filtered = computed(() =>
  (users.value || []).filter(u => {
    const matchSearch = (u.nom || '').toLowerCase().includes(search.value.toLowerCase()) || (u.email || '').toLowerCase().includes(search.value.toLowerCase());
    const matchRole = roleFilter.value === 'Tous' || u.role === roleFilter.value;
    return matchSearch && matchRole;
  })
);
</script>
