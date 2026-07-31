<script setup lang="ts">
import type { MotionProps } from 'motion-v';
import { AnimatePresence, Motion, animate as animateMotionValue, motionValue, useTransform } from 'motion-v';
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue';

export type StaggerFrom = 'first' | 'last' | 'center' | 'random' | number;
export type SplitBy = 'characters' | 'words' | 'lines';

type TransitionType = NonNullable<MotionProps['transition']>;
type InitialType = NonNullable<MotionProps['initial']>;
type AnimateType = NonNullable<MotionProps['animate']>;
type ExitType = NonNullable<MotionProps['exit']>;

interface WordElement {
  characters: string[];
  needsSpace: boolean;
}

interface RotatingTextProps {
  texts: string[];
  transition?: TransitionType;
  initial?: InitialType;
  animate?: AnimateType;
  exit?: ExitType;
  animatePresenceMode?: 'sync' | 'wait';
  animatePresenceInitial?: boolean;
  rotationInterval?: number;
  staggerDuration?: number;
  staggerFrom?: StaggerFrom;
  loop?: boolean;
  auto?: boolean;
  splitBy?: SplitBy;
  onNext?: (index: number) => void;
  mainClassName?: string;
  splitLevelClassName?: string;
  elementLevelClassName?: string;
}

const cn = (...classes: (string | undefined | null | boolean)[]): string => {
  return classes.filter(Boolean).join(' ');
};

const props = withDefaults(defineProps<RotatingTextProps>(), {
  transition: () =>
    ({
      type: 'spring',
      damping: 25,
      stiffness: 300
    }) as TransitionType,
  initial: () => ({ y: '100%', opacity: 0 }) as InitialType,
  animate: () => ({ y: 0, opacity: 1 }) as AnimateType,
  exit: () => ({ y: '-120%', opacity: 0 }) as ExitType,
  animatePresenceMode: 'wait',
  animatePresenceInitial: false,
  rotationInterval: 2000,
  staggerDuration: 0,
  staggerFrom: 'first',
  loop: true,
  auto: true,
  splitBy: 'characters'
});

const currentTextIndex = ref(0);
const el = ref<HTMLElement | null>(null);
let intervalId: ReturnType<typeof setInterval> | null = null;

// --- Smooth width: the container animates between word widths so the
//     preceding inline text (e.g. "Premium") glides instead of jumping. ---
const containerWidth = motionValue<number>(0);
const widthStyle = useTransform(containerWidth, (w) => (w > 0 ? `${w}px` : 'auto'));
const measureRef = ref<HTMLSpanElement | null>(null);

function getRootEl(): HTMLElement | null {
  return ((el.value as any)?.$el || el.value) as HTMLElement | null;
}

function measureCurrentWidth(): number {
  if (!measureRef.value) return 0;
  const root = getRootEl();
  let extra = 0;
  if (root) {
    const cs = getComputedStyle(root);
    extra =
      (parseFloat(cs.paddingLeft) || 0) +
      (parseFloat(cs.paddingRight) || 0) +
      (parseFloat(cs.borderLeftWidth) || 0) +
      (parseFloat(cs.borderRightWidth) || 0);
  }
  return Math.ceil(measureRef.value.getBoundingClientRect().width + extra);
}

function animateWidthTo(nextWidth: number) {
  if (!nextWidth) return;
  animateMotionValue(containerWidth, nextWidth, {
    type: 'spring',
    stiffness: 110,
    damping: 20,
    mass: 0.9,
  });
}

// Delay the width animation until the old word has mostly exited so the
// badge never clips the outgoing characters.
let widthTimer: ReturnType<typeof setTimeout> | null = null;
watch(currentTextIndex, async () => {
  await nextTick();
  const w = measureCurrentWidth();
  if (!w) return;
  if (widthTimer) clearTimeout(widthTimer);
  widthTimer = setTimeout(() => animateWidthTo(w), 260);
});

onMounted(async () => {
  reducedMotion.value = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const target = getRootEl();
  if (target) {
    observer = new IntersectionObserver(
      ([entry]) => {
        inView.value = entry?.isIntersecting ?? false;
        if (!inView.value) cleanupInterval();
        else if (props.auto && !reducedMotion.value) startInterval();
      },
      { threshold: 0.1 }
    );
    observer.observe(target);
  }
  // Lock the container to the initial word width so later rotations
  // animate px→px instead of snapping from auto.
  await nextTick();
  const w = measureCurrentWidth();
  if (w) containerWidth.set(w);
  startInterval();
});

onUnmounted(() => {
  cleanupInterval();
  observer?.disconnect();
  if (widthTimer) clearTimeout(widthTimer);
});

// Only rotate while the headline is actually visible, and never for
// users who prefer reduced motion (they see the first word, static).
const inView = ref(false);
const reducedMotion = ref(false);
let observer: IntersectionObserver | null = null;



const splitIntoCharacters = (text: string): string[] => {
  if (typeof Intl !== 'undefined' && 'Segmenter' in Intl) {
    const IntlWithSegmenter = Intl as typeof Intl & {
      Segmenter: new (
        locales?: string | string[],
        options?: { granularity: 'grapheme' | 'word' | 'sentence' }
      ) => {
        segment: (text: string) => Iterable<{ segment: string }>;
      };
    };
    const segmenter = new IntlWithSegmenter.Segmenter('en', { granularity: 'grapheme' });
    return [...segmenter.segment(text)].map(({ segment }) => segment);
  }

  return [...text];
};
const elements = computed((): WordElement[] => {
  const currentText = props.texts[currentTextIndex.value];

  switch (props.splitBy) {
    case 'characters': {
      const words = currentText.split(' ');
      return words.map((word, i) => ({
        characters: splitIntoCharacters(word),
        needsSpace: i !== words.length - 1
      }));
    }
    case 'words': {
      const words = currentText.split(' ');
      return words.map((word, i) => ({
        characters: [word],
        needsSpace: i !== words.length - 1
      }));
    }
    case 'lines': {
      const lines = currentText.split('\n');
      return lines.map((line, i) => ({
        characters: [line],
        needsSpace: i !== lines.length - 1
      }));
    }
    default: {
      const parts = currentText.split(props.splitBy!);
      return parts.map((part, i) => ({
        characters: [part],
        needsSpace: i !== parts.length - 1
      }));
    }
  }
});

const getStaggerDelay = (index: number, totalChars: number): number => {
  const { staggerDuration, staggerFrom } = props;

  switch (staggerFrom) {
    case 'first':
      return index * staggerDuration;
    case 'last':
      return (totalChars - 1 - index) * staggerDuration;
    case 'center': {
      const center = Math.floor(totalChars / 2);
      return Math.abs(center - index) * staggerDuration;
    }
    case 'random': {
      const randomIndex = Math.floor(Math.random() * totalChars);
      return Math.abs(randomIndex - index) * staggerDuration;
    }
    default:
      return Math.abs((staggerFrom as number) - index) * staggerDuration;
  }
};

const handleIndexChange = (newIndex: number): void => {
  currentTextIndex.value = newIndex;
  props.onNext?.(newIndex);
};

const next = (): void => {
  const isAtEnd = currentTextIndex.value === props.texts.length - 1;
  const nextIndex = isAtEnd ? (props.loop ? 0 : currentTextIndex.value) : currentTextIndex.value + 1;

  if (nextIndex !== currentTextIndex.value) {
    handleIndexChange(nextIndex);
  }
};

const previous = (): void => {
  const isAtStart = currentTextIndex.value === 0;
  const prevIndex = isAtStart
    ? props.loop
      ? props.texts.length - 1
      : currentTextIndex.value
    : currentTextIndex.value - 1;

  if (prevIndex !== currentTextIndex.value) {
    handleIndexChange(prevIndex);
  }
};

const jumpTo = (index: number): void => {
  const validIndex = Math.max(0, Math.min(index, props.texts.length - 1));
  if (validIndex !== currentTextIndex.value) {
    handleIndexChange(validIndex);
  }
};

const reset = (): void => {
  if (currentTextIndex.value !== 0) {
    handleIndexChange(0);
  }
};

const cleanupInterval = (): void => {
  if (intervalId) {
    clearInterval(intervalId);
    intervalId = null;
  }
};

const startInterval = (): void => {
  if (props.auto && inView.value && !reducedMotion.value) {
    intervalId = setInterval(next, props.rotationInterval);
  }
};

defineExpose({
  next,
  previous,
  jumpTo,
  reset
});

watch(
  () => props,
  () => {
    cleanupInterval();
    startInterval();
  }
);
</script>

<template>
  <Motion
    ref="el"
    tag="span"
    :class="cn('flex-wrap whitespace-pre-wrap relative', mainClassName)"
    :style="{ width: widthStyle }"
    v-bind="$attrs"
    :transition="transition"
  >
    <!-- Hidden probe: measures the exact width of the current word -->
    <span ref="measureRef" aria-hidden="true" class="absolute invisible whitespace-nowrap pointer-events-none">
      {{ texts[currentTextIndex] }}
    </span>

    <span class="sr-only">
      {{ texts[currentTextIndex] }}
    </span>

    <AnimatePresence :mode="animatePresenceMode" :initial="animatePresenceInitial">
      <Motion
        :key="currentTextIndex"
        tag="span"
        :class="cn(splitBy === 'lines' ? 'flex flex-col w-full' : 'flex flex-wrap whitespace-pre-wrap relative')"
        aria-hidden="true"
      >
        <span v-for="(wordObj, wordIndex) in elements" :key="wordIndex" :class="cn('inline-flex', splitLevelClassName)">
          <Motion
            v-for="(char, charIndex) in wordObj.characters"
            :key="charIndex"
            tag="span"
            :initial="initial"
            :animate="animate"
            :exit="exit"
            :transition="{
              ...transition,
              delay: getStaggerDelay(
                elements.slice(0, wordIndex).reduce((sum, word) => sum + word.characters.length, 0) + charIndex,
                elements.reduce((sum, word) => sum + word.characters.length, 0)
              )
            }"
            :class="cn('inline-block', elementLevelClassName)"
          >
            {{ char }}
          </Motion>
          <span v-if="wordObj.needsSpace" class="whitespace-pre"></span>
        </span>
      </Motion>
    </AnimatePresence>
  </Motion>
</template>
