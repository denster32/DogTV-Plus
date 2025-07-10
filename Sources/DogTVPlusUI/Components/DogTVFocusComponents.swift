// swiftlint:disable import_organization availability_attributes
import SwiftUI
import DogTVCore
// swiftlint:enable import_organization

/// Apple TV-compliant focus-aware button component
@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
public struct DogTVFocusButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @FocusState private var isFocused: Bool
    @State private var isPressed: Bool = false
    
    private let buttonStyle: ButtonStyle
    
    public enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case ghost
    }
    
    public init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.buttonStyle = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DogTVDesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(DogTVDesignSystem.Typography.dynamicHeadline)
                        .foregroundColor(textColor)
                }
                
                Text(title)
                    .font(DogTVDesignSystem.Typography.dynamicBody)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                    .dynamicTypeSize(.large...(.accessibility1))
            }
            .padding(.horizontal, DogTVDesignSystem.Spacing.lg)
            .padding(.vertical, DogTVDesignSystem.Spacing.md)
            .background(backgroundColor)
            .cornerRadius(DogTVDesignSystem.AppleTVFocus.focusCornerRadius)
            .scaleEffect(isFocused ? DogTVDesignSystem.AppleTVFocus.focusScale : 1.0)
            .shadow(
                color: isFocused ? .black.opacity(DogTVDesignSystem.AppleTVFocus.focusShadowOpacity) : .clear,
                radius: DogTVDesignSystem.AppleTVFocus.focusShadowRadius,
                x: 0,
                y: DogTVDesignSystem.AppleTVFocus.focusShadowOffset
            )
            .overlay(
                RoundedRectangle(cornerRadius: DogTVDesignSystem.AppleTVFocus.focusCornerRadius)
                    .stroke(
                        isFocused ? DogTVDesignSystem.AppleTVFocus.focusRingColor : Color.clear,
                        lineWidth: isFocused ? 4 : 0
                    )
            )
            .animation(DogTVDesignSystem.AppleTVFocus.focusAnimationSpring, value: isFocused)
            .animation(DogTVDesignSystem.AppleTVFocus.focusAnimationSpring, value: isPressed)
        }
        .focused($isFocused)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {
            // Handle press state for visual feedback
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isFocused ? .isSelected : [])
    }
    
    private var backgroundColor: Color {
        switch buttonStyle {
        case .primary:
            return isFocused ? DogTVDesignSystem.Colors.dogPlayful : DogTVDesignSystem.Colors.dogWarm
        case .secondary:
            return isFocused ? DogTVDesignSystem.Colors.dogCalm : DogTVDesignSystem.Colors.dogGrayMedium
        case .destructive:
            return isFocused ? DogTVDesignSystem.Colors.dogError.opacity(0.8) : DogTVDesignSystem.Colors.dogError
        case .ghost:
            return isFocused ? DogTVDesignSystem.Colors.dogGrayLight : Color.clear
        }
    }
    
    private var textColor: Color {
        switch buttonStyle {
        case .primary, .destructive:
            return .white
        case .secondary:
            return isFocused ? .white : DogTVDesignSystem.Colors.dogTextPrimary
        case .ghost:
            return DogTVDesignSystem.Colors.dogTextPrimary
        }
    }
    
    private var accessibilityLabel: String {
        if let icon = icon {
            return "\(icon), \(title)"
        }
        return title
    }
    
    private var accessibilityHint: String {
        switch buttonStyle {
        case .primary:
            return "Primary action button"
        case .secondary:
            return "Secondary action button"
        case .destructive:
            return "Destructive action button"
        case .ghost:
            return "Ghost action button"
        }
    }
}

/// Apple TV-compliant focus-aware card component for scenes
@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
public struct DogTVFocusCard: View {
    let scene: Scene
    let action: () -> Void
    
    @FocusState private var isFocused: Bool
    @State private var isPressed: Bool = false
    
    public init(scene: Scene, action: @escaping () -> Void) {
        self.scene = scene
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: DogTVDesignSystem.Spacing.md) {
                // Scene preview area
                ZStack {
                    RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadiusLarge)
                        .fill(sceneColor.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    VStack {
                        Image(systemName: sceneIcon)
                            .font(.system(size: 48))
                            .foregroundColor(sceneColor)
                        
                        Text(scene.name)
                            .font(DogTVDesignSystem.Typography.dynamicTitle3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .dynamicTypeSize(.large...(.accessibility1))
                    }
                }
                
                // Scene description
                Text(scene.description)
                    .font(DogTVDesignSystem.Typography.dynamicBody)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .dynamicTypeSize(.large...(.accessibility1))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DogTVDesignSystem.Spacing.lg)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(DogTVDesignSystem.AppleTVFocus.focusCornerRadiusLarge)
            .scaleEffect(isFocused ? DogTVDesignSystem.AppleTVFocus.focusScaleLarge : 1.0)
            .shadow(
                color: isFocused ? .black.opacity(DogTVDesignSystem.AppleTVFocus.focusShadowOpacity) : .clear,
                radius: DogTVDesignSystem.AppleTVFocus.focusShadowRadius,
                x: 0,
                y: DogTVDesignSystem.AppleTVFocus.focusShadowOffset
            )
            .overlay(
                RoundedRectangle(cornerRadius: DogTVDesignSystem.AppleTVFocus.focusCornerRadiusLarge)
                    .stroke(
                        isFocused ? DogTVDesignSystem.AppleTVFocus.focusRingColor : Color.clear,
                        lineWidth: isFocused ? 6 : 0
                    )
            )
            .animation(DogTVDesignSystem.AppleTVFocus.focusAnimationSpring, value: isFocused)
        }
        .focused($isFocused)
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(scene.name)
        .accessibilityHint(DogTVDesignSystem.AccessibilityEnhanced.sceneDescriptions[scene.type.rawValue] ?? scene.description)
        .accessibilityAddTraits(isFocused ? .isSelected : [])
    }
    
    private var sceneColor: Color {
        switch scene.type {
        case .ocean:
            return .dogCalm
        case .forest:
            return .green
        case .fireflies:
            return .yellow
        case .rain:
            return .blue
        case .sunset:
            return .dogPlayful
        case .stars:
            return .purple
        }
    }
    
    private var sceneIcon: String {
        switch scene.type {
        case .ocean:
            return "water.waves"
        case .forest:
            return "tree.fill"
        case .fireflies:
            return "sparkles"
        case .rain:
            return "cloud.rain.fill"
        case .sunset:
            return "sun.max.fill"
        case .stars:
            return "moon.stars.fill"
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, tvOS 17.0, macOS 14.0, *)
struct DogTVFocusComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DogTVFocusButton(title: "Play Scene", icon: "play.fill") {
                print("Play tapped")
            }
            
            DogTVFocusButton(title: "Settings", icon: "gear", style: .secondary) {
                print("Settings tapped")
            }
            
            DogTVFocusButton(title: "Stop", icon: "stop.fill", style: .destructive) {
                print("Stop tapped")
            }
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}
