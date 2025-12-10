<?php
/**
 * Theme Setup Functions
 *
 * Handles enqueuing of styles and scripts for the child theme.
 *
 * @package   DiviFiveChild
 * @since     1.0.0
 */

// Theme setup.
add_action(
	'after_setup_theme',
	function () {
		// Enable theme as hybrid block theme.
		add_theme_support( 'block-template-parts' );
		add_theme_support( 'block-templates' );
		add_theme_support( 'wp-block-styles' );
	}
);

// Enqueue styles and scripts.
if ( ! function_exists( 'dt_enqueue_styles' ) ) {
	/**
	 * Enqueue styles and scripts for the theme.
	 */
	function dt_enqueue_styles() {
		$parenthandle = 'divi-style-parent'; // This is 'divi-style' for the Divi 5 theme.
		$theme        = wp_get_theme();

		wp_enqueue_style(
			$parenthandle,
			get_template_directory_uri() . '/style.css',
			array(), // If the parent theme code has a dependency, copy it here.
			$theme->parent() ? $theme->parent()->get( 'Version' ) : null
		);

		wp_enqueue_style(
			'child-style',
			get_stylesheet_uri(),
			array( $parenthandle ),
			$theme->get( 'Version' )
		);

		wp_enqueue_script(
			'main',
			get_stylesheet_directory_uri() . '/main.js',
			array( '' ), // jquery.
			$theme->get( 'Version' ),
			true
		);
	}
}
add_action( 'wp_enqueue_scripts', 'dt_enqueue_styles' );