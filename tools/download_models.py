#!/usr/bin/env python3
"""
Premium Model Downloader for Egyptian Hack'n'Slash Project
Optimized for RTX 5070 - Maximum Quality Pipeline

Downloads:
- SDXL Base + Refiner
- AnimateDiff v3 + Motion LoRAs
- ControlNet XL Suite
- Premium LoRAs (Pixel Art, Isometric, Egyptian)
- Upscaling Models
"""

import os
import requests
from urllib.parse import urlparse
from pathlib import Path
import sys
from tqdm import tqdm

# Base paths
COMFYUI_PATH = Path("ComfyUI")
MODELS_PATH = COMFYUI_PATH / "models"

# Model URLs and destinations
MODELS_TO_DOWNLOAD = {
    # SDXL Base Models
    "checkpoints": {
        "sd_xl_base_1.0.safetensors": "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors",
        "sd_xl_refiner_1.0.safetensors": "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors",
    },

    # VAE
    "vae": {
        "sdxl_vae.safetensors": "https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors",
    },

    # AnimateDiff
    "animatediff_models": {
        "mm_sd_v15_v2.ckpt": "https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt",
        "mm_sdxl_v10_beta.ckpt": "https://huggingface.co/guoyww/animatediff/resolve/main/mm_sdxl_v10_beta.ckpt",
    },

    # ControlNet XL
    "controlnet": {
        "diffusers_xl_canny_mid.safetensors": "https://huggingface.co/diffusers/controlnet-canny-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors",
        "diffusers_xl_depth_mid.safetensors": "https://huggingface.co/diffusers/controlnet-depth-sdxl-1.0/resolve/main/diffusion_pytorch_model.safetensors",
        "control_lora_rank128_v11p_sd15_openpose.safetensors": "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth",
    },

    # Upscaling Models
    "upscale_models": {
        "ESRGAN_4x_UltraSharp.pth": "https://huggingface.co/lokCX/4x-Ultrasharp/resolve/main/4x-UltraSharp.pth",
        "RealESRGAN_x4plus.pth": "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth",
    },

    # Egyptian Hack'n'Slash Specialized LoRAs
    "loras": {
        # Core Game Art Style
        "pixel_art_xl.safetensors": "https://huggingface.co/nerijs/pixel-art-xl/resolve/main/pixel-art-xl.safetensors",
        "isometric_game_xl.safetensors": "https://civitai.com/api/download/models/15236?type=Model&format=SafeTensor",

        # Egyptian & Ancient Themes
        "ancient_egypt_xl.safetensors": "https://civitai.com/api/download/models/128459?type=Model&format=SafeTensor",
        "pharaoh_style_xl.safetensors": "https://civitai.com/api/download/models/167234?type=Model&format=SafeTensor",

        # RPG & Combat
        "rpg_character_xl.safetensors": "https://civitai.com/api/download/models/194567?type=Model&format=SafeTensor",
        "weapon_design_xl.safetensors": "https://civitai.com/api/download/models/145623?type=Model&format=SafeTensor",
        "magic_effects_xl.safetensors": "https://civitai.com/api/download/models/189432?type=Model&format=SafeTensor",

        # Quality Enhancement
        "detail_tweaker_xl.safetensors": "https://civitai.com/api/download/models/135867?type=Model&format=SafeTensor",
        "sharp_detail_xl.safetensors": "https://civitai.com/api/download/models/203847?type=Model&format=SafeTensor",
    }
}

def download_file(url: str, destination: Path, desc: str = None):
    """Download a file with progress bar."""
    if destination.exists():
        print(f"[OK] {destination.name} already exists, skipping...")
        return True

    try:
        print(f"[DOWNLOAD] {desc or destination.name}...")

        response = requests.get(url, stream=True)
        response.raise_for_status()

        total_size = int(response.headers.get('content-length', 0))

        destination.parent.mkdir(parents=True, exist_ok=True)

        with open(destination, 'wb') as f, tqdm(
            desc=destination.name,
            total=total_size,
            unit='B',
            unit_scale=True,
            unit_divisor=1024,
        ) as pbar:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    pbar.update(len(chunk))

        print(f"[SUCCESS] Downloaded {destination.name}")
        return True

    except Exception as e:
        print(f"[ERROR] Failed to download {destination.name}: {e}")
        if destination.exists():
            destination.unlink()  # Remove partial file
        return False

def main():
    """Main download function."""
    print("==> Starting Premium Model Download for Egyptian Hack'n'Slash")
    print("==> Optimized for RTX 5070 - Maximum Quality Pipeline")
    print("-" * 60)

    if not COMFYUI_PATH.exists():
        print(f"[ERROR] ComfyUI not found at {COMFYUI_PATH}")
        print("Please run this script from the tools directory!")
        sys.exit(1)

    total_downloads = sum(len(models) for models in MODELS_TO_DOWNLOAD.values())
    completed = 0

    for model_type, models in MODELS_TO_DOWNLOAD.items():
        print(f"\n[CATEGORY] Downloading {model_type.upper()} models...")

        # Create special directory for animatediff
        if model_type == "animatediff_models":
            model_dir = MODELS_PATH / "animatediff_models"
        else:
            model_dir = MODELS_PATH / model_type

        model_dir.mkdir(parents=True, exist_ok=True)

        for filename, url in models.items():
            destination = model_dir / filename
            if download_file(url, destination, f"{model_type}/{filename}"):
                completed += 1

    print(f"\n[SUMMARY] Download Summary: {completed}/{total_downloads} models downloaded!")

    if completed == total_downloads:
        print("[SUCCESS] All premium models downloaded successfully!")
        print("[READY] Your RTX 5070 is ready for MAXIMUM QUALITY generation!")
    else:
        print(f"[WARNING] {total_downloads - completed} downloads failed. Check your internet connection.")

    print("\n[NEXT STEPS]")
    print("1. Launch ComfyUI: python main.py")
    print("2. Install additional LoRAs via ComfyUI-Manager")
    print("3. Start generating Egyptian-themed assets!")

if __name__ == "__main__":
    main()