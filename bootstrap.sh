#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

BUILD=0
OPEN=0
GENERATE=0

usage() {
  cat <<'EOF'
Uso: ./bootstrap.sh [--build] [--open] [--generate]

Prepara o projeto Iphone Info e descompacta CPU-x.ipa em extracted/.

  --build      compila o scheme IphoneInfo no simulador iPhone 17
  --open       abre IphoneInfo/IphoneInfo.xcodeproj no Xcode
  --generate   regenera o .xcodeproj com xcodegen a partir de IphoneInfo/project.yml
  -h, --help   mostra esta ajuda
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build) BUILD=1 ;;
    --open) OPEN=1 ;;
    --generate) GENERATE=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opção desconhecida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! xcode-select -p >/dev/null 2>&1 || ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Xcode não encontrado. Instale o Xcode e rode: sudo xcode-select -s /Applications/Xcode.app" >&2
  exit 1
fi

if [[ "$GENERATE" -eq 1 ]]; then
  if ! command -v xcodegen >/dev/null 2>&1; then
    echo "xcodegen não está no PATH. Instale com: brew install xcodegen" >&2
    exit 1
  fi
  echo "Gerando IphoneInfo/IphoneInfo.xcodeproj com xcodegen..."
  (cd IphoneInfo && xcodegen generate)
else
  echo "Usando o IphoneInfo.xcodeproj versionado. Passe --generate para recriar com xcodegen."
fi

if [[ ! -d IphoneInfo/IphoneInfo.xcodeproj ]]; then
  echo "IphoneInfo/IphoneInfo.xcodeproj não existe. Rode de novo com --generate (precisa do xcodegen)." >&2
  exit 1
fi

if [[ -f CPU-x.ipa ]]; then
  echo "Descompactando CPU-x.ipa em extracted/..."
  rm -rf extracted
  mkdir -p extracted
  unzip -q CPU-x.ipa -d extracted
else
  echo "CPU-x.ipa não encontrado. Pulando a descompactação."
fi

if [[ "$BUILD" -eq 1 ]]; then
  echo "Compilando IphoneInfo para o simulador iPhone 17..."
  xcodebuild \
    -project IphoneInfo/IphoneInfo.xcodeproj \
    -scheme IphoneInfo \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    -derivedDataPath IphoneInfo/build \
    build
fi

if [[ "$OPEN" -eq 1 ]]; then
  open IphoneInfo/IphoneInfo.xcodeproj
fi

echo "Pronto."
