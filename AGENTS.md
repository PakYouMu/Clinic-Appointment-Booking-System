## Design Context

### Users
- **Consumer users**: General end-users accessing the application for its core functionality
- **Admin/Internal staff**: Internal team members managing content, users, and operations
- Both user types have distinct needs but share the same design language

### Brand Personality
- **Elegant/Premium**: Refined, sophisticated aesthetic that feels polished and high-quality
- Clean visual hierarchy with thoughtful spacing and typography
- Subtle, refined interactions that feel premium without being flashy

### Aesthetic Direction
- **Theme**: Supports both light and dark modes with consistent quality in each
- **Design System**: Built on Tailwind CSS v4 + Shadcn Vue (Reka UI) component library
- **Color Palette**: Neutral, cool-gray primary colors using OKLCH color space
  - Primary: `oklch(0.21 0.006 285.885)` (dark charcoal)
  - Background: `oklch(1 0 0)` (white) / dark: `oklch(0.141 0.005 285.823)`
  - Uses semantic tokens: card, popover, primary, secondary, muted, destructive, border, etc.
- **Typography**: System fonts (no custom font set yet - consider adding refined sans-serif)
- **Spacing**: 0.625rem border radius, standard Tailwind spacing scale

### Design Principles
1. **Refined Simplicity** - Every element should have a purpose; avoid unnecessary decoration
2. **Consistent Hierarchy** - Clear visual distinction between primary, secondary, and tertiary elements
3. **Premium Feel** - Thoughtful micro-interactions, smooth transitions, polished details
4. **Accessibility-First** - Leverage shadcn-vue's built-in accessibility; maintain WCAG compliance
5. **Dual-Theme Quality** - Both light and dark modes should feel equally intentional and refined