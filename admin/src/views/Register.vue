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
            Create an account
          </CardTitle>
          <CardDescription class="text-muted-foreground">
            Enter your details below to get started
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
            <Label for="register-email">Email</Label>
            <Input
              id="register-email"
              v-model="form.email"
              type="email"
              placeholder="you@example.com"
              required
              autocomplete="email"
            />
          </div>

          <div class="space-y-2">
            <Label for="register-password">Password</Label>
            <Input
              id="register-password"
              v-model="form.password"
              type="password"
              placeholder="Min. 8 characters"
              required
              minlength="8"
              autocomplete="new-password"
            />
          </div>

          <div class="space-y-2">
            <Label for="register-password-confirm">Confirm Password</Label>
            <Input
              id="register-password-confirm"
              v-model="form.passwordConfirmation"
              type="password"
              placeholder="Repeat your password"
              required
              minlength="8"
              autocomplete="new-password"
            />
          </div>

          <div class="space-y-2 py-2">
            <div class="flex items-center justify-between">
              <Label for="register-secret" class="text-primary font-bold">Admin Secret Code</Label>
              <span class="text-[10px] text-muted-foreground uppercase font-black px-1.5 py-0.5 bg-muted rounded">Required</span>
            </div>
            <Input
              id="register-secret"
              v-model="form.adminSecret"
              type="password"
              placeholder="Enter internal registration code"
              required
            />
            <p class="text-[10px] text-muted-foreground italic">
              This code is required for internal clinic staff registration.
            </p>
          </div>

          <Button type="submit" class="w-full" size="lg" :disabled="submitting">
            <Loader2 v-if="submitting" class="animate-spin mr-2 h-4 w-4" />
            {{ submitting ? 'Authorizing & Creating…' : 'Register Admin Account' }}
          </Button>
        </form>
      </CardContent>

      <CardFooter class="flex flex-col gap-2 pt-0 pb-6">
        <div class="h-px w-full bg-border"></div>
        <p class="text-[10px] text-muted-foreground text-center px-6">
          Authorized User Access Only. All registration attempts are logged for security auditing.
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
const { signUp } = useAuth()

const form = reactive({
  email: '',
  password: '',
  passwordConfirmation: '',
  adminSecret: ''
})

const submitting = ref(false)
const errorMessage = ref('')

async function handleSubmit() {
  errorMessage.value = ''

  if (form.password !== form.passwordConfirmation) {
    errorMessage.value = 'Passwords do not match'
    return
  }

  submitting.value = true
  try {
    await signUp({
      email: form.email,
      password: form.password,
      passwordConfirmation: form.passwordConfirmation,
      adminSecret: form.adminSecret
    })
    router.push({ name: 'Home' })
  } catch (err) {
    errorMessage.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>
