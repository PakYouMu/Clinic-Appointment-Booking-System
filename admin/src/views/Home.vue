<template>
  <div class="space-y-8 animate-in fade-in duration-500">
    <!-- Header with Stats -->
    <div class="flex flex-col gap-6">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Dashboard Overview</h1>
        <p class="text-muted-foreground">Welcome back! Here's what's happening today, {{ todayDisplay }}.</p>
      </div>

      <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card class="bg-card/50 backdrop-blur-md border-primary/10 transition-all hover:border-primary/30 hover:shadow-lg group">
          <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle class="text-sm font-medium">All Appointments</CardTitle>
            <CalendarDays class="h-4 w-4 text-muted-foreground group-hover:scale-110 transition-transform" />
          </CardHeader>
          <CardContent>
            <div class="text-2xl font-bold">{{ loading ? '...' : todayAppointments.length }}</div>
            <p class="text-xs text-muted-foreground">Across all doctors</p>
          </CardContent>
        </Card>

        <Card class="bg-card/50 backdrop-blur-md border-primary/10 transition-all hover:border-primary/30 hover:shadow-lg group">
          <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle class="text-sm font-medium">Pending / Booked</CardTitle>
            <Clock class="h-4 w-4 text-primary group-hover:scale-110 transition-transform" />
          </CardHeader>
          <CardContent>
            <div class="text-2xl font-bold text-primary">{{ loading ? '...' : pendingToday.length }}</div>
            <p class="text-xs text-muted-foreground">Yet to be seen</p>
          </CardContent>
        </Card>

        <Card class="bg-card/50 backdrop-blur-md border-primary/10 transition-all hover:border-primary/30 hover:shadow-lg group">
          <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle class="text-sm font-medium">Completed</CardTitle>
            <CircleCheck class="h-4 w-4 text-green-600 group-hover:scale-110 transition-transform" />
          </CardHeader>
          <CardContent>
            <div class="text-2xl font-bold text-green-600">{{ loading ? '...' : completedToday.length }}</div>
            <p class="text-xs text-muted-foreground">Successful visits</p>
          </CardContent>
        </Card>

        <Card class="bg-card/50 backdrop-blur-md border-primary/10 transition-all hover:border-primary/30 hover:shadow-lg group">
          <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle class="text-sm font-medium">Cancellations/No-Show</CardTitle>
            <CircleX class="h-4 w-4 text-destructive group-hover:scale-110 transition-transform" />
          </CardHeader>
          <CardContent>
            <div class="text-2xl font-bold text-destructive">{{ loading ? '...' : cancelledToday.length + noShowToday.length }}</div>
            <p class="text-xs text-muted-foreground">Missed appointments</p>
          </CardContent>
        </Card>
      </div>
    </div>

    <!-- Today's Schedule -->
    <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
      <Card class="lg:col-span-4 bg-card/50 backdrop-blur-md border-primary/5">
        <CardHeader class="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Upcoming Schedule</CardTitle>
            <CardDescription>Quick overview of all scheduled visits.</CardDescription>
          </div>
          <Button variant="outline" size="sm" @click="$router.push('/appointments')">View All</Button>
        </CardHeader>
        <CardContent>
          <div v-if="loading" class="py-10 flex justify-center text-muted-foreground animate-pulse">Loading today's list...</div>
          <div v-else-if="todayAppointments.length === 0" class="py-10 text-center text-muted-foreground italic bg-muted/20 rounded-xl border-dashed border-2">
            No appointments scheduled for today.
          </div>
          <div v-else class="space-y-4">
            <div 
              v-for="appt in todayAppointments.slice(0, 5)" 
              :key="appt.id"
              class="flex items-center justify-between p-3 rounded-lg border bg-background/50 transition-all hover:shadow-sm"
            >
              <div class="flex items-center gap-4">
                <div class="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center font-bold text-primary shrink-0">
                  {{ appt.patient.firstName.charAt(0) }}{{ appt.patient.lastName.charAt(0) }}
                </div>
                <div>
                  <p class="font-bold text-sm">{{ appt.patient.firstName }} {{ appt.patient.lastName }}</p>
                  <p class="text-xs text-muted-foreground">with Dr. {{ appt.doctor.lastName }} at {{ formatTime(appt.startDatetime) }}</p>
                </div>
              </div>
              <span :class="['px-2.5 py-0.5 text-[10px] font-bold rounded-full uppercase tracking-wider', statusBadge(appt.status)]">
                {{ appt.status }}
              </span>
            </div>
            <p v-if="todayAppointments.length > 5" class="text-center text-xs text-muted-foreground pt-2">
              + {{ todayAppointments.length - 5 }} more appointments today
            </p>
          </div>
        </CardContent>
      </Card>

      <Card class="lg:col-span-3 bg-card/50 backdrop-blur-md border-primary/5">
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
          <CardDescription>Key events across the clinic portal.</CardDescription>
        </CardHeader>
        <CardContent>
           <div class="space-y-6">
             <div class="flex gap-4">
               <div class="h-8 w-8 rounded-full bg-green-100 flex items-center justify-center text-green-600 shrink-0">
                 <Star class="h-4 w-4" />
               </div>
               <div>
                 <p class="text-sm font-medium">New specialist onboarded</p>
                 <p class="text-xs text-muted-foreground">2 hours ago</p>
               </div>
             </div>
             <div class="flex gap-4">
               <div class="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 shrink-0">
                 <Stethoscope class="h-4 w-4" />
               </div>
               <div>
                 <p class="text-sm font-medium">Total 24 bookings confirmed</p>
                 <p class="text-xs text-muted-foreground">Today</p>
               </div>
             </div>
             <div class="flex gap-4 opacity-50">
               <div class="h-8 w-8 rounded-full bg-muted flex items-center justify-center shrink-0">
                 <Settings class="h-4 w-4" />
               </div>
               <div>
                 <p class="text-sm font-medium">System maintenance completed</p>
                 <p class="text-xs text-muted-foreground">Yesterday</p>
               </div>
             </div>
           </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_ADMIN_APPOINTMENTS_QUERY } from '@/graphql/appointments'
import { Button } from '@/components/ui/button'
import { 
  CalendarDays, 
  Clock, 
  CircleCheck, 
  CircleX, 
  Star, 
  Stethoscope, 
  Settings 
} from 'lucide-vue-next'
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from '@/components/ui/card'

// Fetch ALL appointments (no date filter) so the dashboard has a full picture
const { result, loading } = useQuery(GET_ADMIN_APPOINTMENTS_QUERY, {})

const todayAppointments = computed(() => result.value?.adminAppointments || [])

const pendingToday = computed(() => todayAppointments.value.filter(a => a.status === 'booked'))
const completedToday = computed(() => todayAppointments.value.filter(a => a.status === 'completed'))
const cancelledToday = computed(() => todayAppointments.value.filter(a => a.status === 'cancelled'))
const noShowToday = computed(() => todayAppointments.value.filter(a => a.status === 'no_show'))

const todayDisplay = computed(() => {
  return new Date().toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })
})

const formatTime = (isoStr) => {
  const d = new Date(isoStr)
  const date = d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })
  const time = d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })
  return `${date}, ${time}`
}

const statusBadge = (status) => {
  switch (status) {
    case 'booked': return 'bg-primary/10 text-primary'
    case 'completed': return 'bg-green-100 text-green-700'
    case 'cancelled': return 'bg-destructive/10 text-destructive'
    case 'no_show': return 'bg-orange-100 text-orange-700'
    default: return 'bg-muted text-muted-foreground'
  }
}
</script>
