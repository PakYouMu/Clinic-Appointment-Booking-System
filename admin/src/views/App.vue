<template>
  <div v-if="loading" class="flex min-h-screen items-center justify-center bg-background">
    <div class="text-muted-foreground animate-pulse">Loading…</div>
  </div>
  <router-view v-else />
</template>

<script setup>
import { useAuth } from '@/composables/useAuth'

const { loading } = useAuth()
</script>