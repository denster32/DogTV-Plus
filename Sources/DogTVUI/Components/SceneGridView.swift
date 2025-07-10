// swiftlint:disable import_organization availability_attributes
import SwiftUI
import DogTVCore
// swiftlint:enable import_organization

@available(iOS 17.0, tvOS 17.0, macOS 11.0, *)
struct SceneGridView: View {
    @EnvironmentObject var dogTVCore: DogTVCore
    @FocusState private var focusedSceneID: String?

    private let columns = [
        GridItem(.adaptive(minimum: 350, maximum: 500), spacing: DogTVDesignSystem.Spacing.lg)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DogTVDesignSystem.Spacing.xl) {
                    if dogTVCore.isPlaying, let currentScene = dogTVCore.currentScene {
                        CurrentSceneView(scene: currentScene)
                            .accessibilityIdentifier("current_scene_view")
                    } else {
                        SceneCollectionView()
                            .accessibilityIdentifier("scene_collection_view")
                    }
                }
                .padding(.horizontal, DogTVDesignSystem.Spacing.lg)
                .padding(.bottom, DogTVDesignSystem.Spacing.xl)
                .padding(.horizontal, 80) // HIG safe area for tvOS
                .padding(.vertical, 60) // HIG safe area for tvOS
            }
            .navigationTitle("DogTV+ Scenes")
            .navigationBarTitleDisplayMode(.large)
            .dynamicTypeSize(.large...(.accessibility1))
        }
        .accessibilityIdentifier("scene_grid_view")
    }
    
    private struct CurrentSceneView: View {
        let scene: Scene
        @EnvironmentObject var dogTVCore: DogTVCore
        
        var body: some View {
            VStack(spacing: DogTVDesignSystem.Spacing.lg) {
                // Large scene preview
                ZStack {
                    Rectangle()
                        .fill(sceneColor.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: sceneIcon)
                                    .font(.system(size: 120))
                                    .foregroundColor(sceneColor)
                                
                                Text("Scene: \(scene.name)")
                                    .font(DogTVDesignSystem.Typography.dynamicTitle)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .dynamicTypeSize(.large...(.accessibility1))
                            }
                        )
                }
                .aspectRatio(16 / 9, contentMode: .fit)
                .cornerRadius(DogTVDesignSystem.AppleTVFocus.focusCornerRadiusLarge)
                .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)

                VStack(spacing: DogTVDesignSystem.Spacing.md) {
                    Text(scene.name)
                        .font(DogTVDesignSystem.Typography.dynamicLargeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(DogTVDesignSystem.Colors.dogTextPrimary)
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(.large...(.accessibility1))

                    Text(scene.description)
                        .font(DogTVDesignSystem.Typography.dynamicHeadline)
                        .foregroundColor(DogTVDesignSystem.Colors.dogTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .dynamicTypeSize(.large...(.accessibility1))
                }

                HStack(spacing: DogTVDesignSystem.Spacing.lg) {
                    DogTVFocusButton(
                        title: "Pause",
                        icon: "pause.fill",
                        style: .secondary
                    ) {
                        Task {
                            try? await dogTVCore.pauseScene()
                        }
                    }
                    
                    DogTVFocusButton(
                        title: "Stop",
                        icon: "stop.fill",
                        style: .destructive
                    ) {
                        Task {
                            try? await dogTVCore.stopScene()
                        }
                    }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Currently playing \(scene.name)")
        }
        
        private var sceneColor: Color {
            switch scene.type {
            case .ocean: return .blue
            case .forest: return .green
            case .fireflies: return .yellow
            case .rain: return .cyan
            case .sunset: return .orange
            case .stars: return .purple
            }
        }
        
        private var sceneIcon: String {
            switch scene.type {
            case .ocean: return "water.waves"
            case .forest: return "tree.fill"
            case .fireflies: return "sparkles"
            case .rain: return "cloud.rain.fill"
            case .sunset: return "sun.max.fill"
            case .stars: return "moon.stars.fill"
            }
        }
    }
    
    private struct SceneCollectionView: View {
        @EnvironmentObject var dogTVCore: DogTVCore
        @FocusState private var focusedSceneID: String?
        
        private let columns = [
            GridItem(.adaptive(minimum: 350, maximum: 500), spacing: DogTVDesignSystem.Spacing.lg)
        ]
        
        var body: some View {
            VStack(spacing: DogTVDesignSystem.Spacing.lg) {
                Text("Choose Your Scene")
                    .font(DogTVDesignSystem.Typography.dynamicTitle)
                    .fontWeight(.bold)
                    .foregroundColor(DogTVDesignSystem.Colors.dogTextPrimary)
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.large...(.accessibility1))
                
                LazyVGrid(columns: columns, spacing: DogTVDesignSystem.Spacing.lg) {
                    ForEach(dogTVCore.contentService.availableScenes) { scene in
                        DogTVFocusCard(scene: scene) {
                            Task {
                                try? await dogTVCore.playScene(scene)
                            }
                        }
                        .focused($focusedSceneID, equals: scene.id)
                    }
                }
            }
            .onAppear {
                // Set focus to first scene when view appears
                if let firstScene = dogTVCore.contentService.availableScenes.first {
                    focusedSceneID = firstScene.id
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Scene selection grid with \(dogTVCore.contentService.availableScenes.count) available scenes")
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, tvOS 17.0, macOS 11.0, *)
struct SceneGridView_Previews: PreviewProvider {
    static var previews: some View {
        SceneGridView()
            .environmentObject(DogTVCore.shared)
            .preferredColorScheme(.dark)
    }
}
// swiftlint:enable availability_attributes
