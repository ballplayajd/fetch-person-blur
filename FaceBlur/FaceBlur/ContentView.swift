//
//  ContentView.swift
//  FaceBlur
//
//  Created by Joe Donino on 1/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        CameraView(image: $viewModel.currentFrame)
            .onAppear(){
                viewModel.start()
            }
            .onDisappear(){
                viewModel.stop()
            }
            .overlay(alignment: .bottomTrailing){
                VStack(alignment: .trailing){
                    Text("Blur")
                        .foregroundColor(.white)
                        .font(Font.system(size: 20, weight: .bold))
                    Toggle(isOn: $viewModel.blurOn){
                        EmptyView()
                    }
                }
                .padding(16)
            }
    }
}

#Preview {
    ContentView()
}
