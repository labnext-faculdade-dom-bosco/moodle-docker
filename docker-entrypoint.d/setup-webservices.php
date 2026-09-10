<?php
// Habilita o serviço "Moodle mobile web service" e garante um token permanente para o usuário admin, 
// para que seja possível trabalhar com a API REST do Moodle.

define('CLI_SCRIPT', true);
require('/var/www/html/config.php');
require_once($CFG->libdir . '/externallib.php');

global $DB;

$adminuser = get_admin();
if (!$adminuser) {
    cli_error('Usuário admin não encontrado.');
}

\core\cron::setup_user($adminuser);

$service = $DB->get_record('external_services', ['shortname' => MOODLE_OFFICIAL_MOBILE_SERVICE]);
if (!$service) {
    cli_error('Serviço "moodle_mobile_app" não encontrado.');
}

if (!$service->enabled) {
    $service->enabled = 1;
    $DB->update_record('external_services', $service);
    mtrace('Serviço "Moodle mobile web service" habilitado.');
}

$token = $DB->get_record('external_tokens', [
    'userid' => $adminuser->id,
    'externalserviceid' => $service->id,
    'tokentype' => EXTERNAL_TOKEN_PERMANENT,
]);

if (!$token) {
    $context = \context_system::instance();
    $tokenvalue = \core_external\util::generate_token(
        EXTERNAL_TOKEN_PERMANENT,
        $service,
        $adminuser->id,
        $context,
        0,
        '',
        'Token gerado automaticamente no start do container'
    );
} else {
    $tokenvalue = $token->token;
}

file_put_contents('/var/www/moodledata/webservice_token.txt', $tokenvalue . "\n");
mtrace("Token do admin para a API REST: {$tokenvalue}");
