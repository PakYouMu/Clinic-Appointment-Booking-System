<template>
  <div class="flex flex-col min-h-[calc(100vh-4rem)]">
    <!-- Header Section -->
    <div class="bg-muted/30 py-12 md:py-16 border-b">
      <div class="container mx-auto px-4 max-w-6xl">
        <h1 class="text-3xl md:text-5xl font-extrabold tracking-tight mb-4 text-foreground">
          Our Specialists
        </h1>
        <p class="text-lg text-muted-foreground max-w-2xl">
          Experienced professionals dedicated to providing you with the best possible care. Browse our team and find the right specialist for your needs.
        </p>
      </div>
    </div>

    <!-- Main Content Area -->
    <div class="container mx-auto px-4 py-8 max-w-6xl flex-1 flex flex-col md:flex-row gap-8">
      
      <!-- Sidebar / Filters -->
      <aside class="w-full md:w-64 shrink-0 space-y-6">
        <div>
          <h3 class="font-semibold text-lg mb-4 flex items-center gap-2">
            <SlidersHorizontal class="h-4 w-4 text-primary" /> Filter by Specialty
          </h3>
          
          <div class="flex flex-col gap-2">
            <Button
              variant="outline"
              v-for="specialty in ['All Specialties', ...specialties]"
              :key="specialty"
              @click="selectedSpecialty = (specialty === 'All Specialties' ? null : specialty)"
              :class="[
                'w-full h-auto min-h-10 py-3 px-4 justify-start text-left items-center cursor-pointer transition-colors',
                'whitespace-normal break-words leading-tight',
                (selectedSpecialty === specialty || (!selectedSpecialty && specialty === 'All Specialties')) 
                  ? 'bg-primary/10 border-primary/50 text-primary font-medium' 
                  : ''
              ]"
            >
              {{ specialty }}
            </Button>
          </div>
        </div>
      </aside>

      <!-- Grid Area -->
      <div class="flex-1">
        <!-- Loading State -->
        <div v-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <Card v-for="i in 6" :key="i" class="overflow-hidden animate-pulse border-primary/5">
            <div class="h-32 bg-muted/50"></div>
            <CardContent class="p-6">
              <div class="flex items-center gap-4 mb-4">
                <div class="h-12 w-12 rounded-full bg-muted"></div>
                <div class="space-y-2">
                  <div class="h-4 w-24 bg-muted rounded"></div>
                  <div class="h-3 w-16 bg-muted rounded"></div>
                </div>
              </div>
              <div class="h-9 w-full bg-muted rounded"></div>
            </CardContent>
          </Card>
        </div>

        <!-- Error State -->
        <div v-else-if="error" class="bg-destructive/10 text-destructive p-6 rounded-lg flex items-center gap-4">
          <AlertCircle class="h-6 w-6" />
          <div>
            <h3 class="font-semibold">Failed to load doctors</h3>
            <p class="text-sm mt-1">{{ error.message }}</p>
          </div>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredDoctors.length === 0" class="text-center py-20 border rounded-lg bg-muted/10 border-dashed">
          <Stethoscope class="h-12 w-12 mx-auto mb-4 text-primary/40" />
          <h3 class="font-medium text-lg">No doctors found</h3>
          <p class="text-muted-foreground mt-2">Try selecting a different specialty or check back later.</p>
          <Button variant="outline" class="mt-4" @click="selectedSpecialty = null" v-if="selectedSpecialty">
            Clear Filters
          </Button>
        </div>

        <!-- Doctor Grid -->
        <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <Card 
            v-for="doctor in filteredDoctors" 
            :key="doctor.id"
            class="overflow-hidden transition-all hover:shadow-md hover:border-primary/30 flex flex-col group border-primary/10 bg-background/50 backdrop-blur-sm supports-[backdrop-filter]:bg-background/20"
          >
            <!-- Decorative top banner -->
            <div class="h-2 bg-gradient-to-r from-primary/40 to-primary/10"></div>
            
            <CardContent class="p-6 flex-1 flex flex-col">
              <div class="flex flex-col items-center text-center mb-6">
                <!-- Generic avatar -->
                <div class="h-20 w-20 rounded-full bg-primary/10 flex items-center justify-center text-primary text-xl font-bold mb-4 ring-4 ring-background border border-primary/20 group-hover:bg-primary/20 transition-colors">
                  {{ doctor.firstName.charAt(0) }}{{ doctor.lastName.charAt(0) }}
                </div>
                
                <h3 class="font-semibold text-lg">Dr. {{ doctor.firstName }} {{ doctor.lastName }}</h3>
                <span class="inline-flex items-center rounded-2xl border px-3 py-1 text-xs font-semibold mt-3 bg-muted/50 text-foreground border-primary/20 shadow-sm text-balance">
                  {{ doctor.specialty }}
                </span>
              </div>
              
              <div class="mt-auto pt-4 border-t border-border/50">
                <Button class="w-full shadow-sm" @click="$router.push(`/book?doctor=${doctor.id}`)">
                  Book Appointment
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { GET_DOCTORS_QUERY } from '@/graphql/queries'

import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { SlidersHorizontal, Stethoscope, AlertCircle } from 'lucide-vue-next'

const selectedSpecialty = ref(null)

// Ensure we only fetch when this component mounts by using network-only or cache-first as needed
const { result, loading, error } = useQuery(GET_DOCTORS_QUERY, null, {
  fetchPolicy: 'cache-and-network'
})

// Extract unique specialties from the doctors list
const specialties = computed(() => {
  if (!result.value?.doctors) return []
  const allSpecialties = result.value.doctors.map(d => d.specialty)
  return [...new Set(allSpecialties)].sort() // Unique and sorted
})

// Filter doctors based on selected specialty
const filteredDoctors = computed(() => {
  if (!result.value?.doctors) return []
  
  if (!selectedSpecialty.value) {
    return result.value.doctors
  }
  
  return result.value.doctors.filter(d => d.specialty === selectedSpecialty.value)
})
</script>
