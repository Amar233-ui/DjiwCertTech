// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

let currentFilter = 'all';

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    // Filter tabs
    document.querySelectorAll('.filter-tab').forEach(tab => {
        tab.addEventListener('click', () => {
            document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            currentFilter = tab.getAttribute('data-filter');
            loadVendors();
        });
    });

    // Search
    document.getElementById('vendorSearch')?.addEventListener('input', (e) => {
        loadVendors(e.target.value);
    });
});

async function loadVendors(searchQuery = '') {
    try {
        let query = window.db.collection(window.COLLECTIONS.vendors);

        // Apply filter
        if (currentFilter !== 'all') {
            query = query.where('status', '==', currentFilter);
        }

        const snapshot = await query.orderBy('createdAt', 'desc').get();
        const tbody = document.getElementById('vendorsTableBody');
        
        if (snapshot.empty) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">Aucun vendeur trouvé</td></tr>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const vendor = doc.data();
            
            // Filter by search query
            if (searchQuery && !matchesSearch(vendor, searchQuery)) {
                return;
            }

            html += `
                <tr>
                    <td>${vendor.name || 'N/A'}</td>
                    <td>${vendor.email || 'N/A'}</td>
                    <td>${vendor.phoneNumber || 'N/A'}</td>
                    <td><span class="status-badge status-${vendor.status || 'pending'}">${getStatusText(vendor.status)}</span></td>
                    <td>${formatDate(vendor.createdAt?.toDate())}</td>
                    <td>
                        <button class="btn btn-primary" onclick="openVendorModal('${doc.id}')">
                            <i class="fas fa-eye"></i> Voir
                        </button>
                    </td>
                </tr>
            `;
        });

        tbody.innerHTML = html || '<tr><td colspan="6" style="text-align: center;">Aucun vendeur trouvé</td></tr>';
    } catch (error) {
        console.error('Error loading vendors:', error);
    }
}

function matchesSearch(vendor, query) {
    const searchLower = query.toLowerCase();
    return (
        (vendor.name && vendor.name.toLowerCase().includes(searchLower)) ||
        (vendor.email && vendor.email.toLowerCase().includes(searchLower)) ||
        (vendor.phoneNumber && vendor.phoneNumber.includes(searchLower))
    );
}

async function openVendorModal(vendorId) {
    try {
        const doc = await window.db.collection(window.COLLECTIONS.vendors).doc(vendorId).get();
        if (!doc.exists) {
            alert('Vendeur non trouvé');
            return;
        }

        const vendor = doc.data();
        const modalBody = document.getElementById('vendorModalBody');
        
        modalBody.innerHTML = `
            <div class="vendor-details">
                <div class="detail-group">
                    <label>Nom:</label>
                    <p>${vendor.name || 'N/A'}</p>
                </div>
                <div class="detail-group">
                    <label>Email:</label>
                    <p>${vendor.email || 'N/A'}</p>
                </div>
                <div class="detail-group">
                    <label>Téléphone:</label>
                    <p>${vendor.phoneNumber || 'N/A'}</p>
                </div>
                <div class="detail-group">
                    <label>Adresse:</label>
                    <p>${vendor.address || 'N/A'}</p>
                </div>
                <div class="detail-group">
                    <label>Statut:</label>
                    <p><span class="status-badge status-${vendor.status || 'pending'}">${getStatusText(vendor.status)}</span></p>
                </div>
                <div class="detail-group">
                    <label>Date d'inscription:</label>
                    <p>${formatDate(vendor.createdAt?.toDate())}</p>
                </div>
                ${vendor.certificationDocuments ? `
                    <div class="detail-group">
                        <label>Documents de certification:</label>
                        <div class="documents-list">
                            ${Object.entries(vendor.certificationDocuments).map(([key, url]) => 
                                `<a href="${url}" target="_blank" class="document-link">${key}</a>`
                            ).join('')}
                        </div>
                    </div>
                ` : ''}
            </div>
        `;

        // Update modal buttons
        document.getElementById('approveVendorBtn').onclick = () => approveVendor(vendorId);
        document.getElementById('rejectVendorBtn').onclick = () => rejectVendor(vendorId);

        // Show modal
        document.getElementById('modalOverlay').classList.add('active');
    } catch (error) {
        console.error('Error opening vendor modal:', error);
        alert('Erreur lors du chargement des détails du vendeur');
    }
}

async function approveVendor(vendorId) {
    try {
        await window.db.collection(window.COLLECTIONS.vendors).doc(vendorId).update({
            status: 'approved',
            approvedAt: firebase.firestore.FieldValue.serverTimestamp(),
            approvedBy: (await firebase.auth().currentUser)?.uid
        });
        
        alert('Vendeur approuvé avec succès');
        closeModal();
        loadVendors();
        if (window.refreshDashboard) window.refreshDashboard();
    } catch (error) {
        console.error('Error approving vendor:', error);
        alert('Erreur lors de l\'approbation du vendeur');
    }
}

async function rejectVendor(vendorId) {
    const reason = prompt('Raison du rejet:');
    if (!reason) return;

    try {
        await window.db.collection(window.COLLECTIONS.vendors).doc(vendorId).update({
            status: 'rejected',
            rejectedAt: firebase.firestore.FieldValue.serverTimestamp(),
            rejectedBy: (await firebase.auth().currentUser)?.uid,
            rejectionReason: reason
        });
        
        alert('Vendeur rejeté');
        closeModal();
        loadVendors();
    } catch (error) {
        console.error('Error rejecting vendor:', error);
        alert('Erreur lors du rejet du vendeur');
    }
}

function getStatusText(status) {
    const statusMap = {
        'pending': 'En attente',
        'approved': 'Approuvé',
        'rejected': 'Rejeté'
    };
    return statusMap[status] || status;
}

function formatDate(date) {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
}

function closeModal() {
    document.getElementById('modalOverlay').classList.remove('active');
}

// Make functions available globally
window.loadVendors = loadVendors;
window.openVendorModal = openVendorModal;
window.closeModal = closeModal;

