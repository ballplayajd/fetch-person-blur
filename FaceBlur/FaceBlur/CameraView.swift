//
//  CameraView.swift
//  FaceBlur
//
//  Created by Joe Donino on 1/29/25.
//

import SwiftUI

import SwiftUI

struct CameraView: View {
    
    @Binding var image: CGImage?
    
    var body: some View {
        GeometryReader { geometry in
            if let image = image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
            } else {
                VStack{
                    Text("Content Unavailable")
                    Image(systemName: "xmark.circle.fill")
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
}
