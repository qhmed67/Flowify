@echo off
REM Cleanup script to remove unused backend and deprecated files
REM Run this from the FlowcharDesigner project root directory

echo ========================================
echo  FlowcharDesigner Project Cleanup
echo ========================================
echo.
echo This script will delete:
echo - Backend directory (Python server)
echo - Backend-related scripts
echo - Unused widget files
echo - Deprecated utilities
echo - Outdated documentation
echo.
pause

echo.
echo [1/6] Removing backend directory...
if exist backend rmdir /S /Q backend && echo ✓ backend/ deleted || echo ✗ backend/ not found

echo.
echo [2/6] Removing backend scripts...
if exist start_backend.bat del /F start_backend.bat && echo ✓ start_backend.bat deleted || echo ✗ start_backend.bat not found
if exist start_backend.sh del /F start_backend.sh && echo ✓ start_backend.sh deleted || echo ✗ start_backend.sh not found  
if exist test_backend.py del /F test_backend.py && echo ✓ test_backend.py deleted || echo ✗ test_backend.py not found
if exist find_ip.bat del /F find_ip.bat && echo ✓ find_ip.bat deleted || echo ✗ find_ip.bat not found
if exist find_ip.sh del /F find_ip.sh && echo ✓ find_ip.sh deleted || echo ✗ find_ip.sh not found

echo.
echo [3/6] Removing unused widget files...
if exist lib\widgets\flowchart_viewer.dart del /F lib\widgets\flowchart_viewer.dart && echo ✓ flowchart_viewer.dart deleted || echo ✗ flowchart_viewer.dart not found
if exist lib\widgets\enhanced_flowchart_viewer.dart del /F lib\widgets\enhanced_flowchart_viewer.dart && echo ✓ enhanced_flowchart_viewer.dart deleted || echo ✗ enhanced_flowchart_viewer.dart not found
if exist lib\widgets\vertical_flowchart_viewer.dart del /F lib\widgets\vertical_flowchart_viewer.dart && echo ✓ vertical_flowchart_viewer.dart deleted || echo ✗ vertical_flowchart_viewer.dart not found
if exist lib\widgets\html_flowchart_viewer.dart del /F lib\widgets\html_flowchart_viewer.dart && echo ✓ html_flowchart_viewer.dart deleted || echo ✗ html_flowchart_viewer.dart not found

echo.
echo [4/6] Removing unused utilities...
if exist lib\utils\mermaid_parser.dart del /F lib\utils\mermaid_parser.dart && echo ✓ mermaid_parser.dart deleted || echo ✗ mermaid_parser.dart not found
if exist lib\config\app_config.dart del /F lib\config\app_config.dart && echo ✓ app_config.dart deleted || echo ✗ app_config.dart not found

echo.
echo [5/6] Removing outdated documentation...
if exist QUICKSTART.md del /F QUICKSTART.md && echo ✓ QUICKSTART.md deleted || echo ✗ QUICKSTART.md not found
if exist START_HERE.md del /F START_HERE.md && echo ✓ START_HERE.md deleted || echo ✗ START_HERE.md not found
if exist TEST_CONNECTION.md del /F TEST_CONNECTION.md && echo ✓ TEST_CONNECTION.md deleted || echo ✗ TEST_CONNECTION.md not found
if exist ARCHITECTURE.md del /F ARCHITECTURE.md && echo ✓ ARCHITECTURE.md deleted || echo ✗ ARCHITECTURE.md not found
if exist MIGRATION_NOTES.md del /F MIGRATION_NOTES.md && echo ✓ MIGRATION_NOTES.md deleted || echo ✗ MIGRATION_NOTES.md not found

echo.
echo [6/6] Cleanup complete!
echo.
echo Next steps:
echo 1. Run 'flutter analyze' to verify no broken imports
echo 2. Run 'flutter build apk --debug' to test compilation
echo 3. Test app functionality
echo.
pause
