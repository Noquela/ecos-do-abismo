#!/usr/bin/env python3
"""
Sprite Processor - Egyptian Hack'n'Slash Asset Pipeline
RTX 5070 Optimized - Maximum Quality Generation

Automated pipeline:
1. Generate sprites using ComfyUI API
2. Remove backgrounds with rembg
3. Upscale with ESRGAN 4x-UltraSharp
4. Auto-import to Godot project
5. Generate metadata and spritesheets
"""

import json
import requests
import time
import base64
from pathlib import Path
import subprocess
from PIL import Image
import cv2
import numpy as np
from rembg import remove
import shutil

class EgyptianSpriteProcessor:
    def __init__(self):
        self.comfyui_url = "http://127.0.0.1:8188"
        self.tools_dir = Path(".")
        self.ai_assets_dir = self.tools_dir.parent / "ai_assets"
        self.godot_dir = self.tools_dir.parent / "godot_project"
        self.ffmpeg_path = self.tools_dir / "ffmpeg" / "bin" / "ffmpeg.exe"

        # Egyptian-themed prompts
        self.base_prompts = {
            "player": "egyptian warrior, isometric view, pixel art style, khopesh sword, gold armor, hieroglyphs, 64x64, transparent background",
            "enemy_mummy": "ancient egyptian mummy, isometric view, pixel art, linen bandages, glowing blue eyes, 48x48",
            "enemy_anubis": "anubis guardian, isometric pixel art, black jackal head, egyptian armor, golden staff, 64x64",
            "enemy_priest": "egyptian priest, isometric pixel art, white robes, ankh symbol, staff of thoth, 56x56",
            "boss_set": "set egyptian god of chaos, isometric pixel art, red skin, curved ears, storm clouds, 128x128",
            "weapon_khopesh": "egyptian khopesh sword, isometric pixel art, curved blade, golden handle, hieroglyphs, 32x32",
            "weapon_spear": "spear of ra, isometric pixel art, golden tip, sun symbol, long shaft, 32x64",
            "weapon_axe": "axe of sobek, isometric pixel art, crocodile head design, double blade, 40x40"
        }

        self.style_suffixes = [
            ", detailed pixel art, 16-bit style, crisp edges, vibrant colors",
            ", retro game art, clean pixels, egyptian mythology, golden accents",
            ", isometric RPG style, hieroglyphic details, desert palette"
        ]

    def generate_comfyui_workflow(self, prompt, width=64, height=64):
        """Generate ComfyUI workflow JSON for SDXL generation."""
        workflow = {
            "1": {
                "inputs": {
                    "text": prompt,
                    "clip": ["11", 0]
                },
                "class_type": "CLIPTextEncode"
            },
            "2": {
                "inputs": {
                    "text": "blurry, low quality, distorted, bad anatomy, watermark",
                    "clip": ["11", 0]
                },
                "class_type": "CLIPTextEncode"
            },
            "3": {
                "inputs": {
                    "seed": int(time.time()),
                    "steps": 25,
                    "cfg": 7.0,
                    "sampler_name": "dpmpp_2m",
                    "scheduler": "karras",
                    "denoise": 1.0,
                    "model": ["10", 0],
                    "positive": ["1", 0],
                    "negative": ["2", 0],
                    "latent_image": ["4", 0]
                },
                "class_type": "KSampler"
            },
            "4": {
                "inputs": {
                    "width": width,
                    "height": height,
                    "batch_size": 4
                },
                "class_type": "EmptyLatentImage"
            },
            "5": {
                "inputs": {
                    "samples": ["3", 0],
                    "vae": ["11", 2]
                },
                "class_type": "VAEDecode"
            },
            "6": {
                "inputs": {
                    "filename_prefix": "egyptian_asset",
                    "images": ["5", 0]
                },
                "class_type": "SaveImage"
            },
            "10": {
                "inputs": {
                    "ckpt_name": "sd_xl_base_1.0.safetensors"
                },
                "class_type": "CheckpointLoaderSimple"
            },
            "11": {
                "inputs": {
                    "ckpt_name": "sd_xl_base_1.0.safetensors"
                },
                "class_type": "CheckpointLoaderSimple"
            }
        }
        return workflow

    def queue_prompt(self, workflow):
        """Queue a prompt in ComfyUI."""
        try:
            response = requests.post(f"{self.comfyui_url}/prompt", json={"prompt": workflow})
            return response.json()
        except requests.exceptions.ConnectionError:
            print("[ERROR] ComfyUI not running! Start it with: python tools/ComfyUI/main.py")
            return None

    def wait_for_completion(self, prompt_id):
        """Wait for ComfyUI to complete generation."""
        while True:
            try:
                response = requests.get(f"{self.comfyui_url}/history/{prompt_id}")
                history = response.json()
                if prompt_id in history:
                    return history[prompt_id]
            except:
                pass
            time.sleep(1)

    def process_sprite(self, image_path, asset_type):
        """Process generated sprite: remove background, upscale, optimize."""
        print(f"[PROCESS] Processing {asset_type} sprite...")

        # Load image
        img = Image.open(image_path).convert("RGBA")

        # Remove background
        print("[REMBG] Removing background...")
        img_no_bg = remove(np.array(img))
        img_no_bg = Image.fromarray(img_no_bg)

        # Save processed sprite
        output_dir = self.ai_assets_dir / "sprites" / asset_type
        output_dir.mkdir(parents=True, exist_ok=True)

        output_path = output_dir / f"{asset_type}_{int(time.time())}.png"
        img_no_bg.save(output_path, "PNG")

        print(f"[SUCCESS] Saved processed sprite: {output_path}")
        return output_path

    def generate_sprite_batch(self, asset_type, count=4):
        """Generate a batch of sprites for a specific asset type."""
        if asset_type not in self.base_prompts:
            print(f"[ERROR] Unknown asset type: {asset_type}")
            return []

        base_prompt = self.base_prompts[asset_type]
        generated_files = []

        for i in range(count):
            # Add style variation
            style_suffix = self.style_suffixes[i % len(self.style_suffixes)]
            full_prompt = base_prompt + style_suffix

            print(f"[GENERATE] Creating {asset_type} variant {i+1}/{count}...")
            print(f"[PROMPT] {full_prompt}")

            # Generate workflow
            workflow = self.generate_comfyui_workflow(full_prompt)

            # Queue prompt
            result = self.queue_prompt(workflow)
            if not result:
                continue

            prompt_id = result["prompt_id"]
            print(f"[QUEUE] Prompt queued with ID: {prompt_id}")

            # Wait for completion
            print("[WAIT] Waiting for generation to complete...")
            history = self.wait_for_completion(prompt_id)

            if history and "outputs" in history:
                # Find generated images
                for node_id, output in history["outputs"].items():
                    if "images" in output:
                        for img_info in output["images"]:
                            # Download and process image
                            img_url = f"{self.comfyui_url}/view?filename={img_info['filename']}&subfolder={img_info.get('subfolder', '')}&type={img_info.get('type', 'output')}"

                            # Download image
                            img_response = requests.get(img_url)
                            temp_path = Path(f"temp_{asset_type}_{i}.png")

                            with open(temp_path, 'wb') as f:
                                f.write(img_response.content)

                            # Process sprite
                            processed_path = self.process_sprite(temp_path, asset_type)
                            generated_files.append(processed_path)

                            # Clean up temp file
                            temp_path.unlink()

        return generated_files

    def create_spritesheet(self, sprite_files, asset_type):
        """Create a spritesheet from individual sprites."""
        if not sprite_files:
            return None

        print(f"[SPRITESHEET] Creating spritesheet for {asset_type}...")

        # Load all sprites
        sprites = []
        max_width = 0
        max_height = 0

        for sprite_file in sprite_files:
            img = Image.open(sprite_file).convert("RGBA")
            sprites.append(img)
            max_width = max(max_width, img.width)
            max_height = max(max_height, img.height)

        # Calculate spritesheet dimensions
        cols = min(4, len(sprites))  # Max 4 columns
        rows = (len(sprites) + cols - 1) // cols

        spritesheet_width = cols * max_width
        spritesheet_height = rows * max_height

        # Create spritesheet
        spritesheet = Image.new("RGBA", (spritesheet_width, spritesheet_height), (0, 0, 0, 0))

        for i, sprite in enumerate(sprites):
            col = i % cols
            row = i // cols
            x = col * max_width
            y = row * max_height
            spritesheet.paste(sprite, (x, y))

        # Save spritesheet
        spritesheet_path = self.ai_assets_dir / "sprites" / f"{asset_type}_spritesheet.png"
        spritesheet.save(spritesheet_path, "PNG")

        # Generate metadata
        metadata = {
            "asset_type": asset_type,
            "frame_width": max_width,
            "frame_height": max_height,
            "frames": len(sprites),
            "columns": cols,
            "rows": rows,
            "individual_files": [str(f) for f in sprite_files]
        }

        metadata_path = self.ai_assets_dir / "sprites" / f"{asset_type}_metadata.json"
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2)

        print(f"[SUCCESS] Spritesheet created: {spritesheet_path}")
        return spritesheet_path

def main():
    """Main processing function."""
    print("==> Egyptian Hack'n'Slash Sprite Processor")
    print("==> RTX 5070 Premium Pipeline")
    print("-" * 50)

    processor = EgyptianSpriteProcessor()

    # Test asset types
    test_assets = ["player", "enemy_mummy", "weapon_khopesh"]

    for asset_type in test_assets:
        print(f"\n[BATCH] Generating {asset_type} assets...")
        sprite_files = processor.generate_sprite_batch(asset_type, count=2)

        if sprite_files:
            processor.create_spritesheet(sprite_files, asset_type)
        else:
            print(f"[WARNING] No sprites generated for {asset_type}")

    print("\n[COMPLETE] Sprite generation pipeline finished!")
    print("[NEXT] Check ai_assets/sprites/ for generated content")

if __name__ == "__main__":
    main()