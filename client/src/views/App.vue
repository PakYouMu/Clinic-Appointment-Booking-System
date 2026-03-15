<template>
  <div v-if="loading" class="flex min-h-screen items-center justify-center bg-background">
    <div class="flex flex-col items-center gap-4">
      <div class="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
      <p class="text-sm text-muted-foreground font-medium animate-pulse">Loading Application...</p>
    </div>
  </div>
  <router-view v-else />
</template>

<script setup>
import { useAuth } from '@/composables/useAuth'

const { loading } = useAuth()
</script>