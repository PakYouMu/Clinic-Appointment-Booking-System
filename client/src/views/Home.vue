<template>
  <div class="flex min-h-screen flex-col bg-background">
    <!-- Header -->
    <header class="border-b bg-card">
      <div class="mx-auto flex h-16 max-w-5xl items-center justify-between px-4">
        <h1 class="text-lg font-semibold tracking-tight">
          Vue + Rails Boilerplate
        </h1>

        <div class="flex items-center gap-4">
          <span class="text-sm text-muted-foreground">
            {{ currentUser?.email }}
          </span>
          <Button variant="outline" size="sm" @click="handleSignOut" :disabled="signingOut">
            {{ signingOut ? 'Signing out…' : 'Sign Out' }}
          </Button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="mx-auto flex w-full max-w-5xl flex-1 flex-col items-center justify-center px-4 py-12">
      <Card class="w-full max-w-lg text-center">
        <CardHeader>
          <CardTitle class="text-3xl font-bold tracking-tight">
            Welcome! 🎉
          </CardTitle>
          <CardDescription class="text-base">
            You are successfully authenticated as
            <span class="font-medium text-foreground">{{ currentUser?.email }}</span>
          </CardDescription>
        </CardHeader>
        <CardContent class="space-y-4">
          <p class="text-sm text-muted-foreground">
            This boilerplate is ready for you to start building.
            The backend is powered by Rails + GraphQL, and the frontend
            uses Vue 3 + Apollo with Shadcn Vue components.
          </p>

          <div class="rounded-lg border bg-muted/50 p-4">
            <h3 class="mb-2 font-semibold text-sm">Stack Overview</h3>
            <div class="grid grid-cols-2 gap-2 text-xs text-muted-foreground">
              <div class="rounded-md bg-background p-2">🖥️ Vue 3 + Vite</div>
              <div class="rounded-md bg-background p-2">🚀 Apollo Client</div>
              <div class="rounded-md bg-background p-2">💎 Rails 8 API</div>
              <div class="rounded-md bg-background p-2">📡 GraphQL</div>
              <div class="rounded-md bg-background p-2">🔐 JWT Auth (HttpOnly)</div>
              <div class="rounded-md bg-background p-2">🎨 Shadcn Vue</div>
            </div>
          </div>
        </CardContent>
      </Card>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card'

const router = useRouter()
const { currentUser, signOut } = useAuth()

const signingOut = ref(false)

async function handleSignOut() {
  signingOut.value = true
  try {
    await signOut()
    router.push({ name: 'Login' })
  } finally {
    signingOut.value = false
  }
}
</script>
