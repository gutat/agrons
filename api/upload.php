<?php
/**
 * upload.php — accepts valid upload tokens, saves files to /uploads
 *
 * Setup:
 *   - Set UPLOAD_SIGNING_KEY in .user.ini / php.ini (same key as
 *     upload-token.php — see docs/plans/RUMAH_WEB_MIGRATION.md)
 *   - Create the uploads directory (public_html/uploads) with chmod 755
 *   - Add uploads/.htaccess hardening rules (no script execution, no listing)
 *
 * Usage:
 *   POST /api/upload.php
 *   Headers: X-Upload-Token: <token from upload-token.php>
 *   Body:    multipart/form-data (file, folder)
 *   → { "ok": true, "url": "https://domain/uploads/{folder}/{file}" }
 */
declare(strict_types=1);

// --- Config -------------------------------------------------------------
$signingKey  = getenv('UPLOAD_SIGNING_KEY'); // same key as upload-token.php
$uploadDir   = __DIR__ . '/../uploads';
$maxBytes    = 20 * 1024 * 1024;             // 20 MB
$allowedExt  = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'mp4', 'webm'];
$allowedMime = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'video/mp4', 'video/webm'];
// ------------------------------------------------------------------------

header('Content-Type: application/json');

if ($signingKey === false || $signingKey === '') {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Server misconfigured']);
    exit;
}

// 1) Verify custom token: "exp.nonce.sig"
$token = $_SERVER['HTTP_X_UPLOAD_TOKEN'] ?? '';
[$exp, $nonce, $sig] = array_pad(explode('.', $token, 3), 3, '');
$expected = hash_hmac('sha256', "upload:$exp:$nonce", $signingKey);
if (!hash_equals($expected, $sig)) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'error' => 'Invalid token']);
    exit;
}
if ((int) $exp < time()) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'error' => 'Token expired']);
    exit;
}
// One-time use: reject if nonce was already consumed
$usedFile = sys_get_temp_dir() . '/upl_used_' . $nonce;
if (is_file($usedFile)) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'error' => 'Token already used']);
    exit;
}
file_put_contents($usedFile, (string) time());

// 2) File checks — extension AND real MIME (spoof-proof)
if (empty($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'No file uploaded']);
    exit;
}
$file = $_FILES['file'];
if ($file['size'] > $maxBytes) {
    http_response_code(413);
    echo json_encode(['ok' => false, 'error' => 'File too large (max 20 MB)']);
    exit;
}
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (!in_array($ext, $allowedExt, true)) {
    http_response_code(415);
    echo json_encode(['ok' => false, 'error' => 'Unsupported file type']);
    exit;
}
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime  = $finfo ? finfo_file($finfo, $file['tmp_name']) : '';
if ($finfo) {
    finfo_close($finfo);
}
if (!in_array($mime, $allowedMime, true)) {
    http_response_code(415);
    echo json_encode(['ok' => false, 'error' => 'Unsupported file type']);
    exit;
}

// 3) Save: uploads/{folder}/{timestamp}-{safe-name}
$folder = preg_replace('/[^a-z0-9_-]/', '', $_POST['folder'] ?? 'misc') ?: 'misc';
$dir    = "$uploadDir/$folder";
if (!is_dir($dir)) {
    mkdir($dir, 0755, true);
}
$name = time() . '-' . preg_replace('/[^a-zA-Z0-9._-]/', '', basename($file['name']));
if (!move_uploaded_file($file['tmp_name'], "$dir/$name")) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Save failed']);
    exit;
}

$base = (isset($_SERVER['HTTPS']) ? 'https' : 'http') . "://{$_SERVER['HTTP_HOST']}";
echo json_encode(['ok' => true, 'url' => "$base/uploads/$folder/$name"]);
