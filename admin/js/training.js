// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

async function loadTraining() {
    try {
        const snapshot = await window.db.collection(window.COLLECTIONS.training)
            .orderBy('createdAt', 'desc')
            .get();

        const tbody = document.getElementById('trainingTableBody');
        
        if (snapshot.empty) {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">Aucune formation trouvée</td></tr>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const training = doc.data();
            
            html += `
                <tr>
                    <td>${training.title || 'N/A'}</td>
                    <td>${training.category || 'N/A'}</td>
                    <td>${training.duration || 0} min</td>
                    <td>
                        <span class="status-badge status-${training.isPublished ? 'active' : 'pending'}">
                            ${training.isPublished ? 'Publiée' : 'Brouillon'}
                        </span>
                    </td>
                    <td>${formatDate(training.createdAt?.toDate())}</td>
                    <td>
                        <button class="btn btn-primary" onclick="editTraining('${doc.id}')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-${training.isPublished ? 'secondary' : 'success'}" onclick="toggleTrainingStatus('${doc.id}', ${!training.isPublished})">
                            <i class="fas fa-${training.isPublished ? 'eye-slash' : 'eye'}"></i>
                        </button>
                        <button class="btn btn-danger" onclick="deleteTraining('${doc.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
        });

        tbody.innerHTML = html;
    } catch (error) {
        console.error('Error loading training:', error);
    }
}

function openAddTrainingModal() {
    // TODO: Implement add training modal
    alert('Fonctionnalité à implémenter - Utilisez l\'application mobile pour ajouter des formations');
}

async function editTraining(trainingId) {
    // TODO: Implement edit training
    alert('Fonctionnalité à implémenter');
}

async function toggleTrainingStatus(trainingId, isPublished) {
    try {
        await window.db.collection(window.COLLECTIONS.training).doc(trainingId).update({
            isPublished: isPublished,
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        
        alert(`Formation ${isPublished ? 'publiée' : 'dépubliée'} avec succès`);
        loadTraining();
    } catch (error) {
        console.error('Error toggling training status:', error);
        alert('Erreur lors de la mise à jour');
    }
}

async function deleteTraining(trainingId) {
    if (confirm('Êtes-vous sûr de vouloir supprimer cette formation ?')) {
        try {
            await window.db.collection(window.COLLECTIONS.training).doc(trainingId).delete();
            alert('Formation supprimée avec succès');
            loadTraining();
        } catch (error) {
            console.error('Error deleting training:', error);
            alert('Erreur lors de la suppression');
        }
    }
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
window.loadTraining = loadTraining;
window.openAddTrainingModal = openAddTrainingModal;
window.editTraining = editTraining;
window.toggleTrainingStatus = toggleTrainingStatus;
window.deleteTraining = deleteTraining;

