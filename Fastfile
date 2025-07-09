fastlane_version "2.0.0"

default_platform(:tvos)

# Dependency Management
platform :tvos do
  desc "Install and manage project dependencies"
  lane :dependencies do
    # Swift Package Manager
    sh "swift package resolve"
    
    # Cache SPM dependencies
    spm_packages_path = "~/.swiftpm"
    if File.directory?(spm_packages_path)
      cache(paths: [
        spm_packages_path,
        "DerivedData"
      ])
    end

    # Carthage bootstrap if Cartfile exists
    if File.exist?("Cartfile")
      carthage(
        command: "bootstrap",
        platform: "tvOS",
        use_ssh: false,
        use_submodules: true
      )
    end

    # CocoaPods install if Podfile exists
    if File.exist?("Podfile")
      cocoapods(
        clean_install: true,
        podfile: "Podfile",
        try_repo_update_on_error: true
      )
    end
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    dependencies
    increment_build_number(xcodeproj: "DogTV+.xcodeproj")
    build_app(scheme: "DogTV+", export_method: "app-store")
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end

  desc "Submit to App Store for release"
  lane :release do
    dependencies
    capture_screenshots
    increment_build_number(xcodeproj: "DogTV+.xcodeproj")
    build_app(scheme: "DogTV+", export_method: "app-store")
    upload_to_app_store
  end
end 