# Restaurant Digital Menu

> **Note:** For restaurant-specific information (name, address, menu items, and prices), see [docs/specs/menu-data.md](specs/menu-data.md)

## Objective
Make restaurant menus digital to provide a better customer experience and easier menu management.

## Problems with Physical Menus

Physical menus in restaurants face several challenges:

1. **High Cost** - Printing and maintaining physical menus is expensive
2. **Difficult to Update** - Dish prices often depend on the season and ingredient availability, making it hard to keep physical menus current
3. **Limited Availability** - Typically only 1-2 menus per table
4. **Wait Times** - Customers have to wait for available menus before ordering

## How Digital Menus Solve These Issues

Digital menus provide significant advantages:

1. **Easy Updates** - Menu can be quickly updated based on grocery availability
2. **Dynamic Pricing** - Prices can be adjusted easily based on seasonal changes
3. **Trend Adaptation** - Dish names and descriptions can be customized to match current trends
4. **Universal Access** - Every customer can scan a QR code with their smartphone to view the menu simultaneously

## Solution Implementation

### Approach
- QR codes will be placed on all restaurant tables
- Customers scan the QR code to access the digital menu on their phones
- The menu will be built as a responsive website using HTML, CSS, and JavaScript

### Technical Stack
- **Frontend**: HTML, CSS, JavaScript
- **Assets**: Images stored in `static/images` directory
- **Reference**: Physical menu images available in the `docs/specs` directory

### Website Structure

The digital menu website will include multiple pages:

1. **Home/Menu Page (index.html)** - Main digital menu
   - Restaurant name and address displayed prominently
   - Navigation bar with links to Menu, Gallery, and Contact pages
   - Menu organized by categories (Starters, Main Course, Breads, Rice & Dal, etc.)
   - Each dish displays: image, name, and price
   - Responsive design for mobile viewing

2. **Image Gallery Page (gallery.html)** - Restaurant ambiance showcase
   - Navigation bar for easy page switching
   - Responsive grid layout displaying restaurant photos
   - Interior, exterior, and ambiance images
   - Lightbox/modal functionality for enlarged image viewing
   - Optimized images for fast loading

3. **Contact Page (contact.html)** - Customer connection information
   - Navigation bar
   - Contact details (phone number and email)
   - Embedded Google Maps showing restaurant location
   - Full address with directions
   - Operating hours (optional)
   - Social media links (optional)
   - Call-to-action buttons for phone and email

### Page Components

**Common Elements (All Pages):**
- Responsive navigation bar
- Restaurant branding (name and logo)
- Footer with quick links and social media
- Mobile-friendly design

**Menu Page Specific:**
- Category navigation/filtering
- Dish cards with images and prices
- Smooth scrolling between categories
- Search functionality (optional)

**Gallery Page Specific:**
- Image grid layout
- Lightbox modal for full-screen viewing
- Image captions (optional)

**Contact Page Specific:**
- Interactive Google Maps
- Click-to-call phone button
- Click-to-email button
- Contact form (optional)

### Directory Structure
```
restaurant-menu/
├── docs/
│   ├── README.md (this file)
│   ├── specs-file.txt
│   └── specs/ (physical menu reference images)
├── static/
│   ├── css/
│   │   └── styles.css
│   ├── images/
│   │   ├── dishes/ (dish images)
│   │   └── gallery/ (restaurant ambiance images)
│   └── js/
│       └── script.js
├── index.html (main menu page)
├── gallery.html (image gallery page)
└── contact.html (contact information page)
```

## Benefits

- Cost-effective menu management
- Real-time updates for prices and availability
- Better customer experience with no wait times
- Environmentally friendly (less paper waste)
- Accessible to all customers simultaneously

## Project Checklist

### Phase 1: Project Setup
- [ ] Review physical menu images in `docs/specs/` directory
- [ ] Create `static/` directory structure
  - [ ] Create `static/css/` directory
  - [ ] Create `static/images/` directory for dish images
  - [ ] Create `static/js/` directory
- [ ] Gather or create images for all menu dishes
- [ ] Decide on restaurant name and branding

### Phase 2: Design & Planning
- [ ] Define menu categories (Appetizers, Main Course, Desserts, Beverages, etc.)
- [ ] List all dishes with prices and descriptions
- [ ] Plan color scheme and design theme
- [ ] Sketch wireframe/layout for the menu website

### Phase 3: Development
- [ ] Create `index.html` with basic structure
  - [ ] Add restaurant name header and address
  - [ ] Create navigation bar (Menu, Gallery, Contact)
  - [ ] Create navigation for menu categories
  - [ ] Build dish card template for all categories
  - [ ] Link to `static/css/styles.css`
  - [ ] Link to `static/js/script.js`
- [ ] Create `gallery.html` for image gallery
  - [ ] Add navigation bar
  - [ ] Create responsive grid layout for images
  - [ ] Implement lightbox/modal for enlarged images
  - [ ] Add restaurant interior/exterior photos
- [ ] Create `contact.html` for contact information
  - [ ] Add navigation bar
  - [ ] Display phone number
  - [ ] Display email address
  - [ ] Embed Google Maps with restaurant location
  - [ ] Display full address
  - [ ] Add operating hours (if available)
  - [ ] Add social media links (if available)
- [ ] Create `static/css/styles.css` for styling
  - [ ] Implement responsive design for mobile devices
  - [ ] Style header and restaurant branding
  - [ ] Style navigation bar
  - [ ] Style menu category sections
  - [ ] Style dish cards (image, name, price, description)
  - [ ] Style gallery page layout
  - [ ] Style contact page layout
  - [ ] Add hover effects and animations
- [ ] Create `static/js/script.js` for interactivity
  - [ ] Implement smooth scrolling between sections
  - [ ] Add category filtering/navigation
  - [ ] Add gallery lightbox functionality
  - [ ] Add any dynamic features (search, etc.)

### Phase 4: Content Population
- [ ] Create subdirectories in `static/images/`
  - [ ] Create `static/images/dishes/` directory
  - [ ] Create `static/images/gallery/` directory
- [ ] Add all dish images to `static/images/dishes/` directory
- [ ] Add restaurant ambiance images to `static/images/gallery/` directory
- [ ] Input all dish names, prices, and descriptions
- [ ] Organize dishes into appropriate categories
- [ ] Add contact information (phone, email)
- [ ] Get Google Maps embed code for location
- [ ] Verify all content is accurate and up-to-date

### Phase 5: Testing & Optimization
- [ ] Test on various mobile devices (iOS, Android)
- [ ] Test on different screen sizes (phone, tablet)
- [ ] Test on different browsers (Chrome, Safari, Firefox)
- [ ] Optimize images for faster loading
- [ ] Verify all links and navigation work correctly
- [ ] Check for spelling and grammar errors

### Phase 6: Deployment
- [ ] Choose hosting platform (GitHub Pages, Netlify, Vercel, etc.)
- [ ] Deploy website to hosting platform
- [ ] Generate QR code linking to the deployed website
- [ ] Test QR code scanning functionality
- [ ] Print QR codes for restaurant tables

### Phase 7: Maintenance
- [ ] Document process for updating menu items
- [ ] Create guidelines for adding new dishes
- [ ] Set up version control for tracking changes
- [ ] Plan regular reviews for price and availability updates
