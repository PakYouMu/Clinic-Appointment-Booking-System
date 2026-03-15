<template>
  <div class="container mx-auto px-4 py-8 md:py-16 max-w-5xl bg-background min-h-[calc(100vh-4rem)]">
    <div class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="text-3xl md:text-5xl font-extrabold tracking-tight mb-2 text-foreground">
          My Dashboard
        </h1>
        <p class="text-muted-foreground text-lg">
          Manage your upcoming appointments and view your medical history.
        </p>
      </div>
      <Button @click="$router.push('/doctors')" size="lg" class="shrink-0 gap-2">
        <Plus class="h-5 w-5" />
        <span>Book New Appointment</span>
      </Button>
    </div>

    <!-- Loading & Error States -->
    <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-muted-foreground animate-pulse">
      <div class="h-10 w-10 border-4 border-primary border-t-transparent rounded-full animate-spin mb-4"></div>
      <p>Loading your profile...</p>
    </div>
    
    <div v-else-if="error" class="bg-destructive/10 text-destructive p-6 rounded-lg border border-destructive/20 mb-8">
      <h3 class="font-bold mb-2 text-lg">Unable to load dashboard</h3>
      <p>{{ error.message }}</p>
      <Button variant="outline" class="mt-4" @click="refetch">Try Again</Button>
    </div>

    <!-- Main Content -->
    <div v-else class="space-y-12">
      <!-- Inline Action Feedback -->
      <div v-if="errorMessage" class="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive animate-in fade-in slide-in-from-top-2 duration-300">
        <div class="flex items-center gap-2">
          <AlertCircle class="h-4 w-4" />
          <span>{{ errorMessage }}</span>
        </div>
      </div>
      
      <!-- Upcoming Appointments Section -->
      <section>
        <div class="border-b pb-2 mb-6 flex items-center gap-3">
          <div class="h-8 w-2 bg-primary rounded-full"></div>
          <h2 class="text-2xl font-bold">Upcoming Appointments</h2>
          <span class="bg-primary/10 text-primary text-xs font-bold px-2 py-1 rounded-full">{{ upcomingAppointments.length }}</span>
        </div>

        <div v-if="upcomingAppointments.length === 0" class="bg-muted/30 border border-dashed rounded-xl p-12 text-center text-muted-foreground">
          <p class="mb-4">You have no upcoming appointments.</p>
          <Button variant="outline" @click="$router.push('/doctors')">Find a Doctor</Button>
        </div>

        <div v-else class="grid gap-6 md:grid-cols-2">
          <Card v-for="appt in upcomingAppointments" :key="appt.id" class="border-primary/20 shadow-md relative overflow-hidden group">
            <div class="absolute top-0 left-0 w-1 h-full bg-primary"></div>
            <CardHeader class="pb-3">
              <div class="flex justify-between items-start mb-1">
                <span class="bg-primary/10 text-primary text-xs font-bold px-2.5 py-0.5 rounded uppercase tracking-wider">Booked</span>
              </div>
              <CardTitle class="text-xl">Dr. {{ appt.doctor.firstName }} {{ appt.doctor.lastName }}</CardTitle>
              <CardDescription class="whitespace-normal">{{ appt.doctor.specialty }}</CardDescription>
            </CardHeader>
            <CardContent class="pb-4 space-y-3">
              <div class="flex items-center gap-3 text-sm">
                  <div class="h-8 w-8 rounded-full bg-muted flex items-center justify-center shrink-0">
                    <CalendarDays class="h-4 w-4 text-muted-foreground" />
                  </div>
                 <div>
                   <p class="font-medium">{{ formatDate(appt.startDatetime) }}</p>
                   <p class="text-muted-foreground">{{ formatTime(appt.startDatetime) }}</p>
                 </div>
              </div>
              
              <div v-if="appt.reasonForVisit" class="text-sm bg-muted/40 p-3 rounded border">
                <p class="text-xs text-muted-foreground font-semibold mb-1 uppercase tracking-widest">Reason</p>
                <p>{{ appt.reasonForVisit }}</p>
              </div>
            </CardContent>
            <CardFooter class="pt-2 border-t bg-muted/10 flex justify-end gap-3">
              <Button 
                variant="destructive" 
                size="sm" 
                variant-type="outline"
                @click="openCancelDialog(appt)"
                :disabled="isCancelling || !isCancellable(appt.startDatetime)"
                :title="!isCancellable(appt.startDatetime) ? 'Appointments starting within 1 hour cannot be cancelled online.' : ''"
              >
                {{ isCancelling === appt.id ? 'Cancelling...' : 'Cancel Appointment' }}
              </Button>
            </CardFooter>
          </Card>
        </div>
      </section>

      <!-- History Section -->
      <section>
        <div class="border-b pb-2 mb-6 flex items-center gap-3 opacity-80">
          <div class="h-8 w-2 bg-muted-foreground rounded-full"></div>
          <h2 class="text-2xl font-bold">Past & Cancelled</h2>
        </div>

        <div v-if="pastAppointments.length === 0" class="text-muted-foreground italic px-4">
          No history found.
        </div>

        <div v-else class="grid gap-4">
          <div v-for="appt in pastAppointments" :key="appt.id" 
               class="bg-card border rounded-lg p-5 flex flex-col md:flex-row md:items-center justify-between gap-4 transition-colors hover:bg-muted/20">
            
            <div class="flex items-start gap-4">
              <div :class="['h-10 w-10 rounded-full flex items-center justify-center shrink-0 text-white shadow-sm', statusColors(appt.status).bg]">
                 <component :is="statusIcon(appt.status)" class="h-5 w-5" />
              </div>
              <div>
                <h4 class="font-bold whitespace-normal">Dr. {{ appt.doctor.firstName }} {{ appt.doctor.lastName }}</h4>
                <p class="text-sm text-muted-foreground whitespace-normal">{{ appt.doctor.specialty }}</p>
                <p class="text-sm text-muted-foreground whitespace-normal">{{ formatDate(appt.startDatetime) }} at {{ formatTime(appt.startDatetime) }}</p>
              </div>
            </div>

            <div class="flex items-center gap-4">
              <span :class="['px-3 py-1 text-xs font-bold rounded-full uppercase tracking-wider border', statusColors(appt.status).badge]">
                {{ formatStatus(appt.status) }}
              </span>
            </div>

          </div>
        </div>
      </section>

    </div>

    <!-- Cancel Confirmation Dialog -->
    <AlertDialog :open="showCancelDialog" @update:open="showCancelDialog = $event">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Cancel Appointment</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to cancel your appointment with
            <span class="font-semibold text-foreground">Dr. {{ cancelTarget?.doctor.firstName }} {{ cancelTarget?.doctor.lastName }}</span>?
            This action cannot be undone.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel @click="showCancelDialog = false">Keep Appointment</AlertDialogCancel>
          <AlertDialogAction variant="destructive" @click="confirmCancel">Yes, Cancel</AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_MY_APPOINTMENTS_QUERY } from '@/graphql/queries'
import { CANCEL_APPOINTMENT_MUTATION } from '@/graphql/mutations'
import { Button } from '@/components/ui/button'
import { 
  CalendarDays, 
  Plus, 
  CheckCircle2, 
  XCircle, 
  AlertCircle, 
  Circle 
} from 'lucide-vue-next'
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogFooter,
  AlertDialogTitle,
  AlertDialogDescription,
  AlertDialogAction,
  AlertDialogCancel,
} from '@/components/ui/alert-dialog'

// Fetch appointments hook
const { result, loading, error, refetch } = useQuery(GET_MY_APPOINTMENTS_QUERY, null, {
  fetchPolicy: 'cache-and-network' // Ensure we get fresh data when navigating
})

const { mutate: cancelMutation } = useMutation(CANCEL_APPOINTMENT_MUTATION)

const appointments = computed(() => result.value?.myAppointments || [])

// Sorting logic
const upcomingAppointments = computed(() => {
  const now = new Date()
  return appointments.value.filter(a => {
    return new Date(a.startDatetime) >= now && a.status === 'booked'
  }).sort((a, b) => new Date(a.startDatetime) - new Date(b.startDatetime))
})

const pastAppointments = computed(() => {
  const now = new Date()
  return appointments.value.filter(a => {
    return new Date(a.startDatetime) < now || a.status !== 'booked'
  })
})

// Cancellation handling
const isCancelling = ref(null)
const errorMessage = ref('')
const showCancelDialog = ref(false)
const cancelTarget = ref(null)

const isCancellable = (startDatetime) => {
  const ONE_HOUR = 60 * 60 * 1000
  const timeDiff = new Date(startDatetime).getTime() - new Date().getTime()
  return timeDiff > ONE_HOUR
}

const openCancelDialog = (appt) => {
  cancelTarget.value = appt
  showCancelDialog.value = true
}

const confirmCancel = async () => {
  showCancelDialog.value = false
  const appt = cancelTarget.value
  if (!appt) return
  
  isCancelling.value = appt.id
  try {
    const res = await cancelMutation({ id: appt.id })
    const payload = res.data.cancelAppointment
    
    if (payload.errors && payload.errors.length > 0) {
      errorMessage.value = payload.errors.join(', ')
    } else {
      errorMessage.value = ''
      await refetch()
    }
  } catch (err) {
    console.error(err)
    errorMessage.value = "Failed to cancel appointment. Please try again."
  } finally {
    isCancelling.value = null
    cancelTarget.value = null
  }
}

// Helpers
const formatDate = (isoStr) => {
  return new Date(isoStr).toLocaleDateString(undefined, {
    weekday: 'short', year: 'numeric', month: 'short', day: 'numeric'
  })
}

const formatTime = (isoStr) => {
  return new Date(isoStr).toLocaleTimeString(undefined, {
    hour: 'numeric', minute: '2-digit'
  })
}

const formatStatus = (status) => {
  if (status === 'no_show') return 'No Show'
  return status
}

const statusColors = (status) => {
  switch (status) {
    case 'completed': return { bg: 'bg-green-500', badge: 'bg-green-500/10 text-green-600 border-green-200' }
    case 'cancelled': return { bg: 'bg-destructive/80', badge: 'bg-destructive/10 text-destructive border-destructive/20' }
    case 'no_show': return { bg: 'bg-orange-500', badge: 'bg-orange-500/10 text-orange-600 border-orange-200' }
    default: return { bg: 'bg-muted-foreground', badge: 'bg-muted/50 text-muted-foreground border-muted' }
  }
}

const statusIcon = (status) => {
  switch (status) {
    case 'completed': return CheckCircle2
    case 'cancelled': return XCircle
    case 'no_show': return AlertCircle
    default: return Circle
  }
}
</script>
