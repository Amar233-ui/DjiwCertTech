// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

async function loadSubsidies() {
    try {
        const snapshot = await window.db.collection(window.COLLECTIONS.subsidies)
            .orderBy('createdAt', 'desc')
            .get();

        const tbody = document.getElementById('subsidiesTableBody');
        
        if (snapshot.empty) {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align: center;">Aucune subvention trouvée</td></tr>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const subsidy = doc.data();
            
            html += `
                <tr>
                    <td>${subsidy.name || 'N/A'}</td>
                    <td>${subsidy.type || 'N/A'}</td>
                    <td>${subsidy.amount?.toFixed(0) || 0} FCFA</td>
                    <td>${subsidy.beneficiaries?.length || 0}</td>
                    <td>${formatDate(subsidy.startDate?.toDate())}</td>
                    <td>${formatDate(subsidy.endDate?.toDate())}</td>
                    <td>
                        <span class="status-badge status-${getSubsidyStatus(subsidy)}">
                            ${getSubsidyStatusText(subsidy)}
                        </span>
                    </td>
                    <td>
                        <button class="btn btn-primary" onclick="editSubsidy('${doc.id}')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger" onclick="deleteSubsidy('${doc.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
        });

        tbody.innerHTML = html;
    } catch (error) {
        console.error('Error loading subsidies:', error);
    }
}

function openAddSubsidyModal() {
    // TODO: Implement add subsidy modal
    const name = prompt('Nom de la subvention:');
    if (!name) return;

    const type = prompt('Type de subvention:');
    const amount = parseFloat(prompt('Montant (FCFA):'));
    
    if (!type || isNaN(amount)) {
        alert('Données invalides');
        return;
    }

    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + 6);

    window.db.collection(window.COLLECTIONS.subsidies).add({
        name,
        type,
        amount,
        beneficiaries: [],
        startDate: firebase.firestore.Timestamp.fromDate(startDate),
        endDate: firebase.firestore.Timestamp.fromDate(endDate),
        status: 'active',
        createdAt: firebase.firestore.FieldValue.serverTimestamp()
    })
    .then(() => {
        alert('Subvention créée avec succès');
        loadSubsidies();
    })
    .catch(error => {
        console.error('Error creating subsidy:', error);
        alert('Erreur lors de la création');
    });
}

function editSubsidy(subsidyId) {
    // TODO: Implement edit subsidy
    alert('Fonctionnalité à implémenter');
}

function deleteSubsidy(subsidyId) {
    if (confirm('Êtes-vous sûr de vouloir supprimer cette subvention ?')) {
        window.db.collection(window.COLLECTIONS.subsidies).doc(subsidyId).delete()
            .then(() => {
                alert('Subvention supprimée avec succès');
                loadSubsidies();
            })
            .catch(error => {
                console.error('Error deleting subsidy:', error);
                alert('Erreur lors de la suppression');
            });
    }
}

function getSubsidyStatus(subsidy) {
    if (!subsidy.startDate || !subsidy.endDate) return 'pending';
    
    const now = new Date();
    const start = subsidy.startDate.toDate();
    const end = subsidy.endDate.toDate();
    
    if (now < start) return 'pending';
    if (now > end) return 'rejected';
    return 'approved';
}

function getSubsidyStatusText(subsidy) {
    const status = getSubsidyStatus(subsidy);
    const statusMap = {
        'pending': 'À venir',
        'approved': 'Active',
        'rejected': 'Expirée'
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

// Make functions available globally
window.loadSubsidies = loadSubsidies;
window.openAddSubsidyModal = openAddSubsidyModal;
window.editSubsidy = editSubsidy;
window.deleteSubsidy = deleteSubsidy;

