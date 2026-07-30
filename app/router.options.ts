import type { RouterConfig } from 'nuxt/schema'

export default <RouterConfig>{
  scrollBehavior(to, from, savedPosition) {
    if (to.hash) {
      return new Promise((resolve) => {
        const check = () => {
          const el = document.querySelector(to.hash)
          if (el) {
            resolve({ el: to.hash, behavior: 'smooth' })
          } else {
            setTimeout(check, 50)
          }
        }
        check()
      })
    }
    if (savedPosition) {
      return savedPosition
    }
    return { top: 0 }
  },
}
