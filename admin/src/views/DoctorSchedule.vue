<template>
  <div class="space-y-6">
    <div class="flex items-center gap-4">
      <Button variant="ghost" size="sm" @click="$router.push('/doctors')">
        <span>←</span> Back
      </Button>
      <div>
        <h1 class="text-3xl font-bold tracking-tight">
          Manage Schedule: <span v-if="doctor" class="text-primary font-black uppercase tracking-tighter">Dr. {{ doctor.lastName }}</span>
        </h1>
        <p class="text-muted-foreground">Configure work hours and available slots for this specialist.</p>
      </div>
    </div>

    <div class="grid gap-6 lg:grid-cols-3">
      <!-- Right Side: Existing Schedules List (First to show state) -->
      <Card class="lg:col-span-2">
        <CardHeader>
          <CardTitle>Existing Shifts</CardTitle>
          <CardDescription>A list of upcoming availability tokens in the database.</CardDescription>
        </CardHeader>
        <CardContent>
          <div v-if="loading" class="py-12 flex justify-center text-muted-foreground animate-pulse">Loading schedules...</div>
          <div v-else-if="!doctor?.schedules || doctor.schedules.length === 0" class="py-12 text-center text-muted-foreground italic bg-muted/20 rounded-xl border-2 border-dashed">
            No shifts configured yet. Use the bulk tool on the right to get started.
          </div>
          <div v-else class="space-y-2">
            <div 
              v-for="s in paginatedSchedules" 
              :key="s.id"
              class="flex items-center justify-between p-3 rounded-lg border bg-card hover:bg-muted/30 transition-colors"
            >
              <div class="flex items-center gap-4">
                <div class="h-10 w-10 rounded bg-primary/10 flex flex-col items-center justify-center font-bold text-primary text-xs uppercase">
                  <span>{{ new Date(s.date).toLocaleDateString(undefined, { month: 'short' }) }}</span>
                  <span class="text-lg leading-none">{{ new Date(s.date).getDate() }}</span>
                </div>
                <div>
                  <p class="font-bold">{{ s.startTime }} - {{ s.endTime }}</p>
                  <p class="text-xs text-muted-foreground">{{ new Date(s.date).toLocaleDateString(undefined, { weekday: 'long', year: 'numeric' }) }}</p>
                </div>
              </div>
              <Button 
                variant="ghost" 
                size="sm" 
                class="text-destructive hover:bg-destructive/10"
                @click="confirmDelete(s)"
                :disabled="deleting === s.id"
              >
                {{ deleting === s.id ? '...' : '✕' }}
              </Button>
            </div>

            <!-- Pagination Controls -->
            <div v-if="totalPages > 1" class="flex items-center justify-between pt-4 border-t">
              <p class="text-xs text-muted-foreground">
                Page <strong>{{ currentPage }}</strong> of {{ totalPages }}
              </p>
              <div class="flex gap-2">
                <Button 
                  variant="outline" 
                  size="sm" 
                  @click="currentPage--" 
                  :disabled="currentPage === 1"
                >
                  Previous
                </Button>
                <Button 
                  variant="outline" 
                  size="sm" 
                  @click="currentPage++" 
                  :disabled="currentPage === totalPages"
                >
                  Next
                </Button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- Left Side: Bulk Generation Tool -->
      <Card class="h-fit sticky top-8">
        <CardHeader>
          <CardTitle>Bulk Generate</CardTitle>
          <CardDescription>Rapidly populate availability for a date range.</CardDescription>
        </CardHeader>
        <CardContent class="space-y-4">
          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-2">
              <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">From</label>
              <input v-model="bulkData.startDate" type="date" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2" />
            </div>
            <div class="space-y-2">
              <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">To</label>
              <input v-model="bulkData.endDate" type="date" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2" />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-2">
              <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">Start Time</label>
              <input v-model="bulkData.startTime" type="time" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2" />
            </div>
            <div class="space-y-2">
              <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">End Time</label>
              <input v-model="bulkData.endTime" type="time" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2" />
            </div>
          </div>

          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">Apply to Days</label>
            <div class="flex flex-wrap gap-2">
              <button 
                v-for="day in weekDays" 
                :key="day.val"
                @click="toggleDay(day.val)"
                :class="[
                  'h-8 px-3 text-xs font-bold rounded border transition-all',
                  bulkData.daysOfWeek.includes(day.val) ? 'bg-primary border-primary text-primary-foreground shadow-md' : 'bg-background border-muted text-muted-foreground hover:border-primary'
                ]"
              >
                {{ day.label }}
              </button>
            </div>
          </div>

          <div v-if="bulkError" class="text-sm text-destructive font-medium border border-destructive/20 bg-destructive/10 p-3 rounded">
            {{ bulkError }}
          </div>
          <div v-if="successMsg" class="text-sm text-green-600 font-medium border border-green-200 bg-green-50 p-3 rounded">
            {{ successMsg }}
          </div>
        </CardContent>
        <CardFooter class="border-t p-4 flex flex-col gap-2">
          <Button class="w-full shadow-lg" @click="handleBulkCreate" :disabled="submitting">
            {{ submitting ? 'Generating...' : 'Generate Shifts' }}
          </Button>
          <p class="text-[10px] text-center text-muted-foreground">This will skip existing records or update them with new times.</p>
        </CardFooter>
      </Card>
    </div>
  </div>

  <!-- Delete Confirmation -->
  <AlertDialog :open="showDeleteConfirm" @update:open="showDeleteConfirm = $event">
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>Delete Shift</AlertDialogTitle>
        <AlertDialogDescription>
          Are you sure you want to delete this shift for 
          <strong>{{ new Date(scheduleToDelete?.date).toLocaleDateString() }}</strong> ({{ scheduleToDelete?.startTime }} - {{ scheduleToDelete?.endTime }})?
          This will remove availability for this slot.
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel @click="showDeleteConfirm = false">Cancel</AlertDialogCancel>
        <AlertDialogAction variant="destructive" @click="handleDelete">Delete Shift</AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_DOCTOR_SCHEDULES_QUERY, BULK_CREATE_SCHEDULES_MUTATION, DELETE_SCHEDULE_MUTATION } from '@/graphql/schedules'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'
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
const route = useRoute()
const doctorId = route.params.id

const { result, loading, refetch } = useQuery(GET_DOCTOR_SCHEDULES_QUERY, { id: doctorId })
const doctor = computed(() => result.value?.doctor)

const weekDays = [
  { label: 'Mon', val: 1 },
  { label: 'Tue', val: 2 },
  { label: 'Wed', val: 3 },
  { label: 'Thu', val: 4 },
  { label: 'Fri', val: 5 },
  { label: 'Sat', val: 6 },
  { label: 'Sun', val: 0 }
]

const bulkData = ref({
  startDate: '',
  endDate: '',
  startTime: '09:00',
  endTime: '17:00',
  daysOfWeek: [1, 2, 3, 4, 5]
})

function toggleDay(val) {
  const index = bulkData.value.daysOfWeek.indexOf(val)
  if (index > -1) bulkData.value.daysOfWeek.splice(index, 1)
  else bulkData.value.daysOfWeek.push(val)
}

// Pagination
const currentPage = ref(1)
const pageSize = 5
const totalPages = computed(() => Math.ceil((doctor.value?.schedules?.length || 0) / pageSize))

const paginatedSchedules = computed(() => {
  if (!doctor.value?.schedules) return []
  const start = (currentPage.value - 1) * pageSize
  const end = start + pageSize
  return doctor.value.schedules.slice(start, end)
})

// Deletion
const deleting = ref(null)
const showDeleteConfirm = ref(false)
const scheduleToDelete = ref(null)

const { mutate: deleteMutation } = useMutation(DELETE_SCHEDULE_MUTATION)

function confirmDelete(s) {
  scheduleToDelete.value = s
  showDeleteConfirm.value = true
}

async function handleDelete() {
  const s = scheduleToDelete.value
  if (!s) return
  
  showDeleteConfirm.value = false
  deleting.value = s.id
  
  try {
    const res = await deleteMutation({ scheduleId: s.id })
    if (res.data.deleteSchedule.success) {
      // Adjust page if we deleted the last item on the current page
      if (paginatedSchedules.value.length === 1 && currentPage.value > 1) {
        currentPage.value--
      }
      await refetch()
    } else {
      bulkError.value = res.data.deleteSchedule.errors.join(', ')
    }
  } catch (e) {
    bulkError.value = e.message
  } finally {
    deleting.value = null
    scheduleToDelete.value = null
  }
}

const submitting = ref(false)
const bulkError = ref(null)
const successMsg = ref(null)

const { mutate: bulkCreateMutation } = useMutation(BULK_CREATE_SCHEDULES_MUTATION)

async function handleBulkCreate() {
  if (!bulkData.value.startDate || !bulkData.value.endDate) {
    bulkError.value = "Please select a date range."
    return
  }

  submitting.value = true
  bulkError.value = null
  successMsg.value = null

  try {
    const res = await bulkCreateMutation({
      doctorId: doctorId,
      ...bulkData.value
    })

    const data = res.data.bulkCreateSchedules
    if (data.errors.length > 0) {
      bulkError.value = data.errors.join(', ')
    } else {
      successMsg.value = `Successfully generated ${data.schedules.length} shifts!`
      await refetch()
    }
  } catch (e) {
    bulkError.value = e.message
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  // Default to this week (Monday → Sunday)
  const today = new Date()
  const day = today.getDay()
  const diffToMonday = today.getDate() - day + (day === 0 ? -6 : 1)
  
  const monday = new Date(today)
  monday.setDate(diffToMonday)
  monday.setHours(0, 0, 0, 0)
  
  const sunday = new Date(monday)
  sunday.setDate(monday.getDate() + 6)
  
  const fmt = (d) => {
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const dd = String(d.getDate()).padStart(2, '0')
    return `${y}-${m}-${dd}`
  }
  
  bulkData.value.startDate = fmt(monday)
  bulkData.value.endDate = fmt(sunday)
})
</script>
