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

          <div class="space-y-2">
            <Label for="register-phone">Phone Number</Label>
            <div class="vue-tel-input-custom" :class="{ 'is-invalid': phoneTouched && !isPhoneValid, 'is-valid': phoneTouched && isPhoneValid }">
              <vue-tel-input
                v-model="form.phoneNumber"
                v-bind="telInputOptions"
                @validate="onPhoneValidate"
                @input="onPhoneInput"
              />
            </div>
            <p v-if="phoneTouched && !isPhoneValid" class="text-[10px] text-destructive italic mt-1">
              Please enter a valid phone number.
            </p>
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

          <Button type="submit" class="w-full" size="lg" :disabled="submitting || !isFormValid">
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
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import { VueTelInput } from 'vue-tel-input'
import 'vue-tel-input/vue-tel-input.css'

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
  phoneNumber: '',
  adminSecret: ''
})

const submitting = ref(false)
const errorMessage = ref('')

// Phone handling
const isPhoneValid = ref(false)
const phoneTouched = ref(false)
const formattedPhone = ref('')

const telInputOptions = {
  defaultCountry: 'PH',
  preferredCountries: ['PH', 'US', 'GB', 'SG', 'AU'],
  inputOptions: {
    placeholder: 'Enter phone number',
    required: true,
    autocomplete: 'tel'
  },
  dropdownOptions: {
    showDialCodeInList: true,
    showDialCodeInSelection: true,
    showFlags: true,
    showSearchBox: true
  },
  mode: 'international'
}

const onPhoneValidate = (validation) => {
  isPhoneValid.value = validation.valid
  if (validation.valid) {
    formattedPhone.value = validation.number
  }
}

const onPhoneInput = () => {
  phoneTouched.value = true
}

const isFormValid = computed(() => {
  return form.email && 
         form.password && 
         isPhoneValid.value && 
         form.password === form.passwordConfirmation && 
         form.adminSecret
})

async function handleSubmit() {
  errorMessage.value = ''

  if (!isFormValid.value) {
    if (form.password !== form.passwordConfirmation) {
      errorMessage.value = 'Passwords do not match'
    } else if (!isPhoneValid.value) {
      errorMessage.value = 'Please enter a valid phone number'
    }
    return
  }

  submitting.value = true
  try {
    await signUp({
      email: form.email,
      password: form.password,
      passwordConfirmation: form.passwordConfirmation,
      phoneNumber: formattedPhone.value,
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

<style scoped>
/* vue-tel-input overrides to match shadcn design system */
.vue-tel-input-custom {
  position: relative;
  width: 100%;
}

.vue-tel-input-custom :deep(.vue-tel-input) {
  border: 1px solid var(--input);
  border-radius: var(--radius-md);
  background-color: var(--background);
  font-size: 0.875rem;
  height: 2.5rem;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-shadow: none;
}

.vue-tel-input-custom :deep(.vue-tel-input:focus-within) {
  outline: none;
  box-shadow: 0 0 0 2px var(--background), 0 0 0 4px var(--ring);
  border-color: var(--ring);
}

.vue-tel-input-custom :deep(.vti__input) {
  background: transparent;
  font-size: 0.875rem;
  color: var(--foreground);
  border-radius: 0 var(--radius-md) var(--radius-md) 0;
}

.vue-tel-input-custom :deep(.vti__input::placeholder) {
  color: var(--muted-foreground);
}

.vue-tel-input-custom :deep(.vti__dropdown) {
  background-color: var(--background);
  border-right: 1px solid var(--input);
  border-radius: var(--radius-md) 0 0 var(--radius-md);
  padding: 0 0.5rem;
}

.vue-tel-input-custom :deep(.vti__dropdown:hover),
.vue-tel-input-custom :deep(.vti__dropdown.open) {
  background-color: var(--muted);
}

.vue-tel-input-custom :deep(.vti__dropdown-list) {
  background-color: var(--popover);
  color: var(--popover-foreground);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  z-index: 50;
  width: 300px;
  max-height: 250px;
  margin-top: 4px;
}

.vue-tel-input-custom :deep(.vti__dropdown-item) {
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
}

.vue-tel-input-custom :deep(.vti__dropdown-item:hover),
.vue-tel-input-custom :deep(.vti__dropdown-item.highlighted) {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

.vue-tel-input-custom :deep(.vti__search_box) {
  background-color: var(--background);
  border: 1px solid var(--input);
  border-radius: var(--radius-sm);
  color: var(--foreground);
  margin: 0.5rem;
  padding: 0.375rem 0.5rem;
  font-size: 0.875rem;
  width: calc(100% - 1rem);
}

/* Validation states */
.vue-tel-input-custom.is-valid :deep(.vue-tel-input) {
  border-color: oklch(0.627 0.194 149.214); /* success color */
}

.vue-tel-input-custom.is-invalid :deep(.vue-tel-input) {
  border-color: var(--destructive);
}
</style>
