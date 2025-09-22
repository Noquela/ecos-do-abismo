# 🚀 DEPLOYMENT & RELEASE MANAGEMENT
**Complete deployment pipeline and release procedures**

---

## **📋 DOCUMENT OVERVIEW**

| Field | Value |
|-------|-------|
| **Document Type** | Deployment & Release Management |
| **Scope** | Build, deployment, and release processes |
| **Audience** | Developers, DevOps, Release Managers |
| **Dependencies** | All project documentation |
| **Status** | Final - Production Ready |

---

## **🏗️ BUILD PIPELINE**

### **BUILD ENVIRONMENTS**
```
DEVELOPMENT BUILD:
├── Purpose: Daily development and testing
├── Frequency: Every commit
├── Target: Local development machines
├── Optimizations: Debug symbols, verbose logging
├── Assets: Placeholder/development assets
├── Performance: Not optimized
└── Distribution: Internal team only

STAGING BUILD:
├── Purpose: Pre-release validation and testing
├── Frequency: Weekly or feature-complete
├── Target: Testing environment
├── Optimizations: Partial release optimizations
├── Assets: Final or near-final assets
├── Performance: Release-level performance
└── Distribution: QA team and stakeholders

RELEASE BUILD:
├── Purpose: Public distribution
├── Frequency: Sprint completion or milestones
├── Target: End users
├── Optimizations: Full release optimizations
├── Assets: Final polished assets
├── Performance: Maximum optimization
└── Distribution: Public release channels
```

### **AUTOMATED BUILD SYSTEM**
```batch
REM build_pipeline.bat - Master build script
@echo off
setlocal EnableDelayedExpansion

echo ==========================================
echo    ECOS DO ABISMO - BUILD PIPELINE
echo ==========================================

REM Get build parameters
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=development

set VERSION=%2
if "%VERSION%"=="" (
    for /f %%i in ('git rev-parse --short HEAD') do set VERSION=dev-%%i
)

echo Build Type: %BUILD_TYPE%
echo Version: %VERSION%

REM Set environment variables
set GODOT_PATH="C:\Godot_v4.4.1-stable_win64.exe"
set PROJECT_PATH="%CD%\godot-project"
set BUILD_OUTPUT="%CD%\builds"

REM Clean previous builds
echo Cleaning previous builds...
if exist "%BUILD_OUTPUT%" rmdir /s /q "%BUILD_OUTPUT%"
mkdir "%BUILD_OUTPUT%"

REM Run pre-build validation
echo Running pre-build validation...
call scripts\validate_project.bat
if %ERRORLEVEL% NEQ 0 (
    echo Pre-build validation failed!
    exit /b 1
)

REM Execute build based on type
if "%BUILD_TYPE%"=="development" call :build_development
if "%BUILD_TYPE%"=="staging" call :build_staging
if "%BUILD_TYPE%"=="release" call :build_release

echo Build completed successfully!
goto :eof

:build_development
echo Building development version...
%GODOT_PATH% --headless --path %PROJECT_PATH% --export-debug "Windows Desktop" "%BUILD_OUTPUT%\dev\EcosDoAbismo_dev.exe"
copy /y "%PROJECT_PATH%\project.godot" "%BUILD_OUTPUT%\dev\"
echo Development build ready at: %BUILD_OUTPUT%\dev\
goto :eof

:build_staging
echo Building staging version...
%GODOT_PATH% --headless --path %PROJECT_PATH% --export-release "Windows Desktop" "%BUILD_OUTPUT%\staging\EcosDoAbismo_staging.exe"
call scripts\package_staging.bat
echo Staging build ready at: %BUILD_OUTPUT%\staging\
goto :eof

:build_release
echo Building release version...
call scripts\pre_release_checks.bat
if %ERRORLEVEL% NEQ 0 (
    echo Pre-release checks failed!
    exit /b 1
)

%GODOT_PATH% --headless --path %PROJECT_PATH% --export-release "Windows Desktop" "%BUILD_OUTPUT%\release\EcosDoAbismo.exe"
call scripts\package_release.bat
call scripts\post_release_validation.bat

echo Release build ready at: %BUILD_OUTPUT%\release\
goto :eof
```

### **PRE-BUILD VALIDATION**
```batch
REM validate_project.bat - Pre-build validation
@echo off

echo Validating project structure...

REM Check critical files exist
if not exist "godot-project\project.godot" (
    echo ERROR: project.godot not found
    exit /b 1
)

if not exist "godot-project\scenes\Main.tscn" (
    echo ERROR: Main.tscn not found
    exit /b 1
)

REM Validate Godot project settings
%GODOT_PATH% --headless --path "godot-project" --check-only
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Godot project validation failed
    exit /b 1
)

REM Check for placeholder assets in release builds
if "%BUILD_TYPE%"=="release" (
    echo Checking for placeholder assets...
    findstr /s /i "placeholder\|todo\|fixme" "godot-project\*.gd" > nul
    if %ERRORLEVEL% EQU 0 (
        echo WARNING: Placeholder content found in release build
        echo Continue anyway? (y/n)
        set /p confirm=
        if not "!confirm!"=="y" exit /b 1
    )
)

echo Project validation passed
exit /b 0
```

---

## **📦 PACKAGING & DISTRIBUTION**

### **RELEASE PACKAGING STRUCTURE**
```
EcosDoAbismo_v1.0.0/
├── EcosDoAbismo.exe                 # Main executable
├── EcosDoAbismo.pck                 # Game data (if separate)
├── README.txt                       # Installation instructions
├── LICENSE.txt                      # License information
├── CHANGELOG.txt                    # Version history
├── docs/
│   ├── manual.pdf                   # User manual (future)
│   └── controls.txt                 # Control reference
├── saves/                           # Save directory (future)
└── logs/                            # Log directory
```

### **PACKAGING SCRIPT**
```batch
REM package_release.bat - Release packaging
@echo off

set PACKAGE_NAME=EcosDoAbismo_v%VERSION%
set PACKAGE_DIR=%BUILD_OUTPUT%\%PACKAGE_NAME%
set ARCHIVE_NAME=%PACKAGE_NAME%.zip

echo Creating release package...

REM Create package directory
mkdir "%PACKAGE_DIR%"

REM Copy main files
copy /y "%BUILD_OUTPUT%\release\EcosDoAbismo.exe" "%PACKAGE_DIR%\"
if exist "%BUILD_OUTPUT%\release\EcosDoAbismo.pck" (
    copy /y "%BUILD_OUTPUT%\release\EcosDoAbismo.pck" "%PACKAGE_DIR%\"
)

REM Create documentation
echo Creating documentation...
call scripts\generate_readme.bat "%PACKAGE_DIR%"
call scripts\generate_changelog.bat "%PACKAGE_DIR%"
copy /y "LICENSE" "%PACKAGE_DIR%\LICENSE.txt"

REM Create directory structure
mkdir "%PACKAGE_DIR%\logs"
mkdir "%PACKAGE_DIR%\saves"

REM Create archive
echo Creating archive...
if exist "C:\Program Files\7-Zip\7z.exe" (
    "C:\Program Files\7-Zip\7z.exe" a -tzip "%BUILD_OUTPUT%\%ARCHIVE_NAME%" "%PACKAGE_DIR%\*"
) else (
    echo WARNING: 7-Zip not found, manual archive creation required
)

echo Package created: %BUILD_OUTPUT%\%ARCHIVE_NAME%
```

### **AUTO-GENERATED DOCUMENTATION**
```batch
REM generate_readme.bat - Auto-generate README
@echo off
set OUTPUT_DIR=%1

(
echo ECOS DO ABISMO
echo ==============
echo.
echo Um jogo de cartas psicológico onde cada decisão
echo te aproxima da vitória... ou da loucura.
echo.
echo INSTALAÇÃO:
echo -----------
echo 1. Extraia todos os arquivos em uma pasta
echo 2. Execute EcosDoAbismo.exe
echo 3. Aproveite o jogo!
echo.
echo CONTROLES:
echo ----------
echo Mouse: Clique nas cartas para jogá-las
echo ESC: Pausar ^(futuro^)
echo F11: Tela cheia ^(futuro^)
echo.
echo REQUISITOS MÍNIMOS:
echo -------------------
echo OS: Windows 10 64-bit
echo RAM: 4 GB
echo GPU: DirectX 11 compatível
echo Espaço: 500 MB
echo.
echo CONTATO:
echo --------
echo Para bugs ou feedback, acesse:
echo https://github.com/user/ecos-do-abismo/issues
echo.
echo Versão: %VERSION%
echo Data: %DATE%
) > "%OUTPUT_DIR%\README.txt"

echo README.txt generated
```

---

## **🔄 DEPLOYMENT STRATEGIES**

### **DEVELOPMENT DEPLOYMENT**
```
CONTINUOUS INTEGRATION:
├── Trigger: Every commit to main branch
├── Process: Automated build + basic tests
├── Deployment: Internal file server
├── Notification: Team Slack/Discord
└── Rollback: Automatic on test failure

DAILY BUILDS:
├── Schedule: 6 AM daily (if changes exist)
├── Process: Full build + extended tests
├── Deployment: Shared development server
├── Notification: Email summary to team
└── Archive: Keep last 7 builds for reference
```

### **STAGING DEPLOYMENT**
```
WEEKLY RELEASES:
├── Trigger: Manual or milestone completion
├── Process: Full release pipeline
├── Testing: Complete QA validation
├── Approval: Lead developer sign-off
└── Documentation: Release notes generated

HOTFIX DEPLOYMENT:
├── Trigger: Critical bug fixes
├── Process: Expedited release pipeline
├── Testing: Focused regression testing
├── Approval: Emergency approval process
└── Communication: Immediate stakeholder notification
```

### **PRODUCTION DEPLOYMENT**
```
MAJOR RELEASES:
├── Trigger: Sprint completion
├── Process: Complete release pipeline
├── Testing: Full QA + user acceptance testing
├── Approval: Stakeholder and legal sign-off
├── Documentation: Complete release package
├── Distribution: All configured channels
└── Monitoring: Post-release health checks

PATCH RELEASES:
├── Trigger: Critical fixes only
├── Process: Minimal viable release pipeline
├── Testing: Targeted testing of fixes
├── Approval: Technical lead approval
├── Distribution: Existing channels only
└── Communication: Patch notes to users
```

---

## **📊 RELEASE MANAGEMENT**

### **RELEASE PLANNING FRAMEWORK**
```
RELEASE TYPES:

MAJOR RELEASE (x.0.0):
├── Scope: New features, major changes
├── Frequency: Every 3-6 months
├── Testing: Full validation cycle
├── Documentation: Complete update
├── Marketing: Full campaign
└── Support: Extended support window

MINOR RELEASE (x.y.0):
├── Scope: Feature additions, improvements
├── Frequency: Monthly
├── Testing: Standard validation
├── Documentation: Feature documentation
├── Marketing: Feature announcements
└── Support: Standard support

PATCH RELEASE (x.y.z):
├── Scope: Bug fixes, security patches
├── Frequency: As needed
├── Testing: Regression testing
├── Documentation: Patch notes
├── Marketing: Minimal communication
└── Support: Quick response

HOTFIX RELEASE (x.y.z.1):
├── Scope: Critical fixes only
├── Frequency: Emergency only
├── Testing: Minimal validation
├── Documentation: Fix description
├── Marketing: Issue communication
└── Support: Immediate response
```

### **RELEASE CHECKLIST TEMPLATE**
```
RELEASE: Ecos do Abismo v[VERSION]
TARGET DATE: [DATE]
RELEASE TYPE: [Major/Minor/Patch/Hotfix]

PRE-RELEASE CHECKLIST:
├── [ ] All planned features completed
├── [ ] Code review completed
├── [ ] Unit tests passing (100%)
├── [ ] Integration tests passing
├── [ ] Performance benchmarks met
├── [ ] Security review completed
├── [ ] User acceptance testing passed
├── [ ] Documentation updated
├── [ ] Release notes written
├── [ ] Build pipeline validated
├── [ ] Deployment plan reviewed
├── [ ] Rollback plan prepared
├── [ ] Stakeholder approval received
├── [ ] Legal clearance obtained
└── [ ] Marketing materials ready

BUILD & PACKAGE:
├── [ ] Clean build environment
├── [ ] Release build successful
├── [ ] Package creation successful
├── [ ] Installation testing completed
├── [ ] Virus scan clean
├── [ ] Digital signatures applied
├── [ ] Archive integrity verified
└── [ ] Distribution files ready

POST-RELEASE:
├── [ ] Deployment successful
├── [ ] Health checks passed
├── [ ] User notifications sent
├── [ ] Documentation published
├── [ ] Support team briefed
├── [ ] Monitoring alerts configured
├── [ ] Feedback channels ready
└── [ ] Success metrics tracked
```

---

## **🔧 DISTRIBUTION CHANNELS**

### **PRIMARY DISTRIBUTION**
```
DIRECT DISTRIBUTION:
├── Platform: Company website/GitHub releases
├── Format: ZIP archive download
├── Updates: Manual download and install
├── Analytics: Download tracking
├── Support: Direct contact/GitHub issues
└── Revenue: Free (MVP) / Paid (future)

ITCH.IO DISTRIBUTION (Future):
├── Platform: itch.io indie marketplace
├── Format: Itch app + direct download
├── Updates: Automatic via Itch app
├── Analytics: Itch.io provided analytics
├── Support: Itch.io + direct contact
└── Revenue: Pay-what-you-want model

STEAM DISTRIBUTION (Future):
├── Platform: Steam Store
├── Format: Steam integration
├── Updates: Automatic via Steam
├── Analytics: Steam analytics suite
├── Support: Steam support system
└── Revenue: Steam revenue sharing
```

### **DISTRIBUTION CONFIGURATION**
```json
{
  "distribution_config": {
    "mvp_phase": {
      "primary_channel": "github_releases",
      "backup_channel": "direct_download",
      "update_mechanism": "manual",
      "analytics": "google_analytics",
      "support": "github_issues"
    },
    "post_mvp": {
      "primary_channel": "itch_io",
      "secondary_channel": "github_releases",
      "update_mechanism": "itch_app",
      "analytics": "itch_analytics",
      "support": "itch_io + github"
    },
    "commercial": {
      "primary_channel": "steam",
      "secondary_channel": "itch_io",
      "update_mechanism": "automatic",
      "analytics": "steam_analytics",
      "support": "steam_support"
    }
  }
}
```

---

## **📈 MONITORING & ANALYTICS**

### **RELEASE HEALTH MONITORING**
```
TECHNICAL METRICS:
├── Crash Rate: < 0.1% of sessions
├── Performance: 60+ FPS average
├── Load Time: < 3 seconds
├── Memory Usage: < 500MB peak
├── Error Rate: < 1% of actions
└── Response Time: < 100ms input lag

USER METRICS:
├── Download Rate: Track downloads per day
├── Session Length: Average 15+ minutes
├── Retention: 24h, 7d, 30d retention rates
├── User Rating: 4+ stars average
├── Support Tickets: < 5% of users
└── Feature Usage: Card play frequency

BUSINESS METRICS:
├── Acquisition: New users per day
├── Engagement: Daily/Monthly active users
├── Satisfaction: NPS score 7+
├── Conversion: Download to play rate
├── Growth: Week-over-week growth
└── Revenue: (Future) Sales and payments
```

### **MONITORING IMPLEMENTATION**
```gdscript
# Basic analytics for MVP
class_name Analytics
extends Node

var session_start_time: float
var cards_played: int = 0
var max_enemy_level: int = 0
var crash_occurred: bool = false

func _ready():
    session_start_time = Time.get_unix_time_from_system()

    # Connect to game events
    GameEvents.card_played.connect(_on_card_played)
    GameEvents.enemy_died.connect(_on_enemy_died)
    GameEvents.game_over.connect(_on_game_over)

func _on_card_played(card: Card, target: Enemy):
    cards_played += 1

func _on_enemy_died(enemy: Enemy):
    max_enemy_level = max(max_enemy_level, enemy.level)

func _on_game_over(reason: String):
    send_session_data({
        "session_length": Time.get_unix_time_from_system() - session_start_time,
        "cards_played": cards_played,
        "max_enemy_level": max_enemy_level,
        "death_reason": reason,
        "version": ProjectSettings.get_setting("application/config/version")
    })

func send_session_data(data: Dictionary):
    # For MVP: log to file
    var log_file = FileAccess.open("user://analytics.json", FileAccess.WRITE)
    if log_file:
        log_file.store_line(JSON.stringify(data))
        log_file.close()

    # Future: Send to analytics service
    # send_to_analytics_service(data)
```

---

## **🔄 VERSION CONTROL & BRANCHING**

### **BRANCHING STRATEGY**
```
BRANCH STRUCTURE:
main
├── Protected branch, release-ready code only
├── Direct commits forbidden
├── Requires PR + review for changes
└── Auto-tagged for releases

develop
├── Integration branch for features
├── All feature branches merge here first
├── Regular builds and testing
└── Merges to main for releases

feature/[feature-name]
├── Individual feature development
├── Branched from develop
├── Merged back to develop when complete
└── Deleted after successful merge

hotfix/[fix-description]
├── Critical fixes branched from main
├── Minimal changes, focused fixes only
├── Merged to both main and develop
└── Immediate release after merge

release/[version]
├── Release preparation branch
├── Final testing and bug fixes only
├── No new features allowed
└── Merged to main when ready
```

### **COMMIT CONVENTIONS**
```
COMMIT MESSAGE FORMAT:
<type>(<scope>): <description>

[optional body]

[optional footer]

TYPES:
├── feat: New feature
├── fix: Bug fix
├── docs: Documentation changes
├── style: Code style changes
├── refactor: Code refactoring
├── test: Adding or updating tests
├── chore: Maintenance tasks
└── release: Release preparation

EXAMPLES:
feat(combat): add corruption system
fix(ui): resolve card button state issues
docs(readme): update installation instructions
test(player): add resource management tests
release: bump version to 1.0.0

SCOPE EXAMPLES:
├── combat, cards, ui, player, enemy
├── audio, vfx, performance
├── build, deploy, ci
└── docs, test, config
```

---

## **🚨 ROLLBACK & RECOVERY**

### **ROLLBACK PROCEDURES**
```
IMMEDIATE ROLLBACK TRIGGERS:
├── Crash rate > 5% within first hour
├── Performance degradation > 50%
├── Critical gameplay bugs reported
├── Security vulnerability discovered
└── Legal or compliance issues

ROLLBACK PROCESS:
1. ASSESS SEVERITY (5 minutes)
   ├── Determine impact scope
   ├── Identify affected users
   ├── Evaluate rollback necessity
   └── Alert stakeholders

2. EXECUTE ROLLBACK (15 minutes)
   ├── Remove current version from distribution
   ├── Restore previous version
   ├── Verify rollback success
   └── Monitor for stability

3. COMMUNICATE (30 minutes)
   ├── Notify users of temporary issue
   ├── Provide estimated fix timeline
   ├── Offer workarounds if available
   └── Update support channels

4. INVESTIGATE & FIX (Variable)
   ├── Root cause analysis
   ├── Develop and test fix
   ├── Prepare emergency patch
   └── Plan re-release

5. RE-RELEASE (60 minutes)
   ├── Deploy fixed version
   ├── Validate deployment
   ├── Monitor health metrics
   └── Communicate resolution
```

### **DISASTER RECOVERY PLAN**
```
BACKUP STRATEGY:
├── Source Code: Git repositories (GitHub)
├── Assets: Cloud storage + local backups
├── Documentation: Version controlled
├── Builds: Archive last 10 releases
├── User Data: N/A (no user accounts)
└── Analytics: Local files + cloud backup

RECOVERY SCENARIOS:

Scenario 1: Build Server Failure
├── Impact: Cannot create new builds
├── Recovery: Local builds on dev machines
├── Timeline: 1-2 hours
└── Prevention: Multiple build environments

Scenario 2: Distribution Platform Down
├── Impact: Users cannot download
├── Recovery: Alternative distribution channels
├── Timeline: 1-4 hours
└── Prevention: Multiple distribution channels

Scenario 3: Source Code Loss
├── Impact: Development stops
├── Recovery: Git repository restoration
├── Timeline: 30 minutes
└── Prevention: Multiple Git remotes

Scenario 4: Complete Infrastructure Loss
├── Impact: All services unavailable
├── Recovery: Cold start from backups
├── Timeline: 4-8 hours
└── Prevention: Geographic distribution
```

---

## **📋 COMPLIANCE & LEGAL**

### **RELEASE COMPLIANCE CHECKLIST**
```
LEGAL REQUIREMENTS:
├── [ ] Software license included
├── [ ] Third-party license compliance
├── [ ] Privacy policy (if data collection)
├── [ ] Terms of service (if applicable)
├── [ ] Age rating compliance
├── [ ] Platform-specific requirements
├── [ ] Accessibility compliance (future)
└── [ ] Regional compliance (EU, etc.)

TECHNICAL COMPLIANCE:
├── [ ] Platform technical requirements
├── [ ] Security best practices
├── [ ] Performance standards
├── [ ] Compatibility requirements
├── [ ] Installation/uninstall standards
├── [ ] User data protection
├── [ ] Error handling standards
└── [ ] Update mechanism compliance

CONTENT COMPLIANCE:
├── [ ] Content rating appropriate
├── [ ] No copyright violations
├── [ ] No trademark violations
├── [ ] Asset licensing verified
├── [ ] Text/language appropriate
├── [ ] Cultural sensitivity review
├── [ ] Violence/content warnings
└── [ ] Marketing claims accurate
```

---

**Document End - Complete Deployment & Release Guide**
**Status: Ready for Production Deployment**
**Next: Implement Build Pipeline**