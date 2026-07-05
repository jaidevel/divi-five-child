#!/bin/bash

# Divi 5 Child Theme Setup Script
# Automates the setup of a new theme from the starter template.
# Usage: ./setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTER_WORKSPACE="divi-five-child.code-workspace"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }
print_info()    { echo -e "${YELLOW}→ $1${NC}"; }
print_step()    { echo -e "\n${BOLD}${CYAN}$1${NC}"; }
print_hint()    { echo -e "  ${YELLOW}$1${NC}"; }

# ─── Helpers ─────────────────────────────────────────────────────────────────

kebab_to_title() {
	echo "$1" | sed -r 's/(^|-)([a-z])/\U\2/g'
}

kebab_to_pascal() {
	echo "$1" | sed -r 's/(^|-)([a-z])/\U\2/g'
}

normalize_kebab() {
	echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//; s/-\{2,\}/-/g'
}

expand_path() {
	echo "${1/#\~/$HOME}"
}

is_valid_kebab() {
	[[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

# ─── Prompt functions (set globals directly — no subshell) ────────────────────

# Sets: CLIENT_NAME
prompt_client_name() {
	print_step "Step 1/3 – Client Name"
	echo "  Enter the client's name. Spaces and uppercase are fine;"
	echo "  the script will normalise it to kebab-case automatically."
	print_hint "Example: \"Acme Corp\" → acme-corp  |  \"Helhetshelse\" → helhetshelse"
	echo ""

	local raw_name=""
	while true; do
		read -r -p "  Client name: " raw_name
		CLIENT_NAME="$(normalize_kebab "$raw_name")"

		if [ -z "$CLIENT_NAME" ]; then
			print_error "Client name cannot be empty. Please try again."
			continue
		fi

		if ! is_valid_kebab "$CLIENT_NAME"; then
			print_error "Could not produce a valid slug from \"$raw_name\". Use letters, numbers, or hyphens."
			continue
		fi

		echo ""
		print_success "Client name: $CLIENT_NAME"
		break
	done
}

# Sets: THEME_SLUG
prompt_theme_slug() {
	local default_slug="divi-${CLIENT_NAME}"

	print_step "Step 2/3 – Theme Slug"
	echo "  The slug is used as the folder name, package name, and text domain."
	echo "  Press Enter to accept the suggestion, or type a custom slug."
	echo ""

	local raw_slug=""
	read -r -p "  Theme slug [${default_slug}]: " raw_slug
	THEME_SLUG="${raw_slug:-$default_slug}"
	THEME_SLUG="$(normalize_kebab "$THEME_SLUG")"

	if ! is_valid_kebab "$THEME_SLUG"; then
		print_error "\"$THEME_SLUG\" is not a valid slug. Use lowercase letters, numbers, and hyphens."
		exit 1
	fi

	echo ""
	print_success "Theme slug: $THEME_SLUG"
}

# Sets: THEME_FOLDER  (literal path, or the string "current")
prompt_theme_folder() {
	local default_target="${HOME}/Development/Projects/${CLIENT_NAME}/www/${THEME_SLUG}"

	print_step "Step 3/3 – Theme Folder"
	echo "  Where should the new theme be created?"
	echo ""
	echo "    1) Current folder (./)"
	echo "       Set up in place. The starter folder will be renamed to ${THEME_SLUG}."
	echo ""
	echo "    2) Target folder  (recommended for new projects)"
	echo "       Copy the starter to a separate location."
	echo "       The starter repo stays untouched and can be reused."
	print_hint "       Excluded from copy: .git/, vendor/, .vscode/, .cursor/, setup.sh, lock files"
	echo ""

	local choice=""
	read -r -p "  Choice [1]: " choice
	choice="${choice:-1}"

	case "$choice" in
	1)
		THEME_FOLDER="current"
		echo ""
		print_success "Will set up in current folder (${SCRIPT_DIR})"
		print_hint "  Folder will be renamed to ${THEME_SLUG}/"
		;;
	2)
		echo ""
		echo "  Press Enter to accept the suggested path, or type a custom path."
		print_hint "  Any missing directories will be created automatically."
		echo ""

		local raw_path=""
		read -r -p "  Target path [${default_target}]: " raw_path
		raw_path="${raw_path:-$default_target}"
		THEME_FOLDER="$(expand_path "$raw_path")"

		if [ -d "$THEME_FOLDER" ] && [ -n "$(ls -A "$THEME_FOLDER" 2>/dev/null)" ]; then
			print_error "Target directory already exists and is not empty:"
			print_error "  $THEME_FOLDER"
			print_error "Please choose a different path or empty the directory first."
			exit 1
		fi

		mkdir -p "$THEME_FOLDER"
		echo ""
		print_success "Target folder: $THEME_FOLDER"
		;;
	*)
		print_error "Invalid choice \"$choice\". Please enter 1 or 2."
		exit 1
		;;
	esac
}

# ─── Work functions ───────────────────────────────────────────────────────────

copy_starter_to_target() {
	local source_dir="$1"
	local target_dir="$2"

	if ! command -v rsync &>/dev/null; then
		print_error "rsync is required to copy the starter theme to a target folder."
		print_error "Install it with: sudo apt install rsync  (or your distro's equivalent)"
		exit 1
	fi

	rsync -a \
		--exclude='.git/' \
		--exclude='vendor/' \
		--exclude='.vscode/' \
		--exclude='.cursor/' \
		--exclude='setup.sh' \
		--exclude='package-lock.json' \
		--exclude='composer.lock' \
		--exclude='yarn.lock' \
		--exclude='pnpm-lock.yaml' \
		--exclude='npm-shrinkwrap.json' \
		"${source_dir}/" "${target_dir}/"
}

apply_theme_transforms() {
	local client_title="$1"
	local theme_slug="$2"
	local package_name="$3"

	print_info "Updating style.css..."
	sed -i "s/^Theme Name:.*/Theme Name: Divi $client_title Child/" style.css
	sed -i "s/^Description:.*/Description: Divi 5 child theme developed for $client_title/" style.css
	sed -i "s/^Version:.*/Version: 1.0.0/" style.css
	print_success "style.css updated"

	print_info "Updating src/scss/style.scss..."
	sed -i "s/^Theme Name:.*/Theme Name: Divi $client_title Child/" src/scss/style.scss
	sed -i "s/^Description:.*/Description: Divi 5 child theme developed for $client_title/" src/scss/style.scss
	sed -i "s/^Version:.*/Version: 1.0.0/" src/scss/style.scss
	print_success "src/scss/style.scss updated"

	print_info "Updating package.json..."
	sed -i "s/\"name\": \".*\"/\"name\": \"$theme_slug\"/" package.json
	print_success "package.json updated"

	print_info "Updating PHP @package tags..."
	find . -name "*.php" -type f -not -path "./vendor/*" \
		-exec sed -i "s/@package.*DiviFiveChild/@package   $package_name/" {} \;
	print_success "PHP @package tags updated"
}

rename_workspace_file() {
	local theme_slug="$1"
	local target="${theme_slug}.code-workspace"

	if [ ! -f "$STARTER_WORKSPACE" ]; then
		print_info "Workspace file not found, skipping..."
		return
	fi

	if [ "$STARTER_WORKSPACE" = "$target" ]; then
		print_info "Workspace file already uses the theme slug."
		return
	fi

	if [ -f "$target" ]; then
		print_error "Workspace file $target already exists."
		exit 1
	fi

	mv "$STARTER_WORKSPACE" "$target"
	print_success "Workspace file renamed to $target"
}

install_dependencies() {
	print_info "Installing npm dependencies..."
	if command -v npm &>/dev/null; then
		npm install
		print_success "npm dependencies installed"
	else
		print_error "npm not found — skipping npm install"
	fi

	print_info "Installing composer dependencies..."
	if command -v composer &>/dev/null; then
		composer install
		print_success "Composer dependencies installed"
	else
		print_error "composer not found — skipping composer install"
	fi
}

rename_theme_folder_if_needed() {
	local theme_slug="$1"
	local current_dir
	current_dir="$(basename "$PWD")"

	if [ "$current_dir" = "$theme_slug" ]; then
		print_info "Folder already has correct name, skipping..."
		return
	fi

	cd ..

	if [ -d "$theme_slug" ]; then
		print_error "Cannot rename: a directory named $theme_slug already exists here."
		cd "$current_dir"
		exit 1
	fi

	mv "$current_dir" "$theme_slug"
	print_success "Folder renamed from $current_dir/ to $theme_slug/"
	cd "$theme_slug"
}

# ─── Guard: must run from the starter theme directory ────────────────────────

if [ ! -f "${SCRIPT_DIR}/style.css" ] || [ ! -f "${SCRIPT_DIR}/functions.php" ] || [ ! -f "${SCRIPT_DIR}/package.json" ]; then
	print_error "Required theme files not found. Run this script from the starter theme directory."
	exit 1
fi

# ─── Main ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD}  Divi 5 Child Theme Setup${NC}"
echo -e "${BOLD}============================================${NC}"
echo "  Starter: ${SCRIPT_DIR}"

prompt_client_name
prompt_theme_slug
prompt_theme_folder

CLIENT_TITLE="$(kebab_to_title "$CLIENT_NAME")"
PACKAGE_NAME="$(kebab_to_pascal "$THEME_SLUG")"

echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD}  Summary${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo "  Client name:  $CLIENT_NAME"
echo "  Theme slug:   $THEME_SLUG"
echo "  Display name: Divi $CLIENT_TITLE Child"
echo "  Package name: $PACKAGE_NAME"
if [ "$THEME_FOLDER" = "current" ]; then
	echo "  Theme folder: ${SCRIPT_DIR} (renamed to ${THEME_SLUG}/)"
else
	echo "  Theme folder: ${THEME_FOLDER}"
fi
echo ""

read -r -p "Continue with setup? (y/n): " -n 1 confirm_reply
echo ""
if [[ ! $confirm_reply =~ ^[Yy]$ ]]; then
	print_info "Setup cancelled."
	exit 0
fi

echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD}  Running setup...${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

if [ "$THEME_FOLDER" = "current" ]; then
	cd "$SCRIPT_DIR"
	IN_PLACE=true
else
	print_info "Copying starter theme to target folder..."
	copy_starter_to_target "$SCRIPT_DIR" "$THEME_FOLDER"
	print_success "Starter theme copied"
	cd "$THEME_FOLDER"
	IN_PLACE=false
fi

apply_theme_transforms "$CLIENT_TITLE" "$THEME_SLUG" "$PACKAGE_NAME"
rename_workspace_file "$THEME_SLUG"
install_dependencies

if [ "$IN_PLACE" = true ]; then
	rename_theme_folder_if_needed "$THEME_SLUG"
fi

echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
print_success "Setup complete!"
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo ""
print_info "Next steps:"
if [ "$IN_PLACE" = false ]; then
	echo "  1. Open your new theme:   cd \"$THEME_FOLDER\""
	echo "  2. Initialise git:        git init && git add . && git commit -m 'Initial commit'"
else
	echo "  1. Start fresh git:       rm -rf .git && git init && git add . && git commit -m 'Initial commit'"
fi
echo "  3. Copy theme to WordPress:  wp-content/themes/${THEME_SLUG}/"
echo "  4. Activate theme in WordPress admin"
echo ""
print_info "Theme is ready for development!"
