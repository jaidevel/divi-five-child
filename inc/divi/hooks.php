<?php
/**
 * Divi Hooks
 *
 * This file contains Divi related actions, filters, and overrides.
 *
 * @package   DiviNordian
 * @since     1.0.0
 */

add_action(
	'template_redirect',
	function () {
		if ( is_singular( 'product' ) || is_shop() || is_product_category() || is_product_tag() ) {
			remove_action( 'et_sidebar', 'et_get_sidebar' );
		}
	},
	9
);
