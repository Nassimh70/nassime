<template>
  <div class="announcements-page flex flex-col gap-4">
    
    <div v-if="!canPublish" class="bg-blue-50 border border-blue-200 rounded-lg p-4">
      <div class="flex items-start gap-3">
        <Bell class="w-6 h-6 text-blue-600 flex-shrink-0" />
        <div>
          <h3 class="font-semibold text-blue-900">Publication d'Annonces</h3>
          <p class="text-sm text-blue-700 mt-1">Seuls les délégués, professeurs et administrateurs peuvent créer et publier des annonces.
          </p>
        </div>
      </div>
    </div>
    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
  
      <div class="flex flex-wrap gap-3">
        <button
          v-for="f in filterButtons"
          :key="f.value"
          @click="activeFilter = f.value"
          class="px-3 py-1.5 rounded-xl text-xs transition-all"
          :style="{
            background: activeFilter === f.value ? f.gradient : f.bg,
            color: activeFilter === f.value ? '#FFFFFF' : f.color,
            fontWeight: 600,
            boxShadow: activeFilter === f.value ? f.shadow : '0 1px 4px rgba(0,0,0,0.08)',
          }"
        >
          {{ f.label }}
        </button>
      </div>
      <button
        v-if="canPublish"
        @click="showForm = !showForm"
        class="flex items-center gap-1.5 px-4 py-2.5 rounded-xl text-white text-sm transition-all hover:opacity-90 active:scale-95 shadow-lg"
        style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 600"
      >
        <Plus class="w-3.5 h-3.5" />
        Publier
      </button>
      <div v-else class="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-500 rounded-lg cursor-not-allowed">
        <Lock class="w-5 h-5" />
        <span class="text-sm">Accès restreint</span>
      </div>
    </div>

    <!-- Formulaire d'ajout -->
    <div v-if="showForm && canPublish" class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5 animate-slide-down">
      <h3 class="text-sm mb-3 form-title">Nouvelle Annonce</h3>
      <div class="grid grid-cols-1 gap-3 mb-3 sm:grid-cols-2">
        <input v-model="form.titre" placeholder="Titre de l'annonce*" class="col-span-1 sm:col-span-2" />
        <input v-model="form.cours" placeholder="Cours / Module" />
        <CustomSelect
          v-model="form.type"
          :options="typeOptions"
          placeholder="Type d'annonce"
          :disabled="!isAdmin"
        />
        <textarea v-model="form.contenu" placeholder="Contenu de l'annonce*" rows="3" class="col-span-2 resize-none"></textarea>
      </div>
              <div class="flex gap-3 justify-end">
          <button 
            @click="showForm = false" 
            class="px-5 py-2.5 rounded-xl text-sm font-medium transition-all hover:opacity-80"
            :style="{ background: 'rgba(99, 102, 241, 0.08)', color: '#6366f1' }"
          >
            Annuler
          </button>
          <button 
            @click="addAnnonce" 
            :disabled="submitting || !formValid"
            class="px-5 py-2.5 rounded-xl text-white text-sm font-semibold transition-all hover:opacity-90 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              style="background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%); font-weight: 600"
          >
            <Loader2 v-if="submitting" class="w-4 h-4 animate-spin" />
            <Send v-else class="w-4 h-4" />
            {{ submitting ? 'Publication...' : 'Publier' }}
          </button>
        </div>
    </div>

      
    <!-- Loading state -->
    <div v-if="loading" class="flex flex-col gap-3">
      <div v-for="n in 3" :key="n" class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 animate-pulse">
        <div class="space-y-3">
          <div class="flex gap-2">
            <div class="h-5 w-20 rounded-full bg-gray-200"></div>
            <div class="h-5 w-16 rounded-full bg-gray-200"></div>
          </div>
          <div class="h-5 w-3/4 rounded bg-gray-200"></div>
          <div class="h-4 w-full rounded bg-gray-100"></div>
          <div class="h-4 w-2/3 rounded bg-gray-100"></div>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else-if="filteredAnnonces.length === 0" class="text-center py-12">
      <Bell class="w-12 h-12 mx-auto mb-3 text-gray-300" />
      <p class="text-sm text-gray-500">
        {{ annonces.length === 0 ? 'Aucune annonce pour le moment.' : 'Aucune annonce dans cette catégorie.' }}
      </p>
    </div>

    <div v-else class="flex flex-col gap-3">
      <div
        v-for="annonce in filteredAnnonces"
        :key="annonce.id"
        class="bg-white dark:bg-slate-800 p-6 rounded-3xl border border-blue-100 dark:border-blue-900 shadow-lg shadow-blue-500/5"
      >
        <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 mb-2 flex-wrap">
              <span
                class="text-xs px-2.5 py-0.5 rounded-full font-semibold"
                :style="typeStyleFor(annonce.type)"
              >
                {{ annonce.type }}
              </span>
              <span
                class="text-xs px-2.5 py-0.5 rounded-full font-semibold"
                :style="roleStyleFor(annonce.role)"
              >
                {{ annonce.role }}
              </span>
              <span v-if="annonce.cours && annonce.cours !== 'Général'" class="meta text-xs">
                <BookOpen class="w-3 h-3 inline mr-1" />
                {{ annonce.cours }}
              </span>
            </div>
            <h3 class="text-base mb-1 form-title">
              {{ annonce.titre }}
            </h3>
            <p class="text-sm leading-relaxed mb-3 content-text">
              {{ annonce.contenu }}
            </p>
            <div class="flex items-center gap-4">
              <div class="meta flex items-center gap-1.5 text-xs">
                <User class="w-3.5 h-3.5" />
                {{ annonce.auteur }}
              </div>
              <div class="meta flex items-center gap-1.5 text-xs">
                <Calendar class="w-3.5 h-3.5" />
                {{ annonce.date }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { Bell, Plus, BookOpen, Calendar, User, Lock, Send } from 'lucide-vue-next';
import CustomSelect from './CustomSelect.vue'
import { createAnnonce, listAnnonces, invalidateAnnoncesCache } from '../composables/useAnnonces'
import { useAuth } from '../composables/useAuth'

// Props pour contrôler qui peut publier et réagir
const props = defineProps({
  canPublish: {
    type: Boolean,
    default: false, // Par défaut, pas de publication
  },
});

const { user, isDelegate } = useAuth()

const userRoleName = computed(() => {
  const r = user.value && user.value.role
  let roleName = ''
  if (!r) roleName = ''
  else if (typeof r === 'string') roleName = r
  else if (r.nom_roles) roleName = r.nom_roles
  else if (r.name) roleName = r.name
  return (roleName || '').toString().toLowerCase()
})

const isAdmin = computed(() => userRoleName.value === 'admin' || userRoleName.value === 'administration')
const isProfesseur = computed(() => userRoleName.value === 'professeur')

// ─── Type options based on role ───────────────────
const typeOptions = computed(() => {
  if (isAdmin.value) {
    return [
      { value: 'Pédagogique', label: 'Pédagogique' },
      { value: 'Administrative', label: 'Administrative' },
      { value: 'Événement', label: 'Événement' },
    ]
  } else if (isProfesseur.value) {
    return [{ value: 'Pédagogique', label: 'Pédagogique' }]
  } else if (isDelegate.value) {
    return [{ value: 'Événement', label: 'Événement' }]
  }
  return [{ value: 'Pédagogique', label: 'Pédagogique' }] // fallback
})

// ─── Filter buttons ──────────────────────────────
const filterButtons = ref([
  { value: 'Toutes', label: 'Toutes', color: '#255fe3', bg: '#DEE2F0', gradient: 'linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%)', shadow: '0 2px 8px rgba(37,95,227,0.35)' },
  { value: 'Pédagogique', label: 'Pédagogique', color: '#4F5CF5', bg: '#F3F4FF', gradient: 'linear-gradient(135deg, #3d48d9 0%, #4F5CF5 50%, #363fb5 100%)', shadow: '0 2px 8px rgba(79,92,245,0.35)' },
  { value: 'Administrative', label: 'Administrative', color: '#CA8A04', bg: '#FEF9C3', gradient: 'linear-gradient(135deg, #b47d04 0%, #CA8A04 50%, #a16e03 100%)', shadow: '0 2px 8px rgba(202,138,4,0.35)' },
  { value: 'Événement', label: 'Événement', color: '#16A34A', bg: '#DCFCE7', gradient: 'linear-gradient(135deg, #128c3e 0%, #16A34A 50%, #0f7a35 100%)', shadow: '0 2px 8px rgba(22,163,74,0.35)' },
])

// ─── Normalize type for comparison ───────────────
function normalizeType(value) {
  if (!value) return ''
  const raw = String(value).trim().toLowerCase()
  const normalized = raw.normalize('NFD').replace(/[\u0300-\u036f]/g, '')

  if (normalized === 'pedagogique' || normalized === 'cours' || normalized === 'course') return 'Pédagogique'
  if (normalized === 'administrative' || normalized === 'admin') return 'Administrative'
  if (normalized === 'evenement' || normalized === 'evenements' || normalized === 'event' || normalized === 'events') return 'Événement'

  // Return the original value with proper capitalization if no match
  return String(value).trim()
}

onMounted(async () => {
  await loadAnnonces()
  setDefaultType()
})

function setDefaultType() {
  if (isDelegate.value) {
    form.type = 'Événement'
  } else if (isProfesseur.value) {
    form.type = 'Pédagogique'
  } else if (isAdmin.value) {
    form.type = 'Administrative'
  } else {
    form.type = 'Pédagogique'
  }
}

const activeFilter = ref('Toutes');
const loading = ref(true);
const submitting = ref(false);

const formValid = computed(() => {
  return form.titre.trim() && form.contenu.trim() && form.type;
});

const annonces = ref([])

// ─── Type badge styles ───────────────────────────
const typeStyles = {
  'Pédagogique': { background: '#EEF2FF', color: '#4F46E5' },
  'Administrative': { background: '#FEF9C3', color: '#A16207' },
  'Événement': { background: '#DCFCE7', color: '#15803D' },
}

// ─── Role badge styles ───────────────────────────
const roleStyles = {
  'Professeur': { background: '#FEF3C7', color: '#B45309' },
  'Admin': { background: '#FEE2E2', color: '#DC2626' },
  'Délégué': { background: '#EDE9FE', color: '#7C3AED' },
  'Étudiant': { background: '#E0F2FE', color: '#0369A1' },
}

const filteredAnnonces = computed(() => {
  if (activeFilter.value === 'Toutes') {
    return annonces.value;
  }
  return annonces.value.filter(a => normalizeType(a.type) === activeFilter.value);
});

async function loadAnnonces() {
  loading.value = true
  try {
    const res = await listAnnonces(true)
    if (res && res.data) {
      annonces.value = res.data.map(a => ({
        id: a.id,
        titre: a.titre_annonce,
        contenu: a.contenu_annonce,
        date: a.date_publication_annonce ? new Date(a.date_publication_annonce).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' }) : '',
        auteur: a.auteur || 'Inconnu',
        role: a.role_auteur || 'Inconnu',
        cours: a.cours || 'Général',
        type: normalizeType(a.type_annonce) || 'Pédagogique',
      }))
    }
  } catch (err) {
    console.error('Erreur chargement annonces', err)
    if (err && err.status === 401) {
      alert('Non autorisé — votre session a peut-être expiré. Veuillez vous reconnecter.')
    }
  } finally {
    loading.value = false
  }
}

const showForm = ref(false);
const form = reactive({
  titre: '',
  cours: '',
  type: '',
  contenu: '',
});

const addAnnonce = async () => {
  if (!formValid.value || submitting.value) return;
  submitting.value = true;
  try {
    const payload = {
      titre_annonce: form.titre,
      contenu_annonce: form.contenu,
      cours: form.cours,
      type_annonce: form.type,
    }
    const res = await createAnnonce({ annonce: payload })
    if (res && res.data) {
      const a = res.data
      const item = {
        id: a.id,
        titre: a.titre_annonce,
        contenu: a.contenu_annonce,
        date: a.date_publication_annonce ? new Date(a.date_publication_annonce).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short', year: 'numeric' }) : '',
        auteur: a.auteur || 'Inconnu',
        role: a.role_auteur || 'Inconnu',
        cours: a.cours || form.cours || 'Général',
        type: normalizeType(a.type_annonce) || form.type,
      }
      annonces.value.unshift(item)
      // reset form
      form.titre = '';
      form.cours = '';
      setDefaultType();
      form.contenu = '';
      showForm.value = false;
      // invalidate and reload to keep cache consistent
      invalidateAnnoncesCache()
      await loadAnnonces()
      return
    }
  } catch (err) {
    console.error('Erreur création annonce', err)
    const msg = (err && (err.message || err.error)) || 'Impossible de publier l\'annonce'
    alert(msg)
  } finally {
    submitting.value = false;
  }
}

function typeStyleFor(t) {
  const normalized = normalizeType(t)
  const s = typeStyles[normalized]
  if (s) return { background: s.background, color: s.color, fontWeight: 600 }
  return { background: '#F3F4F6', color: '#6B7280', fontWeight: 600 }
}

function roleStyleFor(r) {
  const s = roleStyles[r]
  if (s) return { background: s.background, color: s.color, fontWeight: 600 }
  return { background: '#F3F4F6', color: '#6B7280', fontWeight: 600 }
}
</script>

<style scoped>
.banner-subtitle,
.meta,
.content-text {
  color: var(--muted-foreground);
}

.surface-card {
  background: var(--card);
  box-shadow: 0 2px 12px var(--shadow-neutral-soft);
}

.form-title {
  color: var(--foreground);
  font-weight: 700;
}

.publish-btn {
  background: linear-gradient(135deg, #1f54d2 0%, #255fe3 50%, #1d3f95 100%);
  color: #ffffff;
  font-weight: 600;
}

.cancel-btn {
  background: #f3f4f6;
  color: #6b7280;
  font-weight: 600;
}

/* Pulse animation */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}
.animate-pulse {
  animation: pulse 1.5s ease-in-out infinite;
}
</style>