// swiftlint:disable import_organization
import SwiftUI
import DogTVCore
// swiftlint:enable import_organization

// swiftlint:disable:next availability_attributes
@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
struct SettingsView: View {
    @EnvironmentObject var settingsService: SettingsService

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Audio Settings")) {
                    Toggle("Enable Audio", isOn: $settingsService.audioSettings.isEnabled)

                    VStack(alignment: .leading) {
                        Text("Volume")
                        Slider(value: $settingsService.audioSettings.volume, in: 0...1)
                    }

                    Picker("Frequency Range", selection: $settingsService.audioSettings.frequencyRange) {
                        ForEach(FrequencyRange.allCases, id: \.self) { range in
                            Text(range.rawValue.capitalized).tag(range)
                        }
                    }

                    Toggle("Include Nature Sounds", isOn: $settingsService.audioSettings.includeNatureSounds)
                }

                Section(header: Text("Preferences")) {
                    Toggle("Auto Play", isOn: $settingsService.userPreferences.autoPlay)

                    VStack(alignment: .leading) {
                        Text("Session Duration")
                        Slider(value: $settingsService.userPreferences.sessionDuration, in: 900...7200)
                        Text("\(Int(settingsService.userPreferences.sessionDuration / 60)) minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Toggle("Notifications", isOn: $settingsService.userPreferences.notificationsEnabled)
                }

                Section {
                    Button("Reset to Defaults") {
                        settingsService.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
