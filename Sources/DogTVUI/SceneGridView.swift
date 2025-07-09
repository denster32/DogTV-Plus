// swiftlint:disable import_organization availability_attributes
import SwiftUI
import DogTVCore
// swiftlint:enable import_organization

@available(iOS 17.0, tvOS 17.0, macOS 11.0, *)
struct SceneGridView: View {
    @EnvironmentObject var dogTVCore: DogTVCore

    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            if dogTVCore.isPlaying, let currentScene = dogTVCore.currentScene {
                VStack {
                    ZStack {
                        // MetalView(sceneType: currentScene.type)
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .overlay(
                                Text("Scene: \(currentScene.name)")
                                    .foregroundColor(.white)
                            )
                    }
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .cornerRadius(20)
                    .padding()
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                    Text(currentScene.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, -10)

                    Text(currentScene.description)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)

                    Button(action: {
                        Task {
                            try? await dogTVCore.stopScene()
                        }
                    }) {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.title2)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .shadow(radius: 5)
                }
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(dogTVCore.contentService.availableScenes) { scene in
                        SceneCard(scene: scene)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("DogTV+ Scenes")
    }
}
// swiftlint:enable availability_attributes
