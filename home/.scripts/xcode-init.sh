#!/usr/bin/env bash
set -euo pipefail

# Find .xcodeproj in current directory
XCODEPROJ=$(find . -maxdepth 1 -name "*.xcodeproj" -type d | head -1)
if [[ -z "$XCODEPROJ" ]]; then
  echo "Error: No .xcodeproj found in current directory" >&2
  exit 1
fi

PBXPROJ="$XCODEPROJ/project.pbxproj"
if [[ ! -f "$PBXPROJ" ]]; then
  echo "Error: $PBXPROJ not found" >&2
  exit 1
fi

APP_NAME=$(basename "$XCODEPROJ" .xcodeproj)
echo "Configuring $APP_NAME..."

# Modify build settings in project.pbxproj
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [^;]*/IPHONEOS_DEPLOYMENT_TARGET = 26.0/g' "$PBXPROJ"
sed -i '' 's/SWIFT_VERSION = [^;]*/SWIFT_VERSION = 6.0/g' "$PBXPROJ"
sed -i '' 's/TARGETED_DEVICE_FAMILY = "[^"]*"/TARGETED_DEVICE_FAMILY = 1/g' "$PBXPROJ"
sed -i '' 's/SUPPORTED_PLATFORMS = "[^"]*"/SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"/g' "$PBXPROJ"

echo "  ✓ iOS 26.0 deployment target"
echo "  ✓ Swift 6.0"
echo "  ✓ iPhone only"

# Add .gitignore
cat > .gitignore << 'EOF'
xcuserdata/
*.xcscmblueprint
DerivedData/
build/
.build/
.swiftpm/
.DS_Store
EOF
echo "  ✓ .gitignore"

# Git init + initial commit
git init -q
git add -A
git commit -q -m "feat: scaffold $APP_NAME iOS app"
echo "  ✓ Git initialized with initial commit"

# Create private GitHub repo and push
gh repo create "$APP_NAME" --private --source=. --push
echo "  ✓ Private GitHub repo created"

# Create production branch
git checkout -q -b production
git push -q -u origin production
git checkout -q main
echo "  ✓ Production branch created"

# Add Xcode MCP server for this project
claude mcp add xcode -s user -- xcrun mcpbridge &>/dev/null && echo "  ✓ Xcode MCP server configured"

echo ""
echo "Done! $APP_NAME is ready."
echo "  GitHub: $(gh repo view --json url -q .url)"
echo "  Branches: main, production"
