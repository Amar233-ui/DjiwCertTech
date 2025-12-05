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
    document.getElementById('trainingId').value = '';
    document.getElementById('trainingForm').reset();
    document.getElementById('trainingModalTitle').textContent = 'Ajouter une formation';
    document.getElementById('trainingModalOverlay').style.display = 'flex';
}

function closeTrainingModal() {
    document.getElementById('trainingModalOverlay').style.display = 'none';
    document.getElementById('trainingForm').reset();
}

async function editTraining(trainingId) {
    try {
        const doc = await window.db.collection(window.COLLECTIONS.training).doc(trainingId).get();
        if (!doc.exists) {
            alert('Formation non trouvée');
            return;
        }
        
        const training = doc.data();
        document.getElementById('trainingId').value = trainingId;
        document.getElementById('trainingTitle').value = training.title || '';
        document.getElementById('trainingDescription').value = training.description || '';
        document.getElementById('trainingCategory').value = training.category || '';
        document.getElementById('trainingDuration').value = training.duration || 0;
        document.getElementById('trainingContent').value = training.content || '';
        document.getElementById('trainingVideoUrl').value = training.videoUrl || '';
        document.getElementById('trainingAudioUrl').value = training.audioUrl || '';
        document.getElementById('trainingImageUrl').value = training.imageUrl || '';
        document.getElementById('trainingIsDownloadable').checked = training.isDownloadable || false;
        document.getElementById('trainingIsPublished').checked = training.isPublished !== false;
        
        document.getElementById('trainingModalTitle').textContent = 'Modifier la formation';
        document.getElementById('trainingModalOverlay').style.display = 'flex';
    } catch (error) {
        console.error('Error loading training:', error);
        alert('Erreur lors du chargement');
    }
}

async function saveTraining(event) {
    if (event) event.preventDefault();
    
    const form = document.getElementById('trainingForm');
    const trainingId = document.getElementById('trainingId').value;
    const submitButton = event?.target || document.querySelector('#trainingModal .modal-footer .btn-primary');
    
    let originalText = '';
    if (submitButton) {
        originalText = submitButton.innerHTML;
        submitButton.disabled = true;
        submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Enregistrement...';
    }
    
    try {
        const trainingData = {
            title: document.getElementById('trainingTitle').value.trim(),
            description: document.getElementById('trainingDescription').value.trim(),
            category: document.getElementById('trainingCategory').value,
            duration: parseInt(document.getElementById('trainingDuration').value) || 0,
            content: document.getElementById('trainingContent').value.trim(),
            videoUrl: document.getElementById('trainingVideoUrl').value.trim() || null,
            audioUrl: document.getElementById('trainingAudioUrl').value.trim() || null,
            imageUrl: document.getElementById('trainingImageUrl').value.trim() || null,
            isDownloadable: document.getElementById('trainingIsDownloadable').checked,
            isPublished: document.getElementById('trainingIsPublished').checked,
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        };
        
        if (!trainingId) {
            // Nouvelle formation
            trainingData.createdAt = firebase.firestore.FieldValue.serverTimestamp();
            await window.db.collection(window.COLLECTIONS.training).add(trainingData);
            alert('Formation ajoutée avec succès');
        } else {
            // Modification
            await window.db.collection(window.COLLECTIONS.training).doc(trainingId).update(trainingData);
            alert('Formation modifiée avec succès');
        }
        
        closeTrainingModal();
        loadTraining();
    } catch (error) {
        console.error('Error saving training:', error);
        alert('Erreur lors de l\'enregistrement: ' + (error.message || 'Erreur inconnue'));
    } finally {
        if (submitButton) {
            submitButton.disabled = false;
            submitButton.innerHTML = originalText;
        }
    }
}

// Make functions available globally
window.closeTrainingModal = closeTrainingModal;
window.saveTraining = saveTraining;

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

