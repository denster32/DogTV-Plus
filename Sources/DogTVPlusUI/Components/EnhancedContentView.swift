// swiftlint:disable import_organization availability_attributes
import SwiftUI
import DogTVCore
import struct DogTVCore.Scene

// swiftlint:enable import_organization

/// Enhanced ContentView with Apple TV HIG compliance and focus management
@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
public struct EnhancedContentView: View {
    @EnvironmentObject var dogTVCore: DogTVCore
    @State private var selectedScene: Scene?
    @FocusState private var focusedSection: FocusSection?
    
    private enum FocusSection: Hashable {
        case header
        case content
        case controls
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DogTVDesignSystem.Spacing.xl) {
                    HeaderView()
                        .focused($focusedSection, equals: .header)

                    if dogTVCore.isPlaying {
                        PlayingView()
                            .focused($focusedSection, equals: .content)
                    } else {
                        SceneSelectionView()
                            .focused($focusedSection, equals: .content)
                    }
                    
                    // Add some bottom padding for focus navigation
                    Spacer(minLength: DogTVDesignSystem.Spacing.xl)
                }
                .padding(.horizontal, DogTVDesignSystem.Spacing.lg)
            }
            .padding(.horizontal)
            .padding(.vertical)
            .navigationTitle("DogTV+ Enhanced")
            .navigationBarTitleDisplayMode(.large)
            .dynamicTypeSize(.large...(.accessibility1))
        }
        .onAppear {
            // Set initial focus to content area
            focusedSection = .content
        }
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct HeaderView: View {
    var body: some View {
        VStack(spacing: DogTVDesignSystem.Spacing.md) {
            Text("DogTV+ Enhanced")
                .font(DogTVDesignSystem.Typography.dynamicLargeTitle)
                .fontWeight(.bold)
                .foregroundColor(DogTVDesignSystem.Colors.dogTextPrimary)
                .multilineTextAlignment(.center)
                .dynamicTypeSize(.large...(.accessibility1))

            Text("Canine Entertainment with Advanced Features")
                .font(DogTVDesignSystem.Typography.dynamicHeadline)
                .foregroundColor(DogTVDesignSystem.Colors.dogTextSecondary)
                .multilineTextAlignment(.center)
                .dynamicTypeSize(.large...(.accessibility1))
        }
        .padding(.vertical, DogTVDesignSystem.Spacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("DogTV+ Enhanced Header")
        .accessibilityHint("Welcome to the enhanced DogTV+ experience.")
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct PlayingView: View {
    @EnvironmentObject var dogTVCore: DogTVCore

    var body: some View {
        VStack(spacing: DogTVDesignSystem.Spacing.lg) {
            // Now Playing header
            Text("Now Playing")
                .font(DogTVDesignSystem.Typography.dynamicTitle)
                .fontWeight(.semibold)
                .foregroundColor(DogTVDesignSystem.Colors.dogTextPrimary)
                .dynamicTypeSize(.large...(.accessibility1))

            // Scene info card
            VStack(spacing: DogTVDesignSystem.Spacing.md) {
                Text(dogTVCore.currentScene?.name ?? "Unknown Scene")
                    .font(DogTVDesignSystem.Typography.dynamicTitle2)
                    .foregroundColor(DogTVDesignSystem.Colors.dogPlayful)
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(.large...(.accessibility1))

                Text(dogTVCore.currentScene?.description ?? "")
                    .font(DogTVDesignSystem.Typography.dynamicBody)
                    .foregroundColor(DogTVDesignSystem.Colors.dogTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .dynamicTypeSize(.large...(.accessibility1))
            }
            .padding(DogTVDesignSystem.Spacing.lg)
            .background(DogTVDesignSystem.Colors.dogSoft)
            .cornerRadius(DogTVDesignSystem.Layout.cornerRadiusLarge)
            
            // Control buttons
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
                    title: "Stop Scene",
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
        .accessibilityLabel("Playback controls for the current scene.")
        .accessibilityHint("You can pause or stop the scene from here.")
    }
}

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
private struct SceneSelectionView: View {
    @EnvironmentObject var dogTVCore: DogTVCore
    @FocusState private var focusedSceneID: String?

    var body: some View {
        VStack(spacing: DogTVDesignSystem.Spacing.lg) {
            Text("Choose a Scene")
                .font(DogTVDesignSystem.Typography.dynamicTitle2)
                .fontWeight(.semibold)
                .foregroundColor(DogTVDesignSystem.Colors.dogTextPrimary)
                .dynamicTypeSize(.large...(.accessibility1))

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300, maximum: 400), spacing: DogTVDesignSystem.Spacing.lg)
            ], spacing: DogTVDesignSystem.Spacing.lg) {
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
        .accessibilityLabel("Scene selection grid")
        .accessibilityHint("Browse and select a scene to begin playback.")
    }
}

// MARK: - Preview

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
struct EnhancedContentView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedContentView()
            .environmentObject(DogTVCore.shared)
            .preferredColorScheme(.dark)
    }
}
// swiftlint:enable availability_attributes
