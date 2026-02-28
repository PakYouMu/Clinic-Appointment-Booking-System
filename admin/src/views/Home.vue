<template>
  <div class="flex min-h-screen flex-col items-center justify-center bg-background p-4 text-center">
    <h1 class="admin-title font-black uppercase tracking-tighter text-primary">
      ADMIN
    </h1>
    <p class="mt-6 text-xl text-muted-foreground font-semibold">
      Vue + Rails Admin Dashboard
    </p>

    <Card v-if="currentUser" class="mt-8 w-full max-w-sm">
      <CardHeader>
        <CardDescription>Signed in as</CardDescription>
        <CardTitle class="text-lg">{{ currentUser.email }}</CardTitle>
      </CardHeader>
      <CardFooter class="flex justify-center">
        <Button variant="outline" size="sm" @click="handleSignOut" :disabled="signingOut">
          {{ signingOut ? 'Signing out…' : 'Sign Out' }}
        </Button>
      </CardFooter>
    </Card>

    <div v-else class="mt-8 flex gap-4">
      <Button as-child size="lg">
        <router-link to="/login">Sign In</router-link>
      </Button>
      <Button variant="outline" as-child size="lg">
        <router-link to="/register">Sign Up</router-link>
      </Button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardDescription,
  CardFooter,
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

<style scoped>
.admin-title {
  font-size: clamp(6rem, 20vw, 14rem);
  line-height: 1;
  letter-spacing: -0.05em;
}
</style>
