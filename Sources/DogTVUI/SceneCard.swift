// swiftlint:disable import_organization
import SwiftUI
import DogTVCore
import DogTVVision
// swiftlint:enable import_organization

// swiftlint:disable:next availability_attributes
@available(iOS 17.0, tvOS 17.0, macOS 11.0, *)
struct SceneCard: View {
    let scene: Scene
    @EnvironmentObject var dogTVCore: DogTVCore

    var body: some View {
        VStack {
            ZStack {
                // MetalView(sceneType: scene.type)
            }
            .frame(height: 150)
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(scene.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(scene.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.dogSoft) // Using custom design system color
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .onTapGesture {
            Task {
                if dogTVCore.isPlaying && dogTVCore.currentScene?.id == scene.id {
                    try? await dogTVCore.stopScene()
                } else {
                    try? await dogTVCore.startScene(scene)
                }
            }
        }
    }
}
