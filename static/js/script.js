/* =================================================================
   Restaurant Digital Menu - Bapu Ki Kutia
   Interactive JavaScript Features
   ================================================================= */

// =================================================================
// Menu Data Management - Load from JSON
// =================================================================
let menuData = null;

async function loadMenuData() {
    try {
        const response = await fetch('static/data/menu-data.json');
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        menuData = await response.json();
        return menuData;
    } catch (error) {
        console.error('Error loading menu data:', error);
        showErrorMessage('Failed to load menu. Please refresh the page.');
        return null;
    }
}

function renderCategoryNav(categories) {
    const navContainer = document.getElementById('categoryNavContainer');
    if (!navContainer) return;

    const categoryLinks = categories
        .sort((a, b) => a.display_order - b.display_order)
        .map(category => `<a href="#${category.id}">${category.name.split('(')[0].trim()}</a>`)
        .join('');

    navContainer.innerHTML = categoryLinks;
}

function renderMenuCategories(categories) {
    const menuContainer = document.getElementById('menuContainer');
    if (!menuContainer) return;

    const menuHTML = categories
        .sort((a, b) => a.display_order - b.display_order)
        .map(category => {
            const availableDishes = category.dishes.filter(dish => dish.available);

            if (availableDishes.length === 0) {
                return ''; // Skip empty categories
            }

            const dishesHTML = availableDishes.map(dish => `
                <div class="dish-card" data-dish-id="${dish.id}">
                    <img src="${dish.image}" alt="${dish.alt_text || dish.name}" loading="lazy">
                    <h3>${dish.name}</h3>
                    <p class="price">₹${dish.price}</p>
                </div>
            `).join('');

            return `
                <section id="${category.id}" class="menu-category">
                    <h2>${category.name}</h2>
                    <div class="dish-grid">
                        ${dishesHTML}
                    </div>
                </section>
            `;
        })
        .join('');

    menuContainer.innerHTML = menuHTML;
}

function hideLoadingIndicator() {
    const indicator = document.getElementById('loadingIndicator');
    if (indicator) {
        indicator.style.display = 'none';
    }
}

function showErrorMessage(message) {
    const menuContainer = document.getElementById('menuContainer');
    if (menuContainer) {
        menuContainer.innerHTML = `
            <div style="text-align: center; padding: 50px; color: #c41e3a;">
                <h2>⚠️ ${message}</h2>
                <button onclick="location.reload()" style="margin-top: 20px; padding: 10px 20px; background: #c41e3a; color: white; border: none; border-radius: 5px; cursor: pointer;">
                    Reload Page
                </button>
            </div>
        `;
    }
}

async function initializeMenu() {
    try {
        // Load menu data from JSON
        const data = await loadMenuData();

        if (!data || !data.categories) {
            throw new Error('Invalid menu data structure');
        }

        // Render category navigation and menu
        renderCategoryNav(data.categories);
        renderMenuCategories(data.categories);

        // Hide loading indicator
        hideLoadingIndicator();

        // Initialize all interactive features after menu is rendered
        Cart.init();
        initSmoothScrolling();
        initCategoryNavigation();
        initActiveNavigation();
        initScrollToTop();
        initImageErrorHandling();
        initSearchFunctionality();
        initCategoryHighlight();
        initMobileMenu();
        initCartUI();
        initAddToCartButtons();
        addCategoryCounters();
        initPriceFilter();

        console.log('✅ Restaurant Menu loaded successfully!');
        console.log(`📊 Loaded ${data.categories.length} categories with ${data.categories.reduce((sum, cat) => sum + cat.dishes.length, 0)} dishes`);
    } catch (error) {
        console.error('Error initializing menu:', error);
        hideLoadingIndicator();
        showErrorMessage('Failed to load menu. Please refresh the page.');
    }
}

// =================================================================
// Shopping Cart State Management
// =================================================================
const Cart = {
    items: [],

    // Initialize cart from localStorage
    init() {
        const savedCart = localStorage.getItem('restaurantCart');
        if (savedCart) {
            this.items = JSON.parse(savedCart);
        }
        this.updateCartUI();
    },

    // Add item to cart
    addItem(id, name, price, image) {
        const existingItem = this.items.find(item => item.id === id);

        if (existingItem) {
            existingItem.quantity += 1;
        } else {
            this.items.push({
                id,
                name,
                price,
                image,
                quantity: 1
            });
        }

        this.save();
        this.updateCartUI();
        this.showNotification(`${name} added to cart!`);
    },

    // Remove item from cart
    removeItem(id) {
        this.items = this.items.filter(item => item.id !== id);
        this.save();
        this.updateCartUI();
    },

    // Update item quantity
    updateQuantity(id, quantity) {
        const item = this.items.find(item => item.id === id);
        if (item) {
            if (quantity <= 0) {
                this.removeItem(id);
            } else {
                item.quantity = quantity;
                this.save();
                this.updateCartUI();
            }
        }
    },

    // Get total items count
    getTotalItems() {
        return this.items.reduce((total, item) => total + item.quantity, 0);
    },

    // Get total price
    getTotalPrice() {
        return this.items.reduce((total, item) => total + (item.price * item.quantity), 0);
    },

    // Clear cart
    clear() {
        this.items = [];
        this.save();
        this.updateCartUI();
    },

    // Save cart to localStorage
    save() {
        localStorage.setItem('restaurantCart', JSON.stringify(this.items));
    },

    // Update cart UI
    updateCartUI() {
        const cartCount = document.querySelector('.cart-count');
        const cartItemsList = document.querySelector('.cart-items');
        const cartTotal = document.querySelector('.cart-total-price');
        const emptyCartMsg = document.querySelector('.empty-cart-message');

        // Update cart count badge
        if (cartCount) {
            const totalItems = this.getTotalItems();
            cartCount.textContent = totalItems;
            cartCount.style.display = totalItems > 0 ? 'flex' : 'none';
        }

        // Update cart items list
        if (cartItemsList) {
            if (this.items.length === 0) {
                cartItemsList.innerHTML = '';
                if (emptyCartMsg) emptyCartMsg.style.display = 'block';
            } else {
                if (emptyCartMsg) emptyCartMsg.style.display = 'none';
                cartItemsList.innerHTML = this.items.map(item => `
                    <div class="cart-item" data-id="${item.id}">
                        <img src="${item.image}" alt="${item.name}" class="cart-item-image">
                        <div class="cart-item-details">
                            <h4 class="cart-item-name">${item.name}</h4>
                            <p class="cart-item-price">₹${item.price}</p>
                        </div>
                        <div class="cart-item-controls">
                            <button class="quantity-btn minus" onclick="Cart.updateQuantity('${item.id}', ${item.quantity - 1})" aria-label="Decrease quantity">-</button>
                            <span class="quantity">${item.quantity}</span>
                            <button class="quantity-btn plus" onclick="Cart.updateQuantity('${item.id}', ${item.quantity + 1})" aria-label="Increase quantity">+</button>
                        </div>
                        <button class="remove-item" onclick="Cart.removeItem('${item.id}')" aria-label="Remove item">🗑️</button>
                    </div>
                `).join('');
            }
        }

        // Update total price
        if (cartTotal) {
            cartTotal.textContent = `₹${this.getTotalPrice()}`;
        }
    },

    // Show notification
    showNotification(message) {
        const notification = document.createElement('div');
        notification.className = 'cart-notification';
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.classList.add('show');
        }, 10);

        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 2000);
    }
};

// =================================================================
// DOM Content Loaded - Initialize when page is ready
// =================================================================
document.addEventListener('DOMContentLoaded', function() {
    // Initialize menu with data from JSON
    initializeMenu();
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

// Category counters are initialized in initializeMenu()

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

// Price filter is initialized in initializeMenu()

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
// Initialize Cart UI - Create cart sidebar
// =================================================================
function initCartUI() {
    // Create cart sidebar
    const cartSidebar = document.createElement('div');
    cartSidebar.className = 'cart-sidebar';
    cartSidebar.id = 'cartSidebar';
    cartSidebar.innerHTML = `
        <div class="cart-header">
            <h2>🛒 Your Cart</h2>
            <button class="close-cart" id="closeCart" aria-label="Close cart">✕</button>
        </div>
        <div class="empty-cart-message" style="display: none;">
            <p>🍽️ Your cart is empty</p>
            <p>Add some delicious items!</p>
        </div>
        <div class="cart-items"></div>
        <div class="cart-footer">
            <div class="cart-total">
                <span>Total:</span>
                <span class="cart-total-price">₹0</span>
            </div>
            <button class="checkout-btn" onclick="goToCheckout()">Proceed to Bill</button>
            <button class="clear-cart-btn" onclick="confirmClearCart()">Clear Cart</button>
        </div>
    `;
    document.body.appendChild(cartSidebar);

    // Create cart button in navigation
    const nav = document.querySelector('nav ul');
    if (nav) {
        const cartButton = document.createElement('li');
        cartButton.innerHTML = `
            <a href="#" class="cart-btn" id="cartBtn">
                <span class="cart-icon">🛒</span>
                <span class="cart-count" style="display: none;">0</span>
            </a>
        `;
        nav.appendChild(cartButton);
    }

    // Toggle cart sidebar
    document.getElementById('cartBtn').addEventListener('click', function(e) {
        e.preventDefault();
        cartSidebar.classList.add('open');
        document.body.style.overflow = 'hidden';
    });

    document.getElementById('closeCart').addEventListener('click', function() {
        cartSidebar.classList.remove('open');
        document.body.style.overflow = 'auto';
    });

    // Close cart when clicking outside
    cartSidebar.addEventListener('click', function(e) {
        if (e.target === cartSidebar) {
            cartSidebar.classList.remove('open');
            document.body.style.overflow = 'auto';
        }
    });
}

// =================================================================
// Initialize Add to Cart Buttons
// =================================================================
function initAddToCartButtons() {
    const dishCards = document.querySelectorAll('.dish-card');

    dishCards.forEach(card => {
        // Extract dish information
        const dishName = card.querySelector('h3').textContent;
        const priceText = card.querySelector('.price').textContent;
        const price = parseInt(priceText.replace(/[^\d]/g, ''));
        const image = card.querySelector('img').src;
        const dishId = dishName.toLowerCase().replace(/\s+/g, '-');

        // Create Add to Cart button
        const addToCartBtn = document.createElement('button');
        addToCartBtn.className = 'add-to-cart-btn';
        addToCartBtn.innerHTML = '🛒 Add to Cart';
        addToCartBtn.setAttribute('aria-label', `Add ${dishName} to cart`);

        addToCartBtn.addEventListener('click', function(e) {
            e.preventDefault();
            Cart.addItem(dishId, dishName, price, image);

            // Button animation
            this.classList.add('added');
            this.innerHTML = '✓ Added';
            setTimeout(() => {
                this.classList.remove('added');
                this.innerHTML = '🛒 Add to Cart';
            }, 1500);
        });

        // Add button to card
        const priceElement = card.querySelector('.price');
        priceElement.parentNode.insertBefore(addToCartBtn, priceElement.nextSibling);
    });
}

// =================================================================
// Checkout Function - Navigate to Bill Page
// =================================================================
function goToCheckout() {
    if (Cart.items.length === 0) {
        alert('Your cart is empty! Please add items first.');
        return;
    }
    // Save cart and redirect to bill page
    Cart.save();
    window.location.href = 'bill.html';
}

// =================================================================
// Clear Cart Confirmation
// =================================================================
function confirmClearCart() {
    if (Cart.items.length === 0) {
        return;
    }

    if (confirm('Are you sure you want to clear your cart?')) {
        Cart.clear();
        Cart.showNotification('Cart cleared!');
    }
}

// =================================================================
// Console Welcome Message
// =================================================================
console.log('%c🍽️ Bapu Ki Kutia - Digital Menu', 'color: #c41e3a; font-size: 20px; font-weight: bold;');
console.log('%cPure Vegetarian Restaurant', 'color: #f4a261; font-size: 14px;');
console.log('%cWelcome to our digital menu! Enjoy your meal! 🙏', 'color: #2c3e50; font-size: 12px;');
