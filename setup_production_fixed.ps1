# setup_production.ps1 - Production System Setup Script
# Encoding: UTF-8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GYG Production System Setup" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# 1. Update .env with required variables
Write-Host "`nUpdating .env file..." -ForegroundColor Yellow

$env_content = @"
# GYG Login Credentials
GYG_EMAIL=sunny.operations26@gmail.com
GYG_PASSWORD=YOUR_PASSWORD_HERE
GYG_2FA_SECRET=YOUR_2FA_SECRET_HERE

# Airtable Configuration
AIRTABLE_API_KEY=YOUR_AIRTABLE_API_KEY_HERE
AIRTABLE_BASE_ID=YOUR_BASE_ID_HERE
AIRTABLE_TABLE=Bookings

# DeepSeek API (Optional)
DEEPSEEK_API_KEY=YOUR_DEEPSEEK_API_KEY_HERE

# Database Configuration
DATABASE_PATH=./bookings.db
LOG_FILE=gyg_production.log

# Sync Settings
SYNC_INTERVAL_MINUTES=5
AUTO_SYNC_ENABLED=true
"@

# Create config directory if not exists
if (-Not (Test-Path "config")) {
    New-Item -ItemType Directory -Path "config" -Force | Out-Null
    Write-Host "Created config directory" -ForegroundColor Green
}

# Save .env file
$env_content | Out-File -FilePath "config\.env" -Encoding UTF8 -Force
Write-Host "Successfully created .env file" -ForegroundColor Green

# 2. Install required Python libraries
Write-Host "`nInstalling Python libraries..." -ForegroundColor Yellow

# Activate virtual environment
& ".\venv\Scripts\Activate.ps1"

$libraries = @(
    "playwright",
    "python-dotenv",
    "pyotp",
    "requests",
    "airtable",
    "airtable-python-wrapper"
)

foreach ($lib in $libraries) {
    Write-Host "Installing $lib..." -ForegroundColor Cyan
    pip install $lib --quiet 2>&1 | Out-Null
    Write-Host "Installed $lib" -ForegroundColor Green
}

# 3. Install Playwright Chromium
Write-Host "`nInstalling Playwright Chromium..." -ForegroundColor Yellow
playwright install chromium 2>&1 | Out-Null
Write-Host "Playwright Chromium installed" -ForegroundColor Green

# 4. Create necessary directories
Write-Host "`nCreating directories..." -ForegroundColor Yellow

$folders = @("logs", "data", "backups")
foreach ($folder in $folders) {
    if (-Not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "Created $folder directory" -ForegroundColor Green
    }
}

# 5. Create requirements.txt
Write-Host "`nCreating requirements.txt..." -ForegroundColor Yellow

$requirements = @"
playwright==1.40.0
python-dotenv==1.0.0
pyotp==2.9.0
requests==2.31.0
airtable==2.0.1
airtable-python-wrapper==0.15.3
"@

$requirements | Out-File -FilePath "requirements.txt" -Encoding UTF8 -Force
Write-Host "Created requirements.txt" -ForegroundColor Green

# 6. Display setup completion
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Edit config\.env with your credentials:" -ForegroundColor Cyan
Write-Host "   - GYG_EMAIL: Your email" -ForegroundColor Gray
Write-Host "   - GYG_PASSWORD: Your password" -ForegroundColor Gray
Write-Host "   - GYG_2FA_SECRET: Your 2FA secret" -ForegroundColor Gray
Write-Host "   - AIRTABLE_API_KEY: Your Airtable API key" -ForegroundColor Gray
Write-Host "   - AIRTABLE_BASE_ID: Your Base ID" -ForegroundColor Gray

Write-Host "`n2. Run the production system:" -ForegroundColor Cyan
Write-Host "   python main_production.py" -ForegroundColor White

Write-Host "`n3. View logs:" -ForegroundColor Cyan
Write-Host "   Get-Content gyg_production.log -Tail 50" -ForegroundColor White

Write-Host "`n4. Check database:" -ForegroundColor Cyan
Write-Host "   sqlite3 bookings.db" -ForegroundColor White

Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "   - bookings.db: Local database" -ForegroundColor Gray
Write-Host "   - gyg_production.log: System logs" -ForegroundColor Gray
Write-Host "   - backups/: Backup directory" -ForegroundColor Gray

Write-Host "`nSystem is ready for production!" -ForegroundColor Green
