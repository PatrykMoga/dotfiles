# cenymieszkania.pl Website - Implementation Plan

## Problem Statement
Polish apartment buyers need price transparency - they want to see how developer prices actually change over time, not just current listings. Data from dane.gov.pl provides this, but it's buried in CSVs/Excel files.

## Proposed Solution
Build a static Astro website that:
1. Shows historical apartment price data from developers
2. Lets users browse by location, filter by area/price/rooms/developer
3. Displays price history charts for individual apartments
4. Uses mock data initially (will connect to API later)

## Scope

### In Scope (v1)
- Landing page with value proposition
- Search/browse page with full filters (location, area, price range, rooms, developer)
- Apartment detail page with line chart price history
- ~200 mock apartments with price history data
- Polish language only
- Map mock component (placeholder for future)
- Mobile responsive

### Out of Scope
- Backend API (mocked with JSON)
- Real maps integration
- User accounts/favorites
- English language

## Technical Approach

### Data Structure
Create JSON files in `src/data/`:
- `apartments.json` - apartment listings with current price
- `price-history.json` - historical prices per apartment ID
- `locations.json` - województwo/powiat/gmina hierarchy

### Key Pages
1. `/` - Landing page
2. `/szukaj` - Search/filter page
3. `/mieszkanie/[id]` - Apartment detail with price chart

### Styling
- Vanilla CSS (no framework) - aligns with project philosophy
- Modern, clean design via frontend-design skill
- CSS variables for colors/spacing

### Charting
- Lightweight chart library (Chart.js or uPlot) for price history

### File Structure
```
src/
├── data/
│   ├── apartments.json
│   ├── price-history.json
│   └── locations.json
├── pages/
│   ├── index.astro (landing)
│   ├── szukaj.astro (search)
│   └── mieszkanie/[id].astro (detail)
├── components/
│   ├── Header.astro
│   ├── Footer.astro
│   ├── ApartmentCard.astro
│   ├── FilterSidebar.astro
│   ├── PriceChart.astro (client-side)
│   └── MapPlaceholder.astro
└── layouts/
    └── Layout.astro
```

## Critical Files to Modify/Create
- `website/src/data/*.json` - mock data
- `website/src/pages/*.astro` - all pages
- `website/src/components/*.astro` - UI components
- `website/src/layouts/Layout.astro` - base layout
- `website/package.json` - add chart library

## Task Breakdown
Tasks will be saved to `website/tasks/` folder:
1. Data preparation - parse example CSVs, create JSON mock data
2. Layout & base components - Header, Footer, Layout
3. Landing page - hero, value prop, CTA
4. Search page - filters, apartment list
5. Detail page - apartment info, price history chart
6. Map placeholder component
7. Polish & responsive adjustments

## Verification
1. Run `pnpm dev` - verify all pages render
2. Navigate through: landing → search → filter → apartment detail
3. Verify price chart displays correctly
4. Test responsive design at mobile breakpoints
5. Verify Polish text displays correctly (UTF-8)
