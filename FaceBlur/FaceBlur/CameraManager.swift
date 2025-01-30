//
//  CameraManager.swift
//  FaceBlur
//
//  Created by Joe Donino on 1/29/25.
//

import Foundation
import AVFoundation
import Vision
import CoreImage
import UIKit

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.fetch.sessionQueue")
    private var deviceInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var thermalStateObservation: NSKeyValueObservation?
    var fps: Int = 24
    
   
    private var isProcessing = false

    override init() {
        super.init()
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }
    
    private var addToPreviewStream: ((CGImage) -> Void)?
       
       lazy var previewStream: AsyncStream<CGImage> = {
           AsyncStream { continuation in
               addToPreviewStream = { cgImage in
                   continuation.yield(cgImage)
               }
           }
       }()
    
    private func configureSession() {
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else { return }
        
        // Configure device frame rate
        do {
            try device.lockForConfiguration()
            let format = device.activeFormat
            let desiredFPS: Double = Double(fps)
            let frameDuration = CMTime(value: 1, timescale: CMTimeScale(desiredFPS))
            
            if format.videoSupportedFrameRateRanges.contains(where: {
                $0.minFrameRate...$0.maxFrameRate ~= desiredFPS
            }) {
                device.activeVideoMinFrameDuration = frameDuration
                device.activeVideoMaxFrameDuration = frameDuration
            }
            device.unlockForConfiguration()
        } catch {
            print("Error configuring device: \(error)")
        }
        
        // Add video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        self.videoOutput = videoOutput
        guard captureSession.canAddInput(input),
              captureSession.canAddOutput(videoOutput) else { return }
        
        captureSession.addInput(input)
        captureSession.addOutput(videoOutput)
    }
    
    private func setupObservers() {
        thermalStateObservation = ProcessInfo.processInfo.observe(\.thermalState) { [weak self] _, _ in
            self?.handleThermalStateChange()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    private func handleThermalStateChange() {
        let state = ProcessInfo.processInfo.thermalState.rawValue
        if state >= ProcessInfo.ThermalState.serious.rawValue {
            reduceFPS()
        }
    }

    @objc private func handleMemoryWarning() {
        reduceFPS()
    }
    
    func reduceFPS(){
        stopSession()
        self.fps = 10
        self.configureSession()
        self.startSession()
    }
    
   
    
    func startSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    // MARK: - Video Processing
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !isProcessing else {return}
        
        isProcessing = true
        
        guard let currentFrame = sampleBuffer.cgImage else { return }
        addToPreviewStream?(currentFrame)
        self.isProcessing = false
    }
    
   
    
    private func convertVisionRect(_ visionRect: CGRect) -> CGRect {
        guard let previewLayer = previewLayer else { return .zero }
        return previewLayer.layerRectConverted(fromMetadataOutputRect: visionRect)
    }
}



