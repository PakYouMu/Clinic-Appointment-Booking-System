<template>
  <div class="space-y-6 animate-in fade-in duration-500">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">Doctors</h1>
        <p class="text-muted-foreground">Manage your clinic's medical staff and their schedules.</p>
      </div>
      <Button @click="openAddDialog">
        <Plus class="h-4 w-4 mr-2" />
        Add Doctor
      </Button>
    </div>
    
    <!-- Global Error message for list actions -->
    <div v-if="globalError" class="rounded-md bg-destructive/10 px-4 py-3 text-sm text-destructive animate-in fade-in slide-in-from-top-2 duration-300">
      <div class="flex items-center gap-2">
        <CircleX class="h-4 w-4" />
        <span>{{ globalError }}</span>
      </div>
    </div>

    <!-- Doctors Table -->
    <Card class="bg-card/50 backdrop-blur-md border-primary/5">
      <CardContent class="p-0">
        <div class="relative w-full overflow-auto rounded-xl">
          <table class="w-full caption-bottom text-sm">
            <thead class="bg-muted/50">
              <tr class="border-b transition-colors">
                <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground">Name</th>
                <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground">Specialty</th>
                <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground">Status</th>
                <th class="h-12 px-4 text-right align-middle font-medium text-muted-foreground">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading" class="border-b">
                <td colspan="4" class="p-10 text-center animate-pulse text-muted-foreground">Loading doctors...</td>
              </tr>
              <tr v-else-if="doctors.length === 0" class="border-b">
                <td colspan="4" class="p-10 text-center text-muted-foreground italic">No doctors found.</td>
              </tr>
              <tr 
                v-for="doctor in doctors" 
                :key="doctor.id"
                class="border-b transition-colors hover:bg-muted/30"
              >
                <td class="p-4 align-middle">
                  <div class="flex items-center gap-3">
                    <div class="h-9 w-9 rounded-full bg-primary/10 flex items-center justify-center font-bold text-primary text-xs shrink-0">
                      {{ doctor.firstName.charAt(0) }}{{ doctor.lastName.charAt(0) }}
                    </div>
                    <span class="font-medium">Dr. {{ doctor.firstName }} {{ doctor.lastName }}</span>
                  </div>
                </td>
                <td class="p-4 align-middle text-muted-foreground">{{ doctor.specialty }}</td>
                <td class="p-4 align-middle">
                  <button
                    @click="handleToggleActive(doctor)"
                    :disabled="submitting === doctor.id"
                    :class="[
                      'inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider border cursor-pointer transition-all hover:scale-105',
                      doctor.isActive 
                        ? 'border-transparent bg-green-500/10 text-green-700 hover:bg-green-500/20' 
                        : 'border-transparent bg-muted text-muted-foreground hover:bg-muted/80'
                    ]"
                    :title="doctor.isActive ? 'Click to deactivate' : 'Click to activate'"
                  >
                    <CircleCheck v-if="doctor.isActive" class="h-3 w-3" />
                    <CircleX v-else class="h-3 w-3" />
                    {{ doctor.isActive ? 'Active' : 'Inactive' }}
                  </button>
                </td>
                <td class="p-4 align-middle text-right">
                  <div class="flex justify-end gap-1">
                    <Button variant="outline" size="sm" class="h-8" @click="$router.push(`/doctors/${doctor.id}/schedule`)">
                      <CalendarDays class="h-3.5 w-3.5 mr-1.5" />
                      Schedule
                    </Button>
                    <Button variant="ghost" size="sm" class="h-8" @click="openEditDialog(doctor)">
                      <Pencil class="h-3.5 w-3.5 mr-1.5" />
                      Edit
                    </Button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>

    <!-- Add / Edit Doctor Modal -->
    <div v-if="showDialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4 backdrop-blur-sm" @click.self="showDialog = false">
      <Card class="w-full max-w-md shadow-2xl animate-in zoom-in-95 duration-200">
        <CardHeader class="border-b">
          <CardTitle>{{ isEditing ? 'Edit Doctor' : 'Add New Doctor' }}</CardTitle>
          <CardDescription>{{ isEditing ? 'Update the specialist\'s details below.' : 'Enter the details of the new specialist.' }}</CardDescription>
        </CardHeader>
        <CardContent class="space-y-4 pt-6">
          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">First Name</label>
            <input v-model="formDoctor.firstName" type="text" placeholder="e.g. Gregory" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 transition-shadow" />
          </div>
          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">Last Name</label>
            <input v-model="formDoctor.lastName" type="text" placeholder="e.g. House" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 transition-shadow" />
          </div>
          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-muted-foreground">Specialty</label>
            <input v-model="formDoctor.specialty" type="text" placeholder="e.g. Neurosurgery" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 transition-shadow" />
          </div>
          <div v-if="formError" class="text-sm text-destructive font-medium bg-destructive/10 p-3 rounded-md">{{ formError }}</div>
        </CardContent>
        <CardFooter class="flex justify-between border-t p-4">
          <Button variant="ghost" @click="showDialog = false">Cancel</Button>
          <Button @click="handleSubmit" :disabled="submitting !== null">
            {{ submitting !== null ? 'Saving...' : (isEditing ? 'Save Changes' : 'Add Doctor') }}
          </Button>
        </CardFooter>
      </Card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { GET_DOCTORS_QUERY, CREATE_DOCTOR_MUTATION, UPDATE_DOCTOR_MUTATION } from '@/graphql/doctors'
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'
import { Plus, Pencil, CalendarDays, CircleCheck, CircleX } from 'lucide-vue-next'

const { result, loading, refetch } = useQuery(GET_DOCTORS_QUERY)
const doctors = computed(() => result.value?.doctors || [])

const showDialog = ref(false)
const isEditing = ref(false)
const editingDoctorId = ref(null)
const submitting = ref(null)
const formError = ref(null)
const globalError = ref(null)
const formDoctor = ref({ firstName: '', lastName: '', specialty: '' })

const { mutate: createDoctor } = useMutation(CREATE_DOCTOR_MUTATION)
const { mutate: updateDoctor } = useMutation(UPDATE_DOCTOR_MUTATION)

function openAddDialog() {
  isEditing.value = false
  editingDoctorId.value = null
  formDoctor.value = { firstName: '', lastName: '', specialty: '' }
  formError.value = null
  showDialog.value = true
}

function openEditDialog(doctor) {
  isEditing.value = true
  editingDoctorId.value = doctor.id
  formDoctor.value = {
    firstName: doctor.firstName,
    lastName: doctor.lastName,
    specialty: doctor.specialty
  }
  formError.value = null
  showDialog.value = true
}

async function handleSubmit() {
  submitting.value = 'form'
  formError.value = null
  try {
    if (isEditing.value) {
      const res = await updateDoctor({
        id: editingDoctorId.value,
        ...formDoctor.value
      })
      if (res.data.updateDoctor.errors.length > 0) {
        formError.value = res.data.updateDoctor.errors.join(', ')
      } else {
        await refetch()
        showDialog.value = false
      }
    } else {
      const res = await createDoctor(formDoctor.value)
      if (res.data.createDoctor.errors.length > 0) {
        formError.value = res.data.createDoctor.errors.join(', ')
      } else {
        await refetch()
        showDialog.value = false
        formDoctor.value = { firstName: '', lastName: '', specialty: '' }
      }
    }
  } catch (e) {
    formError.value = e.message
  } finally {
    submitting.value = null
  }
}

async function handleToggleActive(doctor) {
  submitting.value = doctor.id
  try {
    const res = await updateDoctor({
      id: doctor.id,
      isActive: !doctor.isActive
    })
    if (res.data.updateDoctor.errors.length > 0) {
      globalError.value = res.data.updateDoctor.errors.join(', ')
    } else {
      globalError.value = null
      await refetch()
    }
  } catch (e) {
    globalError.value = 'Failed to update status: ' + e.message
  } finally {
    submitting.value = null
  }
}
</script>
