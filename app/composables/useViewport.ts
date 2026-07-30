export function useViewport() {
  const currentSection = ref(0)
  const sectionIds = ['home', 'about', 'products', 'gallery', 'contact']

  function scrollToSection(index: number) {
    const el = document.getElementById(sectionIds[index])
    if (el) el.scrollIntoView({ behavior: 'smooth' })
  }

  function handleKeydown(e: KeyboardEvent) {
    const { key } = e
    const max = sectionIds.length - 1
    if (['ArrowDown', 'PageDown'].includes(key)) {
      e.preventDefault()
      scrollToSection(Math.min(currentSection.value + 1, max))
    } else if (['ArrowUp', 'PageUp'].includes(key)) {
      e.preventDefault()
      scrollToSection(Math.max(currentSection.value - 1, 0))
    } else if (key === 'Home') {
      e.preventDefault()
      scrollToSection(0)
    } else if (key === 'End') {
      e.preventDefault()
      scrollToSection(max)
    }
  }

  // Scroll spy — tracks which section is in view for active nav dot
  function setupScrollSpy() {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            const idx = sectionIds.indexOf(entry.target.id)
            if (idx !== -1) currentSection.value = idx
          }
        }
      },
      { rootMargin: '-45% 0px -45% 0px' }
    )

    onMounted(() => {
      // Wait for nextTick so sibling sections have mounted
      nextTick(() => {
        sectionIds.forEach((id) => {
          const el = document.getElementById(id)
          if (el) observer.observe(el)
        })
        window.addEventListener('keydown', handleKeydown)
      })
    })

    onUnmounted(() => {
      window.removeEventListener('keydown', handleKeydown)
      observer.disconnect()
    })
  }

  // Staggered entry animation — triggers on section scroll into view
  function setupEntryAnimations() {
    onMounted(() => {
      nextTick(() => {
        const observer = new IntersectionObserver(
          (entries) => {
            entries.forEach((entry) => {
              if (entry.isIntersecting) {
                const children = entry.target.querySelectorAll('.animate-entry')
                children.forEach((child) => {
                  child.classList.add('animate')
                })
                observer.unobserve(entry.target)
              }
            })
          },
          { threshold: 0.15 }
        )

        document.querySelectorAll('.section').forEach((el) => observer.observe(el))
      })
    })
  }

  return {
    currentSection,
    sectionIds,
    scrollToSection,
    setupScrollSpy,
    setupEntryAnimations,
  }
}
