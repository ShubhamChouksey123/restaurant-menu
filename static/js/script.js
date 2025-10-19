/* =================================================================
   Restaurant Digital Menu - Bapu Ki Kutia
   Interactive JavaScript Features
   ================================================================= */

// =================================================================
// DOM Content Loaded - Initialize when page is ready
// =================================================================
document.addEventListener('DOMContentLoaded', function() {
    initSmoothScrolling();
    initCategoryNavigation();
    initActiveNavigation();
    initScrollToTop();
    initImageErrorHandling();
    initSearchFunctionality();
    initCategoryHighlight();
    initMobileMenu();
    console.log('✅ Restaurant Menu loaded successfully!');
});

// =================================================================
// Smooth Scrolling for All Links
// =================================================================
function initSmoothScrolling() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#' || targetId === '#menu') {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
                return;
            }
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                const headerOffset = 120; // Account for sticky navs
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                
                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// =================================================================
// Category Navigation - Highlight Active Category
// =================================================================
function initCategoryNavigation() {
    const categoryLinks = document.querySelectorAll('.category-nav a');
    
    categoryLinks.forEach(link => {
        link.addEventListener('click', function() {
            // Remove active class from all links
            categoryLinks.forEach(l => l.classList.remove('active'));
            // Add active class to clicked link
            this.classList.add('active');
        });
    });
}

// =================================================================
// Active Navigation Based on Scroll Position
// =================================================================
function initActiveNavigation() {
    const sections = document.querySelectorAll('.menu-category');
    const categoryLinks = document.querySelectorAll('.category-nav a');
    
    window.addEventListener('scroll', () => {
        let current = '';
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            if (window.pageYOffset >= sectionTop - 200) {
                current = section.getAttribute('id');
            }
        });
        
        categoryLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === `#${current}`) {
                link.classList.add('active');
                // Scroll the active link into view in the category nav
                link.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
            }
        });
    });
}

// =================================================================
// Scroll to Top Button
// =================================================================
function initScrollToTop() {
    // Create scroll to top button
    const scrollBtn = document.createElement('button');
    scrollBtn.innerHTML = '↑';
    scrollBtn.className = 'scroll-to-top';
    scrollBtn.setAttribute('aria-label', 'Scroll to top');
    document.body.appendChild(scrollBtn);
    
    // Show/hide button based on scroll position
    window.addEventListener('scroll', () => {
        if (window.pageYOffset > 300) {
            scrollBtn.classList.add('visible');
        } else {
            scrollBtn.classList.remove('visible');
        }
    });
    
    // Scroll to top on click
    scrollBtn.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

// =================================================================
// Image Error Handling - Fallback for Missing Images
// =================================================================
function initImageErrorHandling() {
    const images = document.querySelectorAll('.dish-card img');
    
    images.forEach(img => {
        img.addEventListener('error', function() {
            // Create a placeholder with the dish name
            const dishName = this.alt;
            const canvas = document.createElement('canvas');
            canvas.width = 400;
            canvas.height = 300;
            const ctx = canvas.getContext('2d');
            
            // Create gradient background
            const gradient = ctx.createLinearGradient(0, 0, 400, 300);
            gradient.addColorStop(0, '#f4a261');
            gradient.addColorStop(1, '#c41e3a');
            ctx.fillStyle = gradient;
            ctx.fillRect(0, 0, 400, 300);
            
            // Add dish emoji
            ctx.font = 'bold 80px Arial';
            ctx.textAlign = 'center';
            ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
            ctx.fillText('🍽️', 200, 120);
            
            // Add text
            ctx.font = 'bold 24px Arial';
            ctx.fillStyle = 'white';
            ctx.fillText(dishName, 200, 180);
            
            // Set the canvas as image source
            this.src = canvas.toDataURL();
        });
    });
}

// =================================================================
// Search Functionality
// =================================================================
function initSearchFunctionality() {
    // Create search bar
    const searchContainer = document.createElement('div');
    searchContainer.className = 'search-container';
    searchContainer.innerHTML = `
        <input type="text" id="menuSearch" placeholder="🔍 Search dishes..." aria-label="Search menu items">
        <button id="clearSearch" class="clear-search" aria-label="Clear search">✕</button>
    `;
    
    // Insert search bar after category nav
    const categoryNav = document.querySelector('.category-nav');
    categoryNav.parentNode.insertBefore(searchContainer, categoryNav.nextSibling);
    
    const searchInput = document.getElementById('menuSearch');
    const clearBtn = document.getElementById('clearSearch');
    const dishCards = document.querySelectorAll('.dish-card');
    const categories = document.querySelectorAll('.menu-category');
    
    // Search functionality
    searchInput.addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase().trim();
        
        if (searchTerm === '') {
            // Show all dishes and categories
            dishCards.forEach(card => card.style.display = 'flex');
            categories.forEach(cat => cat.style.display = 'block');
            clearBtn.style.display = 'none';
            return;
        }
        
        clearBtn.style.display = 'block';
        
        // Filter dishes
        categories.forEach(category => {
            let visibleCount = 0;
            const dishes = category.querySelectorAll('.dish-card');
            
            dishes.forEach(dish => {
                const dishName = dish.querySelector('h3').textContent.toLowerCase();
                const categoryName = category.querySelector('h2').textContent.toLowerCase();
                
                if (dishName.includes(searchTerm) || categoryName.includes(searchTerm)) {
                    dish.style.display = 'flex';
                    visibleCount++;
                } else {
                    dish.style.display = 'none';
                }
            });
            
            // Hide category if no dishes are visible
            category.style.display = visibleCount > 0 ? 'block' : 'none';
        });
    });
    
    // Clear search
    clearBtn.addEventListener('click', function() {
        searchInput.value = '';
        searchInput.dispatchEvent(new Event('input'));
        searchInput.focus();
    });
    
    // Clear search on Escape key
    searchInput.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            this.value = '';
            this.dispatchEvent(new Event('input'));
        }
    });
}

// =================================================================
// Category Highlight on Scroll
// =================================================================
function initCategoryHighlight() {
    const categories = document.querySelectorAll('.menu-category');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '-50px'
    });
    
    categories.forEach(category => {
        observer.observe(category);
    });
}

// =================================================================
// Mobile Menu Toggle
// =================================================================
function initMobileMenu() {
    const nav = document.querySelector('nav');
    const categoryNav = document.querySelector('.category-nav');
    
    // Add mobile menu button
    const menuBtn = document.createElement('button');
    menuBtn.className = 'mobile-menu-toggle';
    menuBtn.innerHTML = '☰';
    menuBtn.setAttribute('aria-label', 'Toggle menu');
    
    nav.querySelector('.container').prepend(menuBtn);
    
    // Toggle menu
    menuBtn.addEventListener('click', function() {
        nav.classList.toggle('mobile-open');
        this.innerHTML = nav.classList.contains('mobile-open') ? '✕' : '☰';
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', function(e) {
        if (!nav.contains(e.target) && nav.classList.contains('mobile-open')) {
            nav.classList.remove('mobile-open');
            menuBtn.innerHTML = '☰';
        }
    });
}

// =================================================================
// Dish Card Animation on Hover
// =================================================================
function initDishCardAnimations() {
    const dishCards = document.querySelectorAll('.dish-card');
    
    dishCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-8px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });
}

// =================================================================
// Category Counter - Show number of dishes
// =================================================================
function addCategoryCounters() {
    const categories = document.querySelectorAll('.menu-category');
    
    categories.forEach(category => {
        const dishCount = category.querySelectorAll('.dish-card').length;
        const heading = category.querySelector('h2');
        const counter = document.createElement('span');
        counter.className = 'dish-count';
        counter.textContent = ` (${dishCount} items)`;
        heading.appendChild(counter);
    });
}

// Initialize category counters after DOM is loaded
document.addEventListener('DOMContentLoaded', addCategoryCounters);

// =================================================================
// Performance: Lazy Loading for Images
// =================================================================
function initLazyLoading() {
    const images = document.querySelectorAll('.dish-card img');
    
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.getAttribute('src');
                img.classList.add('loaded');
                observer.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
}

// =================================================================
// Price Filter - Filter by price range
// =================================================================
function initPriceFilter() {
    // Create price filter controls
    const filterContainer = document.createElement('div');
    filterContainer.className = 'price-filter-container';
    filterContainer.innerHTML = `
        <label for="priceRange">Filter by price: </label>
        <select id="priceRange" aria-label="Filter by price range">
            <option value="all">All Prices</option>
            <option value="0-100">Under ₹100</option>
            <option value="100-200">₹100 - ₹200</option>
            <option value="200-300">₹200 - ₹300</option>
            <option value="300-500">Above ₹300</option>
        </select>
    `;
    
    const searchContainer = document.querySelector('.search-container');
    if (searchContainer) {
        searchContainer.appendChild(filterContainer);
    }
    
    const priceSelect = document.getElementById('priceRange');
    const dishCards = document.querySelectorAll('.dish-card');
    const categories = document.querySelectorAll('.menu-category');
    
    priceSelect.addEventListener('change', function() {
        const range = this.value;
        
        if (range === 'all') {
            dishCards.forEach(card => card.style.display = 'flex');
            categories.forEach(cat => cat.style.display = 'block');
            return;
        }
        
        const [min, max] = range.split('-').map(Number);
        
        categories.forEach(category => {
            let visibleCount = 0;
            const dishes = category.querySelectorAll('.dish-card');
            
            dishes.forEach(dish => {
                const priceText = dish.querySelector('.price').textContent;
                const price = parseInt(priceText.replace(/[^\d]/g, ''));
                
                if (max) {
                    if (price >= min && price <= max) {
                        dish.style.display = 'flex';
                        visibleCount++;
                    } else {
                        dish.style.display = 'none';
                    }
                } else {
                    if (price >= min) {
                        dish.style.display = 'flex';
                        visibleCount++;
                    } else {
                        dish.style.display = 'none';
                    }
                }
            });
            
            category.style.display = visibleCount > 0 ? 'block' : 'none';
        });
    });
}

// Initialize price filter
document.addEventListener('DOMContentLoaded', initPriceFilter);

// =================================================================
// Utility: Debounce Function
// =================================================================
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// =================================================================
// Console Welcome Message
// =================================================================
console.log('%c🍽️ Bapu Ki Kutia - Digital Menu', 'color: #c41e3a; font-size: 20px; font-weight: bold;');
console.log('%cPure Vegetarian Restaurant', 'color: #f4a261; font-size: 14px;');
console.log('%cWelcome to our digital menu! Enjoy your meal! 🙏', 'color: #2c3e50; font-size: 12px;');
