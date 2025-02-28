# Person Blur iOS App

[Watch Demo Video](https://youtube.com/shorts/tTboWCEDRCM)

An iOS application that uses computer vision to detect and blur people in real-time camera feed, running at 24 FPS with toggleable blur effects.

## Overview

This project consists of two main components:

1. iOS Application (`/FaceBlur`)
   - Real-time camera feed processing at 24 FPS
   - Face detection and blurring using CoreML
   - Toggleable blur effect
   - Direct CGImage modification for optimal performance
   - Privacy-focused interface

2. ML Model Training (`/ML Training`) 
   - YOLO model training and conversion scripts
   - CoreML model generation utilities
   - Python environment setup:
     ```bash
     python -m venv env
     source env/bin/activate  # On Unix/macOS
     # or
     .\env\Scripts\activate  # On Windows
     pip install -r requirements.txt
     ```

## Requirements

- iOS 16.0+
- Xcode 13.0+
- Python 3.7+ (for ML model conversion)
- Camera access permission

## Installation

1. Clone the repository:
2. Open /FaceBlur with Xcode
3. Run the app

## Usage

1. Open the app
2. Allow camera access
3. Toggle blur effect
4. Enjoy the app
