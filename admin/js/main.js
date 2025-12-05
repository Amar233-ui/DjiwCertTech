// refreshDashboard sera disponible globalement depuis dashboard.js

console.log('🚀 Initialisation de la navigation...');

// Attendre que le DOM soit chargé
document.addEventListener('DOMContentLoaded', () => {
    console.log('✅ DOM chargé');
    initNavigation();
});

function initNavigation() {
    // Navigation
    const navItems = document.querySelectorAll('.nav-item');
    const pages = document.querySelectorAll('.page');
    
    console.log(`📋 ${navItems.length} éléments de navigation trouvés`);
    console.log(`📄 ${pages.length} pages trouvées`);

navItems.forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        const targetPage = item.getAttribute('data-page');
        
        // Update active nav item
        navItems.forEach(nav => nav.classList.remove('active'));
        item.classList.add('active');
        
        // Show target page
        pages.forEach(page => page.classList.remove('active'));
        const targetPageElement = document.getElementById(`${targetPage}Page`);
        if (targetPageElement) {
            targetPageElement.classList.add('active');
            
            // Load page data
            loadPageData(targetPage);
        }
    });
});

// Sidebar toggle
document.getElementById('sidebarToggle')?.addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('collapsed');
});

// Load page data
function loadPageData(page) {
    switch(page) {
        case 'dashboard':
            if (typeof window.refreshDashboard === 'function') window.refreshDashboard();
            break;
        case 'vendors':
            if (window.loadVendors) window.loadVendors();
            break;
        case 'stock':
            if (window.loadStock) window.loadStock();
            break;
        case 'subsidies':
            if (window.loadSubsidies) window.loadSubsidies();
            break;
        case 'weather':
            if (window.loadWeatherAlerts) window.loadWeatherAlerts();
            break;
        case 'logistics':
            if (window.loadLogistics) window.loadLogistics();
            break;
        case 'training':
            if (window.loadTraining) window.loadTraining();
            break;
        case 'statistics':
            if (window.loadStatistics) window.loadStatistics();
            break;
    }
}

    // Initialize - Show dashboard by default if logged in
    const dashboardPage = document.getElementById('dashboardPage');
    if (dashboardPage && !dashboardPage.classList.contains('active')) {
        const firstNavItem = document.querySelector('.nav-item[data-page="dashboard"]');
        if (firstNavItem) {
            console.log('📊 Affichage du tableau de bord par défaut');
            firstNavItem.click();
        }
    }
}

