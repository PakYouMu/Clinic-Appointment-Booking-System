<template>
  <div class="space-y-4 animate-in fade-in duration-500">
    <!-- Header with Stats -->
    <div class="flex flex-col gap-4">
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
           <div v-if="loading" class="space-y-6">
             <div v-for="i in 3" :key="i" class="flex gap-4 animate-pulse">
               <div class="h-8 w-8 rounded-full bg-muted shrink-0"></div>
               <div class="space-y-2 flex-1">
                 <div class="h-4 bg-muted rounded w-3/4"></div>
                 <div class="h-3 bg-muted rounded w-1/4"></div>
               </div>
             </div>
           </div>
           <div v-else-if="recentActivities.length === 0" class="py-10 text-center text-muted-foreground italic text-sm">
             No recent activity recorded.
           </div>
           <div v-else class="space-y-6">
             <div 
               v-for="activity in recentActivities" 
               :key="activity.id"
               class="flex gap-4 group"
             >
               <div :class="[
                 'h-8 w-8 rounded-full flex items-center justify-center shrink-0 transition-transform group-hover:scale-110',
                 activity.color === 'blue' ? 'bg-blue-100 text-blue-600' : 
                 activity.color === 'green' ? 'bg-green-100 text-green-600' :
                 activity.color === 'orange' ? 'bg-orange-100 text-orange-600' :
                 'bg-destructive/10 text-destructive'
               ]">
                 <component :is="getIcon(activity.iconType)" class="h-4 w-4" />
               </div>
               <div class="flex-1 min-w-0">
                 <p class="text-sm font-medium leading-none mb-1">{{ activity.title }}</p>
                 <p class="text-xs text-muted-foreground truncate" :title="activity.description">{{ activity.description }}</p>
                 <p class="text-[10px] text-muted-foreground/60 mt-1 uppercase font-bold tracking-tight">
                   {{ timeAgo(activity.timestamp) }}
                 </p>
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
import { GET_DASHBOARD_DATA } from '@/graphql/dashboard'
import { Button } from '@/components/ui/button'
import { 
  CalendarDays, 
  Clock, 
  CircleCheck, 
  CircleX, 
  Star, 
  Stethoscope, 
  Settings,
  Calendar,
  Check,
  X
} from 'lucide-vue-next'
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from '@/components/ui/card'

// Fetch ALL data for the dashboard
const { result, loading } = useQuery(GET_DASHBOARD_DATA, {}, { fetchPolicy: 'network-only' })

const todayAppointments = computed(() => result.value?.adminAppointments || [])
const recentActivities = computed(() => result.value?.recentActivities || [])

const pendingToday = computed(() => todayAppointments.value.filter(a => a.status === 'booked'))
const completedToday = computed(() => todayAppointments.value.filter(a => a.status === 'completed'))
const cancelledToday = computed(() => todayAppointments.value.filter(a => a.status === 'cancelled'))
const noShowToday = computed(() => todayAppointments.value.filter(a => a.status === 'no_show'))

const todayDisplay = computed(() => {
  return new Date().toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })
})

const getIcon = (type) => {
  switch (type) {
    case 'calendar': return Calendar
    case 'check': return Check
    case 'x': return X
    case 'stethoscope': return Stethoscope
    case 'star': return Star
    case 'clock': return Clock
    default: return Settings
  }
}

const timeAgo = (isoStr) => {
  const date = new Date(isoStr)
  const seconds = Math.floor((new Date() - date) / 1000)

  let interval = seconds / 31536000
  if (interval > 1) return Math.floor(interval) + " years ago"
  interval = seconds / 2592000
  if (interval > 1) return Math.floor(interval) + " months ago"
  interval = seconds / 86400
  if (interval > 1) return Math.floor(interval) + " days ago"
  interval = seconds / 3600
  if (interval > 1) return Math.floor(interval) + " hours ago"
  interval = seconds / 60
  if (interval > 1) return Math.floor(interval) + " minutes ago"
  return Math.floor(seconds) + " seconds ago"
}

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
