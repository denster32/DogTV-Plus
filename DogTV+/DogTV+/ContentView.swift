import SwiftUI

/// ContentView is the main user interface for the DogTV+ app on Apple TV.
/// It provides a tabbed navigation structure following Apple's Human Interface Guidelines (HIG)
/// for tvOS, ensuring intuitive navigation, clear focus states, and accessibility support.
/// The interface is designed for easy remote control interaction with large, clear elements.
struct ContentView: View {
    @EnvironmentObject var visualRenderer: VisualRenderer // Receive VisualRenderer as an environment object
    @State private var selectedTab = 0
    private let categories = ["Calm & Relax", "Mental Stimulation", "Exercise Motivation", "Separation Anxiety", "Nature Sounds", "Training Videos"]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab - Overview and Quick Access
            VStack {
                Text("Welcome to DogTV+")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 50)
                    .accessibilityLabel("Welcome to DogTV Plus")
                
                Text("Select a category to keep your dog entertained and relaxed.")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
                    .accessibilityLabel("Select a category for your dog")
                
                Spacer()
                
                // Featured Content or Quick Play Button
                Button(action: {
                    // Action to play a recommended or last played content
                    print("Quick Play tapped")
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                        Text("Quick Play")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .frame(width: 300, height: 80)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(CardButtonStyle())
                .accessibilityLabel("Quick Play Button")
                .accessibilityHint("Plays recommended content for your dog")
                
                Spacer()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            .accessibilityLabel("Home Tab")
            
            // Categories Tab - Grid of Content Categories
            VStack {
                Text("Categories")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 50)
                    .accessibilityLabel("Categories")
                
                // Grid layout for categories, optimized for tvOS navigation
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            // Action to navigate to category detail or play content
                            print("Selected category: \(category)")
                        }) {
                            VStack {
                                // Placeholder for category image or icon
                                Image(systemName: categoryIcon(for: category))
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                                    .padding(.bottom, 10)
                                
                                Text(category)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 400, height: 200)
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                        .buttonStyle(CardButtonStyle())
                        .accessibilityLabel("\(category) Category")
                        .accessibilityHint("Select to view \(category) content")
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .tabItem {
                Label("Categories", systemImage: "square.grid.2x2.fill")
            }
            .tag(1)
            .accessibilityLabel("Categories Tab")
            
            // Settings Tab - Customization and Profiles
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 50)
                    .accessibilityLabel("Settings")
                
                Spacer()
                
                // Dog Profile Settings
                Button(action: {
                    // Navigate to dog profile customization
                    print("Dog Profile tapped")
                }) {
                    HStack {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 40))
                        Text("Dog Profile")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .frame(width: 400, height: 80)
                    .background(Color(.systemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .buttonStyle(CardButtonStyle())
                .accessibilityLabel("Dog Profile")
                .accessibilityHint("Customize settings for your dog")
                
                // Audio Settings
                Button(action: {
                    // Navigate to audio settings
                    print("Audio Settings tapped")
                }) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 40))
                        Text("Audio Settings")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .frame(width: 400, height: 80)
                    .background(Color(.systemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .buttonStyle(CardButtonStyle())
                .accessibilityLabel("Audio Settings")
                .accessibilityHint("Adjust volume and sound preferences")
                
                // Visual Settings
                Button(action: {
                    // Navigate to visual settings
                    print("Visual Settings tapped")
                }) {
                    HStack {
                        Image(systemName: "tv.fill")
                            .font(.system(size: 40))
                        Text("Visual Settings")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .frame(width: 400, height: 80)
                    .background(Color(.systemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .buttonStyle(CardButtonStyle())
                .accessibilityLabel("Visual Settings")
                .accessibilityHint("Adjust brightness and visual effects")
                
                Spacer()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(2)
            .accessibilityLabel("Settings Tab")
        }
        .accentColor(.blue) // Highlight color for focused elements
        .background(Color(.systemGroupedBackground)) // Consistent background per HIG
        .ignoresSafeArea() // Full-screen layout for immersive experience
        .accessibilityLabel("DogTV Plus Main Interface")
    }
    
    /// Returns an appropriate SF Symbol icon for each content category.
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Calm & Relax":
            return "moon.stars.fill"
        case "Mental Stimulation":
            return "brain.head.profile"
        case "Exercise Motivation":
            return "figure.walk"
        case "Separation Anxiety":
            return "person.fill"
        case "Nature Sounds":
            return "leaf.fill"
        case "Training Videos":
            return "graduationcap.fill"
        default:
            return "play.circle.fill"
        }
    }
}

/// Custom button style for tvOS, ensuring clear focus states per Apple's HIG.
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Subtle press animation
            .background(configuration.isPressed ? Color(.systemGray) : Color.clear) // Visual feedback on press
            .focusable(true) { isFocused in
                // Additional focus handling if needed
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 