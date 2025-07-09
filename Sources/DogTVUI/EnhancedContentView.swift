// swiftlint:disable import_organization availability_attributes
import SwiftUI
import DogTVCore

typealias AppScene = DogTVCore.Scene
// swiftlint:enable import_organization

/// Enhanced ContentView with procedural content generation and canine optimization
@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
public struct EnhancedContentView: View {
    @EnvironmentObject var dogTVCore: DogTVCore
    @State private var selectedScene: AppScene?

    public init() {}

    public var body: some View {
        NavigationView {
            VStack {
                HeaderView()

                if dogTVCore.isPlaying {
                    PlayingView()
                } else {
                    SceneSelectionView()
                }

                Spacer()
            }
            .navigationTitle("DogTV+ Enhanced")
        }
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct HeaderView: View {
    var body: some View {
        VStack {
            Text("DogTV+ Enhanced")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Canine Entertainment with Advanced Features")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct PlayingView: View {
    @EnvironmentObject var dogTVCore: DogTVCore

    var body: some View {
        VStack {
            Text("Now Playing")
                .font(.title)
                .fontWeight(.semibold)
                .padding()

            Text(dogTVCore.currentScene?.name ?? "Unknown Scene")
                .font(.title2)
                .foregroundColor(.blue)
                .padding()

            Text(dogTVCore.currentScene?.description ?? "")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Button("Stop Scene") {
                Task {
                    try? await dogTVCore.stopScene()
                }
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct SceneSelectionView: View {
    @EnvironmentObject var dogTVCore: DogTVCore

    var body: some View {
        VStack {
            Text("Choose a Scene")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 200))
            ], spacing: 15) {
                ForEach(dogTVCore.contentService.availableScenes) { scene in
                    EnhancedSceneCard(scene: scene)
                }
            }
            .padding()
        }
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct EnhancedSceneCard: View {
    let scene: AppScene
    @EnvironmentObject var dogTVCore: DogTVCore
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 12) {
            // Scene Icon
            Image(systemName: sceneIcon(for: scene.type))
                .font(.system(size: 40))
                .foregroundColor(sceneColor(for: scene.type))
                .padding()

            // Scene Details
            VStack(spacing: 8) {
                Text(scene.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(scene.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                // Duration
                Text("Duration: \(Int(scene.duration / 60)) min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)

            // Play Button
            Button(action: {
                Task {
                    try? await dogTVCore.startScene(scene)
                }
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.green)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private func sceneIcon(for type: SceneType) -> String {
        switch type {
        case .ocean: return "water.waves"
        case .forest: return "tree.fill"
        case .fireflies: return "sparkles"
        case .rain: return "cloud.drizzle.fill"
        case .sunset: return "sun.max.fill"
        case .stars: return "star.fill"
        }
    }

    private func sceneColor(for type: SceneType) -> Color {
        switch type {
        case .ocean: return .blue
        case .forest: return .green
        case .fireflies: return .yellow
        case .rain: return .gray
        case .sunset: return .orange
        case .stars: return .purple
        }
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct EnhancedSceneCard_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedSceneCard(scene: Scene.example)
            .environmentObject(DogTVCore())
    }
}
// swiftlint:enable availability_attributes
