// swiftlint:disable import_organization
import SwiftUI
import DogTVCore
import DogTVVision
// swiftlint:enable import_organization

// swiftlint:disable availability_attributes
/// Main DogTV+ application
@available(iOS 17.0, tvOS 17.0, macOS 11.0, *)
@main
public struct DogTVMainApp: App {
    @StateObject private var dogTVCore = DogTVCore.shared

    public init() {}

    public var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dogTVCore)
                .task {
                    await dogTVCore.initialize()
                }
        }
    }
}
// swiftlint:enable availability_attributes

/// Main content view
@available(iOS 17.0, tvOS 17.0, macOS 11.0, *)
struct ContentView: View {
    @EnvironmentObject var dogTVCore: DogTVCore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                SceneGridView()
            }
            .tabItem {
                Label("Scenes", systemImage: "play.circle")
            }
            .tag(0)

            SettingsView()
                .environmentObject(dogTVCore.settingsService)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
        .accentColor(.primary)
    }
}

#if DEBUG
struct DogTVMainApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DogTVCore.shared)
    }
}
#endif
