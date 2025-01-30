//
//  Extenstions.swift
//  FaceBlur
//
//  Created by Joe Donino on 1/29/25.
//

import Foundation
import Metal
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation


extension CGImage{
    func blurImageRegion(region: CGRect, blurRadius: Float = 10.0) -> CGImage? {
        // Create CIImage from CGImage
        let ciImage = CIImage(cgImage: self)
        
        // Convert normalized coordinates to pixel coordinates
        let pixelRect = CGRect(
            x: region.origin.x * CGFloat(self.width),
            y: region.origin.y * CGFloat(self.height),
            width: region.size.width * CGFloat(self.width),
            height: region.size.height * CGFloat(self.height)
        )
        
        // Create a rectangle mask
        let rectMask = CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: 1))
            .cropped(to: pixelRect)
        
        // Apply gaussian blur to the entire image
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = ciImage
        blur.radius = blurRadius
        
        guard let blurredImage = blur.outputImage else { return nil }
        
        // Create blend with mask filter
        let blend = CIFilter.blendWithMask()
        blend.inputImage = blurredImage
        blend.backgroundImage = ciImage
        blend.maskImage = rectMask
        
        guard let outputImage = blend.outputImage else { return nil }
        
        // Create context and render final image
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return cgImage
    }
    
        func blurImageRegions(regions: [CGRect], blurRadius: Float = 10.0) -> CGImage? {
            guard !regions.isEmpty else {
                return self
            }
            // Create CIImage from CGImage
            let ciImage = CIImage(cgImage: self)
            
            // Apply gaussian blur to the entire image once
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = ciImage
            blur.radius = blurRadius
            
            guard let blurredImage = blur.outputImage else { return nil }
            
            // Create combined mask for all regions
            var combinedMask: CIImage?
            
            for region in regions {
                // Convert normalized coordinates to pixel coordinates for each region
                let pixelRect = CGRect(
                    x: region.origin.x * CGFloat(self.width),
                    y: region.origin.y * CGFloat(self.height),
                    width: region.size.width * CGFloat(self.width),
                    height: region.size.height * CGFloat(self.height)
                )
                
                // Create a rectangle mask for this region
                let rectMask = CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: 1))
                    .cropped(to: pixelRect)
                
                if let existingMask = combinedMask {
                    // Combine with existing mask using maximum blend
                    let maximumCompose = CIFilter.maximumCompositing()
                    maximumCompose.inputImage = existingMask
                    maximumCompose.backgroundImage = rectMask
                    combinedMask = maximumCompose.outputImage
                } else {
                    combinedMask = rectMask
                }
            }
            
            guard let finalMask = combinedMask else { return nil }
            
            // Create final blend with combined mask
            let blend = CIFilter.blendWithMask()
            blend.inputImage = blurredImage
            blend.backgroundImage = ciImage
            blend.maskImage = finalMask
            
            guard let outputImage = blend.outputImage else { return nil }
            
            // Create context and render final image
            let context = CIContext()
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                return nil
            }
            
            return cgImage
        }
}


extension CIImage {
    
    var cgImage: CGImage? {
        let ciContext = CIContext()
        
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        
        return cgImage
    }
    var rotatedCGImage: CGImage? {
        let transformed = self.transformed(by: CGAffineTransform(rotationAngle: -.pi/2)
            .translatedBy(
                    x: -self.extent.height,
                    y: 0
            ))
                
        let context = CIContext()
        return context.createCGImage(transformed, from: transformed.extent)
    }
}


extension CMSampleBuffer {
    
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        
        guard let imagePixelBuffer = pixelBuffer else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: imagePixelBuffer).rotatedCGImage
    }
    
}
