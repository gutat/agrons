export function useMediaSupport() {
    const supportsVideo = ref(false);
    const isMobile = ref(false);
    const prefersReducedMotion = ref(false);

    onMounted(() => {
        const reduced = window.matchMedia("(prefers-reduced-motion: reduce)");
        const nav = navigator as unknown as {
            deviceMemory?: number;
            hardwareConcurrency?: number;
        };
        const lowMemory =
            typeof nav.deviceMemory === "number" && nav.deviceMemory <= 2; // Turunkan batas ke 2GB
        const lowCpu =
            typeof nav.hardwareConcurrency === "number" &&
            nav.hardwareConcurrency <= 2; // Turunkan batas ke 2 core

        // HAPUS pengecekan layar kecil
        isMobile.value = window.matchMedia("(max-width: 768px)").matches;
        prefersReducedMotion.value = reduced.matches;

        supportsVideo.value =
            !reduced.matches &&  // Hanya blokir jika reduced motion
            !lowMemory &&
            !lowCpu;
    });

    return { supportsVideo, isMobile, prefersReducedMotion };
}
