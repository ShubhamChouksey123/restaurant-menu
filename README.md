# Restaurant Digital Menu - Bapu Ki Kutia

[![Validate Files](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/validate.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/validate.yml)
[![Deploy](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/deploy.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/deploy.yml)
[![Check Links](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/link-checker.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/link-checker.yml)
[![Code Quality](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/code-quality.yml/badge.svg)](https://github.com/ShubhamChouksey123/restaurant-menu/actions/workflows/code-quality.yml)

A modern, responsive digital menu website for **Bapu Ki Kutia**, a pure vegetarian restaurant in Bhopal, India. Built with HTML, CSS, and JavaScript - featuring 126 dishes across 16 categories with professional food photography.

## 🌐 Live Demo

**Website:** [https://shubhamchouksey123.github.io/restaurant-menu/](https://shubhamchouksey123.github.io/restaurant-menu/)

---

## ✨ Features

- 🍽️ **126 Dishes** with high-quality images across 16 categories
- 📱 **Responsive Design** optimized for mobile devices
- 🔍 **Interactive Search** to quickly find dishes
- ⚡ **Fast Loading** with optimized images (800x600px, ~95KB each)
- 🚀 **Auto-deployed** via GitHub Actions to GitHub Pages
- ✅ **CI/CD Pipeline** with automated validation and quality checks

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/ShubhamChouksey123/restaurant-menu.git
cd restaurant-menu

# Open in browser
open index.html
```

---

## 🛠️ Tech Stack

- **Frontend:** HTML5, CSS3, Vanilla JavaScript
- **Hosting:** GitHub Pages
- **CI/CD:** GitHub Actions
- **Images:** Unsplash (123 images) + 3 placeholders
- **Total Size:** ~12MB (126 images)

---

## 📁 Project Structure

```
restaurant-menu/
├── .github/workflows/    # CI/CD automation (validate, deploy, quality checks)
├── static/
│   ├── css/             # Styles with red/maroon theme
│   ├── js/              # Interactive features (search, scroll, filter)
│   └── images/dishes/   # 126 dish images (800x600px JPG)
├── docs/                # Project documentation and planning
├── index.html           # Main menu page
└── README.md            # This file
```

---

## 📖 Documentation

- **[Project Documentation](docs/README.md)** - Complete development guide, checklists, and planning
- **[Workflow Documentation](.github/workflows/README.md)** - CI/CD pipeline details

---

## 🎨 Customization

### Update Menu Items
Edit `index.html` to modify dishes, prices, or descriptions.

### Change Theme Colors
Edit CSS variables in `static/css/styles.css`:
```css
:root {
    --primary-color: #c41e3a;
    --primary-dark: #8b0000;
}
```

### Add Images
Place 800x600px JPG images in `static/images/dishes/` and reference in HTML.

---

## 📱 Deployment for Restaurant

1. **Generate QR Code:** Use [QR Code Generator](https://www.qr-code-generator.com) with your site URL
2. **Print:** Recommended size 3x3 inches
3. **Place:** On all restaurant tables
4. **Done:** Customers scan to view menu instantly!

---

## 👨‍💻 Author

**Shubham Chouksey**
- GitHub: [@ShubhamChouksey123](https://github.com/ShubhamChouksey123)
- Email: shubhamchouksey1998@gmail.com

---

## 🏪 About

**Bapu Ki Kutia** - Pure Vegetarian Restaurant
Khajuri Sadak, NH-18, Bhopal, Madhya Pradesh 462030
Cuisine: North Indian, South Indian, Chinese, Continental

---

## 📝 License

MIT License - Images from [Unsplash](https://unsplash.com/license)

**Version:** 1.0.0 | **Status:** 🚀 Production Ready
