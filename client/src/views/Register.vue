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
            <Label for="register-first-name">First Name</Label>
            <Input
              id="register-first-name"
              v-model="form.firstName"
              type="text"
              placeholder="Jane"
              required
            />
          </div>

          <div class="space-y-2">
            <Label for="register-last-name">Last Name</Label>
            <Input
              id="register-last-name"
              v-model="form.lastName"
              type="text"
              placeholder="Doe"
              required
            />
          </div>

          <div class="space-y-2">
            <Label for="register-phone">Phone Number</Label>
            <Input
              id="register-phone"
              v-model="form.phoneNumber"
              type="tel"
              placeholder="(555) 123-4567"
              required
            />
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

          <Button type="submit" class="w-full" size="lg" :disabled="submitting">
            <Loader2 v-if="submitting" class="animate-spin mr-2 h-4 w-4" />
            {{ submitting ? 'Creating account…' : 'Sign Up' }}
          </Button>
        </form>
      </CardContent>

      <CardFooter class="flex justify-center">
        <p class="text-sm text-muted-foreground">
          Already have an account?
          <router-link
            to="/login"
            class="font-medium text-primary underline-offset-4 hover:underline"
          >
            Sign in
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
const { signUp } = useAuth()

const form = reactive({
  firstName: '',
  lastName: '',
  phoneNumber: '',
  email: '',
  password: '',
  passwordConfirmation: ''
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
    // 2. Pass the new form fields to the signUp function
    await signUp({
      firstName: form.firstName,
      lastName: form.lastName,
      phoneNumber: form.phoneNumber,
      email: form.email,
      password: form.password,
      passwordConfirmation: form.passwordConfirmation
    })
    router.push({ name: 'PatientDashboard' })
  } catch (err) {
    errorMessage.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>
