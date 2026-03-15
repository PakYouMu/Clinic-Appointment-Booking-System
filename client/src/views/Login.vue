<template>
  <div class="flex min-h-screen items-center justify-center bg-background px-4">
    <Card class="w-full max-w-md">
      <CardHeader class="space-y-4 text-center">
        <div class="flex items-center justify-center gap-3">
          <div class="h-10 w-10 rounded bg-primary flex items-center justify-center text-primary-foreground font-italic text-xl">M</div>
          <span class="text-2xl font-bold italic tracking-tighter">Mustard Clinic</span>
        </div>
        <div>
          <CardTitle class="text-xl font-bold tracking-tight">
            Welcome back
          </CardTitle>
          <CardDescription class="text-muted-foreground">
            Sign in to your account to continue
          </CardDescription>
        </div>
      </CardHeader>

      <CardContent>
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div
            v-if="errorMessage"
            class="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive"
          >
            {{ errorMessage }}
          </div>

          <div class="space-y-2">
            <Label for="login-email">Email</Label>
            <Input
              id="login-email"
              v-model="form.email"
              type="email"
              placeholder="you@example.com"
              required
              autocomplete="email"
            />
          </div>

          <div class="space-y-2">
            <Label for="login-password">Password</Label>
            <Input
              id="login-password"
              v-model="form.password"
              type="password"
              placeholder="Enter your password"
              required
              autocomplete="current-password"
            />
          </div>

          <Button type="submit" class="w-full" size="lg" :disabled="submitting">
            <Loader2 v-if="submitting" class="animate-spin mr-2 h-4 w-4" />
            {{ submitting ? 'Signing in…' : 'Sign In' }}
          </Button>
        </form>
      </CardContent>

      <CardFooter class="flex justify-center">
        <p class="text-sm text-muted-foreground">
          Don't have an account?
          <router-link
            to="/register"
            class="font-medium text-primary underline-offset-4 hover:underline"
          >
            Sign up
          </router-link>
        </p>
      </CardFooter>
    </Card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Loader2 } from 'lucide-vue-next'
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle
} from '@/components/ui/card'

const router = useRouter()
const { signIn } = useAuth()

const form = reactive({
  email: '',
  password: ''
})

const submitting = ref(false)
const errorMessage = ref('')

async function handleSubmit() {
  errorMessage.value = ''
  submitting.value = true

  try {
    await signIn({
      email: form.email,
      password: form.password
    })
    router.push({ name: 'PatientDashboard' })
  } catch (err) {
    errorMessage.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>
