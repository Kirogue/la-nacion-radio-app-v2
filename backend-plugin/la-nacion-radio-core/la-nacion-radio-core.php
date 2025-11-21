<?php
/**
 * Plugin Name: La Nación Radio Core
 * Plugin URI: https://lanacionradio.fm
 * Description: Plugin maestro para gestionar el contenido de la App Móvil (Programas, Empresas, Publicidad y APIs).
 * Version: 1.0.0
 * Author: La Nación Radio Dev Team
 * Author URI: https://lanacionradio.fm
 * License: GPL2
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly.
}

// Definir constantes
define('LNR_CORE_VERSION', '1.0.0');
define('LNR_CORE_PATH', plugin_dir_path(__FILE__));

/**
 * 1. Registrar Custom Post Types (CPT)
 * Crea las secciones en el admin de WordPress para gestionar Programas, Empresas y Anuncios.
 */
function lnr_register_cpts() {
    
    // --- CPT: Programas (Podcasts) ---
    register_post_type('lnr_program', array(
        'labels' => array(
            'name' => 'Programas de Radio',
            'singular_name' => 'Programa',
            'add_new' => 'Agregar Nuevo',
            'add_new_item' => 'Agregar Nuevo Programa',
            'edit_item' => 'Editar Programa',
            'all_items' => 'Todos los Programas'
        ),
        'public' => true,
        'has_archive' => true,
        'menu_icon' => 'dashicons-microphone',
        'supports' => array('title', 'editor', 'thumbnail', 'custom-fields'),
        'show_in_rest' => true, // Importante para la API
    ));

    // --- CPT: Empresas (Directorio) ---
    register_post_type('lnr_company', array(
        'labels' => array(
            'name' => 'Directorio Empresas',
            'singular_name' => 'Empresa',
            'add_new' => 'Agregar Empresa',
            'add_new_item' => 'Agregar Nueva Empresa',
            'edit_item' => 'Editar Empresa',
            'all_items' => 'Todas las Empresas'
        ),
        'public' => true,
        'has_archive' => true,
        'menu_icon' => 'dashicons-store',
        'supports' => array('title', 'thumbnail', 'custom-fields'),
        'show_in_rest' => true,
    ));

    // --- CPT: Publicidad (Ads) ---
    register_post_type('lnr_ad', array(
        'labels' => array(
            'name' => 'Publicidad App',
            'singular_name' => 'Anuncio',
            'add_new' => 'Agregar Anuncio',
            'add_new_item' => 'Agregar Nuevo Anuncio',
            'edit_item' => 'Editar Anuncio',
            'all_items' => 'Todos los Anuncios'
        ),
        'public' => true,
        'menu_icon' => 'dashicons-megaphone',
        'supports' => array('title', 'thumbnail', 'custom-fields'),
        'show_in_rest' => true,
    ));
}
add_action('init', 'lnr_register_cpts');

/**
 * 2. Registrar Endpoints API REST Personalizados
 * Exponer los datos en la estructura exacta que espera la App Flutter (/wp-json/api/...).
 */
function lnr_register_api_routes() {
    // Namespace: api
    
    // GET /api/programas
    register_rest_route('api', '/programas', array(
        'methods' => 'GET',
        'callback' => 'lnr_get_programas',
        'permission_callback' => '__return_true',
    ));

    // GET /api/companies
    register_rest_route('api', '/companies', array(
        'methods' => 'GET',
        'callback' => 'lnr_get_companies',
        'permission_callback' => '__return_true',
    ));

    // GET /api/ads
    register_rest_route('api', '/ads', array(
        'methods' => 'GET',
        'callback' => 'lnr_get_ads',
        'permission_callback' => '__return_true',
    ));
}
add_action('rest_api_init', 'lnr_register_api_routes');

// --- Callbacks de la API ---

function lnr_get_programas($request) {
    // Lógica para obtener programas. 
    // En un caso real, aquí harías WP_Query a 'lnr_program' y formatearías el JSON.
    // Este es un ejemplo básico compatible con ACF si se usa.
    
    $args = array(
        'post_type' => 'lnr_program',
        'posts_per_page' => -1,
        'post_status' => 'publish'
    );
    $posts = get_posts($args);
    $data = array();

    foreach ($posts as $post) {
        $data[] = lnr_format_post_data($post);
    }
    return $data;
}

function lnr_get_companies($request) {
    $args = array(
        'post_type' => 'lnr_company',
        'posts_per_page' => -1,
        'post_status' => 'publish'
    );
    $posts = get_posts($args);
    $data = array();

    foreach ($posts as $post) {
        $data[] = lnr_format_post_data($post);
    }
    return $data;
}

function lnr_get_ads($request) {
    $args = array(
        'post_type' => 'lnr_ad',
        'posts_per_page' => -1,
        'post_status' => 'publish'
    );
    $posts = get_posts($args);
    $data = array();

    foreach ($posts as $post) {
        $data[] = lnr_format_post_data($post);
    }
    return $data;
}

/**
 * Función auxiliar para formatear la respuesta JSON
 * Incluye campos ACF si el plugin ACF está activo.
 */
function lnr_format_post_data($post) {
    $featured_img_url = get_the_post_thumbnail_url($post->ID, 'full');
    
    $item = array(
        'id' => $post->ID,
        'date' => $post->post_date,
        'title' => array('rendered' => $post->post_title),
        'content' => array('rendered' => $post->post_content),
        'featured_media_url' => $featured_img_url,
        'acf' => array() // Placeholder por si no hay ACF
    );

    // Integración con Advanced Custom Fields (ACF)
    if (function_exists('get_fields')) {
        $acf_fields = get_fields($post->ID);
        if ($acf_fields) {
            $item['acf'] = $acf_fields;
        }
    }

    return $item;
}


