import XCTest
import SwiftUI
@testable import DogTVUI
@testable import DogTVCore

final class DogTVUITests: XCTestCase {

    func testMainAppViewInitialization() {
        let appView = MainAppView()
        XCTAssertNotNil(appView)
    }

    func testSceneSelectionViewInitialization() {
        let scenes = [
            Scene(
                id: "test-1",
                name: "Test Scene 1",
                description: "First test scene",
                duration: 300,
                visualEffects: [],
                audioEffects: [],
                difficulty: .beginner
            )
        ]

        let selectionView = SceneSelectionView(scenes: scenes)
        XCTAssertNotNil(selectionView)
    }

    func testScenePlayerViewInitialization() {
        let scene = Scene(
            id: "test-scene",
            name: "Test Scene",
            description: "A test scene",
            duration: 300,
            visualEffects: [],
            audioEffects: [],
            difficulty: .beginner
        )

        let playerView = ScenePlayerView(scene: scene)
        XCTAssertNotNil(playerView)
    }

    func testSettingsViewInitialization() {
        let settingsView = SettingsView()
        XCTAssertNotNil(settingsView)
    }

    func testCanineUIComponentsInitialization() {
        let components = CanineUIComponents()
        XCTAssertNotNil(components)
    }

    func testNavigationCoordinatorInitialization() {
        let coordinator = NavigationCoordinator()
        XCTAssertNotNil(coordinator)
    }

    func testDogTVDesignSystemInitialization() {
        let designSystem = DogTVDesignSystem()
        XCTAssertNotNil(designSystem)
    }

    func testViewModelInitialization() {
        let viewModel = MainViewModel()
        XCTAssertNotNil(viewModel)
        XCTAssertFalse(viewModel.isPlaying)
    }
}
