<?php
/**
 * Theme Functions
 *
 * This file contains theme functions and extras.
 *
 * @package   DiviFiveChild
 * @since     1.0.0
 */

if ( ! function_exists( 'mittnett_get_top_parent' ) ) {
	/**
	 * Get the top-level parent of a post.
	 *
	 * @param int $post_id The ID of the post.
	 * @return int The ID of the top-level parent post.
	 */
	function mittnett_get_top_parent( $post_id ) {
		$parent_id = wp_get_post_parent_id( $post_id );

		if ( 0 === $parent_id ) {
			return $post_id;
		} else {
			return mittnett_get_top_parent( $parent_id );
		}
	}
}
