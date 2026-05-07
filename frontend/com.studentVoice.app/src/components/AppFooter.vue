<template>
  <footer class="bg-slate-900 text-white pt-16 px-10">
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-[2fr_1fr_1fr] gap-10 max-w-[1100px] mx-auto pb-12 border-b border-white/10">
      <div class="sr-item sr-item-1">
        <h3 class="font-serif text-lg text-white mb-3">Portail StudentVoice</h3>
        <p class="text-[13px] text-white/50 leading-relaxed mb-5">Votre espace numérique dédié à la gestion de vos demandes académiques. Simple, sécurisé et efficace.</p>
        <div class="flex gap-2.5">
          <a class="w-9 h-9 rounded-lg bg-white/10 border border-white/10 flex items-center justify-center text-white/60 text-sm cursor-pointer transition-all hover:bg-blue-600 hover:border-blue-600 hover:text-white hover:-translate-y-0.5 no-underline" :href="social.href" target="_blank" rel="noopener noreferrer" :title="social.label" v-for="social in socials" :key="social.label">
            <component :is="social.icon" :size="18" />
          </a>
        </div>
      </div>

      <div>
        <h4 class="text-[13px] font-bold text-white/90 uppercase tracking-widest mb-4">Navigation</h4>
        <ul class="list-none p-0 m-0 flex flex-col gap-2.5">
          <li v-for="link in navLinks" :key="link.label">
            <a class="text-[13px] text-white/45 no-underline transition-colors hover:text-blue-300" :href="link.href">{{ link.label }}</a>
          </li>
        </ul>
      </div>

      <div>
        <h4 class="text-[13px] font-bold text-white/90 uppercase tracking-widest mb-4">Contact</h4>
        <div class="flex flex-col gap-3">
          <div class="flex items-start gap-2.5" v-for="item in contactItems" :key="item.icon">
            <component :is="item.icon" :size="18" class="text-[15px] shrink-0 mt-[1px] text-blue-600 flex items-center" />
            <p class="text-[12.5px] text-white/45 leading-relaxed m-0" v-html="item.text"></p>
          </div>
        </div>
      </div>
    </div>

    <div class="max-w-[1100px] mx-auto py-5 flex flex-wrap items-center justify-between gap-2">
      <p class="text-xs text-white/30 m-0">© 2026 Université Abderrahmane-Mira de Béjaïa. Tous droits réservés.</p>
      <span class="bg-blue-600/25 border border-blue-600/40 rounded-full px-3 py-1 text-[11px] text-blue-300 inline-flex items-center gap-1.5 leading-none"><Lock :size="11.5" color="white" /> Plateforme sécurisée</span>
    </div>
  </footer>
</template>

<script setup>
import { Send, Linkedin, Facebook, BookOpen, MapPin, Phone, Mail, Clock, Lock } from 'lucide-vue-next'

const socials = [
  { label: 'X (Twitter)', icon: Send, href: 'https://x.com/U_BEJAIA'},
  { label: 'LinkedIn', icon: Linkedin , href: 'https://fr.linkedin.com/company/universit%C3%A9-de-b%C3%A9jaia' },
  { label: 'Facebook', icon: Facebook, href: 'https://www.facebook.com/Universite.A.M.Bejaia/' },
  { label: 'E-Learning', icon: BookOpen , href: 'https://elearning.univ-bejaia.dz/' }
]

const navLinks = [
  { label: 'Accueil', href: '#hero' },
  { label: 'À Propos', href: '#about' },
  { label: 'Soumettre une demande', href: '/home/login' },
  { label: 'Calendrier académique', href: '/src/Asset/L3 Sec A.pdf', download: 'L3 Sec A' },
  { label: 'FAQ', href: '/src/Asset/FAQ.pdf', download: 'FAQ' }
]

const contactItems = [
  { icon: MapPin, text: 'Route de Targa Ouzemour, 06000 Béjaïa.' },
  { icon: Phone, text: '+213 34-81-68-19<br>+213 34-81-68-20' },
  { icon: Mail, text: 'support.messagerie@univ-bejaia.dz' },
  { icon: Clock, text: 'Dim – jeu : 7h00 – 16h30' }
]
</script>
