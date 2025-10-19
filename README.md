# Restaurant Digital Menu - Bapu Ki Kutia

[![Validate Files](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/validate.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/validate.yml)
[![Deploy](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/deploy.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/deploy.yml)
[![Check Links](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/link-checker.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/link-checker.yml)
[![Code Quality](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/code-quality.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/code-quality.yml)

A modern, responsive digital menu website for **Bapu Ki Kutia**, a pure vegetarian restaurant in Bhopal, India. Built with HTML, CSS, and JavaScript to replace traditional physical menus with QR code-accessible digital menus.

## 🌐 Live Demo

**Website:** [https://shubhamchouksey123.github.io/restaurant-menu/](https://shubhamchouksey123.github.io/restaurant-menu/)

> Scan the QR code at restaurant tables to access the digital menu instantly!

---

## ✨ Features

- 🍽️ **126 Dishes** across 16 categories with high-quality images
- 📱 **Responsive Design** optimized for mobile devices
- 🔍 **Interactive Search** to quickly find dishes
- 🎯 **Category Navigation** with smooth scrolling
- ⚡ **Fast Loading** with optimized images
- 📷 **Professional Food Photography** from Unsplash
- ♿ **Accessible** with proper semantic HTML
- 🚀 **Auto-deployed** via GitHub Actions

---

## 📋 Menu Categories

- Starters (Shuruaat Karne Ke Liye)
- Soups
- Chinese Starters
- Tandoori Delights
- Indian Curries
- Chinese Main Course
- Continental
- Italian
- Rice & Dal
- Indian Breads
- Accompaniments (Apke Sath Mey)
- Salads
- Desserts
- Cold Beverages
- Hot Beverages
- Shakes & Ice Creams

---

## 🚀 Quick Start

### View Locally

```bash
# Clone the repository
git clone https://github.com/ShubhamChouksey123/restaurant-menu.git
cd restaurant-menu

# Open in browser
open index.html
```

### Deploy Your Own

1. Fork this repository
2. Enable GitHub Pages in Settings → Pages
3. Select "GitHub Actions" as source
4. Your site will be live at: `https://yourusername.github.io/restaurant-menu/`

---

## 📁 Project Structure

```
restaurant-menu/
├── .github/
│   └── workflows/          # CI/CD automation
│       ├── validate.yml    # File validation
│       ├── deploy.yml      # GitHub Pages deployment
│       ├── link-checker.yml # Broken link detection
│       └── code-quality.yml # Code quality checks
├── static/
│   ├── css/
│   │   └── styles.css      # Main stylesheet
│   ├── js/
│   │   └── script.js       # JavaScript functionality
│   └── images/
│       └── dishes/         # 126 dish images
├── docs/                   # Project documentation
├── index.html              # Main menu page
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

---

## 🛠️ Technologies Used

- **HTML5** - Semantic markup
- **CSS3** - Responsive design with Flexbox/Grid
- **JavaScript (Vanilla)** - Interactive features
- **GitHub Actions** - CI/CD automation
- **GitHub Pages** - Free hosting
- **Unsplash API** - Professional food photography

---

## 🔧 Development

### Prerequisites

- Modern web browser
- Text editor (VS Code, Sublime, etc.)
- Git installed

### Local Development

```bash
# Clone repository
git clone https://github.com/ShubhamChouksey123/restaurant-menu.git
cd restaurant-menu

# Make changes to files
# Open index.html in browser to preview

# Commit changes
git add .
git commit -m "Description of changes"
git push origin master
```

### Running Validations

Workflows run automatically on push, but you can test locally:

```bash
# Validate HTML (requires npm)
npm install -g html-validate
html-validate index.html

# Validate CSS
npm install -g stylelint stylelint-config-standard
stylelint "static/css/*.css"

# Validate JavaScript
npm install -g eslint
eslint static/js/*.js
```

---

## 📊 Automated Workflows

This project uses GitHub Actions for:

- ✅ **HTML/CSS/JS Validation** - Ensures valid syntax
- 🖼️ **Image Validation** - Verifies all 126 images exist
- 🔗 **Link Checking** - Detects broken links (runs weekly)
- 📏 **Code Quality** - Checks formatting and best practices
- 🚀 **Auto Deployment** - Deploys to GitHub Pages on push

[View Workflow Details](.github/workflows/README.md)

---

## 🎨 Customization

### Update Menu Items

Edit dish information in `index.html`:

```html
<div class="dish-card">
    <img src="static/images/dishes/butter-chicken.jpg" alt="Butter Chicken">
    <h3>Butter Chicken</h3>
    <p class="price">₹299</p>
    <p class="description">Creamy tomato-based curry...</p>
</div>
```

### Update Styling

Edit colors and styles in `static/css/styles.css`:

```css
:root {
    --primary-color: #c41e3a;  /* Main theme color */
    --primary-dark: #8b0000;   /* Darker shade */
    /* ... more variables */
}
```

### Add New Categories

1. Add category section in `index.html`
2. Add navigation link in category nav
3. Add images to `static/images/dishes/`
4. Update documentation

---

## 📸 Adding Images

### Image Guidelines

- **Format:** JPG (optimized for web)
- **Dimensions:** 800x600 pixels (4:3 aspect ratio)
- **Size:** 50-150 KB per image
- **Quality:** Professional food photography
- **Naming:** Use kebab-case (e.g., `butter-chicken.jpg`)

### Image Sources

- [Unsplash](https://unsplash.com) - Free high-quality photos
- [Pexels](https://pexels.com) - Free stock photos
- Restaurant's own photography

---

## 🌍 Browser Support

- ✅ Chrome (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Edge (latest)
- ✅ Mobile browsers (iOS Safari, Chrome Mobile)

---

## 📱 QR Code Generation

To create QR codes for restaurant tables:

1. Visit [QR Code Generator](https://www.qr-code-generator.com)
2. Enter your site URL: `https://shubhamchouksey123.github.io/restaurant-menu/`
3. Customize design (optional)
4. Download high-resolution PNG
5. Print and place on tables

**Recommended QR Code Size:** 3x3 inches minimum

---

## 📄 Documentation

Detailed documentation is available:

- [Project Documentation](docs/README.md) - Complete overview
- [Workflow Documentation](.github/workflows/README.md) - CI/CD details

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### How to Contribute

1. Fork the repository
2. Create feature branch (`git checkout -b feature/YourFeature`)
3. Commit changes (`git commit -m 'Add YourFeature'`)
4. Push to branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License.

Images are sourced from Unsplash under the [Unsplash License](https://unsplash.com/license).

---

## 👨‍💻 Author

**Shubham Chouksey**
- GitHub: [@ShubhamChouksey123](https://github.com/ShubhamChouksey123)
- Email: shubhamchouksey1998@gmail.com

---

## 🏪 About Bapu Ki Kutia

**Bapu Ki Kutia** is a pure vegetarian restaurant located in Bhopal, Madhya Pradesh, India.

**Address:** Khajuri Sadak, NH-18, Indore - Bhopal Rd, Bhopal, Madhya Pradesh 462030

**Cuisine:** North Indian, South Indian, Chinese, Continental

---

## ⭐ Show Your Support

If you found this project helpful, please give it a ⭐ on GitHub!

---

## 📞 Contact

For questions or support:
- Open an [issue](https://github.com/ShubhamChouksey123/restaurant-menu/issues)
- Email: shubhamchouksey1998@gmail.com

---

**Version:** 1.0.0
**Last Updated:** October 2025
**Status:** 🚀 Production Ready
