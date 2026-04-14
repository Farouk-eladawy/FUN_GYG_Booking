# create_improved.ps1
# Script لإنشاء paste_improved.py مع التحسينات الكاملة

# نسخ احتياطي
if (Test-Path "paste.py") {
    Copy-Item "paste.py" "paste_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').py"
    Write-Host "تم إنشاء نسخة احتياطية" -ForegroundColor Green
}

# قراءة الملف الأصلي
$originalCode = Get-Content "paste.txt" -Raw -Encoding UTF8

# استبدال دالة _get_total_pages المحسّنة
$improvedGetTotalPages = @'
    async def _get_total_pages(self) -> int:
        """Get total pages with improved detection"""
        try:
            # 1) Try numbered page buttons
            page_buttons = await self.page.query_selector_all(
                'button[aria-label*="Page"], button.p-paginator-page'
            )
            page_numbers = []
            for btn in page_buttons:
                text = await btn.text_content()
                if text and text.strip().isdigit():
                    page_numbers.append(int(text.strip()))
            if page_numbers:
                self.logger.info(f"Found {max(page_numbers)} pages from buttons")
                return max(page_numbers)
            
            # 2) Try "Page X of Y" text
            page_info = await self.page.query_selector('text=/Page\\s+\\d+\\s+of\\s+\\d+/')
            if page_info:
                text = await page_info.text_content()
                match = re.search(r'Page\s+\d+\s+of\s+(\d+)', text)
                if match:
                    total = int(match.group(1))
                    self.logger.info(f"Found {total} pages from 'Page X of Y'")
                    return total
            
            # 3) Calculate from total bookings
            total_text = await self.page.query_selector('text=/Total.*\\d+.*bookings/')
            if total_text:
                text = await total_text.text_content()
                match = re.search(r'Total.*?(\\d+).*bookings', text)
                if match:
                    total_bookings = int(match.group(1))
                    try:
                        cards = await self.page.query_selector_all('[data-testid="booking-card"]')
                        per_page = len(cards) or 10
                    except Exception:
                        per_page = 10
                    total_pages = (total_bookings + per_page - 1) // per_page
                    self.logger.info(f"Calculated {total_pages} pages from {total_bookings} bookings")
                    return total_pages
        except Exception as e:
            self.logger.warning(f"Error getting total pages: {e}")
        
        self.logger.warning("Could not determine total pages, defaulting to 1")
        return 1
'@

# استبدال دالة _navigate_to_page المحسّنة
$improvedNavigateToPage = @'
    async def _navigate_to_page(self, page_number: int) -> bool:
        """Navigate to specific page with multiple fallback methods"""
        try:
            self.logger.info(f"Attempting to navigate to page {page_number}")
            
            # 1) Try aria-label button
            page_button = await self.page.query_selector(
                f'button[aria-label="Page {page_number}"]'
            )
            
            # 2) Try button with exact text match
            if not page_button:
                page_button = await self.page.query_selector(
                    f'button.p-paginator-page:has-text("{page_number}")'
                )
            
            # 3) Search all buttons for exact text match
            if not page_button:
                candidates = await self.page.query_selector_all('button')
                for btn in candidates:
                    text = (await btn.text_content() or '').strip()
                    if text == str(page_number):
                        page_button = btn
                        self.logger.info(f"Found page button via text search")
                        break
            
            # 4) Fallback to Next button
            if not page_button:
                self.logger.warning(f"Page {page_number} button not found, trying Next")
                next_btn = await self.page.query_selector('button:has-text("Next")')
                if next_btn:
                    is_enabled = await self.page.is_enabled('button:has-text("Next")')
                    if is_enabled:
                        await next_btn.click()
                        self.logger.info("Clicked Next button as fallback")
                        try:
                            await self.page.wait_for_load_state('networkidle', timeout=5000)
                        except Exception:
                            await asyncio.sleep(1.5)
                        return True
                return False
            
            # Check if already on this page
            try:
                aria_current = await page_button.get_attribute('aria-current')
                btn_class = (await page_button.get_attribute('class') or '')
                is_selected = (aria_current == 'page') or ('p-paginator-page-selected' in btn_class)
                if is_selected:
                    self.logger.info(f"Already on page {page_number}")
                    return True
            except Exception:
                pass
            
            # Click the button
            await page_button.click()
            self.logger.info(f"Clicked page {page_number} button")
            
            # Wait for page to load
            try:
                await self.page.wait_for_load_state('networkidle', timeout=5000)
            except Exception:
                await asyncio.sleep(1.5)
            
            return True
            
        except Exception as e:
            self.logger.error(f"Error navigating to page {page_number}: {e}")
            return False
'@

# البحث والاستبدال
$pattern1 = '(?s)async def _get_total_pages\(self\) -> int:.*?return 1'
$pattern2 = '(?s)async def _navigate_to_page\(self, page_number: int\) -> bool:.*?return False'

$updatedCode = $originalCode -replace $pattern1, $improvedGetTotalPages
$updatedCode = $updatedCode -replace $pattern2, $improvedNavigateToPage

# حفظ الملف الجديد
$updatedCode | Out-File -FilePath "paste_improved.py" -Encoding UTF8 -NoNewline

Write-Host "`n✅ تم إنشاء paste_improved.py بنجاح!" -ForegroundColor Green
Write-Host "`nالتحسينات المضافة:" -ForegroundColor Cyan
Write-Host "  1. تحسين _get_total_pages() - 3 طرق لاكتشاف عدد الصفحات" -ForegroundColor Yellow
Write-Host "  2. تحسين _navigate_to_page() - 4 طرق للانتقال بين الصفحات مع fallback" -ForegroundColor Yellow
Write-Host "  3. إضافة logging محسّن لتتبع عملية التنقل" -ForegroundColor Yellow
Write-Host "`nلتشغيل النظام المحسّن:" -ForegroundColor Cyan
Write-Host "  python paste_improved.py --test-pages 5" -ForegroundColor White
