import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const routes = [
    {
        path: '/',
        component: () => import('../components/layouts/AdminLayout.vue'),
        meta: { requiresAuth: true },
        children: [
            {
                path: '',
                name: 'Home',
                component: () => import('../views/Home.vue')
            },
            {
                path: 'doctors',
                name: 'Doctors',
                component: () => import('../views/Doctors.vue')
            },
            {
                path: 'doctors/:id/schedule',
                name: 'DoctorSchedule',
                component: () => import('../views/DoctorSchedule.vue')
            },
            {
                path: 'appointments',
                name: 'Appointments',
                component: () => import('../views/Appointments.vue')
            },
            {
                path: 'calendar',
                name: 'Calendar',
                component: () => import('../views/AdminCalendar.vue')
            }
        ]
    },
    {
        path: '/login',
        name: 'Login',
        component: () => import('../views/Login.vue'),
        meta: { guest: true }
    },
    {
        path: '/register',
        name: 'Register',
        component: () => import('../views/Register.vue'),
        meta: { guest: true }
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach(async (to, from, next) => {
    const { isAuthenticated, initialized, fetchCurrentUser } = useAuth()

    // On first navigation, check if the user has a valid session cookie
    if (!initialized.value) {
        await fetchCurrentUser()
    }

    if (to.meta.requiresAuth && !isAuthenticated.value) {
        next({ name: 'Login' })
    } else if (to.meta.guest && isAuthenticated.value) {
        next({ name: 'Home' })
    } else {
        next()
    }
})

export default router
