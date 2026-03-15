<template>
  <div class="min-h-screen flex flex-col bg-background text-foreground">
    <!-- Navigation Header -->
    <header class="sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur-md supports-[backdrop-filter]:bg-background/60">
      <div class="container mx-auto px-4 h-16 flex items-center justify-between">
        
        <!-- Logo Area -->
        <div class="flex items-center gap-2">
          <router-link to="/" class="flex items-center space-x-2">
            <span class="text-xl font-bold italic tracking-tight text-primary underline-offset-4 decoration-primary/30">Mustard Clinic</span>
          </router-link>
        </div>

        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center space-x-6">
          <router-link to="/" class="text-sm font-medium transition-colors hover:text-primary" active-class="text-primary font-semibold">Home</router-link>
          <router-link to="/doctors" class="text-sm font-medium text-muted-foreground transition-colors hover:text-primary" active-class="text-primary font-semibold">Doctors</router-link>
          <router-link to="/book" class="text-sm font-medium text-muted-foreground transition-colors hover:text-primary" active-class="text-primary font-semibold">Book Appointment</router-link>
          
          <router-link v-if="isAuthenticated" to="/dashboard" class="text-sm font-medium text-muted-foreground transition-colors hover:text-primary" active-class="text-primary font-semibold">Dashboard</router-link>
        </div>

        <!-- Auth Actions / Profile -->
        <div class="flex items-center justify-end space-x-4">
          <template v-if="!loading">
            <template v-if="isAuthenticated">
              <DropdownMenu>
                <DropdownMenuTrigger as-child>
                  <Button variant="ghost" class="relative h-9 w-9 rounded-full">
                    <Avatar class="h-9 w-9">
                      <AvatarImage v-if="currentUser?.avatarUrl" :src="currentUser.avatarUrl" alt="Avatar" />
                      <AvatarFallback class="bg-primary/10 text-primary">{{ userInitials }}</AvatarFallback>
                    </Avatar>
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent class="w-56" align="end">
                  <DropdownMenuLabel class="font-normal">
                    <div class="flex flex-col space-y-1">
                      <p class="text-sm font-medium leading-none">{{ currentUser?.firstName }} {{ currentUser?.lastName }}</p>
                      <p class="text-xs leading-none text-muted-foreground">{{ currentUser?.email }}</p>
                    </div>
                  </DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem @click="$router.push('/dashboard')">
                    Dashboard
                  </DropdownMenuItem>
                  <DropdownMenuItem @click="$router.push('/profile')">
                    Profile Settings
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem @click="handleSignOut" class="text-destructive focus:bg-destructive focus:text-destructive-foreground cursor-pointer">
                    Log out
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </template>
            <template v-else>
              <div class="items-center space-x-2 hidden sm:flex">
                <Button variant="ghost" as-child>
                  <router-link to="/login">Sign In</router-link>
                </Button>
                <Button as-child shadow="sm">
                  <router-link to="/register">Get Started</router-link>
                </Button>
              </div>
              <!-- Mobile menu trigger -->
              <div class="sm:hidden">
                <Button variant="ghost" size="icon" @click="mobileMenuOpen = !mobileMenuOpen">
                  <span class="sr-only">Toggle Menu</span>
                  <Menu class="h-6 w-6" />
                </Button>
              </div>
            </template>
          </template>
        </div>
      </div>
    </header>

    <!-- Main Content wrapper -->
    <main class="flex-1 w-full relative">
      <router-view v-slot="{ Component, route }">
        <transition name="fade" mode="out-in">
          <div :key="route.name" class="h-full">
            <component :is="Component" />
          </div>
        </transition>
      </router-view>
    </main>

    <!-- Simple Footer -->
    <footer class="border-t bg-muted/20">
      <div class="container mx-auto px-4 py-8 md:py-12 flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-muted-foreground">
        <div class="flex flex-col items-center md:items-start gap-1">
          <p class="font-medium text-foreground italic">Mustard Clinic</p>
          <p>Providing quality healthcare scheduling securely.</p>
        </div>
        <div class="flex items-center gap-4">
          <router-link to="/terms" class="hover:text-foreground transition-colors">Terms</router-link>
          <router-link to="/privacy" class="hover:text-foreground transition-colors">Privacy Privacy</router-link>
          <router-link to="/contact" class="hover:text-foreground transition-colors">Contact</router-link>
        </div>
        <div>
          <p>&copy; {{ new Date().getFullYear() }} Mustard Clinic. All rights reserved.</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Menu } from 'lucide-vue-next'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const router = useRouter()
const { currentUser, isAuthenticated, loading, signOut } = useAuth()

const userInitials = computed(() => {
  if (!currentUser.value) return '??'
  
  // Try to use first/last name if available (common for patients)
  if (currentUser.value.firstName && currentUser.value.lastName) {
    return `${currentUser.value.firstName.charAt(0)}${currentUser.value.lastName.charAt(0)}`.toUpperCase()
  }
  
  // Fallback to email characters
  if (currentUser.value.email) {
    return currentUser.value.email.substring(0, 2).toUpperCase()
  }
  
  return 'U'
})

async function handleSignOut() {
  await signOut()
  router.push({ name: 'Home' })
}
</script>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
