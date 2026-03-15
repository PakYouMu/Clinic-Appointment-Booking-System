<template>
  <div class="container mx-auto px-4 py-8 md:py-16 max-w-4xl relative min-h-[calc(100vh-4rem)] bg-background">
    <!-- Header -->
    <div class="text-center mb-10">
      <h1 class="text-3xl md:text-5xl font-extrabold tracking-tight mb-4 text-foreground">
        Book an Appointment
      </h1>
      <p class="text-lg text-muted-foreground w-full max-w-2xl mx-auto">
        Follow the steps below to schedule a time with our specialists. Your health is just a few clicks away.
      </p>
    </div>

    <!-- Booking Flow Component -->
    <BookingFlow :initial-doctor-id="doctorIdFromQuery" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import BookingFlow from '@/components/BookingFlow.vue'

const route = useRoute()

// Pull doctor ID from URL if redirected from Doctors Listing page (e.g., /book?doctor=5)
const doctorIdFromQuery = computed(() => route.query.doctor || null)
</script>
