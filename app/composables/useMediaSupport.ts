/**
 * Device/media capability detection for video fallbacks.
 * Videos are skipped on small screens, low-end devices (memory/CPU),
 * and when the user prefers reduced motion — the poster/image shows instead.
 */
export function useMediaSupport() {
    const supportsVideo = ref(false);
    const isMobile = ref(false);
    const prefersReducedMotion = ref(false);

    onMounted(() => {
        const smallScreen = window.matchMedia("(max-width: 768px)");
        const reduced = window.matchMedia("(prefers-reduced-motion: reduce)");
        const nav = navigator as unknown as {
            deviceMemory?: number;
            hardwareConcurrency?: number;
        };
        const lowMemory =
            typeof nav.deviceMemory === "number" && nav.deviceMemory <= 4;
        const lowCpu =
            typeof nav.hardwareConcurrency === "number" &&
            nav.hardwareConcurrency <= 4;

        isMobile.value = smallScreen.matches;
        prefersReducedMotion.value = reduced.matches;
        supportsVideo.value =
            !smallScreen.matches &&
            !reduced.matches &&
            !lowMemory &&
            !lowCpu;
    });

    return { supportsVideo, isMobile, prefersReducedMotion };
}
