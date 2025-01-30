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

## Requirements

- iOS 16.0+
- Xcode 13.0+
- Python 3.7+ (for ML model conversion)
- Camera access permission

## Installation

1. Clone the repository:
