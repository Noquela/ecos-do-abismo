#!/usr/bin/env python3
"""
FFmpeg Setup Script for Egyptian Hack'n'Slash Project
Downloads and configures FFmpeg for audio/video processing
"""

import os
import requests
import zipfile
from pathlib import Path
import sys
import shutil

def download_ffmpeg():
    """Download and extract FFmpeg for Windows."""
    ffmpeg_url = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    tools_dir = Path(".")
    ffmpeg_zip = tools_dir / "ffmpeg.zip"
    ffmpeg_dir = tools_dir / "ffmpeg"

    try:
        print("[DOWNLOAD] Downloading FFmpeg...")
        response = requests.get(ffmpeg_url, stream=True)
        response.raise_for_status()

        with open(ffmpeg_zip, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

        print("[EXTRACT] Extracting FFmpeg...")
        with zipfile.ZipFile(ffmpeg_zip, 'r') as zip_ref:
            zip_ref.extractall(tools_dir)

        # Find the extracted folder and rename it
        extracted_folders = [d for d in tools_dir.iterdir() if d.is_dir() and d.name.startswith('ffmpeg-')]
        if extracted_folders:
            extracted_folders[0].rename(ffmpeg_dir)

        # Clean up zip file
        ffmpeg_zip.unlink()

        print(f"[SUCCESS] FFmpeg installed to {ffmpeg_dir}")
        print(f"[INFO] FFmpeg executable: {ffmpeg_dir / 'bin' / 'ffmpeg.exe'}")

        return ffmpeg_dir / 'bin' / 'ffmpeg.exe'

    except Exception as e:
        print(f"[ERROR] Failed to install FFmpeg: {e}")
        return None

def main():
    """Main setup function."""
    print("==> FFmpeg Setup for Egyptian Hack'n'Slash")
    print("-" * 40)

    if download_ffmpeg():
        print("\n[READY] FFmpeg is ready for audio/video processing!")
        print("[NEXT] You can now process audio and video files for your game assets.")
    else:
        print("\n[ERROR] FFmpeg setup failed. Please install manually.")
        sys.exit(1)

if __name__ == "__main__":
    main()