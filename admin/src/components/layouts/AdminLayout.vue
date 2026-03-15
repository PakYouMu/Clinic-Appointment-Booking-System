<template>
  <div class="flex min-h-screen bg-background">
    <!-- Sidebar -->
    <aside 
      :class="[
        'fixed inset-y-0 left-0 z-50 w-64 border-r bg-card/50 backdrop-blur-xl transition-transform md:translate-x-0',
        sidebarOpen ? 'translate-x-0' : '-translate-x-full'
      ]"
    >
      <div class="flex h-16 items-center border-b px-6">
        <router-link to="/" class="flex items-center gap-2 font-bold tracking-tighter">
          <div class="h-8 w-8 rounded bg-primary flex items-center justify-center text-primary-foreground font-italic">M</div>
          <span class="italic">Mustard Clinic</span>
        </router-link>
      </div>

      <nav class="space-y-1 p-4">
        <router-link 
          v-for="item in navItems" 
          :key="item.name"
          :to="item.path"
          :class="[
            'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
            $route.path === item.path ? 'bg-primary text-primary-foreground' : 'text-muted-foreground hover:bg-muted hover:text-foreground'
          ]"
        >
          <component :is="item.icon" class="h-4 w-4" />
          {{ item.name }}
        </router-link>
      </nav>

      <div class="absolute bottom-0 w-full border-t p-4">
        <div v-if="currentUser" class="mb-4 flex items-center gap-3 px-2">
          <div class="h-8 w-8 rounded-full bg-muted flex items-center justify-center font-bold text-muted-foreground uppercase text-xs">
            {{ currentUser.email.charAt(0) }}
          </div>
          <div class="flex-1 overflow-hidden">
            <p class="truncate text-sm font-semibold">{{ currentUser.email }}</p>
            <p class="text-xs text-muted-foreground uppercase">Admin</p>
          </div>
        </div>
        <Button variant="ghost" class="w-full justify-start gap-3" @click="handleSignOut">
          <LogOut class="h-4 w-4" />
          Sign Out
        </Button>
      </div>
    </aside>

    <!-- Overlay for mobile -->
    <div 
      v-if="sidebarOpen" 
      class="fixed inset-0 z-40 bg-background/80 backdrop-blur-sm md:hidden" 
      @click="sidebarOpen = false"
    ></div>

    <!-- Main Content -->
    <main class="flex-1 md:ml-64">
      <!-- Mobile Header -->
      <header class="sticky top-0 z-30 flex h-16 items-center border-b bg-background/80 px-4 backdrop-blur-md md:hidden">
        <Button variant="ghost" size="icon" @click="sidebarOpen = true">
          <Menu class="h-5 w-5" />
        </Button>
        <span class="ml-4 font-bold tracking-tighter uppercase">Admin Panel</span>
      </header>

      <div class="p-4 md:p-8">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, markRaw } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { Button } from '@/components/ui/button'
import { 
  LayoutDashboard, 
  CalendarDays, 
  Stethoscope, 
  ClipboardList, 
  LogOut, 
  Menu 
} from 'lucide-vue-next'

const router = useRouter()
const { currentUser, signOut } = useAuth()
const sidebarOpen = ref(false)

const navItems = [
  { name: 'Dashboard', path: '/', icon: markRaw(LayoutDashboard) },
  { name: 'Calendar', path: '/calendar', icon: markRaw(CalendarDays) },
  { name: 'Doctors', path: '/doctors', icon: markRaw(Stethoscope) },
  { name: 'Appointments', path: '/appointments', icon: markRaw(ClipboardList) },
]

async function handleSignOut() {
  await signOut()
  router.push({ name: 'Login' })
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
