<template>
  <div>
    <!-- Banner -->
    <div
      class="relative px-8 pt-9 pb-7 text-center overflow-hidden"
      :style="{ background: 'linear-gradient(135deg,#1f54d2 0%,#255fe3 60%,#3b7af0 100%)' }"
    >
      <div
        class="absolute inset-0 opacity-10"
        :style="{
          backgroundImage:
            'radial-gradient(circle at 20% 50%,white 1px,transparent 1px),radial-gradient(circle at 80% 20%,white 1px,transparent 1px)',
          backgroundSize: '40px 40px',
        }"
      />
      <div
        class="relative inline-flex items-center justify-center w-14 h-14 rounded-2xl mb-3"
        :style="{
          background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(10px)',
          border: '1px solid rgba(255,255,255,0.25)',
        }"
      >
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
          <path d="M12 2L2 7l10 5 10-5-10-5z" fill="white" />
          <path d="M2 17l10 5 10-5" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
          <path d="M2 12l10 5 10-5" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      </div>
      <h1 class="text-white text-xl mb-0.5" :style="{ fontWeight: 700, letterSpacing: '-0.02em' }">Connexion</h1>
      <p class="text-blue-100 text-sm" :style="{ opacity: 0.85 }">Accédez à votre espace universitaire</p>
    </div>

    <!-- Form -->
    <div class="px-8 py-7">
        <form @submit.prevent="handleSubmit" class="flex flex-col gap-4">
          <div v-if="error" class="rounded-md p-3 text-sm text-red-800 bg-red-50 border border-red-100 mb-2">
            {{ error }}
          </div>
        <Field 
          id="email" 
          label="Email professionnel" 
          v-model="email"
          placeholder="" 
          :icon="IconEmail"
        />

        <PasswordField id="password" label="Mot de passe" v-model="password" />

        <!-- Remember me -->
        <div class="flex items-center gap-2.5">
          <button
            type="button"
            @click="remember = !remember"
            class="relative flex-shrink-0 w-5 h-5 rounded-md transition-all duration-200"
            :style="{
              background: remember ? '#255fe3' : 'transparent',
              border: remember ? '2px solid #255fe3' : '2px solid #cbd5e1',
              cursor: 'pointer',
            }"
          >
            <svg v-if="remember" class="absolute inset-0 m-auto" width="10" height="10" viewBox="0 0 12 12" fill="none">
              <path d="M2 6l3 3 5-5" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
            </svg>
          </button>
          <span class="text-sm" :style="{ color: '#64748b' }">Se souvenir de moi</span>
        </div>

        <ActionButton label="Se connecter" :loading="loading" :icon="IconArrow" />
      </form>

      <!-- Divider -->
      <div class="flex items-center gap-3 my-5">
        <div class="flex-1 h-px" :style="{ background: '#e2e8f0' }" />
        <span class="text-xs" :style="{ color: '#94a3b8' }">ou</span>
        <div class="flex-1 h-px" :style="{ background: '#e2e8f0' }" />
      </div>

      <div class="text-center">
        <span class="text-sm" :style="{ color: '#64748b' }">Pas encore de compte ? </span>
        <button
          type="button"
          @click="$emit('flip')"
          class="text-sm relative"
          :style="{ color: '#255fe3', fontWeight: 600, background: 'none', border: 'none', cursor: 'pointer', padding: 0 }"
          @mouseenter="(e) => (e.currentTarget.style.color = '#1f54d2')"
          @mouseleave="(e) => (e.currentTarget.style.color = '#255fe3')"
        >
          Créer un compte
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Mail, ArrowRight } from 'lucide-vue-next'
import Field from './Field.vue'
import PasswordField from './PasswordField.vue'
import ActionButton from './ActionButton.vue'
import { useAuth } from '../composables/useAuth'
import { useRouter } from 'vue-router'

const email = ref('')
const password = ref('')
const loading = ref(false)
const remember = ref(false)
const error = ref('')
const IconEmail = Mail
const IconArrow = ArrowRight

defineEmits([
  'flip'
])

const { login, setUser } = useAuth()
const router = useRouter()

const handleSubmit = async () => {
  loading.value = true
  try {
    const user = await login(email.value, password.value)
    setUser(user)
    // Redirect based on role (normalize backend role value)
    const rawRole = (user.role || '').toString()
    const role = rawRole
      .normalize('NFD')
      .replace(/\p{Diacritic}/gu, '')
      .toLowerCase()

      try {
      console.debug('Login success:', { user, role, availableRoutes: router.getRoutes().map(r => r.name || r.path) })
      if (role.includes('prof') || role.includes('enseign') || role.includes('teach')) {
        await router.push('/prof/dashboard')
      } else if (role.includes('etu') || role.includes('student')) {
        await router.push('/student/dashboard')
      } else if (role.includes('admin') || role.includes('administration')) {
        await router.push('/admin/dashboard')
      } else if (role.includes('deleg')) {
        // delegates use student dashboard with special permissions
        await router.push('/student/dashboard')
      } else {
        await router.push('/home')
      }
    } catch (e) {
      // fallback to root if named route fails
      try { window.location.href = '/' } catch { /* ignore */ }
    }
  } catch (err) {
    console.error('Login error', err)
    const message = (err && err.message) || 'Impossible de se connecter'
    error.value = message
  } finally {
    loading.value = false
  }
}

// clear error when user edits input
watch([email, password], () => {
  if (error.value) error.value = ''
})
</script>
