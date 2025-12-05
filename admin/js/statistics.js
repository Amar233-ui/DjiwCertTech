// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

let chartInstances = {};

async function loadStatistics() {
    const period = document.getElementById('statsPeriod')?.value || 'month';
    
    // Load Chart.js if not already loaded
    if (typeof Chart === 'undefined') {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js';
        script.onload = () => {
            loadCharts(period);
        };
        document.head.appendChild(script);
    } else {
        loadCharts(period);
    }

    // Period change handler
    document.getElementById('statsPeriod')?.addEventListener('change', (e) => {
        loadCharts(e.target.value);
    });
}

async function loadCharts(period) {
    await Promise.all([
        loadSalesByZoneChart(period),
        loadDemandPeaksChart(period),
        loadTopProductsChart(period)
    ]);
}

async function loadSalesByZoneChart(period) {
    try {
        const ordersSnapshot = await window.db.collection(window.COLLECTIONS.orders).get();
        
        const zoneSales = {};
        ordersSnapshot.forEach(doc => {
            const order = doc.data();
            // Extract zone from address or use default
            const zone = extractZoneFromAddress(order.address) || 'Non spécifiée';
            zoneSales[zone] = (zoneSales[zone] || 0) + (order.totalAmount || 0);
        });

        const ctx = document.getElementById('salesByZoneChart');
        if (!ctx) return;

        if (chartInstances.salesByZone) {
            chartInstances.salesByZone.destroy();
        }

        chartInstances.salesByZone = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: Object.keys(zoneSales),
                datasets: [{
                    label: 'Ventes (FCFA)',
                    data: Object.values(zoneSales),
                    backgroundColor: '#2E7D32'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error loading sales by zone chart:', error);
    }
}

async function loadDemandPeaksChart(period) {
    try {
        const ordersSnapshot = await window.db.collection(window.COLLECTIONS.orders).get();
        
        const dailyDemand = {};
        ordersSnapshot.forEach(doc => {
            const order = doc.data();
            if (order.createdAt) {
                const date = order.createdAt.toDate().toLocaleDateString('fr-FR');
                dailyDemand[date] = (dailyDemand[date] || 0) + 1;
            }
        });

        const ctx = document.getElementById('demandPeaksChart');
        if (!ctx) return;

        if (chartInstances.demandPeaks) {
            chartInstances.demandPeaks.destroy();
        }

        const sortedDates = Object.keys(dailyDemand).sort();
        chartInstances.demandPeaks = new Chart(ctx, {
            type: 'line',
            data: {
                labels: sortedDates,
                datasets: [{
                    label: 'Nombre de commandes',
                    data: sortedDates.map(date => dailyDemand[date]),
                    borderColor: '#4CAF50',
                    backgroundColor: 'rgba(76, 175, 80, 0.1)',
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error loading demand peaks chart:', error);
    }
}

async function loadTopProductsChart(period) {
    try {
        const ordersSnapshot = await window.db.collection(window.COLLECTIONS.orders).get();
        
        const productSales = {};
        ordersSnapshot.forEach(doc => {
            const order = doc.data();
            if (order.items && Array.isArray(order.items)) {
                order.items.forEach(item => {
                    const productName = item.productName || 'Produit inconnu';
                    productSales[productName] = (productSales[productName] || 0) + (item.quantity || 0);
                });
            }
        });

        // Sort and get top 10
        const sortedProducts = Object.entries(productSales)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 10);

        const ctx = document.getElementById('topProductsChart');
        if (!ctx) return;

        if (chartInstances.topProducts) {
            chartInstances.topProducts.destroy();
        }

        chartInstances.topProducts = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: sortedProducts.map(p => p[0]),
                datasets: [{
                    data: sortedProducts.map(p => p[1]),
                    backgroundColor: [
                        '#2E7D32',
                        '#4CAF50',
                        '#81C784',
                        '#A5D6A7',
                        '#C8E6C9',
                        '#E8F5E9',
                        '#FF9800',
                        '#FFC107',
                        '#FF5722',
                        '#9C27B0'
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right'
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error loading top products chart:', error);
    }
}

function extractZoneFromAddress(address) {
    if (!address) return null;
    
    // Common zones in Senegal
    const zones = ['Dakar', 'Thiès', 'Saint-Louis', 'Kaolack', 'Ziguinchor', 'Tambacounda', 'Louga', 'Fatick', 'Kolda', 'Matam', 'Kaffrine', 'Kédougou', 'Sédhiou'];
    
    for (const zone of zones) {
        if (address.toLowerCase().includes(zone.toLowerCase())) {
            return zone;
        }
    }
    
    return null;
}

// Make function available globally
window.loadStatistics = loadStatistics;

