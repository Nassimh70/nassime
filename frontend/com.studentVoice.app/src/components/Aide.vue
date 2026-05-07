<template>
  <div class="flex flex-col gap-6 w-full max-w-4xl mx-auto py-6">
    <!-- Contact Cards -->
    <div class="grid grid-cols-3 gap-4">
      <div
        v-for="item in contactItems"
        :key="item.label"
        class="help-card rounded-2xl p-4 flex flex-col items-center gap-2 text-center cursor-pointer transition-all hover:shadow-md"
      >
        <div class="w-10 h-10 rounded-xl flex items-center justify-center" :style="{ background: item.bg }">
          <component :is="item.icon" class="w-5 h-5" :style="{ color: item.color }" />
        </div>
        <p class="help-title text-sm">{{ item.label }}</p>
        <p class="help-subtitle text-xs">{{ item.sub }}</p>
      </div>
    </div>

    <!-- FAQ -->
    <div class="help-card rounded-2xl overflow-hidden">
      <div class="flex items-center gap-2 px-5 py-4 border-b help-border">
        <HelpCircle class="w-4 h-4 text-indigo-500" />
        <h3 class="help-title text-base">Questions Fréquentes</h3>
      </div>
      <div class="flex flex-col divide-y help-border">
        <div v-for="(faq, i) in faqs" :key="i">
          <button
            @click="open = open === i ? null : i"
            class="w-full flex items-center justify-between px-5 py-4 text-left transition-colors hover:bg-gray-50 dark:hover:bg-[var(--hover)]"
          >
            <span class="text-sm pr-4 faq-question">{{ faq.q }}</span>
            <ChevronDown
              class="w-4 h-4 flex-shrink-0 transition-transform"
              :style="{ color: 'var(--primary)', transform: open === i ? 'rotate(180deg)' : 'rotate(0deg)' }"
            />
          </button>

          <!-- ✅ Remplacé v-if par faq-body avec animation -->
          <div class="faq-body" :class="{ open: open === i }">
            <div class="faq-body-inner">
              <p class="px-5 pb-4 text-sm faq-answer">{{ faq.a }}</p>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineComponent, ref } from 'vue';
import { HelpCircle, MessageCircle, BookOpen, Phone, ChevronDown } from 'lucide-vue-next';

defineComponent({
  name: 'Aide'
});

const open = ref(null);

const contactItems = [
  { icon: MessageCircle, label: 'Support Chat', sub: 'Disponible 8h-18h', color: '#4F5CF5', bg: '#EEF2FF' },
  { icon: Phone, label: 'Téléphone', sub: '+213 34 81 68 19', color: '#16A34A', bg: '#DCFCE7' },
  { icon: BookOpen, label: 'Documentation', sub: 'Guide utilisateur', color: '#CA8A04', bg: '#FEF9C3' },
];

const faqs = [
  {
    q: 'Comment accéder à la plateforme ?',
    a: "Tous les utilisateurs (étudiants, délégués, professeurs et administrateurs) doivent s'authentifier pour accéder à la plateforme. Utilisez vos identifiants fournis par l'administration. Une fois connecté, vous pouvez consulter et mettre à jour votre profil depuis la section \"Mon Profil\"."
  },
  {
    q: 'Comment soumettre une réclamation ?',
    a: "En tant qu'étudiant ou délégué, rendez-vous dans la section \"Réclamations\" et remplissez le formulaire de soumission. Une fois envoyée, votre réclamation sera traitée par l'administration qui pourra l'accepter ou la refuser avec un motif de décision."
  },
  {
    q: 'Comment suivre le statut de mes réclamations ?',
    a: "Depuis la section \"Réclamations\", vous pouvez consulter le statut de chacun de vos dossiers (En attente, Acceptée, Refusée). Les administrateurs, professeurs et délégués ont également accès à une vue des réclamations avec statistiques détaillées."
  },
  {
    q: 'Comment soumettre et voter pour une suggestion ?',
    a: "Les étudiants peuvent soumettre une suggestion depuis la section dédiée. Tous les utilisateurs peuvent ensuite voter pour les suggestions soumises afin de soutenir les propositions qu'ils jugent pertinentes."
  },
  {
    q: 'Comment sont publiées les annonces ?',
    a: "Les annonces peuvent être publiées par les administrateurs et les professeurs. Il existe deux types d'annonces : les annonces administratives (publiées uniquement par l'administrateur) et les annonces pédagogiques (publiées par l'administrateur ou le professeur). Tous les utilisateurs peuvent les consulter depuis la section \"Annonces\"."
  },
  {
    q: "Comment suivre l'avancement des cours ?",
    a: "Les étudiants peuvent consulter l'avancement des modules depuis leur espace. Les professeurs ont la possibilité de mettre à jour l'avancement du cours en temps réel et peuvent également consulter et gérer les tickets liés à leurs cours."
  },
  {
    q: 'Quel est le rôle du délégué sur la plateforme ?',
    a: "Le délégué est désigné par l'administrateur. Il peut soumettre des réclamations au nom de sa promotion, rédiger et soumettre des tickets, soumettre des suggestions, et voter pour les propositions. Il a aussi accès au statut des réclamations de sa promotion."
  },
]
</script>

<style scoped>
.help-card {
  background: var(--card);
  box-shadow: 0 2px 12px var(--shadow-neutral-soft);
}

.help-title {
  color: var(--foreground);
  font-weight: 700;
}

.help-subtitle {
  color: var(--muted-foreground);
}

.help-border {
  border-color: var(--border);
}

.faq-question {
  color: var(--foreground);
  font-weight: 500;
}

.faq-answer {
  color: var(--muted-foreground);
  line-height: 1.7;
}

.faq-body {
  display: grid;
  grid-template-rows: 0fr;
  transition: grid-template-rows 0.35s cubic-bezier(0.4, 0, 0.2, 1);
}

.faq-body.open {
  grid-template-rows: 1fr;
}

.faq-body-inner {
  overflow: hidden;
}
</style>