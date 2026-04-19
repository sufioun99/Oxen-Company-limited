// ==========================================
// MSP Company Limited - Dynamic Website
// Enhanced Interactive Features
// ==========================================

// DOM Elements
const navToggle = document.getElementById('navToggle');
const navLinks = document.querySelector('.nav-links');
const themeToggle = document.getElementById('themeToggle');

// ==========================================
// Particle Effects for Hero Section
// ==========================================
function initParticles() {
    const hero = document.querySelector('.hero');
    if (!hero) return;

    // Create canvas for particles
    const canvas = document.createElement('canvas');
    canvas.style.cssText = 'position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none;';
    hero.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    canvas.width = hero.offsetWidth;
    canvas.height = hero.offsetHeight;

    // Particle configuration
    const particles = [];
    const particleCount = 50;
    const colors = ['#3498db', '#9b59b6', '#2ecc71', '#e74c3c', '#f39c12'];

    // Create particles
    for (let i = 0; i < particleCount; i++) {
        particles.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            size: Math.random() * 3 + 1,
            speedX: Math.random() * 0.5 - 0.25,
            speedY: Math.random() * 0.5 - 0.25,
            color: colors[Math.floor(Math.random() * colors.length)]
        });
    }

    // Animation loop
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        particles.forEach(p => {
            // Move particles
            p.x += p.speedX;
            p.y += p.speedY;

            // Bounce off walls
            if (p.x < 0 || p.x > canvas.width) p.speedX *= -1;
            if (p.y < 0 || p.y > canvas.height) p.speedY *= -1;

            // Draw particles
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            ctx.fillStyle = p.color;
            ctx.fill();
        });

        // Connect nearby particles
        connectParticles();

        requestAnimationFrame(animate);
    }

    // Connect particles with lines
    function connectParticles() {
        const maxDistance = 100;
        for (let i = 0; i < particles.length; i++) {
            for (let j = i + 1; j < particles.length; j++) {
                const dx = particles[i].x - particles[j].x;
                const dy = particles[i].y - particles[j].y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < maxDistance) {
                    ctx.beginPath();
                    ctx.strokeStyle = `rgba(52, 152, 219, ${0.2 * (1 - distance / maxDistance)})`;
                    ctx.lineWidth = 0.5;
                    ctx.moveTo(particles[i].x, particles[i].y);
                    ctx.lineTo(particles[j].x, particles[j].y);
                    ctx.stroke();
                }
            }
        }
    }

    // Handle window resize
    window.addEventListener('resize', () => {
        canvas.width = hero.offsetWidth;
        canvas.height = hero.offsetHeight;
    });

    // Start animation
    animate();
}

// ==========================================
// FAQ Accordion
// ==========================================
function initFAQ() {
    const faqItems = document.querySelectorAll('.faq-item');
    if (!faqItems.length) return;

    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        const answer = item.querySelector('.faq-answer');
        const toggle = item.querySelector('.faq-toggle');

        // Set initial state
        item.classList.remove('active');
        toggle.textContent = '+';

        question.addEventListener('click', () => {
            const isActive = item.classList.contains('active');

            // Close all other FAQ items
            faqItems.forEach(otherItem => {
                if (otherItem !== item) {
                    otherItem.classList.remove('active');
                    const otherToggle = otherItem.querySelector('.faq-toggle');
                    otherToggle.textContent = '+';
                }
            });

            // Toggle current item
            if (!isActive) {
                item.classList.add('active');
                toggle.textContent = '−';
            } else {
                item.classList.remove('active');
                toggle.textContent = '+';
            }
        });
    });

    // Add keyboard accessibility
    faqItems.forEach(item => {
        item.setAttribute('tabindex', '0');
        item.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                item.querySelector('.faq-question').click();
            }
        });
    });
}

function initParticles() {
    const canvas = document.getElementById('particleCanvas');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    // Particle configuration
    const particles = [];
    const particleCount = 50;
    const particleColors = ['#3498db', '#9b59b6', '#2ecc71', '#e74c3c', '#f39c12'];

    // Create particles
    for (let i = 0; i < particleCount; i++) {
        particles.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            size: Math.random() * 3 + 1,
            speedX: Math.random() * 0.5 - 0.25,
            speedY: Math.random() * 0.5 - 0.25,
            color: particleColors[Math.floor(Math.random() * particleColors.length)],
            opacity: Math.random() * 0.5 + 0.5
        });
    }

    // Animation loop
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        particles.forEach(particle => {
            // Update particle position
            particle.x += particle.speedX;
            particle.y += particle.speedY;

            // Bounce off walls
            if (particle.x < 0 || particle.x > canvas.width) {
                particle.speedX *= -1;
            }
            if (particle.y < 0 || particle.y > canvas.height) {
                particle.speedY *= -1;
            }

            // Draw particle
            ctx.beginPath();
            ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
            ctx.fillStyle = particle.color;
            ctx.globalAlpha = particle.opacity;
            ctx.fill();
            ctx.globalAlpha = 1;
        });

        // Connect particles with lines
        connectParticles(particles, ctx);

        // Request next animation frame
        requestAnimationFrame(animate);
    }

    // Connect particles with lines
    function connectParticles(particles, ctx) {
        const maxDistance = 100;

        for (let i = 0; i < particles.length; i++) {
            for (let j = i + 1; j < particles.length; j++) {
                const dx = particles[i].x - particles[j].x;
                const dy = particles[i].y - particles[j].y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < maxDistance) {
                    ctx.beginPath();
                    ctx.strokeStyle = `rgba(52, 152, 219, ${0.2 * (1 - distance / maxDistance)})`;
                    ctx.lineWidth = 0.5;
                    ctx.moveTo(particles[i].x, particles[i].y);
                    ctx.lineTo(particles[j].x, particles[j].y);
                    ctx.stroke();
                }
            }
        }
    }

    // Handle window resize
    window.addEventListener('resize', () => {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    });

    // Start animation
    animate();
}

function initSmoothScroll() {
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);

            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 80, // Adjust for fixed navbar
                    behavior: 'smooth'
                });
            }
        });
    });

    // Scroll animation for elements
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe elements for scroll animation
    document.querySelectorAll('.about-card, .service-card, .product-card, .innovation-card, .faq-item').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
}

// State Management
let cart = [];
let wishlist = [];
let currentSlide = 0;
let slideInterval;

// Initialize everything on DOM load
document.addEventListener('DOMContentLoaded', () => {
    initNavigation();
    initTheme();
    initCounter();
    initProductSlider();
    initTestimonials();
    initCartSystem();
    initWishlistSystem();
    initSearchFilters();
    initFormValidations();
    initScrollEffects();
    initLiveTime();
    initMouseEffects();
    initParallax();
    initModal();
    // initNewsletterPopup(); // Disabled for testing
    initChatWidget();
    initTooltips();
    initCounterAnimations();
    initProductQuickView();
    initBookingSystem();
    initParticles(); // Add particle effects
    initFAQ(); // Add FAQ accordion
    initSmoothScroll(); // Add smooth scroll animations
    console.log('🎉 All dynamic features initialized!');
});

// ==========================================
// Navigation
// ==========================================
function initNavigation() {
    if (navToggle) {
        navToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');
            navToggle.classList.toggle('active');
        });
    }

    document.querySelectorAll('.nav-links a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            if (navToggle) navToggle.classList.remove('active');
        });
    });

    // Active link on scroll
    const sections = document.querySelectorAll('section[id]');
    window.addEventListener('scroll', () => {
        const scrollY = window.pageYOffset;
        sections.forEach(section => {
            const sectionHeight = section.offsetHeight;
            const sectionTop = section.offsetTop - 100;
            const sectionId = section.getAttribute('id');
            if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
                document.querySelectorAll('.nav-links a').forEach(link => {
                    link.classList.remove('active');
                    if (link.getAttribute('href') === `#${sectionId}`) {
                        link.classList.add('active');
                    }
                });
            }
        });
    });
}

// ==========================================
// Theme Toggle with Animation
// ==========================================
function initTheme() {
    if (themeToggle) {
        // Add transition to theme toggle button
        themeToggle.style.transition = 'all 0.3s ease';
        
        themeToggle.addEventListener('click', () => {
            document.body.classList.toggle('dark-theme');
            const isDark = document.body.classList.contains('dark-theme');
            themeToggle.textContent = isDark ? '☀️ Light Mode' : '🌙 Dark Mode';
            localStorage.setItem('theme', isDark ? 'dark' : 'light');
            
            // Enhanced transition for all elements
            document.body.style.transition = 'background-color 0.5s ease, color 0.5s ease';
            document.querySelectorAll('.card, .product-card, .service-card, .about-card, .innovation-card').forEach(card => {
                card.style.transition = 'background-color 0.5s ease, border-color 0.5s ease, transform 0.3s ease';
            });
            
            // Add animation to theme toggle button
            themeToggle.style.transform = 'scale(0.95)';
            setTimeout(() => {
                themeToggle.style.transform = 'scale(1)';
            }, 100);
            
            showToast(isDark ? '🌙 Dark mode enabled' : '☀️ Light mode enabled');
        });
    }

    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
        document.body.classList.add('dark-theme');
        if (themeToggle) themeToggle.textContent = '☀️ Light Mode';
    }
}

// ==========================================
// Interactive Counter
// ==========================================
let currentCount = 0;
const history = [];

function initCounter() {
    const counterValue = document.getElementById('counterValue');
    const incrementBtn = document.getElementById('incrementBtn');
    const decrementBtn = document.getElementById('decrementBtn');
    const counterHistory = document.getElementById('counterHistory');

    function updateCounter(value) {
        currentCount = value;
        if (counterValue) {
            counterValue.textContent = value;
            counterValue.style.transform = 'scale(1.2)';
            setTimeout(() => counterValue.style.transform = 'scale(1)', 200);
        }
        
        history.push(value);
        if (history.length > 5) history.shift();
        if (counterHistory) counterHistory.textContent = JSON.stringify(history);
    }

    if (incrementBtn) incrementBtn.addEventListener('click', () => updateCounter(currentCount + 1));
    if (decrementBtn) decrementBtn.addEventListener('click', () => updateCounter(currentCount - 1));

    document.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowUp') updateCounter(currentCount + 1);
        if (e.key === 'ArrowDown') updateCounter(currentCount - 1);
    });
}

// ==========================================
// Product Slider/Carousel
// ==========================================
function initProductSlider() {
    const slider = document.querySelector('.products-carousel');
    if (!slider) return;

    const products = slider.querySelectorAll('.product-card');
    if (products.length === 0) return;

    // Create navigation buttons
    const prevBtn = document.createElement('button');
    prevBtn.className = 'slider-btn prev';
    prevBtn.innerHTML = '◀';
    prevBtn.style.cssText = 'position: absolute; left: -40px; top: 50%; transform: translateY(-50%); width: 40px; height: 40px; border-radius: 50%; background: var(--secondary-color); color: white; border: none; cursor: pointer; font-size: 1.2rem; z-index: 10; transition: all 0.3s ease;';

    const nextBtn = document.createElement('button');
    nextBtn.className = 'slider-btn next';
    nextBtn.innerHTML = '▶';
    nextBtn.style.cssText = 'position: absolute; right: -40px; top: 50%; transform: translateY(-50%); width: 40px; height: 40px; border-radius: 50%; background: var(--secondary-color); color: white; border: none; cursor: pointer; font-size: 1.2rem; z-index: 10; transition: all 0.3s ease;';

    slider.style.position = 'relative';
    slider.appendChild(prevBtn);
    slider.appendChild(nextBtn);

    let currentIndex = 0;
    const visibleProducts = window.innerWidth < 768 ? 1 : window.innerWidth < 1024 ? 2 : 4;
    const totalProducts = products.length;

    function showSlide(index) {
        products.forEach((product, i) => {
            product.style.display = i >= index && i < index + visibleProducts ? 'block' : 'none';
            product.style.animation = 'fadeInUp 0.5s ease';
        });
    }

    prevBtn.addEventListener('click', () => {
        currentIndex = Math.max(0, currentIndex - 1);
        showSlide(currentIndex);
    });

    nextBtn.addEventListener('click', () => {
        currentIndex = Math.min(totalProducts - visibleProducts, currentIndex + 1);
        showSlide(currentIndex);
    });

    // Auto-play
    slideInterval = setInterval(() => {
        currentIndex = currentIndex >= totalProducts - visibleProducts ? 0 : currentIndex + 1;
        showSlide(currentIndex);
    }, 4000);

    // Pause on hover
    slider.addEventListener('mouseenter', () => clearInterval(slideInterval));
    slider.addEventListener('mouseleave', () => {
        slideInterval = setInterval(() => {
            currentIndex = currentIndex >= totalProducts - visibleProducts ? 0 : currentIndex + 1;
            showSlide(currentIndex);
        }, 4000);
    });

    showSlide(0);
}

// ==========================================
// Testimonials Slider
// ==========================================
function initTestimonials() {
    const container = document.querySelector('.testimonials-container');
    if (!container) return;

    const cards = container.querySelectorAll('.testimonial-card');
    if (cards.length === 0) return;

    let currentTestimonial = 0;

    // Create indicators
    const indicators = document.createElement('div');
    indicators.className = 'testimonial-indicators';
    indicators.style.cssText = 'display: flex; justify-content: center; gap: 10px; margin-top: 20px;';
    
    cards.forEach((_, index) => {
        const dot = document.createElement('button');
        dot.className = 'testimonial-dot';
        dot.style.cssText = 'width: 12px; height: 12px; border-radius: 50%; border: 2px solid var(--secondary-color); background: transparent; cursor: pointer; transition: all 0.3s ease;';
        if (index === 0) dot.style.background = 'var(--secondary-color)';
        dot.addEventListener('click', () => showTestimonial(index));
        indicators.appendChild(dot);
    });

    container.appendChild(indicators);

    function showTestimonial(index) {
        cards.forEach((card, i) => {
            card.style.display = i === index ? 'block' : 'none';
            card.style.animation = 'fadeInUp 0.5s ease';
        });
        indicators.querySelectorAll('.testimonial-dot').forEach((dot, i) => {
            dot.style.background = i === index ? 'var(--secondary-color)' : 'transparent';
        });
        currentTestimonial = index;
    }

    // Auto-play
    setInterval(() => {
        currentTestimonial = (currentTestimonial + 1) % cards.length;
        showTestimonial(currentTestimonial);
    }, 5000);

    showTestimonial(0);
}

// ==========================================
// Shopping Cart System
// ==========================================
function initCartSystem() {
    const cartBtn = document.querySelector('.cart-btn');
    
    // Load cart from localStorage
    const savedCart = localStorage.getItem('mspCart');
    if (savedCart) {
        cart = JSON.parse(savedCart);
        updateCartCount();
    }

    document.querySelectorAll('.add-cart-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const card = btn.closest('.product-item, .product-card');
            const product = {
                id: Date.now(),
                name: card.querySelector('h3').textContent,
                price: card.querySelector('.current-price')?.textContent || 'Contact for price',
                image: card.querySelector('.product-image')?.textContent || '📦'
            };
            
            cart.push(product);
            localStorage.setItem('mspCart', JSON.stringify(cart));
            updateCartCount();
            
            btn.textContent = '✓ Added!';
            btn.style.backgroundColor = '#27ae60';
            showToast(`${product.name} added to cart! 🛒`);
            
            setTimeout(() => {
                btn.textContent = '🛒 Add to Cart';
                btn.style.backgroundColor = '';
            }, 2000);
        });
    });
}

function updateCartCount() {
    const cartCount = document.querySelector('.cart-count');
    if (cartCount) {
        cartCount.textContent = cart.length;
        cartCount.style.animation = 'pulse 0.3s ease';
    }
}

// ==========================================
// Wishlist System
// ==========================================
function initWishlistSystem() {
    const savedWishlist = localStorage.getItem('mspWishlist');
    if (savedWishlist) {
        wishlist = JSON.parse(savedWishlist);
    }

    document.querySelectorAll('.wishlist-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            const card = btn.closest('.product-item');
            const productName = card.querySelector('h3').textContent;
            
            if (wishlist.includes(productName)) {
                wishlist = wishlist.filter(p => p !== productName);
                btn.textContent = '🤍';
                showToast(`${productName} removed from wishlist`);
            } else {
                wishlist.push(productName);
                btn.textContent = '❤️';
                btn.style.transform = 'scale(1.3)';
                showToast(`${productName} added to wishlist!`);
            }
            
            localStorage.setItem('mspWishlist', JSON.stringify(wishlist));
            setTimeout(() => btn.style.transform = 'scale(1)', 300);
        });
    });
}

// ==========================================
// Search & Filters
// ==========================================
function initSearchFilters() {
    const searchInput = document.getElementById('productSearch');
    const filterBtns = document.querySelectorAll('.filter-btn');
    const products = document.querySelectorAll('.product-item');

    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            const searchTerm = e.target.value.toLowerCase();
            products.forEach(product => {
                const name = product.querySelector('h3').textContent.toLowerCase();
                const desc = product.querySelector('p')?.textContent.toLowerCase() || '';
                product.style.display = name.includes(searchTerm) || desc.includes(searchTerm) ? 'block' : 'none';
            });
        });
    }

    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            const filter = btn.dataset.filter;
            products.forEach(product => {
                if (filter === 'all' || product.dataset.category === filter) {
                    product.style.display = 'block';
                    product.style.animation = 'fadeInUp 0.5s ease';
                } else {
                    product.style.display = 'none';
                }
            });
        });
    });
}

// ==========================================
// Form Validation with Real-time Feedback
// ==========================================
function initFormValidations() {
    document.querySelectorAll('form').forEach(form => {
        const inputs = form.querySelectorAll('input, textarea, select');
        
        inputs.forEach(input => {
            // Real-time validation
            input.addEventListener('input', () => validateField(input));
            input.addEventListener('blur', () => validateField(input));
        });

        form.addEventListener('submit', (e) => {
            e.preventDefault();
            let isValid = true;
            
            inputs.forEach(input => {
                if (!validateField(input)) isValid = false;
            });

            if (isValid) {
                showToast('Form submitted successfully! ✅');
                form.reset();
                form.querySelectorAll('.form-group').forEach(g => g.classList.remove('success', 'error'));
            } else {
                showToast('Please fix the errors above ❌', 'error');
            }
        });
    });
}

function validateField(input) {
    const formGroup = input.closest('.form-group') || input.parentElement;
    if (!formGroup) return true;
    
    formGroup.classList.remove('error', 'success');
    
    const value = input.value.trim();
    let errorMessage = '';

    if (input.required && !value) {
        errorMessage = 'This field is required';
    } else if (input.type === 'email' && !isValidEmail(value)) {
        errorMessage = 'Please enter a valid email';
    } else if (input.type === 'tel' && value.length < 10) {
        errorMessage = 'Please enter a valid phone number';
    } else if (input.type === 'text' && input.minLength && value.length < input.minLength) {
        errorMessage = `Minimum ${input.minLength} characters required`;
    }

    if (errorMessage) {
        formGroup.classList.add('error');
        formGroup.classList.remove('success');
        updateErrorMessage(formGroup, errorMessage);
        return false;
    } else if (value) {
        formGroup.classList.add('success');
        formGroup.classList.remove('error');
        clearErrorMessage(formGroup);
        return true;
    }
    
    return true;
}

function updateErrorMessage(formGroup, message) {
    let errorEl = formGroup.querySelector('.error-message');
    if (!errorEl) {
        errorEl = document.createElement('span');
        errorEl.className = 'error-message';
        errorEl.style.cssText = 'color: var(--danger-color); font-size: 0.8rem; margin-top: 0.3rem; display: block;';
        formGroup.appendChild(errorEl);
    }
    errorEl.textContent = message;
}

function clearErrorMessage(formGroup) {
    const errorEl = formGroup.querySelector('.error-message');
    if (errorEl) errorEl.remove();
}

function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// ==========================================
// Scroll Effects & Animations
// ==========================================
function initScrollEffects() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    document.querySelectorAll('.about-card, .service-card, .product-card, .innovation-card, .pricing-card').forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';
        card.style.transition = 'all 0.6s ease';
        observer.observe(card);
    });

    // Progress bar animation
    const progressObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const progress = entry.target.querySelector('.progress');
                if (progress) {
                    const width = progress.style.width;
                    progress.style.width = '0%';
                    setTimeout(() => progress.style.width = width, 100);
                }
                progressObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    document.querySelectorAll('.service-card, .progress-bar').forEach(card => {
        progressObserver.observe(card);
    });
}

// ==========================================
// Live Date/Time Display
// ==========================================
function initLiveTime() {
    const timeDisplay = document.createElement('div');
    timeDisplay.className = 'live-time';
    timeDisplay.style.cssText = 'position: fixed; top: 80px; right: 20px; background: var(--card-bg); padding: 10px 15px; border-radius: 10px; box-shadow: var(--shadow); font-size: 0.9rem; z-index: 999;';
    document.body.appendChild(timeDisplay);

    function updateTime() {
        const now = new Date();
        const options = { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' };
        timeDisplay.textContent = now.toLocaleDateString('en-US', options);
    }

    updateTime();
    setInterval(updateTime, 60000);
}

// ==========================================
// Interactive Mouse Effects
// ==========================================
function initMouseEffects() {
    const cursor = document.createElement('div');
    cursor.className = 'custom-cursor';
    cursor.style.cssText = 'position: fixed; width: 20px; height: 20px; border: 2px solid var(--secondary-color); border-radius: 50%; pointer-events: none; z-index: 9999; transform: translate(-50%, -50%); transition: transform 0.1s ease, width 0.2s ease, height 0.2s ease;';
    document.body.appendChild(cursor);

    document.addEventListener('mousemove', (e) => {
        cursor.style.left = e.clientX + 'px';
        cursor.style.top = e.clientY + 'px';
    });

    document.querySelectorAll('a, button, .product-card, .service-card').forEach(el => {
        el.addEventListener('mouseenter', () => {
            cursor.style.width = '40px';
            cursor.style.height = '40px';
            cursor.style.backgroundColor = 'rgba(52, 152, 219, 0.2)';
        });
        el.addEventListener('mouseleave', () => {
            cursor.style.width = '20px';
            cursor.style.height = '20px';
            cursor.style.backgroundColor = 'transparent';
        });
    });
}

// ==========================================
// Parallax Scrolling Effect
// ==========================================
function initParallax() {
    const hero = document.querySelector('.hero');
    const pageHero = document.querySelector('.page-hero');
    
    if (!hero && !pageHero) return;

    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        const target = hero || pageHero;
        
        if (target && scrolled < target.offsetHeight) {
            target.style.backgroundPositionY = scrolled * 0.5 + 'px';
        }
    });
}

// ==========================================
// Modal System
// ==========================================
function initModal() {
    // Create modal element
    const modal = document.createElement('div');
    modal.className = 'dynamic-modal';
    modal.innerHTML = `
        <div class="modal-content">
            <span class="modal-close">&times;</span>
            <div class="modal-body"></div>
        </div>
    `;
    modal.style.cssText = 'display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.7); z-index: 2000; align-items: center; justify-content: center;';
    modal.querySelector('.modal-content').style.cssText = 'background: var(--card-bg); padding: 2rem; border-radius: 15px; max-width: 500px; width: 90%; position: relative; animation: fadeInUp 0.3s ease;';
    modal.querySelector('.modal-close').style.cssText = 'position: absolute; top: 10px; right: 15px; font-size: 1.5rem; cursor: pointer; color: var(--text-light);';
    document.body.appendChild(modal);

    // Close modal
    modal.querySelector('.modal-close').addEventListener('click', () => {
        modal.style.display = 'none';
    });

    modal.addEventListener('click', (e) => {
        if (e.target === modal) modal.style.display = 'none';
    });

    // Open modal on certain elements
    document.querySelectorAll('[data-modal]').forEach(el => {
        el.addEventListener('click', () => {
            const modalType = el.dataset.modal;
            showModal(modal, modalType);
        });
    });
}

function showModal(modal, type) {
    const body = modal.querySelector('.modal-body');
    
    const modals = {
        'quick-view': `
            <h2 style="margin-bottom: 1rem;">Quick View</h2>
            <p>Product details would appear here with image, description, and add to cart button.</p>
            <button class="cta-button" style="margin-top: 1rem;">Add to Cart</button>
        `,
        'newsletter': `
            <h2 style="margin-bottom: 1rem;">📬 Subscribe to Newsletter</h2>
            <p>Get the latest deals and updates delivered to your inbox!</p>
            <input type="email" placeholder="Enter your email" style="width: 100%; padding: 10px; margin: 1rem 0; border: 2px solid var(--border-color); border-radius: 8px;">
            <button class="cta-button" style="width: 100%;">Subscribe</button>
        `,
        'success': `
            <div style="text-align: center;">
                <div style="font-size: 4rem; margin-bottom: 1rem;">✅</div>
                <h2 style="margin-bottom: 1rem;">Success!</h2>
                <p>Your action was completed successfully.</p>
            </div>
        `
    };

    body.innerHTML = modals[type] || '<p>Modal content</p>';
    modal.style.display = 'flex';
}

// ==========================================
// Newsletter Popup
// ==========================================
function initNewsletterPopup() {
    const popup = document.createElement('div');
    popup.className = 'newsletter-popup';
    popup.innerHTML = `
        <span class="popup-close">&times;</span>
        <div class="popup-content">
            <h2>🎉 Special Offer!</h2>
            <p>Subscribe to our newsletter and get 10% off your first purchase!</p>
            <input type="email" placeholder="Enter your email" id="popupEmail">
            <button class="cta-button" id="popupSubscribe">Subscribe</button>
        </div>
    `;
    
    popup.style.cssText = 'display: none; position: fixed; bottom: 20px; right: 20px; background: var(--card-bg); padding: 2rem; border-radius: 15px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); z-index: 1500; max-width: 400px; animation: fadeInUp 0.5s ease;';
    popup.querySelector('.popup-close').style.cssText = 'position: absolute; top: 10px; right: 15px; font-size: 1.5rem; cursor: pointer;';
    popup.querySelector('.popup-content').style.cssText = 'text-align: center;';
    popup.querySelector('input').style.cssText = 'width: 100%; padding: 10px; margin: 1rem 0; border: 2px solid var(--border-color); border-radius: 8px;';
    
    document.body.appendChild(popup);

    // Show popup after 5 seconds
    setTimeout(() => {
        if (!localStorage.getItem('newsletterSubscribed')) {
            popup.style.display = 'block';
        }
    }, 5000);

    popup.querySelector('.popup-close').addEventListener('click', () => {
        popup.style.display = 'none';
    });

    popup.querySelector('#popupSubscribe').addEventListener('click', () => {
        const email = popup.querySelector('#popupEmail').value;
        if (email && isValidEmail(email)) {
            localStorage.setItem('newsletterSubscribed', 'true');
            showToast('Subscribed successfully! 🎉');
            popup.style.display = 'none';
        } else {
            showToast('Please enter a valid email', 'error');
        }
    });
}

// ==========================================
// Live Chat Widget
// ==========================================
function initChatWidget() {
    const chatWidget = document.createElement('div');
    chatWidget.className = 'chat-widget';
    chatWidget.innerHTML = `
        <div class="chat-button">💬</div>
        <div class="chat-window">
            <div class="chat-header">
                <span>MSP Support</span>
                <span class="chat-close">&times;</span>
            </div>
            <div class="chat-messages">
                <div class="chat-message bot">Hello! 👋 How can I help you today?</div>
            </div>
            <div class="chat-input">
                <input type="text" placeholder="Type a message..." id="chatInput">
                <button id="chatSend">Send</button>
            </div>
        </div>
    `;
    
    chatWidget.style.cssText = 'position: fixed; bottom: 20px; left: 20px; z-index: 1000;';
    chatWidget.querySelector('.chat-button').style.cssText = 'width: 60px; height: 60px; border-radius: 50%; background: var(--secondary-color); color: white; font-size: 1.5rem; display: flex; align-items: center; justify-content: center; cursor: pointer; box-shadow: var(--shadow); transition: transform 0.3s ease;';
    chatWidget.querySelector('.chat-window').style.cssText = 'display: none; position: absolute; bottom: 70px; left: 0; width: 300px; background: var(--card-bg); border-radius: 15px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); overflow: hidden;';
    chatWidget.querySelector('.chat-header').style.cssText = 'background: var(--secondary-color); color: white; padding: 15px; display: flex; justify-content: space-between;';
    chatWidget.querySelector('.chat-messages').style.cssText = 'height: 250px; overflow-y: auto; padding: 15px;';
    chatWidget.querySelector('.chat-input').style.cssText = 'display: flex; padding: 10px; border-top: 1px solid var(--border-color);';
    chatWidget.querySelector('input').style.cssText = 'flex: 1; padding: 8px; border: 1px solid var(--border-color); border-radius: 5px; margin-right: 5px;';
    chatWidget.querySelector('button').style.cssText = 'padding: 8px 15px; background: var(--secondary-color); color: white; border: none; border-radius: 5px; cursor: pointer;';
    
    document.body.appendChild(chatWidget);

    const chatButton = chatWidget.querySelector('.chat-button');
    const chatWindow = chatWidget.querySelector('.chat-window');
    const chatClose = chatWidget.querySelector('.chat-close');
    const chatInput = document.getElementById('chatInput');
    const chatSend = document.getElementById('chatSend');
    const chatMessages = chatWidget.querySelector('.chat-messages');

    chatButton.addEventListener('click', () => {
        chatWindow.style.display = 'block';
        chatButton.style.transform = 'scale(0.9)';
        setTimeout(() => chatButton.style.transform = 'scale(1)', 200);
    });

    chatClose.addEventListener('click', () => {
        chatWindow.style.display = 'none';
    });

    function sendMessage() {
        const message = chatInput.value.trim();
        if (!message) return;

        // Add user message
        const userMsg = document.createElement('div');
        userMsg.className = 'chat-message user';
        userMsg.style.cssText = 'text-align: right; margin: 10px 0; padding: 8px 12px; background: var(--secondary-color); color: white; border-radius: 15px 15px 0 15px; display: inline-block; max-width: 80%; float: right; clear: both;';
        userMsg.textContent = message;
        chatMessages.appendChild(userMsg);
        chatInput.value = '';

        // Simulate bot response
        setTimeout(() => {
            const botMsg = document.createElement('div');
            botMsg.className = 'chat-message bot';
            botMsg.style.cssText = 'text-align: left; margin: 10px 0; padding: 8px 12px; background: var(--bg-color); border-radius: 15px 15px 15px 0; display: inline-block; max-width: 80%; clear: both;';
            botMsg.textContent = getBotResponse(message);
            chatMessages.appendChild(botMsg);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }, 1000);

        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    chatSend.addEventListener('click', sendMessage);
    chatInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendMessage();
    });
}

function getBotResponse(message) {
    const responses = [
        'Thank you for your message! Our team will get back to you shortly.',
        'I understand. Let me connect you with a specialist.',
        'Great question! You can reach us at +880 1234 567890.',
        'We offer a wide range of electronics. What are you looking for?',
        'Our store is open Saturday-Thursday, 9AM-8PM.',
        'Yes, we provide home service within Dhaka!',
        'All products come with manufacturer warranty.',
        'Feel free to visit our head office at 924/1, PR Tower, Shwerapara, Mirpur, Dhaka.'
    ];
    return responses[Math.floor(Math.random() * responses.length)];
}

// ==========================================
// Custom Tooltips
// ==========================================
function initTooltips() {
    document.querySelectorAll('[data-tooltip]').forEach(el => {
        const tooltip = document.createElement('div');
        tooltip.className = 'custom-tooltip';
        tooltip.textContent = el.dataset.tooltip;
        tooltip.style.cssText = 'position: absolute; background: #333; color: white; padding: 5px 10px; border-radius: 5px; font-size: 0.8rem; z-index: 1000; pointer-events: none; opacity: 0; transition: opacity 0.3s ease; white-space: nowrap;';
        el.style.position = 'relative';
        el.appendChild(tooltip);

        el.addEventListener('mouseenter', () => {
            tooltip.style.opacity = '1';
        });
        el.addEventListener('mouseleave', () => {
            tooltip.style.opacity = '0';
        });
    });
}

// ==========================================
// Animated Number Counters
// ==========================================
function initCounterAnimations() {
    const counters = document.querySelectorAll('[data-count]');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const counter = entry.target;
                const target = parseInt(counter.dataset.count);
                animateValue(counter, 0, target, 2000);
                observer.unobserve(counter);
            }
        });
    }, { threshold: 0.5 });

    counters.forEach(counter => observer.observe(counter));
}

function animateValue(element, start, end, duration) {
    const range = end - start;
    const startTime = performance.now();

    function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const easeOut = 1 - Math.pow(1 - progress, 3);
        const current = Math.floor(start + range * easeOut);
        
        element.textContent = current.toLocaleString() + (element.dataset.suffix || '+');
        
        if (progress < 1) {
            requestAnimationFrame(update);
        }
    }

    requestAnimationFrame(update);
}

// ==========================================
// Product Quick View
// ==========================================
function initProductQuickView() {
    document.querySelectorAll('.product-item').forEach(item => {
        item.addEventListener('dblclick', () => {
            const name = item.querySelector('h3').textContent;
            const price = item.querySelector('.current-price')?.textContent || 'Contact for price';
            const desc = item.querySelector('p')?.textContent || 'High quality product from MSP Company Limited';
            
            showQuickView(name, price, desc);
        });
    });
}

function showQuickView(name, price, desc) {
    const modal = document.querySelector('.dynamic-modal');
    if (!modal) return;
    
    const body = modal.querySelector('.modal-body');
    body.innerHTML = `
        <div style="text-align: center;">
            <div style="font-size: 5rem; margin-bottom: 1rem;">📦</div>
            <h2 style="margin-bottom: 0.5rem;">${name}</h2>
            <p style="color: var(--secondary-color); font-size: 1.5rem; font-weight: bold; margin-bottom: 1rem;">${price}</p>
            <p style="color: var(--text-light); margin-bottom: 1.5rem;">${desc}</p>
            <div style="display: flex; gap: 10px; justify-content: center;">
                <button class="cta-button" onclick="addToCartFromQuickView('${name}')">Add to Cart</button>
                <button class="cta-button" style="background: transparent; border: 2px solid var(--secondary-color); color: var(--secondary-color);">Wishlist</button>
            </div>
        </div>
    `;
    modal.style.display = 'flex';
}

// ==========================================
// Service Booking System
// ==========================================
function initBookingSystem() {
    document.querySelectorAll('.service-btn, .book-btn, [data-book]').forEach(btn => {
        btn.addEventListener('click', () => {
            const serviceName = btn.dataset.service || 'General Inquiry';
            showBookingModal(serviceName);
        });
    });
}

function showBookingModal(service) {
    const modal = document.querySelector('.dynamic-modal');
    if (!modal) return;
    
    const body = modal.querySelector('.modal-body');
    body.innerHTML = `
        <h2 style="margin-bottom: 1rem;">Book ${service}</h2>
        <form id="bookingForm">
            <div class="form-group">
                <label>Your Name</label>
                <input type="text" required style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; margin-bottom: 10px;">
            </div>
            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" required style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; margin-bottom: 10px;">
            </div>
            <div class="form-group">
                <label>Preferred Date</label>
                <input type="date" required style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; margin-bottom: 10px;">
            </div>
            <div class="form-group">
                <label>Address</label>
                <textarea style="width: 100%; padding: 10px; border: 2px solid var(--border-color); border-radius: 8px; margin-bottom: 10px;" rows="3"></textarea>
            </div>
            <button type="submit" class="cta-button" style="width: 100%;">Confirm Booking</button>
        </form>
    `;
    modal.style.display = 'flex';
    
    body.querySelector('#bookingForm').addEventListener('submit', (e) => {
        e.preventDefault();
        showToast('Booking confirmed! We will contact you soon. ✅');
        modal.style.display = 'none';
    });
}

// ==========================================
// Toast Notification System
// ==========================================
function showToast(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    toast.style.cssText = `position: fixed; bottom: 30px; right: 30px; padding: 1rem 2rem; background: ${type === 'error' ? 'var(--danger-color)' : 'var(--secondary-color)'}; color: white; border-radius: 8px; box-shadow: var(--shadow); transform: translateX(150%); transition: transform 0.3s ease; z-index: 2000; max-width: 350px;`;
    document.body.appendChild(toast);

    requestAnimationFrame(() => {
        toast.style.transform = 'translateX(0)';
    });

    setTimeout(() => {
        toast.style.transform = 'translateX(150%)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// ==========================================
// CTA Buttons
// ==========================================
document.querySelectorAll('.cta-button').forEach(btn => {
    btn.addEventListener('click', function(e) {
        if (this.href && !this.onclick) return;
        
        e.preventDefault();
        const text = this.textContent.toLowerCase();
        
        if (text.includes('explore') || text.includes('view')) {
            window.location.href = 'products.html';
        } else if (text.includes('service')) {
            window.location.href = 'services.html';
        } else if (text.includes('contact')) {
            window.location.href = 'contact.html';
        } else if (text.includes('innovation')) {
            window.location.href = 'innovation.html';
        } else if (text.includes('start')) {
            showToast('Welcome aboard! 🎉');
        }
    });
});

// ==========================================
// Print Button
// ==========================================
const printBtn = document.createElement('button');
printBtn.innerHTML = '🖨️';
printBtn.style.cssText = 'position: fixed; bottom: 90px; right: 20px; width: 50px; height: 50px; border-radius: 50%; background: var(--accent-color); color: white; border: none; cursor: pointer; font-size: 1.3rem; box-shadow: var(--shadow); transition: all 0.3s ease; z-index: 1000;';
printBtn.title = 'Print Page';
printBtn.addEventListener('click', () => window.print());
document.body.appendChild(printBtn);

// ==========================================
// Back to Top Button
// ==========================================
const backToTopBtn = document.createElement('button');
backToTopBtn.innerHTML = '⬆️';
backToTopBtn.style.cssText = 'position: fixed; bottom: 150px; right: 20px; width: 50px; height: 50px; border-radius: 50%; background: var(--primary-color); color: white; border: none; cursor: pointer; font-size: 1.3rem; box-shadow: var(--shadow); transition: all 0.3s ease; z-index: 1000; display: none;';
backToTopBtn.title = 'Back to Top';
backToTopBtn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
});
document.body.appendChild(backToTopBtn);

window.addEventListener('scroll', () => {
    backToTopBtn.style.display = window.pageYOffset > 300 ? 'block' : 'none';
});

// ==========================================
// Page Load Animation
// ==========================================
document.body.style.opacity = '0';
window.addEventListener('load', () => {
    document.body.style.transition = 'opacity 0.5s ease';
    requestAnimationFrame(() => {
        document.body.style.opacity = '1';
    });
});

// ==========================================
// Console Welcome
// ==========================================
console.log('%c🏢 MSP Company Limited', 'background: linear-gradient(135deg, #667eea, #764ba2); color: white; font-size: 24px; padding: 15px; font-weight: bold;');
console.log('%c📱 Electronics Sales & Services | 💡 Innovative Solutions', 'background: #2c3e50; color: white; font-size: 14px; padding: 8px;');
console.log('%c✨ Interactive features loaded successfully!', 'background: #27ae60; color: white; font-size: 12px; padding: 5px;');

// Make functions globally available
window.addToCartFromQuickView = function(productName) {
    showToast(`${productName} added to cart! 🛒`);
    const modal = document.querySelector('.dynamic-modal');
    if (modal) modal.style.display = 'none';
};
