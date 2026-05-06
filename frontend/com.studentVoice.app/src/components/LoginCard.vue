<template>
  <div class="login-card-container relative w-full max-w-md mx-4">
    <div
      :style="{
        perspective: '1200px',
        zoom: cardScale,
        transformOrigin: 'center center',
        transition: 'zoom 0.25s ease',
      }"
    >
    <!-- Flip container -->
    <div
      :style="{
        position: 'relative',
        transformStyle: 'preserve-3d',
        transition: 'transform 0.65s cubic-bezier(0.4,0.2,0.2,1), height 0.5s ease',
        transform: flipped ? 'rotateY(180deg)' : 'rotateY(0deg)',
        height: cardHeight ? `${cardHeight}px` : 'auto',
        borderRadius: '1.5rem',
      }"
    >
      <!-- FRONT -->
      <div
        ref="frontElement"
        :style="{
          backfaceVisibility: 'hidden',
          WebkitBackfaceVisibility: 'hidden',
          position: flipped ? 'absolute' : 'relative',
          top: 0,
          left: 0,
          right: 0,
          borderRadius: '1.5rem',
          overflow: 'hidden',
          boxShadow: '0 28px 70px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.07)',
          background: 'rgba(255,255,255,1)',
        }"
      >
        <LoginFace @flip="flipToBack" />
      </div>

      <!-- BACK -->
      <div
        ref="backElement"
        :style="{
          backfaceVisibility: 'hidden',
          WebkitBackfaceVisibility: 'hidden',
          transform: 'rotateY(180deg)',
          position: flipped ? 'relative' : 'absolute',
          top: 0,
          left: 0,
          right: 0,
          borderRadius: '1.5rem',
          overflow: 'hidden',
          boxShadow: '0 28px 70px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.07)',
          background: 'rgba(255,255,255,1)',
        }"
      >
        <SignupFace @flip="flipToFront" />
      </div>
    </div>
  </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import LoginFace from './LoginFace.vue'
import SignupFace from './SignupFace.vue'

const flipped = ref(false)
const cardHeight = ref()
const cardScale = ref(1)
const frontElement = ref()
const backElement = ref()
let resizeObserver = null

let lastActiveHeight = 0
let lastAvailableHeight = 0

const measure = () => {
  let activeH = 0
  if (!flipped.value && frontElement.value) {
    activeH = frontElement.value.offsetHeight
  }
  if (flipped.value && backElement.value) {
    activeH = backElement.value.offsetHeight
  }

  if (!activeH) {
    cardScale.value = 1
    return
  }

  const availableH = Math.max(window.innerHeight - 32, 320)
  
  // Pour éviter la boucle infinie (vibration) causée par les petits changements
  // de hauteur du texte lorsqu'on applique le 'zoom', on ignore les changements mineurs.
  if (Math.abs(activeH - lastActiveHeight) > 15 || Math.abs(availableH - lastAvailableHeight) > 5 || cardHeight.value === undefined) {
    lastActiveHeight = activeH
    lastAvailableHeight = availableH
    
    cardHeight.value = activeH
    const nextScale = Math.min(1, availableH / activeH)
    cardScale.value = Math.max(0.68, nextScale)
  }
}

const flipToBack = () => {
  flipped.value = true
  measure()
}

const flipToFront = () => {
  flipped.value = false
  measure()
}

onMounted(() => {
  measure()
  window.addEventListener('resize', measure)

  resizeObserver = new ResizeObserver(() => {
    measure()
  })

  if (frontElement.value) {
    resizeObserver.observe(frontElement.value)
  }
  if (backElement.value) {
    resizeObserver.observe(backElement.value)
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', measure)
  if (resizeObserver) {
    resizeObserver.disconnect()
  }
})
</script>

<style scoped>
.login-card-container {
  animation: loginCardEnter 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}

@keyframes loginCardEnter {
  0% {
    opacity: 0;
    transform: scale(0.9) translateY(30px);
  }
  50% {
    opacity: 0.8;
    transform: scale(1.02) translateY(-5px);
  }
  100% {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}
</style>
