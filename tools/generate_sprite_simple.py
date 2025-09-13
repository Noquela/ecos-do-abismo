#!/usr/bin/env python3
"""
Simple sprite generator using ComfyUI API
"""

import json
import requests
import time
from pathlib import Path
import base64
from PIL import Image
import io

def generate_sprite():
    comfyui_url = "http://127.0.0.1:8188"

    # Load workflow
    workflow_path = Path("simple_sdxl_workflow.json")
    with open(workflow_path, "r") as f:
        workflow = json.load(f)

    # Update prompt for Egyptian warrior
    workflow["2"]["inputs"]["text"] = "egyptian warrior pharaoh, pixel art style, isometric top-down view, golden khopesh sword, royal armor, hieroglyphs, detailed pixel art, 64x64 game sprite, clean lines, vibrant colors"

    print("[GENERATE] Creating Egyptian warrior sprite...")
    print(f"[PROMPT] {workflow['2']['inputs']['text']}")

    # Submit prompt
    try:
        response = requests.post(f"{comfyui_url}/prompt", json={"prompt": workflow})
        response.raise_for_status()
        result = response.json()

        if "prompt_id" not in result:
            print(f"[ERROR] No prompt_id in response: {result}")
            return

        prompt_id = result["prompt_id"]
        print(f"[QUEUED] Prompt ID: {prompt_id}")

        # Wait for completion
        while True:
            status_response = requests.get(f"{comfyui_url}/history/{prompt_id}")
            if status_response.status_code == 200:
                history = status_response.json()
                if prompt_id in history:
                    print("[COMPLETED] Image generation finished!")

                    # Get output images
                    outputs = history[prompt_id]["outputs"]
                    if "7" in outputs and "images" in outputs["7"]:
                        for img_info in outputs["7"]["images"]:
                            filename = img_info["filename"]
                            print(f"[SUCCESS] Generated: {filename}")

                            # Download image
                            img_response = requests.get(f"{comfyui_url}/view?filename={filename}")
                            if img_response.status_code == 200:
                                # Save to ai_assets directory
                                output_dir = Path("../ai_assets/sprites")
                                output_dir.mkdir(parents=True, exist_ok=True)

                                output_path = output_dir / f"player_warrior_{int(time.time())}.png"
                                with open(output_path, "wb") as f:
                                    f.write(img_response.content)

                                print(f"[SAVED] {output_path}")

                                # Resize to game size (64x64)
                                img = Image.open(output_path)
                                img_resized = img.resize((64, 64), Image.Resampling.LANCZOS)

                                game_sprite_path = output_path.parent / f"game_{output_path.name}"
                                img_resized.save(game_sprite_path)
                                print(f"[RESIZED] {game_sprite_path}")

                    break

            print("[WAITING] Generation in progress...")
            time.sleep(2)

    except Exception as e:
        print(f"[ERROR] {e}")

if __name__ == "__main__":
    generate_sprite()