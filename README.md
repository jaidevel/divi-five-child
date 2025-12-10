# Divi 5 Child Theme Starter

A bare-bones, modern starter child theme for Divi 5, built for rapid development and customization. This theme is ideal for agencies and developers who want a clean, maintainable foundation for WordPress projects using the Divi 5 theme.

## Features

- **Modern Build Tools**: Uses [Vite](https://vitejs.dev/) for fast JavaScript bundling and [Sass](https://sass-lang.com/) for advanced CSS authoring.
- **Organized Structure**: Clean separation of JS, SCSS, and PHP for easy maintenance.
- **Custom Post Types & Shortcodes**: Extendable via `/inc/theme/post-types.php` and `/inc/theme/shortcodes.php`.
- **Divi Integration**: Dedicated hooks file for Divi-specific functionality (`/inc/divi/hooks.php`).
- **WooCommerce Support**: Ready for WooCommerce customizations (`/inc/woocommerce/`).
- **Easy Asset Management**: Scripts and styles are enqueued properly for WordPress best practices.
- **Ready for GitHub**: Includes sensible `.gitignore` and code style settings (see `phpcs.xml`).

## Getting Started

### Prerequisites
- Node.js (v18+ recommended)
- npm
- WordPress with Divi 5 installed
- (Optional, for PHP code style) Composer with [WordPress Coding Standards](https://github.com/WordPress/WordPress-Coding-Standards)

### Quick Setup (Automated)

For new projects, use the automated setup script:

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/divi-five-child.git
   cd divi-five-child
   ```

2. **Run the setup script**
   ```bash
   ./setup.sh client-name
   ```
   Replace `client-name` with your client's name (e.g., `acme-corp`). This will:
   - Rename the theme folder to `divi-client-name`
   - Update theme information in all files
   - Update package name to `divi-client-name`
   - Rename workspace file
   - Install npm and composer dependencies
   - Prepare the theme for development

3. **Initialize git (optional)**
   ```bash
   rm -rf .git
   git init
   git add .
   git commit -m "Initial commit for Divi Client Name theme"
   ```

4. **Activate the theme**
   - Copy the theme folder to your WordPress `wp-content/themes/` directory
   - Activate the theme in the WordPress admin

### Manual Installation

If you prefer manual setup or want to develop the starter theme itself:

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/divi-five-child.git
   cd divi-five-child
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **(Optional) Install PHP CodeSniffer & WordPress Coding Standards**
   ```bash
   composer install
   ```
   This will install [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) and [WordPress Coding Standards](https://github.com/WordPress/WordPress-Coding-Standards) for code linting. See `composer.json` for details.

4. **Start development**
   ```bash
   npm run dev
   ```
   - JS and SCSS will be watched and compiled automatically.

5. **Build for production**
   ```bash
   npm run build
   ```
   - Outputs minified assets for deployment.

6. **Activate the theme**
   - Copy the theme folder to your WordPress `wp-content/themes/` directory (if not already there).
   - Activate "Divi 5 Child Theme" in the WordPress admin.

## File Structure

```
composer.json                # (Optional) PHP code style dependencies
├── setup.sh                 # Automated setup script for new projects
├── functions.php            # Theme setup, includes all functionality files
├── main.js                 # Compiled JS entry (from src/js/)
├── style.css               # Compiled CSS (from src/scss/style.scss)
├── single-post-type.php    # Custom post type template
├── src/
│   ├── js/                 # JS source files
│   │   ├── main.js         # Main JS entry point
│   │   └── modules/        # JS modules
│   └── scss/               # SCSS source files
│       ├── style.scss      # Main SCSS file
│       ├── _variables.scss # SCSS variables
│       └── _nav.scss        # Navigation styles
├── inc/
│   ├── theme/              # Theme-specific functionality
│   │   ├── setup.php       # Theme setup and asset enqueuing
│   │   ├── post-types.php # Custom post types
│   │   ├── shortcodes.php # Custom shortcodes
│   │   └── theme-functions.php # Theme helper functions
│   ├── divi/               # Divi-specific functionality
│   │   └── hooks.php       # Divi hooks and filters
│   └── woocommerce/        # WooCommerce customizations
├── package.json            # NPM scripts and dependencies
├── vite.config.js          # Vite configuration
└── phpcs.xml               # PHP code style rules
```

## NPM Scripts

- `npm run dev` — Start development server (JS + SCSS watch)
- `npm run build` — Build production assets
- `npm run dev:js` — JS only (Vite dev)
- `npm run dev:scss` — SCSS only (Sass watch)
- `npm run build:js` — JS only (Vite build)
- `npm run build:scss` — SCSS only (Sass build)

## Customization
- Add new JS modules in `src/js/modules/` and import them in `src/js/main.js`.
- Add new SCSS partials in `src/scss/` and import them in `style.scss`.
- Extend PHP functionality:
  - Theme functions: `inc/theme/theme-functions.php`
  - Custom post types: `inc/theme/post-types.php`
  - Shortcodes: `inc/theme/shortcodes.php`
  - Divi hooks: `inc/divi/hooks.php`
  - WooCommerce: `inc/woocommerce/`
  - Or add new files and include them in `functions.php` as needed.

## Contributing
Pull requests and suggestions are welcome! Please follow the code style guidelines and test your changes.

### PHP Code Style
If you want to use WordPress Coding Standards for PHP, install Composer dependencies and use the provided `phpcs.xml`:

```bash
composer install
./vendor/bin/phpcs
```

Or use the auto-fixer:
```bash
./vendor/bin/phpcbf
```

You can also configure your editor to use `phpcs.xml` on save.

## License
[MIT](LICENSE)

---

*A starter theme for Divi 5 projects*
