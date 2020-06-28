<?php

// A special handler.

// Verify the request came through CloudFront
if ($_SERVER['HTTP_X_CFSHAREDSECRET'] != $_ENV['CF_SHARED_SECERT']) {
  http_response_code(403);
  die('Proxy authentication failed');
}

// All requests through API Gateway are HTTPS.
$_SERVER['HTTPS'] = 'on';
$_SERVER['DOCUMENT_ROOT'] = "/mnt/root";
chdir("/mnt/root");

$extension_map = array(
  "css" => "text/css",
  "js" => "application/javascript",
  "png" => "image/png",
  "jpeg" => "image/jpeg",
  "jpg" => "image/jpeg",
  "svg" => "image/svg+xml"
);

$request_uri = explode("?", $_SERVER['REQUEST_URI']);
$local_file_path = $_SERVER['DOCUMENT_ROOT'] . $request_uri[0];

if ( $local_file_path == __FILE__ ) {
  http_response_code(400);
  echo 'Sorry';
  exit();
}

$split = explode(".", $local_file_path);
$extension = end($split);
$mapped_type = $extension_map[$extension];

if ( $mapped_type && file_exists( $local_file_path ) ) {
  header("Content-Type: {$mapped_type}");
  readfile($local_file_path);

} elseif ( $extension == "php" && file_exists( $local_file_path ) ) {
  header("X-ExecFile: {$local_file_path}");
  require( $local_file_path );

} elseif ( substr($local_file_path, -1) == "/" && file_exists( $local_file_path . "index.php" ) ) {
  $exec_file_path = $local_file_path . "index.php";
  header("X-ExecFile: {$exec_file_path}");
  require( $exec_file_path );

} else {
  $exec_file_path = getcwd() . '/index.php';
  header("X-ExecFile: {$exec_file_path}");
  require( $exec_file_path );
}
