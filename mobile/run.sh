#!/bin/bash
echo "🚀 Démarrage du serveur ADB..."
adb start-server

echo "🔗 Établissement du tunnel ADB..."
adb reverse tcp:3001 tcp:3001

echo "📱 Lancement de l'app..."
flutter run
