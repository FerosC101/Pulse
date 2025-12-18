# PowerShell script to set CORS for Firebase Storage
# This uses the Firebase Storage REST API

Write-Host "Setting CORS for Firebase Storage bucket..." -ForegroundColor Cyan

# Get Firebase project ID
$projectId = "app-dev-4768b"
$bucketName = "$projectId.firebasestorage.app"

Write-Host ""
Write-Host "To set CORS for your Firebase Storage bucket, follow these steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Install Google Cloud SDK from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Green
Write-Host ""
Write-Host "2. After installation, run:" -ForegroundColor Green
Write-Host "   gcloud auth login" -ForegroundColor White
Write-Host ""
Write-Host "3. Then run:" -ForegroundColor Green
Write-Host "   gsutil cors set cors.json gs://$bucketName" -ForegroundColor White
Write-Host ""
Write-Host "ALTERNATIVE METHOD (Using Google Cloud Console):" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to: https://console.cloud.google.com/storage/browser?project=$projectId" -ForegroundColor Green
Write-Host ""
Write-Host "2. Click on your bucket: $bucketName" -ForegroundColor Green
Write-Host ""
Write-Host "3. Click the 'Permissions' tab" -ForegroundColor Green
Write-Host ""
Write-Host "4. Under 'CORS configuration', click 'Edit CORS Configuration'" -ForegroundColor Green
Write-Host ""
Write-Host "5. Paste this JSON:" -ForegroundColor Green
Write-Host '[' -ForegroundColor White
Write-Host '  {' -ForegroundColor White
Write-Host '    "origin": ["*"],' -ForegroundColor White
Write-Host '    "method": ["GET", "HEAD", "PUT", "POST", "DELETE", "OPTIONS"],' -ForegroundColor White
Write-Host '    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "Range", "Authorization"],' -ForegroundColor White
Write-Host '    "maxAgeSeconds": 3600' -ForegroundColor White
Write-Host '  }' -ForegroundColor White
Write-Host ']' -ForegroundColor White
Write-Host ""
Write-Host "6. Click 'Save'" -ForegroundColor Green
Write-Host ""
Write-Host "After completing either method, your 3D models should load!" -ForegroundColor Cyan
Write-Host ""
