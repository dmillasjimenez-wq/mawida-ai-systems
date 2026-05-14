#!/bin/bash

# ============================================================
# MAWIDA AI SYSTEM · Deploy a GitHub
# Ejecutá este script en la misma carpeta donde está
# el archivo mawida-ai-system.html
# ============================================================

set -e

TOKEN="TU_GITHUB_TOKEN_AQUI"
REPO_NAME="mawida-ai-system"
DESCRIPTION="Sistema Operativo Cannábico Medicinal — Marketing con IA para asociaciones cannábicas en Chile"

echo ""
echo "🌿 MAWIDA AI SYSTEM · Deploy a GitHub"
echo "======================================="
echo ""

# 1. Obtener username
echo "▸ Obteniendo tu usuario de GitHub..."
USERNAME=$(curl -s -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user | python3 -c "import sys,json; print(json.load(sys.stdin)['login'])" 2>/dev/null)

if [ -z "$USERNAME" ]; then
  echo "❌ No se pudo obtener el usuario. Verificá el token."
  exit 1
fi

echo "   Usuario: $USERNAME"

# 2. Crear repositorio
echo ""
echo "▸ Creando repositorio '$REPO_NAME'..."

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -X POST https://api.github.com/user/repos \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"$DESCRIPTION\",
    \"private\": false,
    \"auto_init\": false,
    \"has_issues\": true,
    \"has_wiki\": false
  }")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)

if [ "$HTTP_CODE" == "201" ]; then
  echo "   ✓ Repositorio creado"
elif [ "$HTTP_CODE" == "422" ]; then
  echo "   ℹ️  El repositorio ya existe — continuando..."
else
  echo "   ⚠️  Respuesta HTTP: $HTTP_CODE"
fi

# 3. Verificar que el archivo HTML existe
if [ ! -f "mawida-ai-system.html" ]; then
  echo ""
  echo "❌ No encontré 'mawida-ai-system.html' en esta carpeta."
  echo "   Asegurate de que este script esté en la misma carpeta que el archivo HTML."
  exit 1
fi

# 4. Inicializar git y hacer push
echo ""
echo "▸ Inicializando repositorio git..."

TEMP_DIR=$(mktemp -d)
cp mawida-ai-system.html "$TEMP_DIR/"

cd "$TEMP_DIR"
git init -q
git config user.email "deploy@mawida-ai.cl"
git config user.name "Mawida AI Deploy"

# Crear README.md
cat > README.md << 'READMEEOF'
# 🌿 MAWIDA AI SYSTEM v4.0

**Sistema Operativo Cannábico Medicinal** · Marketing con IA para asociaciones cannábicas en Chile.

## ¿Qué es?

Un software completo de marketing especializado para:
- **Mawida** · Santiago RM
- **Los de la Quinta** · V Región / Valparaíso
- **Bio Bio** · Región del Biobío

## Features

- 🤖 **6 Agentes especializados** — Director Creativo, Social Media, Experto Cannábico, Daniel (Audiovisual), Copywriter, Analista
- 🚀 **Brief Automático** — El equipo completo genera tu campaña en cadena
- 🔍 **Auditor de Coherencia** — Analiza textos vs tu manual de marca
- ⚖️ **Asistente Legal** — Revisión vs normativa chilena (Ley 20.000)
- 🎨 **Generador Visual** — Prompts para Midjourney, Sora, Kling, DALL-E
- 📖 **Narrador de Pacientes** — Relatos éticos con disclaimers automáticos
- ✦ **Agentes editables** — Creá y personalizá tu propio equipo

## Uso

1. Descargá `mawida-ai-system.html`
2. Abrilo en cualquier navegador (doble clic)
3. En Claude.ai: funciona directamente
4. Descargado: configurá tu API Key de Anthropic en ⚙️

## Marco legal

En Chile las asociaciones cannábicas operan como organizaciones sin fines de lucro para socios con receta médica vigente. Todo el contenido generado respeta este marco: educativo, institucional y comunitario.

---

*Powered by Claude (Anthropic) · Desarrollado para el ecosistema cannábico medicinal chileno*
READMEEOF

# Crear .gitignore
cat > .gitignore << 'GITEOF'
.DS_Store
Thumbs.db
*.log
node_modules/
GITEOF

git add .
git commit -q -m "🌿 MAWIDA AI SYSTEM v4.0 — Sistema Operativo Cannábico Medicinal

- 6 agentes especializados con personalidades únicas
- Brief Automático: equipo completo en cadena
- Auditor de Coherencia de Marca
- Asistente Legal (normativa chilena)
- Generador Visual (Midjourney, Sora, Kling, DALL-E)
- Narrador de Historias de Pacientes
- Sistema de Proyectos
- Biblioteca de Marca por asociación
- Agentes editables y creables
- Export/Import de biblioteca compartible"

echo ""
echo "▸ Subiendo a GitHub..."

git remote add origin "https://$TOKEN@github.com/$USERNAME/$REPO_NAME.git"
git branch -M main
git push -q -u origin main 2>/dev/null

echo ""
echo "✅ ¡Listo! Tu repositorio está en:"
echo ""
echo "   🔗 https://github.com/$USERNAME/$REPO_NAME"
echo ""
echo "   🌐 GitHub Pages (activar en Settings → Pages → Deploy from main):"
echo "   🔗 https://$USERNAME.github.io/$REPO_NAME/mawida-ai-system.html"
echo ""

# Limpiar
cd /
rm -rf "$TEMP_DIR"

echo "🌿 Deploy completado. ¡Que funcione!"
echo ""
