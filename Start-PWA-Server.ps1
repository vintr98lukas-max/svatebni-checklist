$ErrorActionPreference = 'Stop'

$port = 8080
$root = $PSScriptRoot
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)
$listener.Start()

Write-Host ""
Write-Host "Svatební checklist PWA běží na:" -ForegroundColor Cyan
Write-Host "  http://localhost:$port/" -ForegroundColor Yellow
Write-Host ""
Write-Host "Pro otevření na iPhonu použijte IP adresu tohoto počítače v lokální síti, například:" -ForegroundColor Cyan
Write-Host "  http://192.168.0.25:$port/" -ForegroundColor Yellow
Write-Host ""
Write-Host "Server ukončíte klávesami Ctrl+C." -ForegroundColor Cyan
Write-Host ""

$contentTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".js" = "application/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".png" = "image/png"
  ".svg" = "image/svg+xml; charset=utf-8"
  ".ico" = "image/x-icon"
}

function Get-ResponseBytes {
  param(
    [int]$StatusCode,
    [string]$ContentType,
    [byte[]]$Body
  )

  $statusText = switch ($StatusCode) {
    200 { 'OK' }
    404 { 'Not Found' }
    default { 'OK' }
  }

  $headerText = "HTTP/1.1 $StatusCode $statusText`r`nContent-Type: $ContentType`r`nContent-Length: $($Body.Length)`r`nConnection: close`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headerText)
  $response = New-Object byte[] ($headerBytes.Length + $Body.Length)
  [Array]::Copy($headerBytes, 0, $response, 0, $headerBytes.Length)
  [Array]::Copy($Body, 0, $response, $headerBytes.Length, $Body.Length)
  return $response
}

try {
  while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
      $stream = $client.GetStream()
      $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()
      if ([string]::IsNullOrWhiteSpace($requestLine)) {
        $client.Close()
        continue
      }

      while ($reader.Peek() -ge 0) {
        $line = $reader.ReadLine()
        if ([string]::IsNullOrEmpty($line)) { break }
      }

      $parts = $requestLine.Split(' ')
      $path = if ($parts.Length -ge 2) { $parts[1] } else { '/' }
      if ($path -eq '/') { $path = '/index.html' }
      $path = $path.Split('?')[0]
      $safePath = $path.TrimStart('/').Replace('/', '\')
      $filePath = Join-Path $root $safePath

      if ((Test-Path $filePath) -and -not (Get-Item $filePath).PSIsContainer) {
        $extension = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
        $contentType = if ($contentTypes.ContainsKey($extension)) { $contentTypes[$extension] } else { 'application/octet-stream' }
        $body = [System.IO.File]::ReadAllBytes($filePath)
        $responseBytes = Get-ResponseBytes -StatusCode 200 -ContentType $contentType -Body $body
      }
      else {
        $body = [System.Text.Encoding]::UTF8.GetBytes('404 - Soubor nebyl nalezen.')
        $responseBytes = Get-ResponseBytes -StatusCode 404 -ContentType 'text/plain; charset=utf-8' -Body $body
      }

      $stream.Write($responseBytes, 0, $responseBytes.Length)
      $stream.Flush()
    }
    finally {
      if ($reader) { $reader.Dispose() }
      if ($stream) { $stream.Dispose() }
      $client.Close()
    }
  }
}
finally {
  $listener.Stop()
}
