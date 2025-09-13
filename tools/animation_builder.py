#!/usr/bin/env python3
"""
Animation Builder - Egyptian Hack'n'Slash Animation Pipeline
AnimateDiff v3 + SparseCtrl Integration for Fluid Character Animations

Generates:
- Character movement cycles (walk, idle, attack)
- Weapon swing animations
- Magic spell effects
- Enemy behavior animations
"""

import json
import requests
import time
import cv2
import numpy as np
from pathlib import Path
from PIL import Image
import subprocess

class EgyptianAnimationBuilder:
    def __init__(self):
        self.comfyui_url = "http://127.0.0.1:8188"
        self.tools_dir = Path(".")
        self.ai_assets_dir = self.tools_dir.parent / "ai_assets"
        self.ffmpeg_path = self.tools_dir / "ffmpeg" / "bin" / "ffmpeg.exe"

        # Animation templates for Egyptian characters
        self.animation_prompts = {
            "player_idle": "egyptian warrior standing idle, subtle breathing motion, khopesh sword at side, isometric pixel art",
            "player_walk": "egyptian warrior walking cycle, 8 frames, side view, rhythmic step motion, armor flowing",
            "player_attack": "egyptian warrior attacking with khopesh, slash motion, 6 frames, dynamic pose",
            "player_dash": "egyptian warrior dashing forward, motion blur effect, speed lines, 4 frames",

            "mummy_idle": "ancient mummy standing idle, bandages swaying gently, glowing eyes pulsing",
            "mummy_walk": "mummy shambling walk cycle, dragging feet, loose bandages, 8 frames",
            "mummy_attack": "mummy lunging attack, arms extended, bandages flying, 5 frames",

            "anubis_idle": "anubis guardian in idle stance, staff glowing, ears twitching slightly",
            "anubis_spell": "anubis casting death magic, staff raised, dark energy swirling, 8 frames",

            "magic_fireball": "egyptian fire spell animation, ra's flame orb growing and flying, 6 frames",
            "magic_lightning": "lightning bolt from egyptian staff, zigzag pattern, blue-white energy",
            "magic_heal": "isis healing magic, golden particles swirling upward, 8 frames"
        }

        self.frame_counts = {
            "idle": 8,
            "walk": 8,
            "attack": 6,
            "dash": 4,
            "spell": 8,
            "magic": 6
        }

    def generate_animatediff_workflow(self, prompt, frame_count=8):
        """Generate ComfyUI workflow with AnimateDiff for smooth animations."""
        workflow = {
            "1": {
                "inputs": {
                    "text": f"{prompt}, smooth animation, consistent character, pixel art style, 16 frames total",
                    "clip": ["10", 1]
                },
                "class_type": "CLIPTextEncode"
            },
            "2": {
                "inputs": {
                    "text": "blurry, inconsistent, deformed, bad animation, flickering",
                    "clip": ["10", 1]
                },
                "class_type": "CLIPTextEncode"
            },
            "3": {
                "inputs": {
                    "model": ["10", 0],
                    "motion_model": "mm_sd_v15_v2.ckpt"
                },
                "class_type": "AnimateDiffLoaderV1"
            },
            "4": {
                "inputs": {
                    "seed": int(time.time()),
                    "steps": 20,
                    "cfg": 8.0,
                    "sampler_name": "euler",
                    "scheduler": "normal",
                    "denoise": 1.0,
                    "model": ["3", 0],
                    "positive": ["1", 0],
                    "negative": ["2", 0],
                    "latent_image": ["5", 0]
                },
                "class_type": "KSampler"
            },
            "5": {
                "inputs": {
                    "width": 512,
                    "height": 512,
                    "batch_size": frame_count
                },
                "class_type": "EmptyLatentImage"
            },
            "6": {
                "inputs": {
                    "samples": ["4", 0],
                    "vae": ["10", 2]
                },
                "class_type": "VAEDecode"
            },
            "7": {
                "inputs": {
                    "filename_prefix": "egyptian_anim",
                    "format": "PNG",
                    "images": ["6", 0]
                },
                "class_type": "SaveImage"
            },
            "8": {
                "inputs": {
                    "images": ["6", 0],
                    "filename_prefix": "egyptian_video",
                    "fps": 12,
                    "quality": 95,
                    "method": "ffmpeg"
                },
                "class_type": "VHS_VideoCombine"
            },
            "10": {
                "inputs": {
                    "ckpt_name": "sd_xl_base_1.0.safetensors"
                },
                "class_type": "CheckpointLoaderSimple"
            }
        }
        return workflow

    def queue_animation(self, workflow):
        """Queue animation generation in ComfyUI."""
        try:
            response = requests.post(f"{self.comfyui_url}/prompt", json={"prompt": workflow})
            return response.json()
        except requests.exceptions.ConnectionError:
            print("[ERROR] ComfyUI not running! Start it with: python tools/ComfyUI/main.py")
            return None

    def wait_for_animation_completion(self, prompt_id):
        """Wait for animation generation to complete."""
        print("[WAIT] Generating animation frames...")
        start_time = time.time()

        while True:
            try:
                response = requests.get(f"{self.comfyui_url}/history/{prompt_id}")
                history = response.json()
                if prompt_id in history:
                    elapsed = time.time() - start_time
                    print(f"[COMPLETE] Animation generated in {elapsed:.1f} seconds")
                    return history[prompt_id]
            except:
                pass

            # Show progress
            if int(time.time() - start_time) % 5 == 0:
                elapsed = time.time() - start_time
                print(f"[PROGRESS] Generating... ({elapsed:.0f}s elapsed)")

            time.sleep(1)

    def process_animation_frames(self, video_path, animation_type):
        """Extract frames from generated video and process them."""
        print(f"[PROCESS] Extracting frames from {animation_type} animation...")

        # Create output directory
        output_dir = self.ai_assets_dir / "animations" / animation_type
        output_dir.mkdir(parents=True, exist_ok=True)

        # Extract frames using ffmpeg
        frames_pattern = output_dir / f"frame_%04d.png"
        cmd = [
            str(self.ffmpeg_path),
            "-i", str(video_path),
            "-vf", "scale=64:64:flags=neighbor",  # Pixel-perfect scaling
            str(frames_pattern)
        ]

        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"[SUCCESS] Frames extracted to {output_dir}")
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] Frame extraction failed: {e}")
            return []

        # Get list of generated frames
        frame_files = sorted(output_dir.glob("frame_*.png"))
        return frame_files

    def create_godot_spritesheet(self, frame_files, animation_type):
        """Create a Godot-compatible spritesheet from animation frames."""
        if not frame_files:
            return None

        print(f"[SPRITESHEET] Creating Godot spritesheet for {animation_type}...")

        # Load all frames
        frames = []
        frame_width = 64
        frame_height = 64

        for frame_file in frame_files:
            img = Image.open(frame_file).convert("RGBA")
            # Resize to consistent size
            img = img.resize((frame_width, frame_height), Image.NEAREST)
            frames.append(img)

        # Create horizontal spritesheet (Godot prefers this)
        spritesheet_width = len(frames) * frame_width
        spritesheet_height = frame_height

        spritesheet = Image.new("RGBA", (spritesheet_width, spritesheet_height), (0, 0, 0, 0))

        for i, frame in enumerate(frames):
            x = i * frame_width
            spritesheet.paste(frame, (x, 0))

        # Save spritesheet
        spritesheet_path = self.ai_assets_dir / "animations" / f"{animation_type}_spritesheet.png"
        spritesheet.save(spritesheet_path, "PNG")

        # Generate Godot-compatible metadata
        metadata = {
            "animation_type": animation_type,
            "frame_width": frame_width,
            "frame_height": frame_height,
            "frame_count": len(frames),
            "fps": 12,
            "loop": True,
            "spritesheet_path": str(spritesheet_path),
            "godot_import_settings": {
                "hframes": len(frames),
                "vframes": 1
            }
        }

        metadata_path = self.ai_assets_dir / "animations" / f"{animation_type}_metadata.json"
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2)

        print(f"[SUCCESS] Godot spritesheet created: {spritesheet_path}")
        return spritesheet_path

    def generate_character_animation_set(self, character_name):
        """Generate a complete animation set for a character."""
        animation_types = ["idle", "walk", "attack"]
        generated_animations = []

        for anim_type in animation_types:
            prompt_key = f"{character_name}_{anim_type}"
            if prompt_key not in self.animation_prompts:
                print(f"[SKIP] No prompt defined for {prompt_key}")
                continue

            print(f"\n[ANIMATE] Generating {character_name} {anim_type} animation...")

            # Get frame count for this animation type
            frame_count = self.frame_counts.get(anim_type, 8)
            prompt = self.animation_prompts[prompt_key]

            # Generate workflow
            workflow = self.generate_animatediff_workflow(prompt, frame_count)

            # Queue animation
            result = self.queue_animation(workflow)
            if not result:
                continue

            prompt_id = result["prompt_id"]
            print(f"[QUEUE] Animation queued with ID: {prompt_id}")

            # Wait for completion
            history = self.wait_for_animation_completion(prompt_id)

            if history and "outputs" in history:
                # Find generated video
                for node_id, output in history["outputs"].items():
                    if "gifs" in output:  # AnimateDiff outputs as GIF/video
                        for vid_info in output["gifs"]:
                            # Download video
                            vid_url = f"{self.comfyui_url}/view?filename={vid_info['filename']}&subfolder={vid_info.get('subfolder', '')}&type={vid_info.get('type', 'output')}"

                            vid_response = requests.get(vid_url)
                            temp_video_path = Path(f"temp_{character_name}_{anim_type}.mp4")

                            with open(temp_video_path, 'wb') as f:
                                f.write(vid_response.content)

                            # Process frames
                            frame_files = self.process_animation_frames(temp_video_path, f"{character_name}_{anim_type}")

                            if frame_files:
                                spritesheet_path = self.create_godot_spritesheet(frame_files, f"{character_name}_{anim_type}")
                                if spritesheet_path:
                                    generated_animations.append(spritesheet_path)

                            # Clean up temp video
                            temp_video_path.unlink()

        return generated_animations

def main():
    """Main animation generation function."""
    print("==> Egyptian Hack'n'Slash Animation Builder")
    print("==> AnimateDiff v3 + RTX 5070 Pipeline")
    print("-" * 50)

    builder = EgyptianAnimationBuilder()

    # Generate character animation sets
    characters = ["player", "mummy"]

    for character in characters:
        print(f"\n[CHARACTER] Generating animation set for {character}...")
        animations = builder.generate_character_animation_set(character)

        if animations:
            print(f"[SUCCESS] Generated {len(animations)} animations for {character}")
        else:
            print(f"[WARNING] No animations generated for {character}")

    print("\n[COMPLETE] Animation generation pipeline finished!")
    print("[NEXT] Check ai_assets/animations/ for generated content")

if __name__ == "__main__":
    main()