#!/bin/bash

# Divi 5 Child Theme Setup Script
# Automates the setup of a new theme from the starter template
# Usage: ./setup.sh client-name

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Function to convert kebab-case to Title Case
kebab_to_title() {
    echo "$1" | sed -r 's/(^|-)([a-z])/\U\2/g'
}

# Function to convert kebab-case to PascalCase
kebab_to_pascal() {
    echo "$1" | sed -r 's/(^|-)([a-z])/\U\2/g'
}

# Check if client name is provided
if [ -z "$1" ]; then
    print_error "Error: Client name is required"
    echo "Usage: ./setup.sh client-name"
    echo "Example: ./setup.sh acme-corp"
    exit 1
fi

CLIENT_NAME="$1"
THEME_SLUG="divi-${CLIENT_NAME}"

# Validate client name format (alphanumeric and hyphens only)
if ! [[ "$CLIENT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    print_error "Error: Client name must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Convert names for different uses
CLIENT_TITLE=$(kebab_to_title "$CLIENT_NAME")
PACKAGE_NAME=$(kebab_to_pascal "$THEME_SLUG")

print_info "Setting up new Divi child theme..."
echo "Client Name: $CLIENT_NAME"
echo "Theme Slug: $THEME_SLUG"
echo "Display Name: Divi $CLIENT_TITLE Child"
echo "Package Name: $PACKAGE_NAME"
echo ""

# Confirm with user
read -p "Continue with setup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setup cancelled"
    exit 0
fi

# Get current directory name
CURRENT_DIR=$(basename "$PWD")

# Check if required files exist
if [ ! -f "style.css" ] || [ ! -f "functions.php" ] || [ ! -f "package.json" ]; then
    print_error "Error: Required theme files not found. Are you in the theme directory?"
    exit 1
fi

print_info "Step 1/8: Updating style.css..."
sed -i "s/^Theme Name:.*/Theme Name: Divi $CLIENT_TITLE Child/" style.css
sed -i "s/^Description:.*/Description: Divi 5 child theme developed for $CLIENT_TITLE/" style.css
sed -i "s/^Version:.*/Version: 1.0.0/" style.css
print_success "style.css updated"

print_info "Step 2/8: Updating src/scss/style.scss..."
sed -i "s/^Theme Name:.*/Theme Name: Divi $CLIENT_TITLE Child/" src/scss/style.scss
sed -i "s/^Description:.*/Description: Divi 5 child theme developed for $CLIENT_TITLE/" src/scss/style.scss
sed -i "s/^Version:.*/Version: 1.0.0/" src/scss/style.scss
print_success "src/scss/style.scss updated"

print_info "Step 3/8: Updating package.json..."
sed -i "s/\"name\": \".*\"/\"name\": \"$THEME_SLUG\"/" package.json
print_success "package.json updated"

print_info "Step 4/8: Updating PHP @package tags..."
# Update all PHP files with @package tag
find . -name "*.php" -type f -not -path "./vendor/*" -exec sed -i "s/@package.*DiviFiveChild/@package   $PACKAGE_NAME/" {} \;
print_success "PHP @package tags updated"

print_info "Step 5/8: Copying workspace file..."
if [ -f "divi-five-child.code-workspace" ]; then
    cp "divi-five-child.code-workspace" "${THEME_SLUG}.code-workspace"
    print_success "Workspace file copied to ${THEME_SLUG}.code-workspace"
else
    print_info "Workspace file not found, skipping..."
fi

print_info "Step 6/8: Installing npm dependencies..."
if command -v npm &> /dev/null; then
    npm install
    print_success "npm dependencies installed"
else
    print_error "npm not found, skipping npm install"
fi

print_info "Step 7/8: Installing composer dependencies..."
if command -v composer &> /dev/null; then
    composer install
    print_success "Composer dependencies installed"
else
    print_error "composer not found, skipping composer install"
fi

print_info "Step 8/8: Renaming theme folder..."
cd ..
if [ "$CURRENT_DIR" != "$THEME_SLUG" ]; then
    if [ -d "$THEME_SLUG" ]; then
        print_error "Error: Directory $THEME_SLUG already exists"
        cd "$CURRENT_DIR"
        exit 1
    fi
    mv "$CURRENT_DIR" "$THEME_SLUG"
    print_success "Folder renamed from $CURRENT_DIR to $THEME_SLUG"
    cd "$THEME_SLUG"
else
    print_info "Folder already has correct name, skipping..."
    cd "$CURRENT_DIR"
fi

echo ""
print_success "Setup complete!"
echo ""
print_info "Next steps:"
echo "1. Remove .git directory if you want a fresh start: rm -rf .git"
echo "2. Initialize new git repo: git init"
echo "3. Make your first commit: git add . && git commit -m 'Initial commit'"
echo "4. Copy theme to WordPress themes directory"
echo "5. Activate theme in WordPress admin"
echo ""
print_info "Theme is ready for development!"

