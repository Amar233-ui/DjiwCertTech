// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

async function loadLogistics() {
    try {
        // Load active orders
        const activeOrdersSnapshot = await window.db.collection(window.COLLECTIONS.orders)
            .where('status', 'in', ['confirmed', 'processing', 'shipping'])
            .orderBy('createdAt', 'desc')
            .get();

        const activeOrdersContainer = document.getElementById('activeOrders');
        
        if (activeOrdersSnapshot.empty) {
            activeOrdersContainer.innerHTML = '<p>Aucune commande en cours</p>';
        } else {
            let html = '<table class="data-table"><thead><tr><th>ID</th><th>Client</th><th>Adresse</th><th>Statut</th><th>Actions</th></tr></thead><tbody>';
            
            activeOrdersSnapshot.forEach(doc => {
                const order = doc.data();
                html += `
                    <tr>
                        <td>${doc.id.substring(0, 8)}</td>
                        <td>${order.userId?.substring(0, 8) || 'N/A'}</td>
                        <td>${order.address || 'N/A'}</td>
                        <td><span class="status-badge status-${order.status || 'pending'}">${getStatusText(order.status)}</span></td>
                        <td>
                            <button class="btn btn-primary" onclick="updateOrderStatus('${doc.id}', 'processing')">Préparer</button>
                            <button class="btn btn-success" onclick="updateOrderStatus('${doc.id}', 'shipping')">Expédier</button>
                            <button class="btn btn-success" onclick="updateOrderStatus('${doc.id}', 'delivered')">Livrer</button>
                        </td>
                    </tr>
                `;
            });
            
            html += '</tbody></table>';
            activeOrdersContainer.innerHTML = html;
        }

        // Load delivery statistics
        await loadDeliveryStats();
    } catch (error) {
        console.error('Error loading logistics:', error);
    }
}

async function loadDeliveryStats() {
    try {
        const allOrdersSnapshot = await window.db.collection(window.COLLECTIONS.orders).get();
        
        let stats = {
            total: 0,
            pending: 0,
            confirmed: 0,
            processing: 0,
            shipping: 0,
            delivered: 0,
            cancelled: 0
        };

        allOrdersSnapshot.forEach(doc => {
            const order = doc.data();
            stats.total++;
            const status = order.status || 'pending';
            if (stats[status] !== undefined) {
                stats[status]++;
            }
        });

        const container = document.getElementById('deliveryStats');
        container.innerHTML = `
            <div class="stats-list">
                <div class="stat-item">
                    <span>Total commandes:</span>
                    <strong>${stats.total}</strong>
                </div>
                <div class="stat-item">
                    <span>En attente:</span>
                    <strong>${stats.pending}</strong>
                </div>
                <div class="stat-item">
                    <span>Confirmées:</span>
                    <strong>${stats.confirmed}</strong>
                </div>
                <div class="stat-item">
                    <span>En préparation:</span>
                    <strong>${stats.processing}</strong>
                </div>
                <div class="stat-item">
                    <span>En livraison:</span>
                    <strong>${stats.shipping}</strong>
                </div>
                <div class="stat-item">
                    <span>Livrées:</span>
                    <strong>${stats.delivered}</strong>
                </div>
                <div class="stat-item">
                    <span>Annulées:</span>
                    <strong>${stats.cancelled}</strong>
                </div>
            </div>
        `;
    } catch (error) {
        console.error('Error loading delivery stats:', error);
    }
}

async function updateOrderStatus(orderId, newStatus) {
    try {
        await window.db.collection(window.COLLECTIONS.orders).doc(orderId).update({
            status: newStatus,
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        
        alert(`Statut de la commande mis à jour: ${getStatusText(newStatus)}`);
        loadLogistics();
    } catch (error) {
        console.error('Error updating order status:', error);
        alert('Erreur lors de la mise à jour');
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

// Make functions available globally
window.loadLogistics = loadLogistics;
window.updateOrderStatus = updateOrderStatus;

