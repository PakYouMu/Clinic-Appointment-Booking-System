<template>
  <div class="flex flex-col">
    <!-- Hero Section -->
    <section class="relative bg-muted/30 py-20 lg:py-32 overflow-hidden w-full px-4">
      <div class="container mx-auto max-w-6xl relative z-10 flex flex-col md:flex-row items-center gap-12">
        <div class="flex-1 space-y-6 text-center md:text-left">
          <h1 class="text-4xl md:text-6xl font-extrabold tracking-tight text-foreground">
            Modern Healthcare, <br/>
            <span class="text-primary">Simplified.</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-xl mx-auto md:mx-0">
            Book appointments, manage your health records, and connect with top specialists all in one place. Your well-being is our priority.
          </p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center md:justify-start pt-4">
            <Button size="lg" as-child class="text-base px-8 h-12 shadow-md hover:shadow-lg transition-all">
              <router-link to="/book">Book Appointment</router-link>
            </Button>
            <Button size="lg" variant="outline" as-child class="text-base px-8 h-12">
              <router-link to="/doctors">Our Doctors</router-link>
            </Button>
          </div>
        </div>
        
        <!-- Hero Graphic placeholder -->
        <div class="flex-1 w-full max-w-md hidden md:block">
          <div class="aspect-square rounded-full bg-gradient-to-tr from-primary/20 to-primary/5 p-8 relative">
            <div class="absolute inset-4 rounded-full border border-primary/20 bg-background/50 backdrop-blur-sm flex items-center justify-center shadow-2xl">
              <Building2 class="h-16 w-16 text-primary" />
            </div>
            <!-- Decorative floating cards -->
            <Card class="absolute -left-8 top-1/4 p-4 shadow-xl border-primary/10 animate-pulse bg-background/90 backdrop-blur-md">
              <div class="flex items-center gap-3">
                <div class="h-10 w-10 rounded-full bg-green-500/10 flex items-center justify-center text-green-500">
                  <CheckCircle2 class="h-6 w-6" />
                </div>
                <div>
                  <p class="text-sm font-bold">Confirmed</p>
                  <p class="text-xs text-muted-foreground">Today, 2:30 PM</p>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </section>

    <!-- Quick Features -->
    <section class="py-20 bg-background">
      <div class="container mx-auto px-4 max-w-6xl">
        <div class="text-center mb-16">
          <h2 class="text-3xl font-bold tracking-tight mb-4">Why Choose Us</h2>
          <p class="text-muted-foreground max-w-2xl mx-auto">We provide a seamless experience from booking to treatment.</p>
        </div>
        
        <div class="grid md:grid-cols-3 gap-8">
          <Card class="border-0 shadow-sm hover:shadow-md transition-shadow bg-muted/10">
            <CardHeader>
              <div class="h-12 w-12 rounded-lg bg-primary/10 text-primary flex items-center justify-center mb-4 border border-primary/20 transition-transform group-hover:scale-110">
                <CalendarDays class="h-6 w-6" />
              </div>
              <CardTitle>Easy Scheduling</CardTitle>
            </CardHeader>
            <CardContent>
              <p class="text-muted-foreground text-sm">Find available slots instantly and book an appointment in seconds without making a phone call.</p>
            </CardContent>
          </Card>
          
          <Card class="border-0 shadow-sm hover:shadow-md transition-shadow bg-muted/10">
            <CardHeader>
              <div class="h-12 w-12 rounded-lg bg-primary/10 text-primary flex items-center justify-center mb-4 border border-primary/20 transition-transform group-hover:scale-110">
                <Stethoscope class="h-6 w-6" />
              </div>
              <CardTitle>Expert Doctors</CardTitle>
            </CardHeader>
            <CardContent>
              <p class="text-muted-foreground text-sm">Access a network of highly qualified specialists across various medical disciplines.</p>
            </CardContent>
          </Card>

          <Card class="border-0 shadow-sm hover:shadow-md transition-shadow bg-muted/10">
            <CardHeader>
              <div class="h-12 w-12 rounded-lg bg-primary/10 text-primary flex items-center justify-center mb-4 border border-primary/20 transition-transform group-hover:scale-110">
                <Smartphone class="h-6 w-6" />
              </div>
              <CardTitle>Digital Records</CardTitle>
            </CardHeader>
            <CardContent>
              <p class="text-muted-foreground text-sm">View your appointment history and manage your personal health information securely online.</p>
            </CardContent>
          </Card>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { Button } from '@/components/ui/button'
import { 
  Building2, 
  CalendarDays, 
  Stethoscope, 
  Smartphone, 
  CheckCircle2 
} from 'lucide-vue-next'
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle
} from '@/components/ui/card'
</script>
