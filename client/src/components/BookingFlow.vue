<template>
  <div class="space-y-8">
    
    <!-- Stepper Indicator -->
    <div class="flex items-center justify-center space-x-4 mb-8">
      <div v-for="step in 4" :key="step" class="flex items-center">
        <div 
          :class="['h-10 w-10 flex items-center justify-center rounded-full border-2 text-sm font-bold transition-colors',
            currentStep === step ? 'border-primary bg-primary text-primary-foreground shadow-md' : 
            currentStep > step ? 'border-primary bg-primary/20 text-primary' : 
            'border-muted bg-muted text-muted-foreground']"
        >
          {{ currentStep > step ? '✓' : step }}
        </div>
        <div v-if="step < 4" :class="['w-12 md:w-24 h-1 mx-2 rounded', currentStep > step ? 'bg-primary/50' : 'bg-muted']"></div>
      </div>
    </div>

    <!-- Step 1: Select Doctor -->
    <transition name="fade" mode="out-in">
      <Card v-if="currentStep === 1" class="border-primary/20 shadow-lg" key="step1">
        <CardHeader>
          <CardTitle>Select a Specialist</CardTitle>
          <CardDescription>Choose the doctor you would like to book an appointment with.</CardDescription>
        </CardHeader>
        <CardContent>
          <div v-if="doctorsLoading" class="py-12 flex justify-center text-muted-foreground animate-pulse">Loading doctors...</div>
          <div v-else-if="doctorsError" class="text-destructive py-4 text-center">Failed to load doctors. Please try again later.</div>
          
          <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div 
              v-for="doc in normalizedDoctors" 
              :key="doc.id" 
              @click="bookingData.doctorId = doc.id"
              :class="['p-4 rounded-xl border-2 cursor-pointer transition-all flex items-center gap-4', 
                       bookingData.doctorId === doc.id ? 'border-primary bg-primary/5 shadow-md' : 'border-muted hover:border-primary/50']"
            >
              <div class="h-12 w-12 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold shrink-0">
                {{ doc.firstName.charAt(0) }}{{ doc.lastName.charAt(0) }}
              </div>
              <div>
                <h4 class="font-bold">Dr. {{ doc.firstName }} {{ doc.lastName }}</h4>
                <p class="text-sm text-muted-foreground whitespace-normal">{{ doc.specialty }}</p>
              </div>
              <div class="ml-auto">
                <div v-if="bookingData.doctorId === doc.id" class="h-6 w-6 rounded-full bg-primary flex items-center justify-center text-primary-foreground text-xs">✓</div>
              </div>
            </div>
          </div>
        </CardContent>
        <CardFooter class="flex justify-between border-t bg-muted/20 py-4">
          <Button variant="ghost" @click="$router.push('/doctors')">Cancel</Button>
          <Button @click="nextStep" :disabled="!bookingData.doctorId" size="lg">Continue</Button>
        </CardFooter>
      </Card>

      <!-- Step 2: Select Date & Time -->
      <Card v-else-if="currentStep === 2" class="border-primary/20 shadow-lg" key="step2">
        <CardHeader>
          <CardTitle>Choose Date & Time</CardTitle>
          <CardDescription>Select an available slot for Dr. {{ selectedDoctorName }}</CardDescription>
        </CardHeader>
        <CardContent class="grid md:grid-cols-2 gap-8">
          
          <!-- Date Picker Column -->
          <div>
            <label class="block text-sm font-medium mb-2">Select Date</label>
            <input 
              type="date" 
              v-model="bookingData.date" 
              :min="todayStr"
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            />
          </div>

          <!-- Time Slots Column -->
          <div>
            <label class="block text-sm font-medium mb-2">Available Times</label>
            
            <div v-if="!bookingData.date" class="text-sm text-muted-foreground italic p-4 bg-muted/30 rounded border border-dashed">
              Please select a date first
            </div>
            <div v-else-if="slotsLoading" class="flex items-center gap-2 text-sm text-muted-foreground animate-pulse p-4">
              <span class="h-4 w-4 border-2 border-primary border-t-transparent rounded-full animate-spin"></span> Checking availability...
            </div>
            <div v-else-if="slotsError" class="text-destructive text-sm p-4 bg-destructive/10 rounded">
              Unable to fetch slots.
            </div>
            <div v-else-if="!availableSlots || availableSlots.length === 0" class="text-sm p-4 bg-muted/30 rounded border border-dashed text-center">
              No available slots on this date.
            </div>
            <div v-else class="grid grid-cols-3 gap-2 max-h-64 overflow-y-auto pr-2 pb-2">
              <button
                v-for="time in availableSlots" 
                :key="time"
                @click="bookingData.time = time"
                :class="['py-2 px-1 text-sm font-medium rounded-md border transition-all text-center cursor-pointer', 
                         bookingData.time === time ? 'bg-primary border-primary text-primary-foreground shadow' : 'bg-background hover:border-primary/50']"
              >
                {{ time }}
              </button>
            </div>
          </div>
        </CardContent>
        <CardFooter class="flex justify-between border-t bg-muted/20 py-4">
          <Button variant="outline" @click="prevStep">Back</Button>
          <Button @click="nextStep" :disabled="!bookingData.date || !bookingData.time" size="lg">Continue</Button>
        </CardFooter>
      </Card>

      <!-- Step 3: Patient Details -->
      <Card v-else-if="currentStep === 3" class="border-primary/20 shadow-lg" key="step3">
        <CardHeader>
          <CardTitle>Appointment Details</CardTitle>
          <CardDescription>Please provide additional information for the doctor.</CardDescription>
        </CardHeader>
        <CardContent class="space-y-6">
          <div class="space-y-2">
            <label class="text-sm font-medium leading-none">Contact Number <span class="text-destructive">*</span></label>
            <div class="vue-tel-input-custom" :class="{ 'is-invalid': phoneInput && !isPhoneValid, 'is-valid': phoneInput && isPhoneValid }">
              <vue-tel-input
                v-model="phoneInput"
                v-bind="telInputOptions"
                @validate="onPhoneValidate"
              />
            </div>
            <p v-if="phoneInput && !isPhoneValid" class="text-[10px] text-destructive italic mt-1">Please enter a valid phone number.</p>
          </div>
          <div class="space-y-2">
            <label for="reason" class="text-sm font-medium leading-none">Reason for Visit <span class="text-destructive">*</span></label>
            <textarea
              id="reason"
              v-model="bookingData.reason"
              rows="4"
              maxlength="500"
              @input="sanitizeReason"
              placeholder="Briefly describe your symptoms or reason for the appointment..."
              class="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 resize-none"
            ></textarea>
            <p class="text-xs text-muted-foreground text-right">{{ (bookingData.reason || '').length }}/500</p>
          </div>
        </CardContent>
        <CardFooter class="flex justify-between border-t bg-muted/20 py-4">
          <Button variant="outline" @click="prevStep">Back</Button>
          <Button @click="nextStep" :disabled="!isPhoneValid || !bookingData.reason || bookingData.reason.trim().length === 0" size="lg">Review Details</Button>
        </CardFooter>
      </Card>

      <!-- Step 4: Review & Confirm -->
      <Card v-else-if="currentStep === 4" class="border-primary/20 shadow-lg relative overflow-hidden" key="step4">
        
        <!-- Loading overlay -->
        <div v-if="submittingBooking" class="absolute inset-0 bg-background/80 backdrop-blur-sm z-10 flex flex-col items-center justify-center">
          <div class="h-12 w-12 border-4 border-primary border-t-transparent rounded-full animate-spin mb-4"></div>
          <p class="font-medium text-lg">Confirming appointment...</p>
        </div>

        <CardHeader>
          <CardTitle>Review & Confirm</CardTitle>
          <CardDescription>Please verify your appointment details before finalizing.</CardDescription>
        </CardHeader>
        <CardContent class="space-y-6">
          <div class="rounded-xl border bg-muted/30 p-6 space-y-4">
            <div class="flex items-start justify-between border-b border-border/50 pb-4">
              <div>
                <p class="text-sm text-muted-foreground font-medium">Doctor</p>
                <p class="text-lg font-bold">Dr. {{ selectedDoctorName }}</p>
              </div>
              <div class="text-right ml-4">
                <p class="text-sm text-muted-foreground font-medium">Specialty</p>
                <p class="text-base font-medium whitespace-normal">{{ selectedDoctorSpecialty }}</p>
              </div>
            </div>
            
            <div class="flex items-start justify-between border-b border-border/50 pb-4">
              <div>
                <p class="text-sm text-muted-foreground font-medium">Date</p>
                <p class="text-lg font-bold">{{ formattedDate }}</p>
              </div>
              <div class="text-right">
                <p class="text-sm text-muted-foreground font-medium">Time</p>
                <p class="text-lg font-bold text-primary">{{ bookingData.time }}</p>
              </div>
            </div>

            <div class="border-b border-border/50 pb-4">
                <p class="text-sm text-muted-foreground font-medium mb-1">Contact Number</p>
                <p class="text-base font-medium">{{ bookingData.contact }}</p>
            </div>

             <div>
                <p class="text-sm text-muted-foreground font-medium mb-1">Reason for Visit</p>
                <p class="text-sm bg-background p-3 rounded-md border">{{ bookingData.reason }}</p>
            </div>
          </div>
          
          <div v-if="submissionError" class="bg-destructive/10 text-destructive p-4 rounded border border-destructive/20 text-sm font-medium">
            {{ submissionError }}
          </div>
        </CardContent>
        <CardFooter class="flex justify-between border-t bg-muted/20 py-4">
          <Button variant="outline" @click="prevStep" :disabled="submittingBooking">Back</Button>
          <Button @click="submitBooking" :disabled="submittingBooking" size="lg" class="bg-primary shadow-md hover:shadow-lg transition-shadow">
            Confirm Booking
          </Button>
        </CardFooter>
      </Card>
      
      <!-- Success View (Step 5 visually) -->
      <Card v-else-if="currentStep === 5" class="border-green-500/30 shadow-xl bg-green-500/5 supports-[backdrop-filter]:bg-background/80" key="step5">
        <CardContent class="py-16 flex flex-col items-center text-center">
          <div class="h-24 w-24 bg-green-500 text-white rounded-full flex items-center justify-center text-5xl mb-8 shadow-lg shadow-green-500/30 ring-8 ring-green-500/20">
            ✓
          </div>
          <h2 class="text-3xl font-extrabold mb-2">Booking Confirmed!</h2>
          <p class="text-lg text-muted-foreground max-w-md mx-auto mb-8">
            Your appointment with <span class="font-bold text-foreground">Dr. {{ selectedDoctorName }}</span> on <span class="font-bold text-foreground">{{ formattedDate }} at {{ bookingData.time }}</span> is successfully scheduled.
          </p>
          <div class="flex gap-4">
            <Button variant="outline" @click="$router.push('/dashboard')">View Dashboard</Button>
            <Button @click="$router.push('/')">Return Home</Button>
          </div>
        </CardContent>
      </Card>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_DOCTORS_QUERY, GET_AVAILABLE_SLOTS_QUERY } from '@/graphql/queries'
import { BOOK_APPOINTMENT_MUTATION } from '@/graphql/mutations'
import { Button } from '@/components/ui/button'
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { VueTelInput } from 'vue-tel-input'
import 'vue-tel-input/vue-tel-input.css'

const props = defineProps({
  initialDoctorId: {
    type: String,
    default: null
  }
})

const router = useRouter()
const currentStep = ref(1)

const bookingData = ref({
  doctorId: null,
  date: '',
  time: '',
  contact: '',
  reason: ''
})

// Phone input state
const phoneInput = ref('')
const isPhoneValid = ref(false)
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
    bookingData.value.contact = validation.number
    formattedPhone.value = validation.number
  } else {
    bookingData.value.contact = ''
  }
}

// Sanitize reason for visit — strip HTML tags and dangerous characters
function sanitizeReason() {
  if (bookingData.value.reason) {
    bookingData.value.reason = bookingData.value.reason
      .replace(/<[^>]*>/g, '')  // Strip HTML tags
      .replace(/[<>]/g, '')     // Remove any remaining angle brackets
  }
}

// --- Data Fetching ---

// Load Doctors
const { result: doctorsResult, loading: doctorsLoading, error: doctorsError } = useQuery(GET_DOCTORS_QUERY)
const normalizedDoctors = computed(() => {
  return doctorsResult.value?.doctors || []
})

// Determine Today's date string for min-date picker
const todayStr = computed(() => {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
})

// Load Slots contextually based on Selected Doctor & Date
const slotsVariables = computed(() => ({
  doctorId: bookingData.value.doctorId,
  date: bookingData.value.date
}))
const slotsEnabled = computed(() => !!bookingData.value.doctorId && !!bookingData.value.date)

const { result: slotsResult, loading: slotsLoading, error: slotsError, refetch: refetchSlots } = useQuery(
  GET_AVAILABLE_SLOTS_QUERY,
  slotsVariables,
  {
    enabled: slotsEnabled,
    fetchPolicy: 'network-only', // always get fresh slots
    pollInterval: 30000 // Auto-refresh every 30 seconds for real-time freshness
  }
)

const availableSlots = computed(() => slotsResult.value?.availableSlots || [])

// Reactively reset Time selection if Date changes
watch(() => bookingData.value.date, () => {
  bookingData.value.time = ''
  if (slotsEnabled.value) refetchSlots()
})

// Initialization effect wrapper
onMounted(() => {
  if (props.initialDoctorId) {
    bookingData.value.doctorId = props.initialDoctorId
    // If we have a legit prepopulated doctor, skip to step 2 visually
    currentStep.value = 2
  }
})

// --- Helper Computeds ---
const selectedDoctor = computed(() => {
  return normalizedDoctors.value.find(d => d.id === bookingData.value.doctorId)
})
const selectedDoctorName = computed(() => selectedDoctor.value ? `${selectedDoctor.value.firstName} ${selectedDoctor.value.lastName}` : '')
const selectedDoctorSpecialty = computed(() => selectedDoctor.value ? selectedDoctor.value.specialty : '')

const formattedDate = computed(() => {
  if (!bookingData.value.date) return ''
  // E.g. "Monday, Oct 14, 2024"
  return new Date(bookingData.value.date + 'T00:00:00').toLocaleDateString(undefined, {
    weekday: 'long', year: 'numeric', month: 'short', day: 'numeric'
  })
})

// --- Navigation Methods ---
const nextStep = () => {
  if (currentStep.value < 4) currentStep.value++
}
const prevStep = () => {
  if (currentStep.value > 1) {
    // If the user came in prepopulated, going back from Date selection should maybe stay or reset. Let's allow step 1.
    currentStep.value--
  }
}

// --- Submission ---
const { mutate: bookAppointmentMutation } = useMutation(BOOK_APPOINTMENT_MUTATION)
const submittingBooking = ref(false)
const submissionError = ref(null)

const submitBooking = async () => {
  submittingBooking.value = true
  submissionError.value = null
  
  try {
    // Parse the date and time strings into proper ISO8601DateTime
    const startObj = new Date(`${bookingData.value.date}T${bookingData.value.time}:00`)
    
    // Add 15 minutes for the end time
    const endObj = new Date(startObj.getTime() + 15 * 60000)
    
    const variables = {
      doctorId: bookingData.value.doctorId,
      startDatetime: startObj.toISOString(),
      endDatetime: endObj.toISOString(),
      contactNumber: bookingData.value.contact,
      reasonForVisit: bookingData.value.reason
    }

    const res = await bookAppointmentMutation(variables)
    const payload = res.data.bookAppointment
    
    if (payload.errors && payload.errors.length > 0) {
      submissionError.value = payload.errors.join(', ')
    } else {
      // Success!
      currentStep.value = 5 // Show success state
    }
  } catch (err) {
    console.error("Booking failed:", err)
    submissionError.value = err.message || "An unexpected error occurred. Please try again."
  } finally {
    submittingBooking.value = false
  }
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

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
  z-index: 100;
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
