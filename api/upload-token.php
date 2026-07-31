<?php
/**
 * upload-token.php — verifies upload API key, issues short-lived upload token
 *
 * Setup:
 *   - Set UPLOAD_API_KEY and UPLOAD_SIGNING_KEY in .user.ini / php.ini
 *     (see docs/plans/RUMAH_WEB_MIGRATION.md)
 *   - The API key must match the upload_api_key row in the Supabase
 *     admin_settings table (RLS-protected — only logged-in admins can read it)
 *
 * Usage:
 *   POST /api/upload-token.php
 *   Headers: X-Api-Key: <upload api key>
 *   → { "ok": true, "token": "<exp>.<nonce>.<sig>", "exp": <unix ts> }
 */
declare(strict_types=1);

// --- Config -------------------------------------------------------------
// Keys come from api/config.php (written at deploy time from GitHub
// secrets); env vars are kept as a fallback for local development.
$configFile = __DIR__ . '/config.php';
$config     = is_file($configFile) ? (require $configFile) : [];
$uploadApiKey  = getenv('UPLOAD_API_KEY') ?: ($config['uploadApiKey'] ?? '');
$signingKey    = getenv('UPLOAD_SIGNING_KEY') ?: ($config['signingKey'] ?? '');
$tokenTtl      = 600;                           // 10 minutes
$rateLimit     = 5;                             // max tokens per hour per IP
// ------------------------------------------------------------------------

header('Content-Type: application/json');

if ($uploadApiKey === false || $uploadApiKey === '' || $signingKey === false || $signingKey === '') {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Server misconfigured']);
    exit;
}

// 1) Auth: upload API key in X-Api-Key header (constant-time compare)
$provided = $_SERVER['HTTP_X_API_KEY'] ?? '';
if (!hash_equals($uploadApiKey, $provided)) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'error' => 'Unauthorized']);
    exit;
}

// 2) Rate limit: simple file-based counter per IP (one bucket per hour)
$ip   = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$hour = date('YmdH');
$file = sys_get_temp_dir() . '/upl_rt_' . md5($ip) . '_' . $hour;
$count = is_file($file) ? (int) file_get_contents($file) : 0;
if ($count >= $rateLimit) {
    http_response_code(429);
    echo json_encode(['ok' => false, 'error' => 'Rate limit exceeded']);
    exit;
}
file_put_contents($file, (string) ($count + 1));

// 3) Issue token: HMAC("upload:{exp}:{nonce}") — nonce marks it one-time use
$exp   = time() + $tokenTtl;
$nonce = bin2hex(random_bytes(16));
$sig   = hash_hmac('sha256', "upload:$exp:$nonce", $signingKey);

echo json_encode([
    'ok'    => true,
    'token' => "$exp.$nonce.$sig",
    'exp'   => $exp,
]);
