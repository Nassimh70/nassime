import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './styles/index.css'
import { useAuth } from './composables/useAuth'

const app = createApp(App)

// attempt to hydrate profile from stored token before mounting
const { loadProfile } = useAuth()
try {
	// top-level await supported by Vite; if not, this will still work as a Promise
	await loadProfile()
} catch (e) {
	// ignore
}

app.use(router).mount('#app')
