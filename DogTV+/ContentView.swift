//
//  ContentView.swift
//  DogTV+
//
//  Created by Denster on 7/6/25.
//

import SwiftUI

import VisualRenderer  // For breed-specific visuals
import CanineAudioEngine  // For audio adjustments
import RelaxationOrchestrator  // For behavior-based content
import PerformanceOptimizer  // For performance monitoring

struct ContentView: View {
    @State private var selectedBreed: String = "Default"
    @State private var behaviorData: BehaviorData? = nil  // From CanineBehaviorAnalyzer
    
    var body: some View {
        VStack {
            // UI for breed selection
            Picker("Select Breed", selection: $selectedBreed) {
                Text("Default").tag("Default")
                Text("Labrador").tag("Labrador")
                Text("Siberian Husky").tag("Siberian Husky")
            }
            .onChange(of: selectedBreed) { newBreed in
                VisualRenderer.shared.optimizeForBreed(breed: newBreed)
            }
            
            // Dynamic content based on behavior
            if let data = behaviorData {
                Text("Current State: \(data.type.rawValue)")
                RelaxationOrchestrator.shared.selectContentBasedOnBehavior(behaviorData: data)
            }
            
            // Performance monitoring indicator
            Text("Performance Status: \(PerformanceOptimizer.shared.getStatus())")  // Assuming a getStatus method
                .onAppear {
                    PerformanceOptimizer.shared.startMonitoring()
                }
            
            // Main content view
            ZStack {
                VisualRenderer.shared.renderView()  // Integrated visual rendering
                CanineAudioEngine.shared.playAudio()  // Background audio
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
