@echo off
echo ========================================
echo   DjiwCertTech - Back-Office Server
echo ========================================
echo.
echo Demarrage du serveur HTTP...
echo.
node server.js
if errorlevel 1 (
    echo.
    echo Erreur: Node.js n'est pas installe ou le serveur a rencontre un probleme.
    echo.
    echo Alternatives:
    echo   1. Installez Node.js depuis https://nodejs.org
    echo   2. Ou utilisez Python: python -m http.server 8080
    echo.
    pause
)

