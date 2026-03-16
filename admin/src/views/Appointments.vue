<template>
  <div class="space-y-6 animate-in slide-in-from-bottom-4 duration-500">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Appointments</h1>
        <p class="text-muted-foreground">Search and manage patient visits across your clinic.</p>
      </div>
    </div>

    <!-- Global Error message -->
    <div v-if="errorMessage" class="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive animate-in fade-in slide-in-from-top-2 duration-300">
      <div class="flex items-center gap-2">
        <CircleX class="h-4 w-4" />
        <span>{{ errorMessage }}</span>
      </div>
    </div>

    <!-- Filters Section -->
    <Card class="bg-card/50 backdrop-blur-md">
      <CardContent class="p-4 flex flex-wrap gap-4 items-end">
        <div class="space-y-1.5 flex-1 min-w-[200px]">
          <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">Filter by Date</label>
          <input v-model="filters.date" type="date" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm" />
        </div>
        
        <div class="space-y-1.5 flex-1 min-w-[200px]">
          <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">Doctor</label>
          <select v-model="filters.doctorId" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm">
            <option :value="null">All Doctors</option>
            <option v-for="d in doctors" :key="d.id" :value="d.id">Dr. {{ d.lastName }} ({{ d.specialty }})</option>
          </select>
        </div>

        <Button variant="outline" @click="resetFilters">Reset</Button>
      </CardContent>
    </Card>

    <!-- Appointments Table -->
    <Card class="border-none shadow-none bg-transparent">
      <CardContent class="p-0 flex flex-col">
        <!-- Fixed-height table container -->
        <div class="relative w-full overflow-auto rounded-t-xl border border-b-0 bg-card" style="min-height: 370px;">
          <table class="w-full caption-bottom text-sm">
            <thead class="bg-muted/50">
              <tr class="border-b transition-colors hover:bg-muted/50">
                <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground">Time & Details</th>
                <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground">Patient</th>
                <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground">Doctor</th>
                <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground">Status</th>
                <th class="h-12 px-4 text-right align-middle font-medium text-muted-foreground">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading" class="border-b">
                <td colspan="5" class="p-10 text-center animate-pulse text-muted-foreground">Querying specialists...</td>
              </tr>
              <tr v-else-if="appointments.length === 0" class="border-b">
                <td colspan="5" class="p-10 text-center text-muted-foreground italic">No appointments match your filters.</td>
              </tr>
              <tr 
                v-for="appt in paginatedAppointments" 
                :key="appt.id"
                class="border-b transition-colors hover:bg-muted/30"
              >
                <td class="p-4 align-middle">
                  <p class="font-bold">{{ formatDateTime(appt.startDatetime).date }}</p>
                  <p class="text-xs text-primary font-semibold">{{ formatDateTime(appt.startDatetime).time }}</p>
                  <p v-if="appt.reasonForVisit" class="text-[10px] mt-1 text-muted-foreground max-w-[150px] truncate" :title="appt.reasonForVisit">
                    "{{ appt.reasonForVisit }}"
                  </p>
                </td>
                <td class="p-4 align-middle">
                  <p class="font-medium text-sm">{{ appt.patient.firstName }} {{ appt.patient.lastName }}</p>
                  <p class="text-[10px] text-muted-foreground">{{ appt.contactNumber }}</p>
                </td>
                <td class="p-4 align-middle">
                  <p class="font-medium text-sm">Dr. {{ appt.doctor.lastName }}</p>
                  <p class="text-[10px] text-muted-foreground uppercase">{{ appt.doctor.specialty }}</p>
                </td>
                <td class="p-4 align-middle">
                  <span :class="['px-2.5 py-0.5 text-[10px] font-bold rounded-full uppercase tracking-wider', statusBadge(appt.status)]">
                    {{ formatStatus(appt.status) }}
                  </span>
                </td>
                <td class="p-4 align-middle text-right space-x-1">
                  <div v-if="appt.status === 'booked'" class="flex justify-end gap-1">
                    <Button 
                      variant="outline" 
                      size="sm" 
                      class="h-7 px-2 text-[10px] bg-green-50 text-green-700 border-green-200 hover:bg-green-100"
                      @click="handleStatusUpdate(appt.id, 'completed')"
                      :disabled="submitting === appt.id"
                    >
                      Complete
                    </Button>
                    <Button 
                      variant="outline" 
                      size="sm" 
                      class="h-7 px-2 text-[10px] bg-orange-50 text-orange-700 border-orange-200 hover:bg-orange-100"
                      @click="handleStatusUpdate(appt.id, 'no_show')"
                      :disabled="submitting === appt.id"
                    >
                      No Show
                    </Button>
                    <Button 
                      variant="outline" 
                      size="sm" 
                      class="h-7 px-2 text-[10px] bg-red-50 text-red-700 border-red-200 hover:bg-red-100"
                      @click="handleStatusUpdate(appt.id, 'cancelled')"
                      :disabled="submitting === appt.id"
                    >
                      Cancel
                    </Button>
                  </div>
                  <span v-else class="text-[10px] text-muted-foreground italic px-2">No further actions</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination Footer -->
        <div class="flex items-center justify-between rounded-b-xl border bg-card px-4 py-3">
          <p class="text-xs text-muted-foreground">
            <template v-if="!loading && appointments.length > 0">
              Showing {{ (currentPage - 1) * PAGE_SIZE + 1 }}–{{ Math.min(currentPage * PAGE_SIZE, appointments.length) }} of {{ appointments.length }}
            </template>
            <template v-else>
              No results
            </template>
          </p>
          <div class="flex items-center gap-1.5">
            <Button
              variant="outline"
              size="icon"
              class="h-8 w-8"
              :disabled="currentPage <= 1"
              @click="currentPage--"
            >
              <ChevronLeft class="h-4 w-4" />
            </Button>
            <span class="text-xs font-medium px-2">{{ currentPage }} / {{ totalPages || 1 }}</span>
            <Button
              variant="outline"
              size="icon"
              class="h-8 w-8"
              :disabled="currentPage >= totalPages"
              @click="currentPage++"
            >
              <ChevronRight class="h-4 w-4" />
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>

  <!-- Status Update Confirmation Dialog -->
  <AlertDialog :open="showConfirmDialog" @update:open="showConfirmDialog = $event">
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>Confirm Status Change</AlertDialogTitle>
        <AlertDialogDescription>
          Are you sure you want to mark this appointment as
          <span class="font-semibold text-foreground">{{ pendingStatus }}</span>?
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel @click="showConfirmDialog = false">Go Back</AlertDialogCancel>
        <AlertDialogAction
          :variant="pendingStatus === 'cancelled' ? 'destructive' : 'default'"
          @click="confirmStatusUpdate"
        >
          Yes, {{ pendingStatus === 'completed' ? 'Complete' : pendingStatus === 'no_show' ? 'Mark No Show' : 'Cancel' }}
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>

<script setup>
import { ref, computed, reactive, watch } from 'vue'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_ADMIN_APPOINTMENTS_QUERY, UPDATE_APPOINTMENT_STATUS_MUTATION } from '@/graphql/appointments'
import { GET_DOCTORS_QUERY } from '@/graphql/doctors'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { CircleX, ChevronLeft, ChevronRight } from 'lucide-vue-next'
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

const filters = reactive({
  date: null,
  doctorId: null
})

const { result: doctorsResult } = useQuery(GET_DOCTORS_QUERY)
const doctors = computed(() => doctorsResult.value?.doctors || [])

const { result, loading, refetch } = useQuery(GET_ADMIN_APPOINTMENTS_QUERY, filters)
const appointments = computed(() => result.value?.adminAppointments || [])

// Pagination
const PAGE_SIZE = 5
const currentPage = ref(1)
const totalPages = computed(() => Math.ceil(appointments.value.length / PAGE_SIZE))
const paginatedAppointments = computed(() => {
  const start = (currentPage.value - 1) * PAGE_SIZE
  return appointments.value.slice(start, start + PAGE_SIZE)
})

// Reset page when filters or data change
watch([() => filters.date, () => filters.doctorId], () => {
  currentPage.value = 1
})

const resetFilters = () => {
  filters.date = null
  filters.doctorId = null
}

const formatDateTime = (isoStr) => {
  const d = new Date(isoStr)
  return {
    date: d.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' }),
    time: d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })
  }
}

const formatStatus = (status) => status ? status.replace(/_/g, ' ') : ''

const statusBadge = (status) => {
  switch (status) {
    case 'booked': return 'bg-primary/10 text-primary'
    case 'completed': return 'bg-green-100 text-green-700'
    case 'cancelled': return 'bg-destructive/10 text-destructive'
    case 'no_show': return 'bg-orange-100 text-orange-700'
    default: return 'bg-muted text-muted-foreground'
  }
}

const submitting = ref(null)
const errorMessage = ref(null)
const showConfirmDialog = ref(false)
const pendingId = ref(null)
const pendingStatus = ref(null)
const { mutate: updateStatus } = useMutation(UPDATE_APPOINTMENT_STATUS_MUTATION)

function handleStatusUpdate(id, newStatus) {
  pendingId.value = id
  pendingStatus.value = newStatus
  showConfirmDialog.value = true
}

async function confirmStatusUpdate() {
  showConfirmDialog.value = false
  const id = pendingId.value
  const newStatus = pendingStatus.value
  if (!id || !newStatus) return

  submitting.value = id
  try {
    const res = await updateStatus({ appointmentId: id, status: newStatus })
    if (res.data.updateAppointmentStatus.errors.length > 0) {
      errorMessage.value = res.data.updateAppointmentStatus.errors.join(', ')
    } else {
      errorMessage.value = null
      await refetch()
    }
  } catch (e) {
    errorMessage.value = "Failed to update status: " + e.message
  } finally {
    submitting.value = null
    pendingId.value = null
    pendingStatus.value = null
  }
}
</script>
