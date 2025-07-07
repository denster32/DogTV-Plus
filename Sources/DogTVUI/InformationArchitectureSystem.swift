import SwiftUI
import DogTVCore

/// Information architecture system for clear visual hierarchy and user guidance
public struct InformationArchitectureSystem {
    
    // MARK: - Action Styling
    
    /// Primary action styling for large, prominent buttons
    public struct PrimaryActionStyle: ViewModifier {
        let isEnabled: Bool
        
        public init(isEnabled: Bool = true) {
            self.isEnabled = isEnabled
        }
        
        public func body(content: Content) -> some View {
            content
                .font(DogTVDesignSystem.Typography.headline)
                .foregroundColor(.white)
                .padding(.horizontal, DogTVDesignSystem.Spacing.lg)
                .padding(.vertical, DogTVDesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                        .fill(isEnabled ? Color.dogWarm : Color.dogGrayMedium)
                )
                .scaleEffect(isEnabled ? 1.0 : 0.98)
                .opacity(isEnabled ? 1.0 : 0.6)
                .animation(.easeInOut(duration: 0.2), value: isEnabled)
        }
    }
    
    /// Secondary action styling for medium-sized buttons
    public struct SecondaryActionStyle: ViewModifier {
        let isEnabled: Bool
        
        public init(isEnabled: Bool = true) {
            self.isEnabled = isEnabled
        }
        
        public func body(content: Content) -> some View {
            content
                .font(DogTVDesignSystem.Typography.body)
                .foregroundColor(isEnabled ? Color.dogWarm : Color.dogGrayMedium)
                .padding(.horizontal, DogTVDesignSystem.Spacing.md)
                .padding(.vertical, DogTVDesignSystem.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                        .stroke(isEnabled ? Color.dogWarm : Color.dogGrayMedium, lineWidth: 2)
                        .background(Color.white)
                )
                .scaleEffect(isEnabled ? 1.0 : 0.98)
                .opacity(isEnabled ? 1.0 : 0.6)
                .animation(.easeInOut(duration: 0.2), value: isEnabled)
        }
    }
    
    /// Tertiary information styling for small, subtle text
    public struct TertiaryTextStyle: ViewModifier {
        public func body(content: Content) -> some View {
            content
                .font(DogTVDesignSystem.Typography.footnote)
                .foregroundColor(Color.dogTextTertiary)
                .lineLimit(2)
        }
    }
    
    // MARK: - Progressive Disclosure
    
    /// Progressive disclosure view for showing complexity only when needed
    public struct ProgressiveDisclosureView<SimpleContent: View, DetailedContent: View>: View {
        @State private var isExpanded = false
        let simpleContent: SimpleContent
        let detailedContent: DetailedContent
        let title: String
        
        public init(
            title: String,
            @ViewBuilder simpleContent: () -> SimpleContent,
            @ViewBuilder detailedContent: () -> DetailedContent
        ) {
            self.title = title
            self.simpleContent = simpleContent()
            self.detailedContent = detailedContent()
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.md) {
                HStack {
                    Text(title)
                        .font(DogTVDesignSystem.Typography.headline)
                        .foregroundColor(Color.dogTextPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(Color.dogWarm)
                            .font(DogTVDesignSystem.Typography.body)
                    }
                }
                
                if isExpanded {
                    detailedContent
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    simpleContent
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(DogTVDesignSystem.Layout.padding)
            .background(
                RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
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
    
    // MARK: - Content Organization
    
    /// Content group view for logical grouping with cards and sections
    public struct ContentGroupView<Content: View>: View {
        let title: String
        let subtitle: String?
        let content: Content
        let style: GroupStyle
        
        public enum GroupStyle {
            case card
            case section
            case grid
        }
        
        public init(
            title: String,
            subtitle: String? = nil,
            style: GroupStyle = .card,
            @ViewBuilder content: () -> Content
        ) {
            self.title = title
            self.subtitle = subtitle
            self.style = style
            self.content = content()
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DogTVDesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DogTVDesignSystem.Typography.title3)
                        .foregroundColor(Color.dogTextPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DogTVDesignSystem.Typography.subheadline)
                            .foregroundColor(Color.dogTextSecondary)
                    }
                }
                
                switch style {
                case .card:
                    content
                        .cardStyle()
                case .section:
                    content
                        .padding(DogTVDesignSystem.Layout.padding)
                        .background(Color.dogGrayLight)
                        .cornerRadius(DogTVDesignSystem.Layout.cornerRadius)
                case .grid:
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DogTVDesignSystem.Spacing.md) {
                        content
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation Indicators
    
    /// Navigation indicator view for clear breadcrumbs and progress indicators
    public struct NavigationIndicatorView: View {
        let currentStep: Int
        let totalSteps: Int
        let title: String
        
        public init(currentStep: Int, totalSteps: Int, title: String) {
            self.currentStep = currentStep
            self.totalSteps = totalSteps
            self.title = title
        }
        
        public var body: some View {
            VStack(spacing: DogTVDesignSystem.Spacing.sm) {
                HStack {
                    Text(title)
                        .font(DogTVDesignSystem.Typography.headline)
                        .foregroundColor(Color.dogTextPrimary)
                    
                    Spacer()
                    
                    Text("\(currentStep) of \(totalSteps)")
                        .font(DogTVDesignSystem.Typography.footnote)
                        .foregroundColor(Color.dogTextSecondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.dogGrayLight)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.dogWarm)
                            .frame(
                                width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps),
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .frame(height: 8)
            }
            .padding(DogTVDesignSystem.Layout.padding)
            .background(
                RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                    .fill(Color.white)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
        }
    }
    
    // MARK: - Consistent Patterns
    
    /// Consistent pattern modifier for similar functions to look and behave similarly
    public struct ConsistentPatternModifier: ViewModifier {
        let patternType: PatternType
        
        public enum PatternType {
            case listItem
            case card
            case button
            case input
            case toggle
        }
        
        public init(patternType: PatternType) {
            self.patternType = patternType
        }
        
        public func body(content: Content) -> some View {
            switch patternType {
            case .listItem:
                content
                    .padding(DogTVDesignSystem.Layout.padding)
                    .background(Color.white)
                    .cornerRadius(DogTVDesignSystem.Layout.cornerRadiusSmall)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
            case .card:
                content
                    .cardStyle()
            case .button:
                content
                    .primaryButtonStyle()
            case .input:
                content
                    .padding(DogTVDesignSystem.Layout.padding)
                    .background(Color.dogGrayLight)
                    .cornerRadius(DogTVDesignSystem.Layout.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                            .stroke(Color.dogGrayMedium, lineWidth: 1)
                    )
            case .toggle:
                content
                    .padding(DogTVDesignSystem.Layout.paddingSmall)
                    .background(Color.dogGrayLight)
                    .cornerRadius(DogTVDesignSystem.Layout.cornerRadiusSmall)
            }
        }
    }
    
    // MARK: - Simplified Choice
    
    /// Simplified choice view for reduced options to minimize decision fatigue
    public struct SimplifiedChoiceView<Option: Hashable, Content: View>: View {
        @Binding var selectedOption: Option
        let options: [Option]
        let content: (Option) -> Content
        
        public init(
            selectedOption: Binding<Option>,
            options: [Option],
            @ViewBuilder content: @escaping (Option) -> Content
        ) {
            self._selectedOption = selectedOption
            self.options = options
            self.content = content
        }
        
        public var body: some View {
            VStack(spacing: DogTVDesignSystem.Spacing.sm) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedOption = option
                        }
                        hapticManager.lightImpact()
                    }) {
                        HStack {
                            content(option)
                            
                            Spacer()
                            
                            if selectedOption == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.dogWarm)
                                    .font(DogTVDesignSystem.Typography.body)
                            }
                        }
                        .padding(DogTVDesignSystem.Layout.padding)
                        .background(
                            RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                                .fill(selectedOption == option ? Color.dogWarm.opacity(0.1) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DogTVDesignSystem.Layout.cornerRadius)
                                        .stroke(
                                            selectedOption == option ? Color.dogWarm : Color.dogGrayMedium,
                                            lineWidth: selectedOption == option ? 2 : 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Visual Hierarchy
    
    /// Visual hierarchy manager for consistent information organization
    public struct VisualHierarchyManager: ViewModifier {
        let hierarchyLevel: HierarchyLevel
        
        public enum HierarchyLevel {
            case primary
            case secondary
            case tertiary
            case quaternary
        }
        
        public init(hierarchyLevel: HierarchyLevel) {
            self.hierarchyLevel = hierarchyLevel
        }
        
        public func body(content: Content) -> some View {
            switch hierarchyLevel {
            case .primary:
                content
                    .font(DogTVDesignSystem.Typography.title)
                    .foregroundColor(Color.dogTextPrimary)
                    .padding(.bottom, DogTVDesignSystem.Spacing.sm)
            case .secondary:
                content
                    .font(DogTVDesignSystem.Typography.headline)
                    .foregroundColor(Color.dogTextPrimary)
                    .padding(.bottom, DogTVDesignSystem.Spacing.xs)
            case .tertiary:
                content
                    .font(DogTVDesignSystem.Typography.body)
                    .foregroundColor(Color.dogTextSecondary)
            case .quaternary:
                content
                    .font(DogTVDesignSystem.Typography.footnote)
                    .foregroundColor(Color.dogTextTertiary)
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply primary action styling
    public func primaryActionStyle(isEnabled: Bool = true) -> some View {
        modifier(InformationArchitectureSystem.PrimaryActionStyle(isEnabled: isEnabled))
    }
    
    /// Apply secondary action styling
    public func secondaryActionStyle(isEnabled: Bool = true) -> some View {
        modifier(InformationArchitectureSystem.SecondaryActionStyle(isEnabled: isEnabled))
    }
    
    /// Apply tertiary text styling
    public func tertiaryTextStyle() -> some View {
        modifier(InformationArchitectureSystem.TertiaryTextStyle())
    }
    
    /// Apply progressive disclosure
    public func progressiveDisclosure<DetailedContent: View>(
        title: String,
        @ViewBuilder detailedContent: @escaping () -> DetailedContent
    ) -> some View {
        InformationArchitectureSystem.ProgressiveDisclosureView(
            title: title,
            simpleContent: { self },
            detailedContent: detailedContent
        )
    }
    
    /// Apply content grouping
    public func contentGroup<Content: View>(
        title: String,
        subtitle: String? = nil,
        style: InformationArchitectureSystem.ContentGroupView<AnyView>.GroupStyle = .card,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        InformationArchitectureSystem.ContentGroupView(
            title: title,
            subtitle: subtitle,
            style: style
        ) {
            content()
        }
    }
    
    /// Apply consistent pattern
    public func consistentPattern(_ patternType: InformationArchitectureSystem.ConsistentPatternModifier.PatternType) -> some View {
        modifier(InformationArchitectureSystem.ConsistentPatternModifier(patternType: patternType))
    }
    
    /// Apply visual hierarchy
    public func visualHierarchy(_ level: InformationArchitectureSystem.VisualHierarchyManager.HierarchyLevel) -> some View {
        modifier(InformationArchitectureSystem.VisualHierarchyManager(hierarchyLevel: level))
    }
} 