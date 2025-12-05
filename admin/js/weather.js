// Utilise les variables globales depuis config.js
// Pas besoin de déclarer db et COLLECTIONS, ils sont déjà dans window

async function loadWeatherAlerts() {
    try {
        // Get weather alerts from Firestore
        const snapshot = await window.db.collection(window.COLLECTIONS.weatherAlerts)
            .orderBy('createdAt', 'desc')
            .limit(20)
            .get();

        const container = document.getElementById('weatherAlerts');
        
        if (snapshot.empty) {
            container.innerHTML = '<p>Aucune alerte météorologique récente</p>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const alert = doc.data();
            const severity = getSeverity(alert.severity || 'medium');
            
            html += `
                <div class="weather-alert-card ${severity}">
                    <h3>${alert.title || 'Alerte météorologique'}</h3>
                    <p><strong>Région:</strong> ${alert.region || 'N/A'}</p>
                    <p><strong>Type:</strong> ${alert.type || 'N/A'}</p>
                    <p><strong>Description:</strong> ${alert.description || 'N/A'}</p>
                    <p><strong>Date:</strong> ${formatDate(alert.createdAt?.toDate())}</p>
                    ${alert.riskLevel ? `<p><strong>Niveau de risque:</strong> ${alert.riskLevel}</p>` : ''}
                </div>
            `;
        });

        container.innerHTML = html;
    } catch (error) {
        console.error('Error loading weather alerts:', error);
        // Fallback: Show message about API integration
        document.getElementById('weatherAlerts').innerHTML = `
            <div class="weather-alert-card">
                <h3>Intégration API Météo</h3>
                <p>Pour activer les alertes météorologiques en temps réel, configurez l'API OpenWeatherMap dans le backend.</p>
                <p>Les alertes seront automatiquement enregistrées dans Firestore lors de la détection de risques climatiques.</p>
            </div>
        `;
    }
}

function getSeverity(severity) {
    const severityMap = {
        'low': 'low',
        'medium': '',
        'high': 'high'
    };
    return severityMap[severity] || '';
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

// Make function available globally
window.loadWeatherAlerts = loadWeatherAlerts;

