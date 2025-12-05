// Firebase Configuration
console.log('🔧 Initialisation de Firebase...');

// Attendre que Firebase soit chargé
if (typeof firebase === 'undefined') {
    console.error('❌ Firebase n\'est pas chargé !');
} else {
    console.log('✅ Firebase est chargé');
}

const firebaseConfig = {
    apiKey: "AIzaSyCDGYXh7QIrueAEb7V_JSPrSpL-9ZFbSu8",
    authDomain: "djiwcerttech-606cd.firebaseapp.com",
    projectId: "djiwcerttech-606cd",
    storageBucket: "djiwcerttech-606cd.appspot.com",
    messagingSenderId: "258048048672",
    appId: "1:258048048672:web:7ec6bfb16799f0c7f24645",
    measurementId: "G-65EVC2YL2W"
};

// Initialize Firebase (using compat version)
try {
    if (!firebase.apps.length) {
        firebase.initializeApp(firebaseConfig);
        console.log('✅ Firebase initialisé');
    } else {
        console.log('✅ Firebase déjà initialisé');
    }

    // Initialize services (disponibles globalement)
    window.auth = firebase.auth();
    window.db = firebase.firestore();
    window.storage = firebase.storage();
    console.log('✅ Services Firebase initialisés');

    // Collections (disponibles globalement)
    window.COLLECTIONS = {
        users: 'users',
        vendors: 'vendors',
        products: 'products',
        orders: 'orders',
        training: 'training',
        subsidies: 'subsidies',
        weatherAlerts: 'weatherAlerts'
    };
    console.log('✅ Collections définies');
} catch (error) {
    console.error('❌ Erreur lors de l\'initialisation de Firebase:', error);
}

