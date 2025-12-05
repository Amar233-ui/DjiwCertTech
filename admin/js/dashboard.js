// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

async function refreshDashboard() {
    try {
        // Load statistics
        const [usersCount, vendorsCount, ordersCount, productsCount] = await Promise.all([
            getUsersCount(),
            getVendorsCount(),
            getOrdersCount(),
            getProductsCount()
        ]);

        // Update stats
        document.getElementById('totalUsers').textContent = usersCount;
        document.getElementById('totalVendors').textContent = vendorsCount;
        document.getElementById('totalOrders').textContent = ordersCount;
        document.getElementById('totalProducts').textContent = productsCount;

        // Load recent orders
        loadRecentOrders();
        
        // Load pending vendors
        loadPendingVendors();
    } catch (error) {
        console.error('Error refreshing dashboard:', error);
    }
}

async function getUsersCount() {
    const snapshot = await window.db.collection(window.COLLECTIONS.users).get();
    return snapshot.size;
}

async function getVendorsCount() {
    const snapshot = await window.db.collection(window.COLLECTIONS.vendors).get();
    return snapshot.size;
}

async function getOrdersCount() {
    const snapshot = await window.db.collection(window.COLLECTIONS.orders).get();
    return snapshot.size;
}

async function getProductsCount() {
    const snapshot = await window.db.collection(window.COLLECTIONS.products).get();
    return snapshot.size;
}

async function loadRecentOrders() {
    try {
        const snapshot = await window.db.collection(window.COLLECTIONS.orders)
            .orderBy('createdAt', 'desc')
            .limit(5)
            .get();

        const container = document.getElementById('recentOrders');
        if (snapshot.empty) {
            container.innerHTML = '<p>Aucune commande récente</p>';
            return;
        }

        let html = '<table class="data-table"><thead><tr><th>ID</th><th>Utilisateur</th><th>Montant</th><th>Statut</th><th>Date</th></tr></thead><tbody>';
        
        snapshot.forEach(doc => {
            const order = doc.data();
            html += `
                <tr>
                    <td>${doc.id.substring(0, 8)}</td>
                    <td>${order.userId.substring(0, 8)}</td>
                    <td>${order.totalAmount?.toFixed(0) || 0} FCFA</td>
                    <td><span class="status-badge status-${order.status || 'pending'}">${getStatusText(order.status)}</span></td>
                    <td>${formatDate(order.createdAt?.toDate())}</td>
                </tr>
            `;
        });
        
        html += '</tbody></table>';
        container.innerHTML = html;
    } catch (error) {
        console.error('Error loading recent orders:', error);
    }
}

async function loadPendingVendors() {
    try {
        const snapshot = await window.db.collection(window.COLLECTIONS.vendors)
            .where('status', '==', 'pending')
            .limit(5)
            .get();

        const container = document.getElementById('pendingVendors');
        if (snapshot.empty) {
            container.innerHTML = '<p>Aucun vendeur en attente</p>';
            return;
        }

        let html = '<table class="data-table"><thead><tr><th>Nom</th><th>Email</th><th>Date</th><th>Actions</th></tr></thead><tbody>';
        
        snapshot.forEach(doc => {
            const vendor = doc.data();
            html += `
                <tr>
                    <td>${vendor.name || 'N/A'}</td>
                    <td>${vendor.email || 'N/A'}</td>
                    <td>${formatDate(vendor.createdAt?.toDate())}</td>
                    <td>
                        <button class="btn btn-success" onclick="reviewVendor('${doc.id}')">Vérifier</button>
                    </td>
                </tr>
            `;
        });
        
        html += '</tbody></table>';
        container.innerHTML = html;
    } catch (error) {
        console.error('Error loading pending vendors:', error);
    }
}

function getStatusText(status) {
    const statusMap = {
        'pending': 'En attente',
        'confirmed': 'Confirmée',
        'processing': 'En préparation',
        'shipping': 'En livraison',
        'delivered': 'Livrée',
        'cancelled': 'Annulée'
    };
    return statusMap[status] || status;
}

function formatDate(date) {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Make functions available globally
window.refreshDashboard = refreshDashboard;
window.loadRecentOrders = loadRecentOrders;
window.loadPendingVendors = loadPendingVendors;

// Make reviewVendor available globally
window.reviewVendor = (vendorId) => {
    window.location.hash = `vendors`;
    setTimeout(() => {
        if (typeof window.openVendorModal === 'function') {
            window.openVendorModal(vendorId);
        }
    }, 100);
};

