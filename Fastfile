fastlane_version "2.0.0"

default_platform(:tvos)

platform :tvos do
  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "DogTV+.xcodeproj")
    build_app(scheme: "DogTV+", export_method: "app-store")
    upload_to_testflight(skip_waiting_for_build_processing: true)
  end

  desc "Submit to App Store for release"
  lane :release do
    capture_screenshots
    increment_build_number(xcodeproj: "DogTV+.xcodeproj")
    build_app(scheme: "DogTV+", export_method: "app-store")
    upload_to_app_store
  end
end 