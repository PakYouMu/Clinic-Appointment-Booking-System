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
            <span>←</span>
          </Button>
          <div class="px-3 text-sm font-semibold min-w-[150px] text-center">
            {{ weekRangeDisplay }}
          </div>
          <Button variant="ghost" size="icon" class="h-8 w-8" @click="changeWeek(1)">
            <span>→</span>
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
      <div class="relative flex flex-col min-h-[600px] overflow-x-auto">
        <!-- Sticky Day Headers -->
        <div class="flex border-b sticky top-0 bg-background/80 backdrop-blur-md z-20">
          <div class="w-20 shrink-0 border-r bg-muted/20"></div>
          <div v-for="day in weekDays" :key="day.date" 
               :class="['flex-1 min-w-[120px] p-3 text-center border-r last:border-r-0', isToday(day.date) ? 'bg-primary/5' : '']">
            <p class="text-[10px] font-bold uppercase tracking-widest text-muted-foreground mb-1">{{ day.label }}</p>
            <p :class="['text-xl font-black leading-none', isToday(day.date) ? 'text-primary' : '']">
              {{ day.date.getDate() }}
            </p>
          </div>
        </div>

        <!-- Scrollable Grid Body -->
        <div class="flex-1 flex max-h-[700px] overflow-y-auto relative">
          <!-- Time Labels -->
          <div class="w-20 shrink-0 border-r bg-muted/10 sticky left-0 z-10">
            <div v-for="hour in hours" :key="hour" class="h-20 border-b last:border-b-0 relative">
               <span class="absolute -top-3 left-0 w-full text-center text-[10px] font-bold text-muted-foreground bg-background/50 backdrop-blur-sm px-1 py-0.5 rounded shadow-sm">
                 {{ formatTime(hour) }}
               </span>
            </div>
          </div>

          <!-- Vertical Day Columns -->
          <div class="flex-1 flex min-w-max relative">
            <div v-for="day in weekDays" :key="day.date" 
                 class="flex-1 min-w-[120px] border-r last:border-r-0 relative bg-grid-slate-100/[0.03]">
              
              <!-- Shaded non-working areas (placeholder logic) -->
              <div v-for="hour in hours" :key="hour" class="h-20 border-b last:border-b-0"></div>

              <!-- Appointment Blocks -->
              <div 
                v-for="appt in filterAppointmentsByDay(day.date)" 
                :key="appt.id"
                :style="getAppointmentStyle(appt)"
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
            </div>
          </div>
        </div>
      </div>
    </Card>

    <!-- Appointment Detail Modal Mock -->
    <div v-if="selectedAppt" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" @click.self="selectedAppt = null">
      <Card class="w-full max-w-sm shadow-2xl animate-in zoom-in-95 duration-200">
        <CardHeader class="pb-2 border-b">
          <div class="flex justify-between items-start">
             <span :class="['px-2 py-0.5 rounded text-[10px] uppercase font-black tracking-widest', statusColors(selectedAppt.status).badge]">
               {{ selectedAppt.status }}
             </span>
             <Button variant="ghost" size="icon" class="h-6 w-6" @click="selectedAppt = null">✕</Button>
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
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_ADMIN_APPOINTMENTS_QUERY } from '@/graphql/appointments'
import { GET_DOCTORS_QUERY } from '@/graphql/doctors'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'

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
const hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18] // 8 AM to 6 PM

const weekDays = computed(() => {
  const d = new Date(baseDate.value)
  const day = d.getDay()
  const diff = d.getDate() - day + (day === 0 ? -6 : 1) // adjust when day is sunday
  const monday = new Date(d)
  monday.setDate(diff)
  // Reset time to midnight to avoid time drift
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

// Use arrow function for variables to ensure proper reactivity with useQuery
const { result: apptsRes, loading } = useQuery(
  GET_ADMIN_APPOINTMENTS_QUERY,
  () => ({
    fromDate: formatISO(weekDays.value[0].date),
    toDate: formatISO(weekDays.value[6].date),
    doctorId: selectedDoctorId.value
  })
)
const appointments = computed(() => apptsRes.value?.adminAppointments || [])

// --- Logic & Helpers ---
function formatISO(date) {
  // Returns YYYY-MM-DD in local timezone
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

const isToday = (date) => new Date().toDateString() === date.toDateString()

const filterAppointmentsByDay = (date) => {
  const dayStr = formatISO(date)
  return appointments.value.filter(a => {
    // Convert UTC start time to local date for comparison
    const aDate = new Date(a.startDatetime)
    return formatISO(aDate) === dayStr
  })
}

const getAppointmentStyle = (appt) => {
  const start = new Date(appt.startDatetime)
  const end = appt.endDatetime ? new Date(appt.endDatetime) : new Date(start.getTime() + 15 * 60000)
  
  const hour = start.getHours()
  const minutes = start.getMinutes()
  
  // Grid starts at 8:00, each hour row is 80px tall
  const topOffset = ((hour - 8) * 80) + (minutes / 60 * 80)
  
  // Calculate dynamic height based on actual duration
  const durationMs = end.getTime() - start.getTime()
  const durationMinutes = durationMs / 60000
  const height = Math.max((durationMinutes / 60) * 80, 20) // Minimum 20px height
  
  return {
    top: `${Math.max(topOffset, 0)}px`,
    height: `${height}px`
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

const statusColors = (status) => {
  switch (status) {
    case 'completed': return { card: 'bg-green-500/10 text-green-700 border-green-500', badge: 'bg-green-500 text-white' }
    case 'cancelled': return { card: 'bg-destructive/10 text-destructive border-destructive', badge: 'bg-destructive text-white' }
    case 'no_show': return { card: 'bg-orange-500/10 text-orange-700 border-orange-500', badge: 'bg-orange-500 text-white' }
    default: return { card: 'bg-primary/10 text-primary border-primary', badge: 'bg-primary text-white' }
  }
}
</script>

<style scoped>
/* Custom grid background effect */
.bg-grid-slate-100 {
  background-image: linear-gradient(to right, rgba(0,0,0,0.05) 1px, transparent 1px);
  background-size: 100% 1px;
}
</style>
