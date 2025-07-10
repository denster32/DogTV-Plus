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
                        .accessibilityIdentifier("enable_audio_toggle")

                    VStack(alignment: .leading) {
                        Text("Volume")
                        Slider(value: $settingsService.audioSettings.volume, in: 0...1)
                            .accessibilityIdentifier("volume_slider")
                    }

                    Picker("Frequency Range", selection: $settingsService.audioSettings.frequencyRange) {
                        ForEach(FrequencyRange.allCases, id: \.self) { range in
                            Text(range.rawValue.capitalized).tag(range)
                        }
                    }
                    .accessibilityIdentifier("frequency_range_picker")

                    Toggle("Include Nature Sounds", isOn: $settingsService.audioSettings.includeNatureSounds)
                        .accessibilityIdentifier("nature_sounds_toggle")
                }

                Section(header: Text("Preferences")) {
                    Toggle("Auto Play", isOn: $settingsService.userPreferences.autoPlay)
                        .accessibilityIdentifier("auto_play_toggle")

                    VStack(alignment: .leading) {
                        Text("Session Duration")
                        Slider(value: $settingsService.userPreferences.sessionDuration, in: 900...7200)
                            .accessibilityIdentifier("session_duration_slider")
                        Text("\(Int(settingsService.userPreferences.sessionDuration / 60)) minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Toggle("Notifications", isOn: $settingsService.userPreferences.notificationsEnabled)
                        .accessibilityIdentifier("notifications_toggle")
                }

                Section(header: Text("Accessibility")) {
                    Toggle("High Contrast Mode", isOn: $settingsService.userPreferences.isHighContrastEnabled)
                        .accessibilityIdentifier("high_contrast_toggle")
                }

                Section {
                    Button("Reset to Defaults") {
                        settingsService.resetSettings()
                    }
                    .foregroundColor(.red)
                    .accessibilityIdentifier("reset_button")
                }
            }
            .navigationTitle("Settings")
        }
        .padding(.horizontal)
        .padding(.vertical)
        .accessibilityIdentifier("settings_view")
    }
}
