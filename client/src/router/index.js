import { createRouter, createWebHistory } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const routes = [
    {
        path: '/',
        component: () => import('../components/layouts/PatientLayout.vue'),
        children: [
            {
                path: '',
                name: 'Home',
                component: () => import('../views/Home.vue'),
                meta: { requiresAuth: false } // Homepage could be public to see the brand
            },
            {
                path: 'doctors',
                name: 'Doctors',
                component: () => import('../views/Doctors.vue'),
                meta: { requiresAuth: false }
            },
            {
                path: 'book',
                name: 'BookAppointment',
                component: () => import('../views/BookAppointment.vue'),
                meta: { requiresAuth: true }
            },
            {
                path: 'dashboard',
                name: 'PatientDashboard',
                component: () => import('../views/PatientDashboard.vue'),
                meta: { requiresAuth: true }
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
    history: createWebHistory(import.meta.env.BASE_URL),
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
        next({ name: 'PatientDashboard' })
    } else {
        next()
    }
})

export default router
