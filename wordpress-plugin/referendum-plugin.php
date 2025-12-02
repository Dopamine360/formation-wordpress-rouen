<?php
/**
 * Plugin Name: Référendum National
 * Description: Gestion des référendums en ligne via un service externe sécurisé.
 * Version: 1.0.0
 * Author: IA
 */

if (!defined('ABSPATH')) { exit; }

class FRReferendumPlugin {
    const OPTION_API_URL = 'fr_ref_api_url';
    const OPTION_API_KEY = 'fr_ref_api_key';
    const NONCE_VOTE = 'fr_ref_vote_nonce';

    public function __construct() {
        add_action('admin_menu', [$this, 'register_menu']);
        add_action('admin_init', [$this, 'register_settings']);
        add_shortcode('referendums_vote', [$this, 'shortcode_display']);
        add_action('wp_enqueue_scripts', [$this, 'enqueue_scripts']);
        add_action('wp_ajax_submit_referendum_vote', [$this, 'handle_vote_ajax']);
        add_action('user_register', [$this, 'mark_email_unverified']);
        add_action('init', [$this, 'maybe_validate_email']);
    }

    public function register_menu() {
        add_menu_page('Référendums', 'Référendums', 'manage_options', 'fr-referendums', [$this, 'render_new_referendum']);
        add_submenu_page('fr-referendums', 'Réglages', 'Réglages', 'manage_options', 'fr-referendums-settings', [$this, 'render_settings']);
    }

    public function register_settings() {
        register_setting('fr_ref_options', self::OPTION_API_URL);
        register_setting('fr_ref_options', self::OPTION_API_KEY);
    }

    public function render_settings() {
        if (!current_user_can('manage_options')) return;
        ?>
        <div class="wrap">
            <h1>Réglages API</h1>
            <form method="post" action="options.php">
                <?php settings_fields('fr_ref_options'); do_settings_sections('fr_ref_options'); ?>
                <table class="form-table">
                    <tr><th scope="row">URL API</th><td><input type="text" name="<?php echo esc_attr(self::OPTION_API_URL); ?>" value="<?php echo esc_attr(get_option(self::OPTION_API_URL)); ?>" class="regular-text" /></td></tr>
                    <tr><th scope="row">Clé API admin</th><td><input type="text" name="<?php echo esc_attr(self::OPTION_API_KEY); ?>" value="<?php echo esc_attr(get_option(self::OPTION_API_KEY)); ?>" class="regular-text" /></td></tr>
                </table>
                <?php submit_button(); ?>
            </form>
        </div>
        <?php
    }

    public function render_new_referendum() {
        if (!current_user_can('manage_options')) return;
        $message = '';
        if (isset($_POST['fr_ref_new_ref_nonce']) && wp_verify_nonce($_POST['fr_ref_new_ref_nonce'], 'fr_ref_new_ref')) {
            $api_url = rtrim(get_option(self::OPTION_API_URL), '/');
            $api_key = get_option(self::OPTION_API_KEY);
            $choices_raw = explode("\n", sanitize_textarea_field($_POST['choices'] ?? ''));
            $choices = array_values(array_filter(array_map('trim', $choices_raw)));
            $payload = [
                'title' => sanitize_text_field($_POST['title'] ?? ''),
                'description' => sanitize_textarea_field($_POST['description'] ?? ''),
                'start_at' => sanitize_text_field($_POST['start_at'] ?? ''),
                'end_at' => sanitize_text_field($_POST['end_at'] ?? ''),
                'choices' => array_map(function($label, $index){ return ['label'=>$label, 'sort_order'=>$index]; }, $choices, array_keys($choices))
            ];
            $response = wp_remote_post($api_url . '/admin/referendums', [
                'headers' => ['Content-Type' => 'application/json', 'x-api-key' => $api_key],
                'body' => wp_json_encode($payload),
                'timeout' => 15
            ]);
            if (is_wp_error($response)) {
                $message = '<div class="notice notice-error"><p>Erreur API: '. esc_html($response->get_error_message()) .'</p></div>';
            } else {
                $code = wp_remote_retrieve_response_code($response);
                if ($code === 201) {
                    $message = '<div class="notice notice-success"><p>Référendum créé.</p></div>';
                } else {
                    $message = '<div class="notice notice-error"><p>Echec: '. esc_html(wp_remote_retrieve_body($response)) .'</p></div>';
                }
            }
        }
        ?>
        <div class="wrap">
            <h1>Nouveau référendum</h1>
            <?php echo $message; ?>
            <form method="post">
                <?php wp_nonce_field('fr_ref_new_ref', 'fr_ref_new_ref_nonce'); ?>
                <table class="form-table">
                    <tr><th>Titre</th><td><input type="text" name="title" class="regular-text" required></td></tr>
                    <tr><th>Description</th><td><textarea name="description" class="large-text" required></textarea></td></tr>
                    <tr><th>Début</th><td><input type="datetime-local" name="start_at" required></td></tr>
                    <tr><th>Fin</th><td><input type="datetime-local" name="end_at" required></td></tr>
                    <tr><th>Options (une par ligne)</th><td><textarea name="choices" class="large-text" rows="5" required></textarea></td></tr>
                </table>
                <?php submit_button('Créer'); ?>
            </form>
        </div>
        <?php
    }

    public function enqueue_scripts() {
        wp_enqueue_script('fr-ref-vote', plugin_dir_url(__FILE__) . 'vote.js', ['jquery'], '1.0', true);
        wp_localize_script('fr-ref-vote', 'frRefData', [
            'ajaxUrl' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce(self::NONCE_VOTE)
        ]);
    }

    public function shortcode_display() {
        if (!is_user_logged_in()) {
            return '<p>Merci de vous connecter pour voter.</p>';
        }
        $user_id = get_current_user_id();
        if (get_user_meta($user_id, 'email_verified', true) != 1) {
            return '<p>Vous devez d\'abord valider votre adresse e-mail.</p>';
        }
        $api_url = rtrim(get_option(self::OPTION_API_URL), '/');
        $token = $this->generate_user_jwt($user_id);
        $refs = wp_remote_get($api_url . '/referendums');
        $votes = wp_remote_get($api_url . '/me/votes', [
            'headers' => ['Authorization' => 'Bearer ' . $token]
        ]);
        $refs_data = is_wp_error($refs) ? [] : json_decode(wp_remote_retrieve_body($refs), true);
        $votes_data = is_wp_error($votes) ? [] : json_decode(wp_remote_retrieve_body($votes), true);
        ob_start();
        ?>
        <div id="fr-ref-list">
            <?php foreach ($refs_data as $ref): ?>
                <div class="fr-ref-item">
                    <h3><?php echo esc_html($ref['title']); ?></h3>
                    <p><?php echo esc_html($ref['description']); ?></p>
                    <?php
                    $already = array_filter($votes_data, function($v) use ($ref){ return intval($v['referendum_id']) === intval($ref['id']);});
                    if ($already):
                        $choice = array_values($already)[0];
                        echo '<p>Vous avez déjà voté: '. esc_html($choice['label']) .'</p>';
                    else:
                    ?>
                    <form class="fr-ref-form" data-referendum="<?php echo esc_attr($ref['id']); ?>">
                        <?php foreach ($ref['choices'] as $choice): ?>
                            <label><input type="radio" name="choice" value="<?php echo esc_attr($choice['id']); ?>"> <?php echo esc_html($choice['label']); ?></label><br>
                        <?php endforeach; ?>
                        <button type="submit">Voter</button>
                    </form>
                    <?php endif; ?>
                </div>
            <?php endforeach; ?>
        </div>
        <?php
        return ob_get_clean();
    }

    public function handle_vote_ajax() {
        check_ajax_referer(self::NONCE_VOTE, 'nonce');
        if (!is_user_logged_in()) wp_send_json_error('Non connecté', 401);
        $user_id = get_current_user_id();
        $choice_id = intval($_POST['choice_id'] ?? 0);
        $referendum_id = intval($_POST['referendum_id'] ?? 0);
        $api_url = rtrim(get_option(self::OPTION_API_URL), '/');
        $token = $this->generate_user_jwt($user_id);
        $response = wp_remote_post($api_url . '/votes', [
            'headers' => ['Content-Type' => 'application/json', 'Authorization' => 'Bearer ' . $token],
            'body' => wp_json_encode([
                'choice_id' => $choice_id,
                'referendum_id' => $referendum_id,
                'wp_user_id' => $user_id
            ])
        ]);
        if (is_wp_error($response)) {
            wp_send_json_error($response->get_error_message());
        }
        $code = wp_remote_retrieve_response_code($response);
        if ($code === 201 || $code === 200) {
            wp_send_json_success(json_decode(wp_remote_retrieve_body($response), true));
        }
        wp_send_json_error(wp_remote_retrieve_body($response), $code);
    }

    private function generate_user_jwt($user_id) {
        $secret = get_option('jwt_auth_secret_key', AUTH_KEY);
        $payload = [
            'sub' => $user_id,
            'iat' => time(),
            'exp' => time() + 7*24*3600
        ];
        return $this->jwt_encode($payload, $secret);
    }

    private function jwt_encode($payload, $secret) {
        $header = base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
        $body = base64_encode(json_encode($payload));
        $signature = rtrim(strtr(base64_encode(hash_hmac('sha256', "$header.$body", $secret, true)), '+/', '-_'), '=');
        return "$header.$body.$signature";
    }

    public function mark_email_unverified($user_id) {
        update_user_meta($user_id, 'email_verified', 0);
        $token = wp_generate_password(20, false);
        update_user_meta($user_id, 'email_verification_token', $token);
        $link = add_query_arg(['verify_email' => $user_id, 'token' => $token], home_url('/'));
        wp_mail(get_userdata($user_id)->user_email, 'Validez votre email', 'Cliquez ici: ' . esc_url($link));
    }

    public function maybe_validate_email() {
        if (isset($_GET['verify_email'], $_GET['token'])) {
            $user_id = intval($_GET['verify_email']);
            $token = sanitize_text_field($_GET['token']);
            $saved = get_user_meta($user_id, 'email_verification_token', true);
            if ($saved && hash_equals($saved, $token)) {
                update_user_meta($user_id, 'email_verified', 1);
                delete_user_meta($user_id, 'email_verification_token');
                wp_safe_redirect(home_url('/?email=verified'));
                exit;
            }
        }
    }
}

new FRReferendumPlugin();
