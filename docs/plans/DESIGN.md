---
name: Agro-Industrial Elegance
colors:
  surface: '#f7fafb'
  surface-dim: '#d7dadb'
  surface-bright: '#f7fafb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f4f5'
  surface-container: '#ebeeef'
  surface-container-high: '#e6e9ea'
  surface-container-highest: '#e0e3e4'
  on-surface: '#181c1d'
  on-surface-variant: '#434843'
  inverse-surface: '#2d3132'
  inverse-on-surface: '#eef1f2'
  outline: '#737973'
  outline-variant: '#c3c8c1'
  surface-tint: '#4d6453'
  primary: '#061b0e'
  on-primary: '#ffffff'
  primary-container: '#1b3022'
  on-primary-container: '#819986'
  inverse-primary: '#b4cdb8'
  secondary: '#7e562e'
  on-secondary: '#ffffff'
  secondary-container: '#fdc796'
  on-secondary-container: '#79512a'
  tertiary: '#171815'
  on-tertiary: '#ffffff'
  tertiary-container: '#2b2c29'
  on-tertiary-container: '#94938f'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d0e9d4'
  primary-fixed-dim: '#b4cdb8'
  on-primary-fixed: '#0b2013'
  on-primary-fixed-variant: '#364c3c'
  secondary-fixed: '#ffdcbf'
  secondary-fixed-dim: '#f1bc8c'
  on-secondary-fixed: '#2d1600'
  on-secondary-fixed-variant: '#633f19'
  tertiary-fixed: '#e4e2dd'
  tertiary-fixed-dim: '#c8c6c2'
  on-tertiary-fixed: '#1b1c19'
  on-tertiary-fixed-variant: '#474744'
  background: '#f7fafb'
  on-background: '#181c1d'
  surface-variant: '#e0e3e4'
typography:
  display-lg:
    fontFamily: Source Serif 4
    fontSize: 64px
    fontWeight: '700'
    lineHeight: 72px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Source Serif 4
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Source Serif 4
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  container-max: 1280px
  gutter: 24px
  margin-mobile: 20px
  section-gap-desktop: 120px
  section-gap-mobile: 64px
---

## Brand & Style
The design system is built to position PT Agro Nusa Sejahtera as a global leader in sustainable agriculture. The brand personality is "Industrial-Organic"—combining the precision of high-end export logistics with the raw, grounded essence of Indonesian coconut processing. 

The aesthetic leverages **Modern Minimalism** infused with **Glassmorphism**. It utilizes generous whitespace to signify premium quality and operational clarity. The UI should evoke a sense of "Sustainable Tech," where natural materials meet sophisticated engineering. Expect high-quality imagery of raw fibers contrasted against sharp, technical UI elements.

## Colors
The palette is rooted in the lifecycle of the coconut. The primary **Deep Forest Green** (#1B3022) represents the lush plantations and sustainability. The accent **Husk Brown** (#8C6239) is used sparingly for highlights, icons, and CTA secondary elements to ground the design.

For the background, a **Soft Cream** (#F9F7F2) replaces pure white to create a more organic, premium feel. In Dark Mode, the interface shifts to a **Deep Charcoal** (#121414) with muted green overlays, maintaining the "Agro-Tech" sophisticated look without harsh contrast.

## Typography
This design system employs a sophisticated serif/sans-serif pairing. **Source Serif 4** provides the authoritative, heritage-driven voice for all high-level messaging and editorial headers. **Hanken Grotesk** serves as the functional workhorse, offering a clean, contemporary feel for technical data and interface labels.

To maintain the premium feel, use "Display" sizes for landing page heroes with tight letter-spacing. UI labels should always utilize the uppercase tracking of the `label-caps` style to differentiate functional elements from narrative content.

## Layout & Spacing
The layout follows a **Fluid Grid** model with a strict 12-column structure for desktop. To emphasize the premium "global exporter" scale, the design system utilizes larger-than-standard vertical gaps (`section-gap-desktop`) to allow the high-quality product photography to breathe.

Content should be centered in a fixed-width container on ultra-wide screens to maintain legibility. On mobile, the margins tighten, and the 12-column grid collapses to a single-column flow, with horizontal swiper components used for product catalogs to conserve vertical space.

## Elevation & Depth
Depth is achieved through **Glassmorphism** rather than traditional drop shadows. Primary cards use a backdrop-blur (12px to 20px) with a semi-transparent cream or charcoal fill. 

For interactive elements, use **Tonal Layers**. Elements that sit higher in the stack should be slightly lighter in value. Borders are kept thin (1px) and low-contrast, acting as subtle "ghost outlines" to define structure without cluttering the visual field. When shadows are necessary for high-impact CTAs, they must be extremely diffused and tinted with the Primary Green to maintain a soft, natural appearance.

## Shapes
The shape language is "Soft-Technical." By using a `Soft` roundedness (4px - 12px), the design system balances the rigidity of industrial manufacturing with the organic nature of the coconut fiber. 

Containers like cards and input fields should use the 8px (`rounded-lg`) standard. Buttons should remain slightly sharper (4px) to convey precision and professionalism. Strictly avoid "Pill" shapes as they appear too casual for an international B2B export brand.

## Components

### Buttons & CTAs
Buttons are high-contrast. The primary action uses the **Deep Forest Green** background with white text. Hover states involve a subtle shift to the **Husk Brown** or a slight elevation increase. Use "Ghost" buttons with thin 1px borders for secondary actions to maintain the minimalist aesthetic.

### Glassmorphic Cards
Used for product features and testimonials. They must feature a `backdrop-filter: blur()` effect with a 1px border colored at 10% opacity of the text color. This allows background imagery (like macro shots of Cocopeat) to bleed through subtly.

### Interactive Swipers
For product galleries (Cocopeat blocks, Cocofiber bales), use a horizontal carousel with pagination dots that utilize the Primary Green for the active state and a muted Slate Gray for inactive states.

### Form Inputs
Inputs use the Soft Cream background with a bottom-border-only focus state in Deep Forest Green. This mimics high-end architectural documentation.

### Progress Indicators
For sustainability reports or shipping tracking, use thin, elegant lines and Hanken Grotesk labels. The visual weight should be light, prioritizing data clarity over decorative elements.