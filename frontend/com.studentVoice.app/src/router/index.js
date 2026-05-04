import { createRouter, createWebHistory } from 'vue-router';

//Layout Roooot
import AdminLayout from '../layouts/AdminLayout.vue';
import StudentLayout from '../layouts/StudentLayout.vue';
import ProfLayout from '../layouts/ProfLayout.vue';


//Components root
import Aide from '../components/Aide.vue';
import Profile from '../components/Profile.vue';


//Home wahi Login root
import HomeView from '../modules/home/HomePage.vue';
import LoginView from '../modules/home/LoginPage.vue';

//Prof root
import Dashboard from '../modules/prof/pages/Dashboard.vue';
import CoursesList from '../modules/prof/pages/CoursesList.vue';
import StudentsList from '../modules/prof/pages/StudentsList.vue';
import GradeManagement from '../modules/prof/pages/GradeManagement.vue';
import Tickets from '../modules/prof/pages/Tickets.vue';
import AnnoncesPageProf from '../modules/prof/pages/AnnoncesPage.vue';


//Admin root
import SharedDashboard from '../components/Dashboard.vue';
import TicketsPage from '../modules/admin/pages/TicketsPage.vue';
import DeleguesPage from '../modules/admin/pages/DeleguesPage.vue';
import UtilisateursPage from '../modules/admin/pages/UtilisateursPage.vue';
import AnnoncesPageAdmin from '../modules/admin/pages/AnnoncesPage.vue';


//Etudiant root
import StudentSuggestions from '../modules/student/pages/Suggestions.vue';
import StudentModuleProgress from '../modules/student/pages/ModuleProgress.vue';
import StudentTickets from '../modules/student/pages/Tickets.vue';
import AnnouncementsPageStudent from '../modules/student/pages/AnnouncementsPage.vue';

const routes = [
  {
    path: '/',
    redirect: '/home',
  },
  {
    path: '/home',
    component: HomeView,
    name: 'home-module',
  },
  {
    path: '/home/login',
    name: 'home-login',
    component: LoginView,
  },
  {
    path: '/prof',
    component: ProfLayout,
    children: [
      { path: '', redirect: '/prof/dashboard' },
      { path: 'dashboard', name: 'prof-dashboard', component: Dashboard },
      { path: 'courses', name: 'prof-courses', component: CoursesList },
      { path: 'students', name: 'prof-students', component: StudentsList },
      { path: 'grades', name: 'prof-grades', component: GradeManagement },
      { path: 'announcements', name: 'prof-announcements', component: AnnoncesPageProf },
      { path: 'tickets', name: 'prof-tickets', component: Tickets },
      { path: 'Profile', name: 'prof-settings', component: Profile },
      { path: 'help', name: 'prof-help', component: Aide },
    ],
  },
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      { path: '', redirect: '/admin/dashboard' },
      { path: 'dashboard', name: 'admin-dashboard', component: SharedDashboard },
      { path: 'tickets', name: 'admin-tickets', component: TicketsPage },
      { path: 'annonces', name: 'admin-annonces', component: AnnoncesPageAdmin },
      { path: 'delegues', name: 'admin-delegues', component: DeleguesPage },
      { path: 'utilisateurs', name: 'admin-utilisateurs', component: UtilisateursPage },
      { path: 'profil', name: 'admin-profil', component: Profile },
      { path: 'aide', name: 'admin-aide', component: Aide },
    ],
  },
  {
    path: '/student',
    component: StudentLayout,
    children: [
      { path: '', redirect: '/student/dashboard' },
      { path: 'dashboard', name: 'student-dashboard', component: SharedDashboard },
      { path: 'complaints', redirect: '/student/tickets' },
      { path: 'suggestions', name: 'student-suggestions', component: StudentSuggestions },
      { path: 'announcements', name: 'student-announcements', component: AnnouncementsPageStudent },
      { path: 'modules', name: 'student-modules', component: StudentModuleProgress },
      { path: 'tickets', name: 'student-tickets', component: StudentTickets },
      { path: 'profile', name: 'student-profile', component: Profile },
      { path: 'help', name: 'student-help', component: Aide },
    ],
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/home',
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

router.beforeEach((to) => {
  const normalizedPath = to.path.replace(/\/+/g, '/');
  if (normalizedPath !== to.path) {
    return {
      path: normalizedPath,
      query: to.query,
      hash: to.hash,
      replace: true,
    };
  }
  return true;
});

export default router
