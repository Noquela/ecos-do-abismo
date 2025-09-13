#!/usr/bin/env python3
"""
Create placeholder sprites for Egyptian hack'n'slash game
Better than circles - creates themed placeholder art
"""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import math

def create_sprite_directory():
    """Create sprite directory structure"""
    base_dir = Path("../ai_assets/sprites")
    base_dir.mkdir(parents=True, exist_ok=True)
    return base_dir

def create_player_sprite(size=64):
    """Create Egyptian warrior placeholder sprite"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Body (golden armor)
    center_x, center_y = size//2, size//2
    body_width, body_height = size//3, size//2

    # Golden armor body
    draw.rectangle([
        center_x - body_width//2, center_y - body_height//4,
        center_x + body_width//2, center_y + body_height//2
    ], fill=(218, 165, 32, 255), outline=(184, 134, 11, 255), width=2)

    # Head/helmet
    head_size = size//4
    draw.ellipse([
        center_x - head_size//2, center_y - body_height//2 - head_size//2,
        center_x + head_size//2, center_y - body_height//2 + head_size//2
    ], fill=(139, 69, 19, 255), outline=(101, 67, 33, 255), width=2)

    # Khopesh sword (curved)
    sword_start_x = center_x + body_width//2 + 2
    sword_start_y = center_y - body_height//4

    # Sword handle
    draw.line([sword_start_x, sword_start_y, sword_start_x, sword_start_y + size//3],
              fill=(139, 69, 19, 255), width=3)

    # Curved blade
    blade_points = []
    for i in range(10):
        angle = -math.pi/3 + (i * math.pi/15)
        blade_x = sword_start_x + int(12 * math.cos(angle))
        blade_y = sword_start_y - 8 + int(12 * math.sin(angle))
        blade_points.append((blade_x, blade_y))

    if len(blade_points) > 1:
        for i in range(len(blade_points)-1):
            draw.line([blade_points[i], blade_points[i+1]], fill=(192, 192, 192, 255), width=2)

    # Egyptian symbols (simplified hieroglyph)
    symbol_size = 6
    draw.ellipse([
        center_x - 2, center_y - 2,
        center_x + 2, center_y + 2
    ], fill=(255, 215, 0, 255))  # Golden ankh center

    return img

def create_projectile_sprite(projectile_type, size=16):
    """Create projectile sprites"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    center_x, center_y = size//2, size//2

    if projectile_type == "fire_bolt":
        # Orange/red fire bolt
        draw.ellipse([2, 2, size-2, size-2], fill=(255, 69, 0, 255))
        draw.ellipse([4, 4, size-4, size-4], fill=(255, 140, 0, 255))
        draw.ellipse([6, 6, size-6, size-6], fill=(255, 215, 0, 255))

    elif projectile_type == "ice_shard":
        # Blue ice crystal
        points = [
            (center_x, 2),
            (center_x + 4, center_y),
            (center_x, size-2),
            (center_x - 4, center_y)
        ]
        draw.polygon(points, fill=(135, 206, 250, 255), outline=(70, 130, 180, 255))

    elif projectile_type == "light_beam":
        # Golden light beam
        draw.ellipse([1, 1, size-1, size-1], fill=(255, 215, 0, 200))
        draw.ellipse([3, 3, size-3, size-3], fill=(255, 255, 224, 255))

    elif projectile_type == "dark_orb":
        # Purple dark orb
        draw.ellipse([1, 1, size-1, size-1], fill=(75, 0, 130, 255))
        draw.ellipse([4, 4, size-4, size-4], fill=(138, 43, 226, 255))

    return img

def create_enemy_sprite(enemy_type, size=48):
    """Create enemy placeholder sprites"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    center_x, center_y = size//2, size//2

    if enemy_type == "mummy":
        # Mummy with bandages
        body_width, body_height = size//3, size//2

        # Body
        draw.rectangle([
            center_x - body_width//2, center_y - body_height//4,
            center_x + body_width//2, center_y + body_height//2
        ], fill=(245, 245, 220, 255), outline=(210, 180, 140, 255), width=2)

        # Head
        head_size = size//4
        draw.ellipse([
            center_x - head_size//2, center_y - body_height//2 - head_size//2,
            center_x + head_size//2, center_y - body_height//2 + head_size//2
        ], fill=(245, 245, 220, 255), outline=(210, 180, 140, 255), width=2)

        # Glowing eyes
        eye_size = 3
        draw.ellipse([center_x - 6, center_y - body_height//3, center_x - 6 + eye_size, center_y - body_height//3 + eye_size],
                    fill=(0, 255, 255, 255))
        draw.ellipse([center_x + 3, center_y - body_height//3, center_x + 3 + eye_size, center_y - body_height//3 + eye_size],
                    fill=(0, 255, 255, 255))

        # Bandage lines
        for i in range(3):
            y = center_y - body_height//4 + (i * 6)
            draw.line([center_x - body_width//2, y, center_x + body_width//2, y],
                     fill=(210, 180, 140, 255), width=1)

    elif enemy_type == "sacerdote":
        # Priest with staff
        body_width, body_height = size//3, size//2

        # Robes (cyan)
        draw.rectangle([
            center_x - body_width//2, center_y - body_height//4,
            center_x + body_width//2, center_y + body_height//2
        ], fill=(0, 139, 139, 255), outline=(0, 100, 100, 255), width=2)

        # Head
        head_size = size//4
        draw.ellipse([
            center_x - head_size//2, center_y - body_height//2 - head_size//2,
            center_x + head_size//2, center_y - body_height//2 + head_size//2
        ], fill=(139, 69, 19, 255), outline=(101, 67, 33, 255), width=2)

        # Staff
        staff_x = center_x - body_width//2 - 3
        draw.line([staff_x, center_y - body_height//2, staff_x, center_y + body_height//2],
                  fill=(139, 69, 19, 255), width=2)
        # Staff orb
        draw.ellipse([staff_x - 3, center_y - body_height//2 - 3, staff_x + 3, center_y - body_height//2 + 3],
                    fill=(255, 215, 0, 255))

    return img

def main():
    print("==> Creating Placeholder Sprites for Egyptian Hack'n'Slash")
    print("==> Professional placeholders while AI pipeline is optimized")
    print("----------------------------------------------------------")

    sprite_dir = create_sprite_directory()

    # Create player sprite
    print("[CREATE] Player warrior sprite...")
    player_img = create_player_sprite(64)
    player_path = sprite_dir / "player_warrior_placeholder.png"
    player_img.save(player_path)
    print(f"[SAVED] {player_path}")

    # Create projectile sprites
    projectile_types = ["fire_bolt", "ice_shard", "light_beam", "dark_orb"]
    for proj_type in projectile_types:
        print(f"[CREATE] {proj_type} projectile...")
        proj_img = create_projectile_sprite(proj_type, 16)
        proj_path = sprite_dir / f"projectile_{proj_type}_placeholder.png"
        proj_img.save(proj_path)
        print(f"[SAVED] {proj_path}")

    # Create enemy sprites
    enemy_types = ["mummy", "sacerdote"]
    for enemy_type in enemy_types:
        print(f"[CREATE] {enemy_type} enemy...")
        enemy_img = create_enemy_sprite(enemy_type, 48)
        enemy_path = sprite_dir / f"enemy_{enemy_type}_placeholder.png"
        enemy_img.save(enemy_path)
        print(f"[SAVED] {enemy_path}")

    print("\n[COMPLETE] Placeholder sprites created!")
    print("These provide visual feedback while AI generation is optimized.")
    print(f"[LOCATION] {sprite_dir}")

if __name__ == "__main__":
    main()