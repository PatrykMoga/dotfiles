# Landing Page Starter Template - Implementation Plan

## Overview
A reusable Astro landing page template with config-driven forms, email notifications via Resend, and Cloudflare Turnstile spam protection. Deployed on Cloudflare Pages in hybrid mode.

## Tech Stack
- **Framework**: Astro 5 (hybrid mode - static pages + server actions)
- **Styling**: Tailwind CSS
- **Form handling**: Astro Actions with Zod validation
- **Email**: Resend
- **Spam protection**: Cloudflare Turnstile (invisible)
- **Deployment**: Cloudflare Pages

## File Structure

```
src/
├── actions/
│   └── index.ts                 # Form submission action
├── components/
│   ├── sections/
│   │   ├── Hero.astro
│   │   ├── Features.astro
│   │   ├── Testimonials.astro
│   │   ├── FAQ.astro
│   │   └── ContactForm.astro
│   ├── form/
│   │   ├── FormField.astro      # Renders field based on type
│   │   ├── TextField.astro
│   │   ├── TextareaField.astro
│   │   ├── SelectField.astro
│   │   ├── RadioField.astro
│   │   ├── CheckboxField.astro
│   │   └── DateField.astro
│   ├── SEO.astro
│   └── Layout.astro
├── config/
│   ├── form.config.ts           # Form fields + validation rules
│   ├── content.config.ts        # Page content (hero, features, etc.)
│   └── theme.config.ts          # Colors, fonts, spacing tokens
├── lib/
│   ├── email.ts                 # Resend email sending
│   ├── turnstile.ts             # Turnstile verification
│   ├── rate-limit.ts            # Simple rate limiting
│   └── schema.ts                # Generate Zod schema from form config
├── pages/
│   └── index.astro
└── styles/
    └── global.css
```

## Implementation Steps

### 1. Setup & Configuration
- Install dependencies: `@astrojs/cloudflare`, `@astrojs/tailwind`, `resend`, `zod`
- Configure `astro.config.mjs` for hybrid mode with Cloudflare adapter
- Set up Tailwind with theme config integration
- Create `.env.example` with required variables:
  ```
  RESEND_API_KEY=
  RECIPIENT_EMAIL=
  TURNSTILE_SECRET_KEY=
  PUBLIC_TURNSTILE_SITE_KEY=
  ```

### 2. Config System
**`src/config/form.config.ts`** - Define form fields with validation:
```ts
export const formConfig = {
  fields: [
    {
      name: "fullName",
      type: "text",
      label: "Full Name",
      placeholder: "John Smith",
      validation: { required: true, minLength: 2 }
    },
    {
      name: "email",
      type: "email",
      label: "Email",
      validation: { required: true }
    },
    {
      name: "serviceType",
      type: "select",
      label: "Service Needed",
      options: ["Interior Painting", "Exterior Painting", "Deck Staining"],
      validation: { required: true }
    },
    // ... more fields
  ]
}
```

**`src/config/content.config.ts`** - Page sections content
**`src/config/theme.config.ts`** - Design tokens (colors, spacing)

### 3. Schema Generation
**`src/lib/schema.ts`** - Generate Zod schema from form config:
- Parse field definitions
- Map validation rules to Zod validators
- Export typed schema for action

### 4. Form Components
**`src/components/form/FormField.astro`** - Routes to correct field component based on type
**Individual field components** - Handle specific input types with:
- Proper labels and placeholders from config
- Error state display
- Tailwind styling

### 5. Contact Form Section
**`src/components/sections/ContactForm.astro`**:
- Renders form from config
- Invisible Turnstile widget
- Client-side JS for:
  - Form submission via Astro Actions
  - Loading state (button disabled + "Sending...")
  - Success message (inline, replaces form)
  - Error handling (preserve data, show message, retry)

### 6. Astro Action
**`src/actions/index.ts`**:
1. Validate Turnstile token
2. Check rate limit (by IP)
3. Validate form data against generated Zod schema
4. Send HTML email via Resend
5. Return success/error response

### 7. Email Template
**`src/lib/email.ts`**:
- HTML email template with submitted data
- Styled to match theme config
- Clear field labels and values

### 8. Rate Limiting
**`src/lib/rate-limit.ts`**:
- Simple in-memory rate limiter (Cloudflare Workers KV could be used for persistence)
- Limit by IP address
- Configurable window (e.g., 5 submissions per hour)

### 9. Section Components
Build modular section components reading from content.config.ts:
- **Hero**: Headline, subheadline, CTA
- **Features**: Grid of feature cards with icons
- **Testimonials**: Customer quotes
- **FAQ**: Accordion-style Q&A

### 10. SEO Component
**`src/components/SEO.astro`**:
- Title, meta description from content config
- Open Graph tags
- Twitter cards
- Structured data (LocalBusiness schema)
- Canonical URL

### 11. Demo Content
Realistic home services example - "Smith's Painting Co.":
- Hero: Professional house painting services
- Features: Licensed & insured, free estimates, quality materials, clean worksite
- Testimonials: 3 fake customer reviews
- FAQ: Common painting questions
- Form: Name, email, phone, service type, project description, preferred date

## Files to Modify/Create

| File | Action |
|------|--------|
| `astro.config.mjs` | Modify - add Cloudflare adapter, Tailwind |
| `package.json` | Modify - add dependencies |
| `tailwind.config.mjs` | Create |
| `.env.example` | Create |
| `src/actions/index.ts` | Create |
| `src/config/*.ts` | Create (3 files) |
| `src/lib/*.ts` | Create (4 files) |
| `src/components/**/*.astro` | Create (~15 files) |
| `src/pages/index.astro` | Modify |
| `src/styles/global.css` | Create |

## Dependencies to Add
```json
{
  "@astrojs/cloudflare": "^12.x",
  "@astrojs/tailwind": "^6.x",
  "tailwindcss": "^4.x",
  "resend": "^4.x",
  "zod": "^3.x"
}
```

## Environment Variables
| Variable | Purpose |
|----------|---------|
| `RESEND_API_KEY` | Resend API authentication |
| `RECIPIENT_EMAIL` | Where form submissions are sent |
| `TURNSTILE_SECRET_KEY` | Server-side Turnstile verification |
| `PUBLIC_TURNSTILE_SITE_KEY` | Client-side Turnstile widget |
