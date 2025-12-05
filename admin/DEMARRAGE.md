# 🚀 Guide de Démarrage - Back-Office DjiwCertTech

## ⚠️ Problème CORS résolu

Le problème CORS que vous rencontriez était dû à l'ouverture directe du fichier HTML (`file://`). 
**Tous les fichiers JavaScript ont été convertis pour fonctionner sans modules ES6.**

## 📋 Méthodes de Démarrage

### Méthode 1 : Serveur Node.js (Recommandé)

1. **Installer Node.js** (si pas déjà installé) :
   - Téléchargez depuis : https://nodejs.org/
   - Version LTS recommandée

2. **Démarrer le serveur** :
   ```bash
   cd admin
   node server.js
   ```

3. **Ouvrir dans le navigateur** :
   - Allez sur : `http://localhost:8080`

### Méthode 2 : Script Batch (Windows)

Double-cliquez sur `start-server.bat` dans le dossier `admin`

### Méthode 3 : Python (Alternative)

Si Node.js n'est pas installé :

```bash
cd admin
python -m http.server 8080
```

Puis ouvrez : `http://localhost:8080`

### Méthode 4 : Live Server (VS Code)

Si vous utilisez VS Code :

1. Installez l'extension "Live Server"
2. Clic droit sur `index.html` → "Open with Live Server"

## ✅ Vérification

Une fois le serveur démarré, vous devriez voir :
- ✅ Pas d'erreurs CORS dans la console
- ✅ Page de connexion s'affiche correctement
- ✅ Firebase se connecte sans erreur

## 🔐 Connexion

Pour vous connecter, vous devez avoir un compte utilisateur dans Firestore avec :
- `role: 'admin'` OU
- `isAdmin: true`

## 📝 Notes

- Le serveur écoute sur le port **8080** par défaut
- Pour changer le port, modifiez `PORT` dans `server.js`
- Le serveur sert tous les fichiers statiques du dossier `admin`

