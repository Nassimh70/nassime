<template>
  <div class="flex flex-col" :style="{ paddingTop: '18px' }">
    <div class="relative flex items-end">
      <!-- Icon -->
      <span
        class="flex-shrink-0 pb-2 pr-2.5 transition-colors duration-250"
        :style="{ color: focused ? 'var(--primary)' : 'var(--muted-foreground)' }"
      >
        <component :is="icon" :size="20" stroke-width="1.8" />
      </span>

      <!-- Input + floating label -->
      <div class="relative flex-1">
        <label
          :for="id"
          class="absolute pointer-events-none"
          :style="{
            left: 0,
            top: active ? '-14px' : '8px',
            fontSize: active ? '0.7rem' : '0.85rem',
            color: focused ? 'var(--primary)' : 'var(--muted-foreground)',
            fontWeight: 600,
            letterSpacing: active ? '0.07em' : '0.02em',
            textTransform: active ? 'uppercase' : 'none',
            transition: 'all 0.25s cubic-bezier(0.4,0,0.2,1)',
          }"
        >
          {{ label }}
        </label>
        <input
          :id="id"
          :type="inputType"
          :value="modelValue"
          :placeholder="placeholder"
          @input="emit('update:modelValue', $event.target.value)"
          @focus="focused = true"
          @blur="focused = false"
          class="w-full bg-transparent pb-2 pt-1 outline-none text-sm input-clean"
          v-bind="$attrs"
        />
      </div>

      <!-- Password Toggle / Right slot -->
      <div v-if="type === 'password'" class="pb-2 pl-2 flex-shrink-0">
        <button
          type="button"
          @click="showPassword = !showPassword"
          class="p-1 rounded-md transition-colors duration-200 hover:bg-slate-100 dark:hover:bg-slate-800"
          :style="{ color: 'var(--muted-foreground)', background: 'none', border: 'none', cursor: 'pointer' }"
        >
          <Eye v-if="showPassword" :size="18" stroke-width="1.8" />
          <EyeOff v-else :size="18" stroke-width="1.8" />
        </button>
      </div>
      <span v-else-if="$slots.right" class="pb-2 pl-1 flex-shrink-0">
        <slot name="right" />
      </span>
    </div>

    <!-- Animated underline -->
    <div :style="{ position: 'relative', height: '2px', background: 'var(--border)' }">
      <div
        :style="{
          position: 'absolute',
          bottom: 0,
          left: 0,
          height: '2px',
          width: focused ? '100%' : '0%',
          background: 'linear-gradient(90deg, var(--primary), var(--brand-light, var(--primary)))',
          transition: 'width 0.3s cubic-bezier(0.4,0,0.2,1)',
        }"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Eye, EyeOff, Lock } from 'lucide-vue-next'

const props = defineProps({
  id: String,
  label: String,
  type: {
    type: String,
    default: 'text'
  },
  modelValue: [String, Number],
  placeholder: {
    type: String,
    default: ''
  },
  icon: {
    type: [Object, Function],
    default: null
  },
  floating: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:modelValue'])

const focused = ref(false)
const showPassword = ref(false)

const active = computed(() => !props.floating || focused.value || (props.modelValue?.toString().length ?? 0) > 0)
const inputType = computed(() => {
  if (props.type === 'password') {
    return showPassword.value ? 'text' : 'password'
  }
  return props.type
})

// Auto-assign Lock icon if it's a password field and no icon is provided
const icon = computed(() => {
  if (props.icon) return props.icon
  if (props.type === 'password') return Lock
  return null
})
</script>

<style scoped>
.input-clean,
.input-clean:focus,
.input-clean:focus-visible {
  border: none !important;
  outline: none !important;
  box-shadow: none !important;
  background: transparent !important;
  -webkit-appearance: none;
  appearance: none;
}

.input-clean:-webkit-autofill,
.input-clean:-webkit-autofill:hover,
.input-clean:-webkit-autofill:focus {
  -webkit-text-fill-color: var(--foreground);
  box-shadow: 0 0 0 1000px transparent inset !important;
  transition: background-color 9999s ease-in-out 0s;
}
</style>
