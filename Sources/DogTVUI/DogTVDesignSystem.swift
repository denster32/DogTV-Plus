import SwiftUI
import DogTVCore

/// Comprehensive design system for DogTV+ reflecting the app's personality
public class DogTVDesignSystem: ObservableObject {
    
    // MARK: - Color Palette
    
    /// Custom color palette for DogTV+
    public struct Colors {
        /// Primary warm brown color
        public static let dogWarm = Color(red: 230/255, green: 179/255, blue: 128/255)
        
        /// Secondary playful orange color
        public static let dogPlayful = Color(red: 255/255, green: 153/255, blue: 51/255)
        
        /// Accent calming blue color
        public static let dogCalm = Color(red: 102/255, green: 153/255, blue: 230/255)
        
        /// Background soft cream color
        public static let dogSoft = Color(red: 245/255, green: 240/255, blue: 232/255)
        
        /// Success green color
        public static let dogSuccess = Color(red: 76/255, green: 175/255, blue: 80/255)
        
        /// Warning orange color
        public static let dogWarning = Color(red: 255/255, green: 152/255, blue: 0/255)
        
        /// Error red color
        public static let dogError = Color(red: 244/255, green: 67/255, blue: 54/255)
        
        /// Neutral gray colors
        public static let dogGrayLight = Color(red: 245/255, green: 245/255, blue: 245/255)
        public static let dogGrayMedium = Color(red: 189/255, green: 189/255, blue: 189/255)
        public static let dogGrayDark = Color(red: 97/255, green: 97/255, blue: 97/255)
        
        /// Text colors
        public static let dogTextPrimary = Color.black
        public static let dogTextSecondary = Color(red: 97/255, green: 97/255, blue: 97/255)
        public static let dogTextTertiary = Color(red: 158/255, green: 158/255, blue: 158/255)
    }
    
    // MARK: - Typography System
    
    /// Typography system with custom fonts
    public struct Typography {
        /// Large title font
        public static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
        
        /// Title font
        public static let title = Font.system(size: 28, weight: .semibold, design: .default)
        
        /// Title 2 font
        public static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
        
        /// Title 3 font
        public static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        
        /// Headline font
        public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        
        /// Body font
        public static let body = Font.system(size: 17, weight: .regular, design: .default)
        
        /// Callout font
        public static let callout = Font.system(size: 16, weight: .regular, design: .default)
        
        /// Subheadline font
        public static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        
        /// Footnote font
        public static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        
        /// Caption font
        public static let caption = Font.system(size: 12, weight: .regular, design: .default)
        
        /// Caption 2 font
        public static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        
        /// Scientific font (monospaced)
        public static let scientific = Font.system(size: 14, weight: .regular, design: .monospaced)
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
}

// MARK: - View Extensions

extension View {
    /// Apply primary button style
    public func primaryButtonStyle() -> some View {
        buttonStyle(DogTVDesignSystem.PrimaryButtonStyle())
    }
    
    /// Apply secondary button style
    public func secondaryButtonStyle() -> some View {
        buttonStyle(DogTVDesignSystem.SecondaryButtonStyle())
    }
    
    /// Apply tertiary button style
    public func tertiaryButtonStyle() -> some View {
        buttonStyle(DogTVDesignSystem.TertiaryButtonStyle())
    }
    
    /// Apply standard card style
    public func cardStyle() -> some View {
        modifier(DogTVDesignSystem.CardStyle())
    }
    
    /// Apply elevated card style
    public func elevatedCardStyle() -> some View {
        modifier(DogTVDesignSystem.ElevatedCardStyle())
    }
    
    /// Apply standard padding
    public func standardPadding() -> some View {
        padding(DogTVDesignSystem.Layout.padding)
    }
    
    /// Apply large padding
    public func largePadding() -> some View {
        padding(DogTVDesignSystem.Layout.paddingLarge)
    }
    
    /// Apply small padding
    public func smallPadding() -> some View {
        padding(DogTVDesignSystem.Layout.paddingSmall)
    }
}

// MARK: - Color Extensions

extension Color {
    /// DogTV+ brand colors
    public static let dogWarm = DogTVDesignSystem.Colors.dogWarm
    public static let dogPlayful = DogTVDesignSystem.Colors.dogPlayful
    public static let dogCalm = DogTVDesignSystem.Colors.dogCalm
    public static let dogSoft = DogTVDesignSystem.Colors.dogSoft
    public static let dogSuccess = DogTVDesignSystem.Colors.dogSuccess
    public static let dogWarning = DogTVDesignSystem.Colors.dogWarning
    public static let dogError = DogTVDesignSystem.Colors.dogError
    public static let dogGrayLight = DogTVDesignSystem.Colors.dogGrayLight
    public static let dogGrayMedium = DogTVDesignSystem.Colors.dogGrayMedium
    public static let dogGrayDark = DogTVDesignSystem.Colors.dogGrayDark
    public static let dogTextPrimary = DogTVDesignSystem.Colors.dogTextPrimary
    public static let dogTextSecondary = DogTVDesignSystem.Colors.dogTextSecondary
    public static let dogTextTertiary = DogTVDesignSystem.Colors.dogTextTertiary
} 