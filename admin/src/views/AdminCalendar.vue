<template>
  <div class="space-y-6 animate-in fade-in duration-700">
    <!-- Header row -->
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Clinic Calendar</h1>
        <p class="text-muted-foreground">Weekly overview of appointments and specialist availability.</p>
      </div>
      
      <div class="flex items-center gap-2">
        <div class="flex items-center rounded-md border bg-card p-1">
          <Button variant="ghost" size="icon" class="h-8 w-8" @click="changeWeek(-1)">
            <ChevronLeft class="h-4 w-4" />
          </Button>
          <div class="px-3 text-sm font-semibold min-w-[150px] text-center">
            {{ weekRangeDisplay }}
          </div>
          <Button variant="ghost" size="icon" class="h-8 w-8" @click="changeWeek(1)">
            <ChevronRight class="h-4 w-4" />
          </Button>
        </div>
        <Button variant="outline" size="sm" @click="goToToday">Today</Button>
      </div>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-4 items-center">
      <div class="flex items-center gap-2 bg-muted/50 p-1.5 rounded-lg border">
         <span class="text-xs font-bold px-2 text-muted-foreground uppercase">Doctor</span>
         <select v-model="selectedDoctorId" class="bg-transparent text-sm border-none focus:ring-0 outline-none pr-8">
            <option :value="null">All Doctors</option>
            <option v-for="d in doctors" :key="d.id" :value="d.id">Dr. {{ d.lastName }}</option>
         </select>
      </div>
      
      <div class="flex items-center gap-4 ml-auto text-[10px] font-bold uppercase tracking-widest text-muted-foreground">
        <div class="flex items-center gap-1.5"><div class="h-2 w-2 rounded-full bg-primary"></div> Booked</div>
        <div class="flex items-center gap-1.5"><div class="h-2 w-2 rounded-full bg-green-500"></div> Done</div>
        <div class="flex items-center gap-1.5"><div class="h-2 w-2 rounded-full bg-destructive"></div> Cancelled</div>
      </div>
    </div>

    <!-- Calendar Grid -->
    <Card class="overflow-hidden border-none shadow-xl bg-card/30 backdrop-blur-md">
      <div class="calendar-scroll-container">
        <div class="calendar-grid" :style="gridTemplateStyle">

          <!-- Top-left corner cell (sticky both ways) -->
          <div class="calendar-corner"></div>

          <!-- Day header cells (sticky top) -->
          <div 
            v-for="day in weekDays" 
            :key="'header-' + day.date.toISOString()" 
            :class="['calendar-day-header', isToday(day.date) ? 'is-today' : '']"
          >
            <p class="text-[10px] font-bold uppercase tracking-widest text-muted-foreground mb-1">{{ day.label }}</p>
            <p :class="['text-xl font-black leading-none', isToday(day.date) ? 'text-primary' : '']">
              {{ day.date.getDate() }}
            </p>
          </div>

          <!-- Time rows -->
          <template v-for="hour in hours" :key="hour">
            <div class="calendar-time-label">
              <span>{{ formatTime(hour) }}</span>
            </div>

            <div 
              v-for="(day, dayIdx) in weekDays" 
              :key="hour + '-' + dayIdx" 
              :class="['calendar-cell', isToday(day.date) ? 'is-today' : '']"
            >
              <!-- Show individual cards only when no overlaps and ≤ 4 -->
              <template v-if="!shouldGroupCell(day.date, hour)">
                <div 
                  v-for="appt in getAppointmentsForCell(day.date, hour)" 
                  :key="appt.id"
                  :style="getAppointmentCellStyle(appt)"
                  :class="[
                    'absolute left-1 right-1 rounded p-1.5 text-[9px] font-bold border-l-4 shadow-sm transition-all hover:z-30 hover:scale-[1.02] cursor-pointer overflow-hidden',
                    statusColors(appt.status).card
                  ]"
                  @click="selectedAppt = appt"
                >
                  <div class="flex items-start justify-between">
                    <span class="truncate pr-1">Dr. {{ appt.doctor.lastName }}</span>
                    <span>{{ formatTimeOnly(appt.startDatetime) }}</span>
                  </div>
                  <div class="truncate text-[10px] leading-tight mt-0.5">
                    {{ appt.patient.firstName }} {{ appt.patient.lastName }}
                  </div>
                </div>
              </template>

              <!-- Grouped badge: > 4 appointments OR overlapping start times -->
              <div 
                v-else
                class="absolute inset-1 rounded-md bg-primary/10 border border-primary/30 flex flex-col items-center justify-center cursor-pointer hover:bg-primary/20 transition-colors"
                @click="openBulkModal(day.date, hour)"
              >
                <CalendarClock class="h-4 w-4 text-primary mb-0.5" />
                <span class="text-xs font-black text-primary">{{ getAppointmentsForCell(day.date, hour).length }}</span>
                <span class="text-[8px] font-bold text-primary/70 uppercase tracking-widest">Appts</span>
              </div>
            </div>
          </template>
        </div>
      </div>
    </Card>

    <!-- Single Appointment Detail Modal -->
    <div v-if="selectedAppt" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" @click.self="selectedAppt = null">
      <Card class="w-full max-w-sm shadow-2xl animate-in zoom-in-95 duration-200">
        <CardHeader class="pb-2 border-b">
          <div class="flex justify-between items-start">
             <span :class="['px-2 py-0.5 rounded text-[10px] uppercase font-black tracking-widest', statusColors(selectedAppt.status).badge]">
               {{ formatStatus(selectedAppt.status) }}
             </span>
             <Button variant="ghost" size="icon" class="h-6 w-6" @click="selectedAppt = null">
               <X class="h-3.5 w-3.5" />
             </Button>
          </div>
          <CardTitle class="text-xl mt-2">Appointment Details</CardTitle>
          <CardDescription>{{ formatLongDate(selectedAppt.startDatetime) }}</CardDescription>
        </CardHeader>
        <CardContent class="py-4 space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mb-1">Patient</p>
              <p class="font-bold">{{ selectedAppt.patient.firstName }} {{ selectedAppt.patient.lastName }}</p>
              <p class="text-xs text-muted-foreground">{{ selectedAppt.contactNumber || 'No phone' }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mb-1">Doctor</p>
              <p class="font-bold">Dr. {{ selectedAppt.doctor.lastName }}</p>
              <p class="text-xs text-muted-foreground">{{ selectedAppt.doctor.specialty }}</p>
            </div>
          </div>
          <div v-if="selectedAppt.reasonForVisit" class="bg-muted/30 p-3 rounded text-sm">
             <p class="text-[10px] font-bold text-muted-foreground uppercase mb-1">Reason for Visit</p>
             <p>{{ selectedAppt.reasonForVisit }}</p>
          </div>
        </CardContent>
        <CardFooter class="border-t p-4">
          <Button variant="outline" class="w-full" @click="selectedAppt = null">Close Details</Button>
        </CardFooter>
      </Card>
    </div>

    <!-- Bulk Appointments Modal (>4 in a cell) -->
    <div v-if="bulkModal.open" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" @click.self="closeBulkModal">
      <Card class="w-full max-w-2xl shadow-2xl animate-in zoom-in-95 duration-200 max-h-[85vh] flex flex-col">
        <CardHeader class="pb-3 border-b shrink-0">
          <div class="flex justify-between items-start">
            <div>
              <CardTitle class="text-xl">Appointments</CardTitle>
              <CardDescription>
                {{ bulkModal.dateLabel }} · {{ formatTime(bulkModal.hour) }} — {{ bulkModalAppointments.length }} total
              </CardDescription>
            </div>
            <Button variant="ghost" size="icon" class="h-7 w-7" @click="closeBulkModal">
              <X class="h-4 w-4" />
            </Button>
          </div>

          <!-- Sort controls -->
          <div class="flex items-center gap-2 mt-3">
            <span class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest">Sort by</span>
            <Button 
              v-for="opt in sortOptions" :key="opt.key"
              :variant="bulkModal.sortKey === opt.key ? 'default' : 'outline'" 
              size="sm" 
              class="h-7 text-xs"
              @click="setBulkSort(opt.key)"
            >
              {{ opt.label }}
              <component 
                :is="bulkModal.sortKey === opt.key ? (bulkModal.sortDir === 'asc' ? ArrowUp : ArrowDown) : ArrowUpDown" 
                class="h-3 w-3 ml-1" 
              />
            </Button>
          </div>
        </CardHeader>

        <CardContent class="py-3 overflow-y-auto flex-1 min-h-0">
          <div class="space-y-2">
            <div 
              v-for="appt in paginatedBulkAppointments" 
              :key="appt.id"
              :class="[
                'flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all hover:shadow-md',
                statusColors(appt.status).card, 'border-l-4'
              ]"
              @click="selectedAppt = appt; closeBulkModal()"
            >
              <!-- Time -->
              <div class="text-center shrink-0 w-14">
                <p class="text-sm font-black leading-tight">{{ formatTimeOnly(appt.startDatetime) }}</p>
                <p class="text-[9px] text-muted-foreground">{{ appt.endDatetime ? formatTimeOnly(appt.endDatetime) : '' }}</p>
              </div>

              <div class="h-8 w-px bg-border shrink-0"></div>

              <!-- Doctor -->
              <div class="shrink-0 w-28">
                <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest">Doctor</p>
                <p class="text-sm font-bold truncate">Dr. {{ appt.doctor.lastName }}</p>
              </div>

              <!-- Patient -->
              <div class="flex-1 min-w-0">
                <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest">Patient</p>
                <p class="text-sm font-bold truncate">{{ appt.patient.firstName }} {{ appt.patient.lastName }}</p>
              </div>

              <!-- Status badge -->
              <span :class="['px-2 py-0.5 rounded text-[9px] uppercase font-black tracking-widest shrink-0', statusColors(appt.status).badge]">
                {{ formatStatus(appt.status) }}
              </span>
            </div>
          </div>

          <!-- Empty state (shouldn't happen, but just in case) -->
          <p v-if="!bulkModalAppointments.length" class="text-sm text-muted-foreground text-center py-8">No appointments found.</p>
        </CardContent>

        <!-- Pagination -->
        <CardFooter v-if="bulkTotalPages > 1" class="border-t px-4 py-3 shrink-0">
          <div class="flex items-center justify-between w-full">
            <p class="text-xs text-muted-foreground">
              Page {{ bulkModal.page }} of {{ bulkTotalPages }}
              <span class="text-muted-foreground/60"> · {{ bulkModalAppointments.length }} appointments</span>
            </p>
            <div class="flex items-center gap-1">
              <Button 
                variant="outline" size="icon" class="h-7 w-7" 
                :disabled="bulkModal.page <= 1" 
                @click="bulkModal.page--"
              >
                <ChevronLeft class="h-3.5 w-3.5" />
              </Button>
              <Button 
                variant="outline" size="icon" class="h-7 w-7" 
                :disabled="bulkModal.page >= bulkTotalPages" 
                @click="bulkModal.page++"
              >
                <ChevronRight class="h-3.5 w-3.5" />
              </Button>
            </div>
          </div>
        </CardFooter>
      </Card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_ADMIN_APPOINTMENTS_QUERY } from '@/graphql/appointments'
import { GET_DOCTORS_QUERY } from '@/graphql/doctors'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'
import { ChevronLeft, ChevronRight, X, CalendarClock, ArrowUp, ArrowDown, ArrowUpDown } from 'lucide-vue-next'

// --- State & Navigation ---
const baseDate = ref(new Date())
const selectedDoctorId = ref(null)
const selectedAppt = ref(null)

const goToToday = () => { baseDate.value = new Date() }
const changeWeek = (dir) => {
  const d = new Date(baseDate.value)
  d.setDate(d.getDate() + (dir * 7))
  baseDate.value = d
}

// --- Grid Config ---
const START_HOUR = 7
const DEFAULT_END_HOUR = 19
const CELL_HEIGHT = 80

const hours = computed(() => {
  let maxHour = DEFAULT_END_HOUR
  if (appointments.value.length) {
    for (const appt of appointments.value) {
      const endDt = appt.endDatetime 
        ? new Date(appt.endDatetime) 
        : new Date(new Date(appt.startDatetime).getTime() + 15 * 60000)
      const endHour = endDt.getHours() + (endDt.getMinutes() > 0 ? 1 : 0)
      if (endHour > maxHour) maxHour = endHour
    }
  }
  const result = []
  for (let h = START_HOUR; h <= maxHour; h++) {
    result.push(h)
  }
  return result
})

const gridTemplateStyle = computed(() => ({
  gridTemplateColumns: '5rem repeat(7, minmax(120px, 1fr))',
  gridTemplateRows: `auto repeat(${hours.value.length}, ${CELL_HEIGHT}px)`
}))

const weekDays = computed(() => {
  const d = new Date(baseDate.value)
  const day = d.getDay()
  const diff = d.getDate() - day + (day === 0 ? -6 : 1)
  const monday = new Date(d)
  monday.setDate(diff)
  monday.setHours(0, 0, 0, 0)
  
  return Array.from({ length: 7 }, (_, i) => {
    const date = new Date(monday)
    date.setDate(monday.getDate() + i)
    return {
      date,
      label: date.toLocaleDateString(undefined, { weekday: 'short' })
    }
  })
})

const weekRangeDisplay = computed(() => {
  const start = weekDays.value[0].date
  const end = weekDays.value[6].date
  const startStr = start.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })
  const endStr = end.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
  return `${startStr} - ${endStr}`
})

// --- Data Fetching ---
const { result: doctorsRes } = useQuery(GET_DOCTORS_QUERY)
const doctors = computed(() => doctorsRes.value?.doctors || [])

const { result: apptsRes, loading } = useQuery(
  GET_ADMIN_APPOINTMENTS_QUERY,
  () => ({
    fromDate: formatISO(weekDays.value[0].date),
    toDate: formatISO(weekDays.value[6].date),
    doctorId: selectedDoctorId.value
  })
)
const appointments = computed(() => apptsRes.value?.adminAppointments || [])

// --- Helpers ---
function formatISO(date) {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

const isToday = (date) => new Date().toDateString() === date.toDateString()

const getAppointmentsForCell = (date, hour) => {
  const dayStr = formatISO(date)
  return appointments.value.filter(a => {
    const aDate = new Date(a.startDatetime)
    return formatISO(aDate) === dayStr && aDate.getHours() === hour
  })
}

// Returns true if a cell should show the grouped badge instead of individual cards
// Rules: more than 4 appointments, OR any two share the same start minute
const shouldGroupCell = (date, hour) => {
  const cellAppts = getAppointmentsForCell(date, hour)
  if (cellAppts.length > 4) return true
  if (cellAppts.length <= 1) return false

  // Check if any appointments share the same start minute
  const minutes = cellAppts.map(a => new Date(a.startDatetime).getMinutes())
  const uniqueMinutes = new Set(minutes)
  return uniqueMinutes.size < minutes.length // duplicates exist
}

const getAppointmentCellStyle = (appt) => {
  const start = new Date(appt.startDatetime)
  const end = appt.endDatetime ? new Date(appt.endDatetime) : new Date(start.getTime() + 15 * 60000)
  
  const minuteOffset = start.getMinutes()
  const topPx = (minuteOffset / 60) * CELL_HEIGHT
  
  const durationMs = end.getTime() - start.getTime()
  const durationMinutes = durationMs / 60000
  const heightPx = Math.max((durationMinutes / 60) * CELL_HEIGHT, 20)
  
  return {
    top: `${topPx}px`,
    height: `${heightPx}px`
  }
}

const formatTime = (hour) => {
  return hour > 12 ? `${hour - 12} PM` : hour === 12 ? '12 PM' : `${hour} AM`
}

const formatTimeOnly = (isoStr) => {
  return new Date(isoStr).toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit', hour12: true })
}

const formatLongDate = (isoStr) => {
  return new Date(isoStr).toLocaleDateString(undefined, { 
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit'
  })
}

const formatStatus = (status) => status ? status.replace(/_/g, ' ') : ''

const statusColors = (status) => {
  switch (status) {
    case 'completed': return { card: 'bg-green-500/10 text-green-700 border-green-500', badge: 'bg-green-500 text-white' }
    case 'cancelled': return { card: 'bg-destructive/10 text-destructive border-destructive', badge: 'bg-destructive text-white' }
    case 'no_show': return { card: 'bg-orange-500/10 text-orange-700 border-orange-500', badge: 'bg-orange-500 text-white' }
    default: return { card: 'bg-primary/10 text-primary border-primary', badge: 'bg-primary text-white' }
  }
}

// =============================================================================
// BULK MODAL — for cells with > 4 appointments
// =============================================================================
const BULK_PAGE_SIZE = 5

const bulkModal = reactive({
  open: false,
  date: null,
  hour: null,
  dateLabel: '',
  sortKey: 'time',   // 'time' | 'patientName' | 'doctorName'
  sortDir: 'asc',    // 'asc' | 'desc'
  page: 1
})

const sortOptions = [
  { key: 'time', label: 'Time' },
  { key: 'doctorName', label: 'Doctor' },
  { key: 'patientName', label: 'Patient' }
]

function openBulkModal(date, hour) {
  bulkModal.open = true
  bulkModal.date = date
  bulkModal.hour = hour
  bulkModal.dateLabel = date.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' })
  bulkModal.sortKey = 'time'
  bulkModal.sortDir = 'asc'
  bulkModal.page = 1
}

function closeBulkModal() {
  bulkModal.open = false
}

function setBulkSort(key) {
  if (bulkModal.sortKey === key) {
    // Toggle direction
    bulkModal.sortDir = bulkModal.sortDir === 'asc' ? 'desc' : 'asc'
  } else {
    bulkModal.sortKey = key
    bulkModal.sortDir = 'asc'
  }
  bulkModal.page = 1
}

// All appointments for the bulk modal's cell, sorted
const bulkModalAppointments = computed(() => {
  if (!bulkModal.open || !bulkModal.date) return []
  
  const cellAppts = [...getAppointmentsForCell(bulkModal.date, bulkModal.hour)]

  // Primary sort: by chosen key. Secondary sort: time then doctor last name
  cellAppts.sort((a, b) => {
    let cmp = 0
    const dir = bulkModal.sortDir === 'asc' ? 1 : -1

    switch (bulkModal.sortKey) {
      case 'time': {
        const tA = new Date(a.startDatetime).getTime()
        const tB = new Date(b.startDatetime).getTime()
        cmp = (tA - tB) * dir
        if (cmp === 0) {
          cmp = a.doctor.lastName.localeCompare(b.doctor.lastName)
        }
        break
      }
      case 'doctorName': {
        cmp = a.doctor.lastName.localeCompare(b.doctor.lastName) * dir
        if (cmp === 0) {
          cmp = new Date(a.startDatetime).getTime() - new Date(b.startDatetime).getTime()
        }
        break
      }
      case 'patientName': {
        cmp = a.patient.lastName.localeCompare(b.patient.lastName) * dir
        if (cmp === 0) {
          cmp = new Date(a.startDatetime).getTime() - new Date(b.startDatetime).getTime()
        }
        break
      }
    }
    return cmp
  })

  return cellAppts
})

const bulkTotalPages = computed(() => Math.ceil(bulkModalAppointments.value.length / BULK_PAGE_SIZE))

const paginatedBulkAppointments = computed(() => {
  const start = (bulkModal.page - 1) * BULK_PAGE_SIZE
  return bulkModalAppointments.value.slice(start, start + BULK_PAGE_SIZE)
})
</script>

<style scoped>
.calendar-scroll-container {
  max-height: 750px;
  overflow: auto;
  position: relative;
}

.calendar-grid {
  display: grid;
  min-width: max-content;
}

.calendar-corner {
  position: sticky;
  top: 0;
  left: 0;
  z-index: 30;
  background-color: var(--background);
  border-bottom: 1px solid var(--border);
  border-right: 1px solid var(--border);
}

.calendar-day-header {
  position: sticky;
  top: 0;
  z-index: 20;
  background-color: var(--background);
  border-bottom: 1px solid var(--border);
  border-right: 1px solid var(--border);
  padding: 0.75rem;
  text-align: center;
}
.calendar-day-header:last-of-type {
  border-right: none;
}
.calendar-day-header.is-today {
  background-color: color-mix(in oklch, var(--primary), transparent 95%);
}

.calendar-time-label {
  position: sticky;
  left: 0;
  z-index: 10;
  background-color: var(--background);
  border-right: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding-top: 0.25rem;
}
.calendar-time-label span {
  font-size: 0.625rem;
  font-weight: 700;
  color: var(--muted-foreground);
  background-color: var(--background);
  padding: 0.125rem 0.25rem;
  border-radius: 0.25rem;
}

.calendar-cell {
  position: relative;
  border-right: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}
.calendar-cell.is-today {
  background-color: color-mix(in oklch, var(--primary), transparent 97%);
}
</style>
