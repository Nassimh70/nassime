<template>
  <div ref="selectRef" class="relative w-full" @keydown.escape="close">
    <!-- Trigger -->
    <button
      type="button"
      @click="toggle"
      class="flex items-center justify-between w-full px-3 py-2 rounded-xl border text-sm transition-all duration-200
             bg-[var(--input)] text-[var(--foreground)] border-[var(--border)]
             hover:border-[var(--ring)] hover:bg-[var(--input-background)]
             focus:outline-none focus:ring-2 focus:ring-[var(--ring)]/20
             focus:border-[var(--ring)]"
    >
      <span class="flex items-center gap-2 truncate">
        <component
          v-if="(selected && selected.icon) || icon"
          :is="(selected && selected.icon) ? selected.icon : icon"
          class="w-4 h-4 text-[var(--muted-foreground)]"
        />
        <span
          :class="!selected ? 'text-[var(--muted-foreground)]' : 'text-[var(--foreground)]'"
          class="truncate"
        >
          {{ selected?.label || placeholder }}
        </span>
      </span>

      <ChevronDown
        class="w-4 h-4 transition-transform duration-200 text-[var(--muted-foreground)]"
        :class="isOpen ? 'rotate-180 text-[var(--ring)]' : ''"
      />
    </button>

    <!-- Dropdown -->
    <transition name="fade-scale">
      <div
        v-if="isOpen"
        class="absolute z-50 mt-2 w-full rounded-xl border p-1
               bg-[var(--popover)] border-[var(--border)]
               shadow-[0_8px_32px_var(--shadow-neutral)]"
      >
        <div
          v-for="(option, i) in options"
          :key="option.value"
          @click="select(option)"
          @mouseenter="focused = i"
          @mouseleave="focused = -1"
          class="flex items-center gap-2 px-3 py-2 rounded-lg cursor-pointer text-sm transition-all duration-150
                 text-[var(--foreground)]"
          :class="[
            modelValue === option.value
              ? 'bg-[var(--ring)]/10 text-[var(--ring)] font-medium'
              : 'text-[var(--foreground)]',
            focused === i && modelValue !== option.value
              ? 'bg-[var(--muted)]'
              : ''
          ]"
        >
          <component
            v-if="option.icon"
            :is="option.icon"
            class="w-4 h-4 text-[var(--muted-foreground)]"
            :class="modelValue === option.value ? 'text-[var(--ring)]' : ''"
          />

          <span class="flex-1">{{ option.label }}</span>

          <Check
            v-if="modelValue === option.value"
            class="w-4 h-4 text-[var(--ring)]"
          />
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { ChevronDown, Check } from 'lucide-vue-next'

const props = defineProps({
  modelValue: [String, Number],
  options: { type: Array, required: true },
  placeholder: { type: String, default: 'Select...' },
  icon: { type: [Object, Function], default: null }
})

const emit = defineEmits(['update:modelValue'])

const isOpen = ref(false)
const focused = ref(-1)
const selectRef = ref(null)

const selected = computed(() =>
  props.options.find(o => o.value === props.modelValue)
)

const toggle = () => {
  isOpen.value = !isOpen.value
  if (isOpen.value) focused.value = -1
}

const close = () => {
  isOpen.value = false
  focused.value = -1
}

const select = (option) => {
  emit('update:modelValue', option.value)
  close()
}

const handleClickOutside = (e) => {
  if (selectRef.value && !selectRef.value.contains(e.target)) {
    close()
  }
}

onMounted(() => document.addEventListener('mousedown', handleClickOutside))
onBeforeUnmount(() => document.removeEventListener('mousedown', handleClickOutside))
</script>

<style scoped>
.fade-scale-enter-active {
  transition: all 0.18s ease;
}
.fade-scale-leave-active {
  transition: all 0.12s ease;
}
.fade-scale-enter-from {
  opacity: 0;
  transform: translateY(-6px) scale(0.96);
}
.fade-scale-leave-to {
  opacity: 0;
  transform: translateY(-4px) scale(0.98);
}
</style>