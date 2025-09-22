# 🎨 ASSET PIPELINE & STYLE GUIDE
**Complete asset workflow and visual standards**

---

## **📋 DOCUMENT OVERVIEW**

| Field | Value |
|-------|-------|
| **Document Type** | Asset Production & Style Guide |
| **Scope** | All visual, audio, and data assets |
| **Audience** | Artists, Developers, Content Creators |
| **Dependencies** | Technical Specification, Game Design Document |
| **Status** | Final - Production Ready |

---

## **🎨 VISUAL STYLE GUIDE**

### **ART DIRECTION PHILOSOPHY**
```
CORE AESTHETIC: "Elegant Minimalism"
├── Clean lines over ornate details
├── High contrast for clarity
├── Monochromatic with accent colors
├── Functional beauty over decoration
└── Consistent visual language

EMOTIONAL TONE: "Focused Tension"
├── UI should not distract from decisions
├── Visual feedback reinforces game state
├── Clarity prevents player confusion
└── Beauty serves function
```

### **COLOR PALETTE**
```
PRIMARY COLORS
├── Background: #1A1A1A (Dark Grey)
├── UI Elements: #2D2D2D (Medium Grey)
├── Text Primary: #FFFFFF (Pure White)
├── Text Secondary: #CCCCCC (Light Grey)
└── Borders: #404040 (Border Grey)

RESOURCE COLORS
├── HP (Health): #4CAF50 (Green) → #F44336 (Red)
├── Vontade (Will): #2196F3 (Blue) → #0D47A1 (Dark Blue)
├── Corruption: #9C27B0 (Purple) → #D32F2F (Dark Red)
├── Cards: #FFC107 (Gold accent)
└── Enemy: #FF5722 (Orange-Red)

FEEDBACK COLORS
├── Success: #4CAF50 (Green)
├── Warning: #FF9800 (Orange)
├── Error: #F44336 (Red)
├── Info: #2196F3 (Blue)
└── Neutral: #9E9E9E (Grey)
```

### **TYPOGRAPHY SYSTEM**
```
FONT HIERARCHY
├── Primary Font: "Roboto" (Clean, readable)
├── Fallback: System Sans-serif
├── Monospace: "Roboto Mono" (Numbers, stats)
└── No decorative fonts (maintain clarity)

TEXT SIZES
├── Title: 32px (Game title, major headers)
├── Header: 24px (Section headers)
├── Body: 16px (Descriptions, UI text)
├── Caption: 14px (Flavor text, hints)
├── Small: 12px (Technical info)
└── Numbers: 18px (Bold, high contrast)

TEXT TREATMENTS
├── High Importance: Bold + White
├── Medium Importance: Normal + Light Grey
├── Low Importance: Normal + Medium Grey
├── Interactive: Bold + Blue (hoverable)
└── Disabled: Normal + Dark Grey
```

---

## **🖼️ UI ASSET SPECIFICATIONS**

### **BUTTON DESIGN SYSTEM**
```
PRIMARY BUTTONS (Action Cards)
├── Size: 200x120px minimum
├── Border Radius: 8px
├── Padding: 16px internal
├── Shadow: 0 4px 8px rgba(0,0,0,0.3)
├── States: Idle, Hover, Pressed, Disabled
└── Animation: 100ms transitions

STATES SPECIFICATION:
Idle State:
├── Background: Linear gradient (#3D3D3D → #2D2D2D)
├── Border: 2px solid #505050
├── Text: #FFFFFF
└── Scale: 1.0

Hover State:
├── Background: Linear gradient (#4D4D4D → #3D3D3D)
├── Border: 2px solid #6D6D6D
├── Text: #FFFFFF
├── Scale: 1.05
└── Transition: 100ms ease-out

Pressed State:
├── Background: Linear gradient (#2D2D2D → #1D1D1D)
├── Border: 2px solid #404040
├── Text: #CCCCCC
├── Scale: 0.95
└── Transition: 50ms ease-in

Disabled State:
├── Background: #2A2A2A (flat)
├── Border: 1px solid #3A3A3A
├── Text: #666666
├── Scale: 1.0
└── Opacity: 0.6
```

### **PROGRESS BAR DESIGN**
```
HEALTH BAR SPECIFICATION
├── Dimensions: 200x20px
├── Background: #333333
├── Fill: Gradient (#4CAF50 → #8BC34A) for healthy
├── Fill: Gradient (#FF9800 → #F57C00) for warning
├── Fill: Gradient (#F44336 → #C62828) for critical
├── Border: 1px solid #555555
├── Border Radius: 4px
└── Animation: Smooth interpolation over 300ms

VONTADE BAR SPECIFICATION
├── Dimensions: 150x16px
├── Background: #1A237E
├── Fill: Gradient (#2196F3 → #1976D2)
├── Pulse Effect: When regenerating
├── Border: 1px solid #3F51B5
└── Segments: 10 discrete units (1 per Vontade point)

CORRUPTION BAR SPECIFICATION
├── Dimensions: 200x12px
├── Background: #212121
├── Fill: Gradient (#9C27B0 → #7B1FA2) at low levels
├── Fill: Gradient (#E91E63 → #C2185B) at medium levels
├── Fill: Gradient (#D32F2F → #B71C1C) at high levels
├── Warning Effect: Pulse red when > 80%
└── Death Effect: Flash red when = 100%
```

### **CARD VISUAL DESIGN**
```
CARD DIMENSIONS
├── Base Size: 180x250px
├── Corner Radius: 12px
├── Border Width: 3px
├── Content Padding: 16px
└── Aspect Ratio: 0.72 (standard card ratio)

CARD TYPE DIFFERENTIATION:
Weak Attack Cards:
├── Border Color: #2196F3 (Blue)
├── Background: Gradient (#1E3A8A → #1E40AF)
├── Icon: Sword symbol
├── Text Color: #FFFFFF
└── Accent: Subtle blue glow

Strong Attack Cards:
├── Border Color: #F44336 (Red)
├── Background: Gradient (#7F1D1D → #991B1B)
├── Icon: Lightning bolt symbol
├── Text Color: #FFFFFF
└── Accent: Dramatic red glow

Support Cards:
├── Border Color: #4CAF50 (Green)
├── Background: Gradient (#14532D → #166534)
├── Icon: Shield/heart symbol
├── Text Color: #FFFFFF
└── Accent: Calming green glow

CARD CONTENT LAYOUT:
Header Section (60px):
├── Card Name: 16px bold
├── Type Icon: 24x24px top-right
└── Background: Semi-transparent overlay

Body Section (130px):
├── Main Effect: Large centered number
├── Description: 12px, 2-3 lines max
└── Flavor Text: 10px italic (optional)

Footer Section (60px):
├── Vontade Cost: 18px bold, left
├── Corruption Cost: 14px, right (if applicable)
└── Resource Icons: 16x16px
```

---

## **📁 FILE ORGANIZATION**

### **DIRECTORY STRUCTURE**
```
assets/
├── ui/
│   ├── buttons/
│   │   ├── button_primary.png
│   │   ├── button_primary_hover.png
│   │   ├── button_primary_pressed.png
│   │   └── button_primary_disabled.png
│   ├── bars/
│   │   ├── health_bar_bg.png
│   │   ├── health_bar_fill.png
│   │   ├── vontade_bar_bg.png
│   │   └── corruption_bar_fill.png
│   ├── cards/
│   │   ├── card_frame_weak.png
│   │   ├── card_frame_strong.png
│   │   ├── card_frame_support.png
│   │   └── card_icons/
│   │       ├── sword.svg
│   │       ├── lightning.svg
│   │       └── shield.svg
│   └── panels/
│       ├── player_panel_bg.png
│       ├── enemy_panel_bg.png
│       └── game_over_panel.png
├── vfx/
│   ├── particles/
│   │   ├── impact_sparks.png
│   │   ├── death_explosion.png
│   │   └── healing_sparkles.png
│   └── animations/
│       ├── damage_number.tscn
│       └── card_flight.tscn
├── audio/
│   ├── sfx/
│   │   ├── card_play.ogg
│   │   ├── damage_hit.ogg
│   │   ├── enemy_death.ogg
│   │   └── button_click.ogg
│   └── music/
│       ├── ambient_low.ogg (future)
│       └── ambient_high.ogg (future)
└── fonts/
    ├── Roboto-Regular.ttf
    ├── Roboto-Bold.ttf
    └── RobotoMono-Regular.ttf
```

### **NAMING CONVENTIONS**
```
FILE NAMING RULES:
├── All lowercase
├── Use underscores for spaces
├── Include state in filename (hover, pressed, etc.)
├── Include dimensions for UI elements
├── Use descriptive, not generic names

EXAMPLES:
├── ✅ health_bar_200x20_bg.png
├── ✅ card_weak_attack_180x250.png
├── ✅ button_primary_hover_200x60.png
├── ❌ button1.png
├── ❌ Health-Bar.png
└── ❌ card.jpg

VERSION CONTROL:
├── No version numbers in filenames
├── Use git for version history
├── Keep working files (.psd, .ai) in separate folder
└── Only import final assets into Godot
```

---

## **🔧 TECHNICAL SPECIFICATIONS**

### **IMAGE FORMATS & SETTINGS**
```
UI ELEMENTS:
├── Format: PNG (for transparency)
├── Color Depth: 32-bit RGBA
├── Compression: Lossless PNG compression
├── DPI: 72 (screen resolution)
├── Color Space: sRGB
└── Max File Size: 500KB per asset

TEXTURE ATLASING:
├── Group related UI elements
├── Max Atlas Size: 2048x2048
├── Padding: 2px between elements
├── Format: PNG for UI, WebP for photos
└── Compression: Godot automatic optimization

ICON SPECIFICATIONS:
├── Base Size: 64x64px (scale down as needed)
├── Format: SVG (vector) preferred
├── Fallback: PNG at multiple sizes
├── Style: Consistent line weight (2-3px)
└── Color: Monochrome + accent color
```

### **AUDIO SPECIFICATIONS**
```
SOUND EFFECTS:
├── Format: OGG Vorbis (best for Godot)
├── Sample Rate: 44.1kHz
├── Bit Depth: 16-bit (sufficient for SFX)
├── Channels: Mono (UI sounds), Stereo (ambient)
├── Compression: Quality 5 (balance size/quality)
└── Duration: < 2 seconds for UI feedback

MUSIC (Future):
├── Format: OGG Vorbis
├── Sample Rate: 44.1kHz
├── Bit Depth: 16-bit
├── Channels: Stereo
├── Compression: Quality 7 (higher quality)
└── Loop Points: Seamless loops required

VOLUME LEVELS:
├── UI Sounds: -20dB to -15dB
├── Impact Sounds: -12dB to -8dB
├── Ambient: -25dB to -20dB
├── Music: -18dB to -15dB
└── Master: User controlled
```

---

## **🛠️ GODOT IMPORT SETTINGS**

### **TEXTURE IMPORT CONFIGURATION**
```gdscript
# .godot/import/ configurations

# UI Textures
[params]
compress/mode=0  # Lossless
compress/high_quality=true
compress/lossy_quality=1.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false  # UI doesn't need mipmaps
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=0

# Effect Textures (particles, etc.)
[params]
compress/mode=2  # VRAM Compressed
compress/high_quality=false
compress/lossy_quality=0.7
mipmaps/generate=true
process/premult_alpha=true
```

### **AUDIO IMPORT CONFIGURATION**
```gdscript
# Audio import settings
[params]
force/8_bit=false
force/mono=false  # Let source determine
force/max_rate=false
force/max_rate_hz=44100
edit/trim=true
edit/normalize=false  # Maintain relative volumes
edit/loop_mode=0  # No loop for SFX
edit/loop_begin=0
edit/loop_end=-1
compress/mode=0  # OGG Vorbis
```

---

## **🎨 PLACEHOLDER ASSET CREATION**

### **RAPID PROTOTYPING ASSETS**
```
For MVP development, create simple placeholder assets:

UI ELEMENTS:
├── Solid color rectangles with borders
├── System fonts for all text
├── Simple geometric shapes for icons
├── Gradient fills for progress bars
└── Basic button states (flat colors)

VISUAL EFFECTS:
├── Simple colored squares for damage numbers
├── Basic particle sprites (circles, squares)
├── Solid color flashes for impacts
├── Simple fade animations
└── No complex particle systems

AUDIO PLACEHOLDERS:
├── Generated tones for UI feedback
├── Free sound effects from freesound.org
├── Simple beeps and clicks
├── No music during MVP phase
└── Focus on gameplay over audio polish

PLACEHOLDER CREATION TOOLS:
├── Figma/Sketch for UI mockups
├── GIMP/Photoshop for textures
├── Online SVG editors for icons
├── Audacity for audio editing
└── Godot's built-in tools for simple shapes
```

### **MVP ASSET CHECKLIST**
```
CRITICAL ASSETS (Must Have):
├── [ ] Card background (3 types)
├── [ ] Health bar (background + fill)
├── [ ] Vontade bar (background + fill)
├── [ ] Corruption bar (background + fill)
├── [ ] Button states (idle, hover, pressed, disabled)
├── [ ] Damage number styling
├── [ ] Basic card icons (sword, lightning, shield)
└── [ ] Game over screen background

ENHANCEMENT ASSETS (Should Have):
├── [ ] Particle effects for impacts
├── [ ] Card flight animation
├── [ ] Enemy death effect
├── [ ] Screen shake implementation
├── [ ] Hover glow effects
├── [ ] Progress bar animations
└── [ ] UI transition effects

POLISH ASSETS (Could Have):
├── [ ] Background patterns/textures
├── [ ] Advanced particle systems
├── [ ] Ambient sound effects
├── [ ] Music tracks
├── [ ] Advanced animations
├── [ ] Detailed illustrations
└── [ ] Custom fonts
```

---

## **📐 DESIGN SYSTEMS**

### **GRID SYSTEM**
```
UI LAYOUT GRID:
├── Base Unit: 8px (all measurements divisible by 8)
├── Margins: 16px minimum from screen edges
├── Gutters: 8px between related elements
├── Gutters: 16px between unrelated elements
├── Component Padding: 8px internal minimum
└── Button Spacing: 12px between buttons

RESPONSIVE SCALING:
├── Base Resolution: 1920x1080
├── Minimum Resolution: 1280x720
├── Scaling Method: Maintain aspect ratio
├── UI Scaling: Vector-based (SVG icons)
└── Text Scaling: Relative to screen size
```

### **COMPONENT LIBRARY**
```
REUSABLE COMPONENTS:
├── ResourceBar (HP, Vontade, Corruption)
├── ActionButton (Cards, Menu buttons)
├── InfoPanel (Player stats, Enemy stats)
├── Modal (Game over, Settings)
├── Tooltip (Card descriptions)
├── ProgressIndicator (Loading, Transitions)
├── NumberDisplay (Damage numbers, Counters)
└── EffectOverlay (Screen effects, Particles)

COMPONENT VARIATIONS:
ResourceBar:
├── bar_health (Green → Red gradient)
├── bar_vontade (Blue solid)
├── bar_corruption (Purple → Red gradient)
└── bar_generic (Customizable colors)

ActionButton:
├── button_primary (Game actions)
├── button_secondary (Menu actions)
├── button_danger (Destructive actions)
└── button_disabled (Unavailable actions)
```

---

## **🔄 ASSET WORKFLOW**

### **CREATION WORKFLOW**
```
1. CONCEPT PHASE
   ├── Sketch ideas on paper/digital
   ├── Reference existing games for inspiration
   ├── Validate with game design requirements
   └── Get approval before production

2. PRODUCTION PHASE
   ├── Create assets in appropriate software
   ├── Follow style guide specifications
   ├── Test at target resolution
   └── Export in correct formats

3. INTEGRATION PHASE
   ├── Import to Godot with correct settings
   ├── Test in-game appearance
   ├── Adjust for gameplay clarity
   └── Optimize file sizes if needed

4. VALIDATION PHASE
   ├── Test on different screen sizes
   ├── Verify performance impact
   ├── Get user feedback if possible
   └── Iterate based on testing results
```

### **QUALITY ASSURANCE**
```
VISUAL QA CHECKLIST:
├── [ ] Asset displays correctly at target resolution
├── [ ] Colors match style guide specifications
├── [ ] No visual artifacts (compression, aliasing)
├── [ ] Consistent with other similar assets
├── [ ] Readable/clear at intended size
├── [ ] Works with different background colors
├── [ ] Animation timing feels appropriate
└── [ ] File size within acceptable limits

TECHNICAL QA CHECKLIST:
├── [ ] Correct file format for use case
├── [ ] Proper import settings in Godot
├── [ ] No memory leaks or performance issues
├── [ ] Scales correctly on different resolutions
├── [ ] Compatible with target platforms
├── [ ] Version control properly managed
├── [ ] Backup of source files maintained
└── [ ] Documentation updated
```

---

## **📚 REFERENCES & RESOURCES**

### **INSPIRATION SOURCES**
```
UI DESIGN REFERENCES:
├── Slay the Spire (Card game UI excellence)
├── Hades (Modern game UI design)
├── Darkest Dungeon (Atmospheric UI)
├── Inscryption (Innovative card presentation)
└── FTL: Faster Than Light (Minimal, functional)

DESIGN TOOLS:
├── Figma (UI design and prototyping)
├── Adobe Creative Suite (Professional assets)
├── GIMP (Free alternative)
├── Inkscape (Free vector graphics)
├── Aseprite (Pixel art)
├── Audacity (Audio editing)
└── Freesound.org (Free sound effects)

ASSET STORES (if needed):
├── Kenney.nl (Free game assets)
├── OpenGameArt.org (Community assets)
├── Unity Asset Store (Some Godot compatible)
├── Itch.io (Indie game assets)
└── Godot Asset Library
```

### **LEGAL CONSIDERATIONS**
```
ASSET LICENSING:
├── All assets must be original or properly licensed
├── Document source and license for each asset
├── Avoid copyrighted material without permission
├── Use Creative Commons or public domain when possible
└── Keep licenses documentation for legal compliance

ATTRIBUTION REQUIREMENTS:
├── Document required attributions
├── Include credits in game if required
├── Maintain license files in project
└── Review licensing before commercial use
```

---

**Document End - Complete Asset Production Guide**
**Status: Ready for Asset Creation**
**Next: Begin Asset Production for Sprint 1**