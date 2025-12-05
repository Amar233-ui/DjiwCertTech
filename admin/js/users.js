// Gestion des utilisateurs
async function loadUsers(searchQuery = '') {
    try {
        const snapshot = await window.db.collection(window.COLLECTIONS.users)
            .orderBy('createdAt', 'desc')
            .get();

        const tbody = document.getElementById('usersTableBody');
        
        if (snapshot.empty) {
            tbody.innerHTML = '<tr><td colspan="8" style="text-align: center;">Aucun utilisateur trouvé</td></tr>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const user = doc.data();
            
            // Filter by search query
            if (searchQuery && !matchesUserSearch(user, searchQuery)) {
                return;
            }
            
            const role = user.role || 'Agriculteur';
            const region = user.region || 'N/A';
            const zone = user.agroEcologicalZone || 'N/A';
            const phone = user.phone || 'N/A';
            const name = user.name || 'N/A';
            const email = user.email || 'N/A';
            
            html += `
                <tr>
                    <td>${name}</td>
                    <td>${email}</td>
                    <td>${phone}</td>
                    <td>${region}</td>
                    <td>${zone}</td>
                    <td>
                        <span class="status-badge status-${role === 'Vendeur' ? 'active' : 'pending'}">
                            ${role}
                        </span>
                    </td>
                    <td>${formatDate(user.createdAt?.toDate())}</td>
                    <td>
                        <button class="btn btn-primary" onclick="viewUserDetails('${doc.id}')">
                            <i class="fas fa-eye"></i>
                        </button>
                        ${role !== 'Vendeur' ? `
                        <button class="btn btn-success" onclick="promoteToVendor('${doc.id}')">
                            <i class="fas fa-store"></i> Vendeur
                        </button>
                        ` : ''}
                    </td>
                </tr>
            `;
        });

        tbody.innerHTML = html;
    } catch (error) {
        console.error('Error loading users:', error);
    }
}

function matchesUserSearch(user, query) {
    const searchLower = query.toLowerCase();
    return (
        (user.name && user.name.toLowerCase().includes(searchLower)) ||
        (user.email && user.email.toLowerCase().includes(searchLower)) ||
        (user.phone && user.phone.includes(searchLower)) ||
        (user.region && user.region.toLowerCase().includes(searchLower))
    );
}

async function viewUserDetails(userId) {
    try {
        const userDoc = await window.db.collection(window.COLLECTIONS.users).doc(userId).get();
        if (!userDoc.exists) {
            alert('Utilisateur non trouvé');
            return;
        }
        
        const user = userDoc.data();
        const details = `
Nom: ${user.name || 'N/A'}
Email: ${user.email || 'N/A'}
Téléphone: ${user.phone || 'N/A'}
Région: ${user.region || 'N/A'}
Zone agro-écologique: ${user.agroEcologicalZone || 'N/A'}
Adresse: ${user.address || 'N/A'}
Rôle: ${user.role || 'Agriculteur'}
Date d'inscription: ${formatDate(user.createdAt?.toDate())}
        `;
        
        alert(details);
    } catch (error) {
        console.error('Error viewing user details:', error);
        alert('Erreur lors du chargement des détails');
    }
}

async function promoteToVendor(userId) {
    if (!confirm('Promouvoir cet utilisateur au statut de vendeur ?')) {
        return;
    }
    
    try {
        await window.db.collection(window.COLLECTIONS.users).doc(userId).update({
            role: 'Vendeur',
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        
        alert('Utilisateur promu au statut de vendeur avec succès');
        loadUsers();
    } catch (error) {
        console.error('Error promoting user:', error);
        alert('Erreur lors de la promotion');
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
window.loadUsers = loadUsers;
window.viewUserDetails = viewUserDetails;
window.promoteToVendor = promoteToVendor;

// Search functionality
document.addEventListener('DOMContentLoaded', () => {
    const userSearch = document.getElementById('userSearch');
    if (userSearch) {
        userSearch.addEventListener('input', (e) => {
            loadUsers(e.target.value);
        });
    }
});
