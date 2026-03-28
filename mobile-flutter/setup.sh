#!/usr/bin/env bash
# =============================================================================
# setup.sh — Inicializa el proyecto Flutter de EcoHome
# Uso: chmod +x setup.sh && ./setup.sh
# =============================================================================
set -e

PROJECT_NAME="ecohome_flutter"
ORG="com.ecohome"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔══════════════════════════════════════════╗"
echo "║   EcoHome Flutter — Setup inicial        ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 1. Verificar Flutter
if ! command -v flutter &> /dev/null; then
  echo "❌  Flutter no está instalado o no está en el PATH."
  echo "    Descárgalo desde https://docs.flutter.dev/get-started/install"
  exit 1
fi
echo "✅  Flutter encontrado: $(flutter --version | head -1)"
echo ""

# 2. Crear proyecto temporal y luego mover archivos generados
TMPDIR=$(mktemp -d)
echo "📁  Creando proyecto base en $TMPDIR..."
flutter create --org "$ORG" --project-name "$PROJECT_NAME" "$TMPDIR/$PROJECT_NAME" > /dev/null

# 3. Copiar boilerplate de plataformas (android, ios, web, test, .dart_tool, etc.)
echo "📦  Copiando archivos de plataforma..."
for dir in android ios web linux macos windows test .dart_tool; do
  src="$TMPDIR/$PROJECT_NAME/$dir"
  dst="$SCRIPT_DIR/$dir"
  if [ -d "$src" ] && [ ! -d "$dst" ]; then
    cp -r "$src" "$dst"
    echo "    → $dir/"
  fi
done

# Copiar archivos raíz de plataforma que no existen aún
for f in .gitignore .metadata analysis_options.yaml; do
  src="$TMPDIR/$PROJECT_NAME/$f"
  dst="$SCRIPT_DIR/$f"
  if [ -f "$src" ] && [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    echo "    → $f"
  fi
done

rm -rf "$TMPDIR"
echo ""

# 4. Instalar dependencias
echo "📥  Ejecutando flutter pub get..."
cd "$SCRIPT_DIR"
flutter pub get

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ✅  Proyecto listo!                     ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Comandos para ejecutar:"
echo ""
echo "  # Emulador Android (URL backend: http://10.0.2.2:8080)"
echo "  flutter run -d emulator"
echo ""
echo "  # Flutter Web (URL backend: http://localhost:8080)"
echo "  flutter run -d chrome \\"
echo "    --dart-define=API_BASE_URL=http://localhost:8080"
echo ""
echo "  # Dispositivo físico (reemplaza <IP> con tu IP local)"
echo "  flutter run -d <device-id> \\"
echo "    --dart-define=API_BASE_URL=http://<IP>:8080"
echo ""
