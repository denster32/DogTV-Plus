// swiftlint:disable import_organization mark_usage
import SwiftUI
import DogTVCore
// swiftlint:enable import_organization

/// Comprehensive design system for DogTV+ reflecting the app's personality
public class DogTVDesignSystem: ObservableObject {
    // MARK: - Color Palette

    /// Custom color palette for DogTV+
    public struct Colors {
        /// Primary warm brown color
        public static let dogWarm = Color("dogWarm")

        /// Secondary playful orange color
        public static let dogPlayful = Color("dogPlayful")

        /// Accent calming blue color
        public static let dogCalm = Color("dogCalm")

        /// Background soft cream color
        public static let dogSoft = Color("dogSoft")

        /// Success green color
        public static let dogSuccess = Color(red: 76 / 255, green: 175 / 255, blue: 80 / 255)

        /// Warning orange color
        public static let dogWarning = Color(red: 255 / 255, green: 152 / 255, blue: 0 / 255)

        /// Error red color
        public static let dogError = Color(red: 244 / 255, green: 67 / 255, blue: 54 / 255)

        /// Neutral gray colors
        public static let dogGrayLight = Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255)
        public static let dogGrayMedium = Color(red: 189 / 255, green: 189 / 255, blue: 189 / 255)
        public static let dogGrayDark = Color(red: 97 / 255, green: 97 / 255, blue: 97 / 255)

        /// Text colors
        public static let dogTextPrimary = Color.black
        public static let dogTextSecondary = Color(red: 97 / 255, green: 97 / 255, blue: 97 / 255)
        public static let dogTextTertiary = Color(red: 158 / 255, green: 158 / 255, blue: 158 / 255)
    }

    // MARK: - Typography System

    /// Typography system optimized for 10-foot viewing on Apple TV with Dynamic Type support
    public struct Typography {
        /// Large title font - optimized for 10-foot viewing
        public static let largeTitle = Font.system(size: 48, weight: .bold, design: .default)

        /// Title font - optimized for 10-foot viewing
        public static let title = Font.system(size: 42, weight: .semibold, design: .default)

        /// Title 2 font - optimized for 10-foot viewing
        public static let title2 = Font.system(size: 36, weight: .semibold, design: .default)

        /// Title 3 font - optimized for 10-foot viewing
        public static let title3 = Font.system(size: 32, weight: .semibold, design: .default)

        /// Headline font - optimized for 10-foot viewing
        public static let headline = Font.system(size: 28, weight: .semibold, design: .default)

        /// Body font - minimum 24pt for 10-foot viewing compliance
        public static let body = Font.system(size: 24, weight: .regular, design: .default)

        /// Callout font - minimum 24pt for readability
        public static let callout = Font.system(size: 24, weight: .regular, design: .default)

        /// Subheadline font - minimum 24pt for readability
        public static let subheadline = Font.system(size: 24, weight: .regular, design: .default)

        /// Footnote font - minimum 20pt for small text
        public static let footnote = Font.system(size: 20, weight: .regular, design: .default)

        /// Caption font - minimum 20pt for small text
        public static let caption = Font.system(size: 20, weight: .regular, design: .default)

        /// Caption 2 font - minimum 20pt for smallest text
        public static let caption2 = Font.system(size: 20, weight: .regular, design: .default)

        /// Scientific font (monospaced) - minimum 20pt
        public static let scientific = Font.system(size: 20, weight: .regular, design: .monospaced)
        
        /// Dynamic Type variants that scale appropriately
        public static let dynamicLargeTitle = Font.largeTitle.weight(.bold)
        public static let dynamicTitle = Font.title.weight(.semibold)
        public static let dynamicTitle2 = Font.title2.weight(.semibold)
        public static let dynamicTitle3 = Font.title3.weight(.semibold)
        public static let dynamicHeadline = Font.headline.weight(.semibold)
        public static let dynamicBody = Font.body
        public static let dynamicCallout = Font.callout
        public static let dynamicSubheadline = Font.subheadline
        public static let dynamicFootnote = Font.footnote
        public static let dynamicCaption = Font.caption
        public static let dynamicCaption2 = Font.caption2
    }

    // MARK: - Spacing System

    /// 8pt grid spacing system
    public struct Spacing {
        /// Extra small spacing (4pt)
        public static let xs: CGFloat = 4

        /// Small spacing (8pt)
        public static let sm: CGFloat = 8

        /// Medium spacing (16pt)
        public static let md: CGFloat = 16

        /// Large spacing (24pt)
        public static let lg: CGFloat = 24

        /// Extra large spacing (32pt)
        public static let xl: CGFloat = 32

        /// Double extra large spacing (48pt)
        public static let xxl: CGFloat = 48

        /// Triple extra large spacing (64pt)
        public static let xxxl: CGFloat = 64
    }

    // MARK: - Layout Constants

    /// Layout constants for consistent spacing
    public struct Layout {
        /// Standard corner radius
        public static let cornerRadius: CGFloat = 12

        /// Large corner radius
        public static let cornerRadiusLarge: CGFloat = 16

        /// Small corner radius
        public static let cornerRadiusSmall: CGFloat = 8

        /// Standard padding
        public static let padding: CGFloat = Spacing.md

        /// Large padding
        public static let paddingLarge: CGFloat = Spacing.lg

        /// Small padding
        public static let paddingSmall: CGFloat = Spacing.sm

        /// Standard margin
        public static let margin: CGFloat = Spacing.md

        /// Large margin
        public static let marginLarge: CGFloat = Spacing.lg

        /// Small margin
        public static let marginSmall: CGFloat = Spacing.sm
    }

    // MARK: - Icon System

    /// Custom icon system for DogTV+
    public struct Icons {
        /// Dog-related icons
        public static let dog = "dog.fill"
        public static let pawPrint = "pawprint.fill"
        public static let bone = "heart.fill" // Using heart as bone

        /// Content icons
        public static let play = "play.fill"
        public static let pause = "pause.fill"
        public static let stop = "stop.fill"
        public static let forward = "forward.fill"
        public static let backward = "backward.fill"

        /// Navigation icons
        public static let home = "house.fill"
        public static let settings = "gear"
        public static let search = "magnifyingglass"
        public static let favorites = "heart.fill"
        public static let history = "clock.fill"

        /// Feature icons
        public static let vision = "eye.fill"
        public static let audio = "speaker.wave.2.fill"
        public static let behavior = "brain.head.profile"
        public static let analytics = "chart.bar.fill"
        public static let privacy = "lock.fill"

        /// Scientific icons
        public static let flask = "flask.fill"
        public static let microscope = "magnifyingglass.circle.fill"
        public static let research = "doc.text.fill"

        /// Status icons
        public static let checkmark = "checkmark.circle.fill"
        public static let warning = "exclamationmark.triangle.fill"
        public static let error = "xmark.circle.fill"
        public static let info = "info.circle.fill"
    }

    // MARK: - Button Styles

    /// Primary action button style
    public struct PrimaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Typography.headline)
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .fill(Colors.dogWarm)
                        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                )
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    /// Secondary action button style
    public struct SecondaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Typography.body)
                .foregroundColor(Colors.dogWarm)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .stroke(Colors.dogWarm, lineWidth: 2)
                        .background(Color.white)
                        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                )
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    /// Tertiary action button style
    public struct TertiaryButtonStyle: ButtonStyle {
        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(Typography.subheadline)
                .foregroundColor(Colors.dogTextSecondary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }

    // MARK: - Card Styles

    /// Standard card style
    public struct CardStyle: ViewModifier {
        public func body(content: Content) -> some View {
            content
                .padding(Layout.padding)
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadius)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
        }
    }

    /// Elevated card style
    public struct ElevatedCardStyle: ViewModifier {
        public func body(content: Content) -> some View {
            content
                .padding(Layout.paddingLarge)
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadiusLarge)
                        .fill(Color.white)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                )
        }
    }
    
    // MARK: - Apple TV Focus Management
    
    /// Apple TV-specific focus management and styling
    public struct AppleTVFocus {
        /// Focus effect colors for Apple TV
        public static let focusRingColor = Color.white
        public static let focusSelectedColor = Color.blue
        public static let focusDisabledColor = Color.gray
        
        /// Focus scaling for tvOS
        public static let focusScale: CGFloat = 1.1
        public static let focusScaleLarge: CGFloat = 1.15
        public static let focusScaleSmall: CGFloat = 1.05
        
        /// Focus corner radius adjustments
        public static let focusCornerRadius: CGFloat = 16
        public static let focusCornerRadiusLarge: CGFloat = 20
        
        /// Focus shadow properties
        public static let focusShadowRadius: CGFloat = 15
        public static let focusShadowOffset: CGFloat = 8
        public static let focusShadowOpacity: Double = 0.3
        
        /// Animation durations for focus changes
        public static let focusAnimationDuration: Double = 0.3
        public static let focusAnimationSpring = Animation.interactiveSpring(response: 0.6, dampingFraction: 0.8)
    }
    
    // MARK: - Apple TV Remote Support
    
    /// Apple TV remote interaction support
    public struct RemoteSupport {
        /// Remote button actions
        public enum RemoteAction {
            case select
            case menu
            case playPause
            case volumeUp
            case volumeDown
            case home
            case search
        }
        
        /// Gesture actions
        public enum GestureAction {
            case swipeUp
            case swipeDown
            case swipeLeft
            case swipeRight
            case clickAndHold
            case doubleClick
        }
    }
    
    // MARK: - Accessibility Enhancements
    
    /// Enhanced accessibility features for Apple TV
    public struct AccessibilityEnhanced {
        /// VoiceOver descriptions for dog-specific content
        public static let sceneDescriptions = [
            "ocean": "Peaceful ocean scene with gentle wave sounds for relaxation",
            "forest": "Natural forest environment with bird songs and rustling leaves",
            "fireflies": "Magical evening scene with twinkling fireflies and soft ambiance",
            "rain": "Soothing rain sounds with gentle droplet visuals",
            "sunset": "Beautiful sunset colors transitioning across the horizon",
            "stars": "Night sky scene with twinkling stars and cosmic sounds"
        ]
        
        /// High contrast color alternatives
        public static let highContrastColors = [
            "background": Color.black,
            "foreground": Color.white,
            "accent": Color.yellow,
            "focus": Color.cyan
        ]
        
        /// Large text multipliers for different accessibility sizes
        public static let largeTextMultipliers = [
            "default": 1.0,
            "large": 1.25,
            "extraLarge": 1.5,
            "accessibility": 2.0
        ]
    }
}

// MARK: - View Extensions

public extension View {
    /// Apply primary button style
    func primaryButtonStyle() -> some View {
        buttonStyle(DogTVDesignSystem.PrimaryButtonStyle())
    }

    /// Apply secondary button style
    func secondaryButtonStyle() -> some View {
        buttonStyle(DogTVDesignSystem.SecondaryButtonStyle())
    }

    /// Apply tertiary button style
    func tertiaryButtonStyle() -> some View {
        buttonStyle(DogTVDesignSystem.TertiaryButtonStyle())
    }

    /// Apply standard card style
    func cardStyle() -> some View {
        modifier(DogTVDesignSystem.CardStyle())
    }

    /// Apply elevated card style
    func elevatedCardStyle() -> some View {
        modifier(DogTVDesignSystem.ElevatedCardStyle())
    }

    /// Apply standard padding
    func standardPadding() -> some View {
        padding(DogTVDesignSystem.Layout.padding)
    }

    /// Apply large padding
    func largePadding() -> some View {
        padding(DogTVDesignSystem.Layout.paddingLarge)
    }

    /// Apply small padding
    func smallPadding() -> some View {
        padding(DogTVDesignSystem.Layout.paddingSmall)
    }
}

// MARK: - Color Extensions

public extension Color {
    /// DogTV+ brand colors
    static let dogWarm = DogTVDesignSystem.Colors.dogWarm
    static let dogPlayful = DogTVDesignSystem.Colors.dogPlayful
    static let dogCalm = DogTVDesignSystem.Colors.dogCalm
    static let dogSoft = DogTVDesignSystem.Colors.dogSoft
    static let dogSuccess = DogTVDesignSystem.Colors.dogSuccess
    static let dogWarning = DogTVDesignSystem.Colors.dogWarning
    static let dogError = DogTVDesignSystem.Colors.dogError
    static let dogGrayLight = DogTVDesignSystem.Colors.dogGrayLight
    static let dogGrayMedium = DogTVDesignSystem.Colors.dogGrayMedium
    static let dogGrayDark = DogTVDesignSystem.Colors.dogGrayDark
    static let dogTextPrimary = DogTVDesignSystem.Colors.dogTextPrimary
    static let dogTextSecondary = DogTVDesignSystem.Colors.dogTextSecondary
    static let dogTextTertiary = DogTVDesignSystem.Colors.dogTextTertiary
}

// MARK: - Font Extensions

public extension Font {
    /// DogTV+ brand fonts
    static let dogLargeTitle = DogTVDesignSystem.Typography.largeTitle
    static let dogTitle = DogTVDesignSystem.Typography.title
    static let dogTitle2 = DogTVDesignSystem.Typography.title2
    static let dogTitle3 = DogTVDesignSystem.Typography.title3
    static let dogHeadline = DogTVDesignSystem.Typography.headline
    static let dogBody = DogTVDesignSystem.Typography.body
    static let dogCallout = DogTVDesignSystem.Typography.callout
    static let dogSubheadline = DogTVDesignSystem.Typography.subheadline
    static let dogFootnote = DogTVDesignSystem.Typography.footnote
    static let dogCaption = DogTVDesignSystem.Typography.caption
    static let dogCaption2 = DogTVDesignSystem.Typography.caption2
    static let dogScientific = DogTVDesignSystem.Typography.scientific
}
// swiftlint:enable mark_usage
