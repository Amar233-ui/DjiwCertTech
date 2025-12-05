// Utilise les variables globales depuis config.js
// Pas besoin de déclarer auth et db, ils sont déjà dans window

console.log('🔐 Initialisation de l\'authentification...');

let currentUser = null;

// Check if user is admin
async function checkAdminStatus(uid) {
    try {
        const userDoc = await window.db.collection('users').doc(uid).get();
        if (userDoc.exists) {
            const userData = userDoc.data();
            return userData.role === 'admin' || userData.isAdmin === true;
        }
        return false;
    } catch (error) {
        console.error('Error checking admin status:', error);
        return false;
    }
}

// Attendre que window.auth soit disponible
function waitForAuth() {
    if (typeof window.auth === 'undefined') {
        console.log('⏳ Attente de window.auth...');
        setTimeout(waitForAuth, 100);
        return;
    }
    console.log('✅ window.auth est disponible');
    initAuth();
}

function initAuth() {
    // Check authentication state
    window.auth.onAuthStateChanged((user) => {
        console.log('👤 État d\'authentification changé:', user ? 'Connecté' : 'Déconnecté');
        currentUser = user;
        if (user) {
            // Check if user is admin
            checkAdminStatus(user.uid).then(isAdmin => {
                console.log('🔍 Statut admin:', isAdmin);
                if (isAdmin) {
                    showMainApp();
                } else {
                    window.auth.signOut();
                    showError('Accès refusé. Vous n\'êtes pas administrateur.');
                }
            });
        } else {
            showLoginPage();
        }
    });
}

// Login form handler
document.getElementById('loginForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('adminEmail').value;
    const password = document.getElementById('adminPassword').value;
    const errorDiv = document.getElementById('loginError');

    try {
        errorDiv.classList.remove('show');
        await window.auth.signInWithEmailAndPassword(email, password);
    } catch (error) {
        errorDiv.textContent = getErrorMessage(error.code);
        errorDiv.classList.add('show');
    }
});

// Logout handler
document.getElementById('logoutBtn')?.addEventListener('click', async () => {
    try {
        await window.auth.signOut();
    } catch (error) {
        console.error('Logout error:', error);
    }
});

// Show login page
function showLoginPage() {
    console.log('🔓 Affichage de la page de connexion');
    const loginPage = document.getElementById('loginPage');
    const mainContent = document.getElementById('mainContent');
    const sidebar = document.getElementById('sidebar');
    
    if (loginPage) {
        loginPage.style.display = 'flex';
        console.log('✅ Page de connexion affichée');
    } else {
        console.error('❌ loginPage introuvable !');
    }
    
    if (mainContent) {
        mainContent.style.display = 'none';
    }
    
    if (sidebar) {
        sidebar.style.display = 'none';
    }
}

// Show main app
function showMainApp() {
    console.log('📊 Affichage de l\'application principale');
    const loginPage = document.getElementById('loginPage');
    const mainContent = document.getElementById('mainContent');
    const sidebar = document.getElementById('sidebar');
    
    if (loginPage) {
        loginPage.style.display = 'none';
        console.log('✅ Page de connexion masquée');
    }
    
    if (mainContent) {
        mainContent.style.display = 'block';
        console.log('✅ Contenu principal affiché');
    } else {
        console.error('❌ mainContent introuvable !');
    }
    
    if (sidebar) {
        sidebar.style.display = 'flex';
        console.log('✅ Sidebar affichée');
    }
    
    // Update user name
    if (currentUser) {
        window.db.collection('users').doc(currentUser.uid).get().then(doc => {
            if (doc.exists) {
                const userData = doc.data();
                const userNameEl = document.getElementById('userName');
                if (userNameEl) {
                    userNameEl.textContent = userData.name || currentUser.email;
                }
            }
        }).catch(error => {
            console.error('Erreur lors de la récupération du nom:', error);
        });
    }
    
    // Load dashboard data
    if (typeof window.refreshDashboard === 'function') {
        window.refreshDashboard();
    }
}

// Error messages
function getErrorMessage(errorCode) {
    const messages = {
        'auth/user-not-found': 'Utilisateur non trouvé',
        'auth/wrong-password': 'Mot de passe incorrect',
        'auth/invalid-email': 'Email invalide',
        'auth/user-disabled': 'Compte désactivé',
        'auth/too-many-requests': 'Trop de tentatives. Réessayez plus tard'
    };
    return messages[errorCode] || 'Erreur de connexion';
}

// Show error
function showError(message) {
    const errorDiv = document.getElementById('loginError');
    if (errorDiv) {
        errorDiv.textContent = message;
        errorDiv.classList.add('show');
    }
}

// Démarrer l'initialisation
waitForAuth();

// Make functions available globally
window.currentUser = () => currentUser;
window.checkAdminStatus = checkAdminStatus;

