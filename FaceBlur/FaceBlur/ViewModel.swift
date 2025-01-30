//
//  ViewModel.swift
//  FaceBlur
//
//  Created by Joe Donino on 1/29/25.
//

import Foundation
import CoreImage
import Vision

class ViewModel: ObservableObject {
    
    private let cameraManager = CameraManager()
    private var request: VNRequest!
    
    @Published var currentFrame: CGImage?
    @Published var detectedBoxes: [CGRect] = []
    @Published var blurOn: Bool = true

    var isProcessing: Bool = false
    
    init() {
        setupCoreML()
        Task {
            await handleCameraPreviews()
        }
    }
    
    func start(){
        self.cameraManager.startSession()
    }
    
    func stop(){
        self.cameraManager.stopSession()
    }
    
    private func setupCoreML() {
        let modelConfig = MLModelConfiguration()
        modelConfig.allowLowPrecisionAccumulationOnGPU = false
        modelConfig.computeUnits = .cpuAndNeuralEngine
        if #available(iOS 17, *) {
        
            modelConfig.setValue(1, forKey: "experimentalMLE5EngineUsage")
        }
        guard let model = try? VNCoreMLModel(for: yolo11s(configuration: modelConfig).model) else {
            fatalError("Failed to load CoreML model")
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.processPredictions(for: request, error: error)
        }
        request.imageCropAndScaleOption = .scaleFill
        self.request = request
    }
    
    func handleCameraPreviews() async {
        for await image in cameraManager.previewStream {
            Task{@MainActor in
                if blurOn{
                    runDetection(cgImage: image)
                    self.currentFrame = image.blurImageRegions(regions: self.detectedBoxes, blurRadius: 10.0)
                }else{
                    self.currentFrame = image
                }
            }
        }
    }
    
    func runDetection(cgImage: CGImage){
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Detection error: \(error)")
            isProcessing = false
        }
    }
    
    private func processPredictions(for request: VNRequest, error: Error?){
        defer { isProcessing = false }
        
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return}
        
        let people = results.filter {
            $0.labels.first?.identifier == "person" && $0.confidence > 0.5
        }
        self.detectedBoxes =  people.map {
            $0.boundingBox
        }
    }
}
