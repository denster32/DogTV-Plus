// MARK: - Internationalization & Localization Engine
// Support for 25+ languages with RTL, cultural adaptation, and accessibility

import Foundation

// MARK: - Localization Manager Protocol
public protocol LocalizationManager {
    func localizedString(for key: String, locale: Locale?) -> String
    func localizedString(for key: String, arguments: [CVarArg], locale: Locale?) -> String
    func setCurrentLocale(_ locale: Locale)
    func getCurrentLocale() -> Locale
    func getSupportedLocales() -> [Locale]
    func getLocalizedCurrency(for locale: Locale) -> Currency
    func getLocalizedDateFormat(for locale: Locale) -> DateFormatter
    func isRTLLanguage(_ locale: Locale) -> Bool
}

// MARK: - Cultural Adaptation Protocol
public protocol CulturalAdaptationEngine {
    func adaptContent(for locale: Locale, content: ContentItem) -> AdaptedContent
    func getCulturalPreferences(for locale: Locale) -> CulturalPreferences
    func validateCulturalSensitivity(content: ContentItem, locale: Locale) -> ValidationResult
    func getRegionalContentRestrictions(for locale: Locale) -> [ContentRestriction]
}

// MARK: - Advanced Internationalization Engine
public class InternationalizationEngine: LocalizationManager, CulturalAdaptationEngine {
    
    private var currentLocale: Locale
    private let supportedLocales: [Locale]
    private let localizedStrings: [String: [String: String]]
    private let culturalPreferences: [String: CulturalPreferences]
    private let contentAdaptations: [String: ContentAdaptationRules]
    
    public init() {
        self.currentLocale = Locale.current
        self.supportedLocales = InternationalizationEngine.createSupportedLocales()
        self.localizedStrings = InternationalizationEngine.loadLocalizedStrings()
        self.culturalPreferences = InternationalizationEngine.loadCulturalPreferences()
        self.contentAdaptations = InternationalizationEngine.loadContentAdaptations()
    }
    
    // MARK: - Localization Manager Implementation
    
    public func localizedString(for key: String, locale: Locale? = nil) -> String {
        let targetLocale = locale ?? currentLocale
        let languageCode = targetLocale.languageCode ?? "en"
        
        return localizedStrings[languageCode]?[key] ?? localizedStrings["en"]?[key] ?? key
    }
    
    public func localizedString(for key: String, arguments: [CVarArg], locale: Locale? = nil) -> String {
        let formatString = localizedString(for: key, locale: locale)
        return String(format: formatString, arguments: arguments)
    }
    
    public func setCurrentLocale(_ locale: Locale) {
        guard supportedLocales.contains(locale) else {
            print("⚠️ Locale \(locale.identifier) not supported, falling back to English")
            currentLocale = Locale(identifier: "en")
            return
        }
        currentLocale = locale
    }
    
    public func getCurrentLocale() -> Locale {
        return currentLocale
    }
    
    public func getSupportedLocales() -> [Locale] {
        return supportedLocales
    }
    
    public func getLocalizedCurrency(for locale: Locale) -> Currency {
        let currencyCode = locale.currencyCode ?? "USD"
        return Currency(
            code: currencyCode,
            symbol: locale.currencySymbol ?? "$",
            locale: locale
        )
    }
    
    public func getLocalizedDateFormat(for locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    public func isRTLLanguage(_ locale: Locale) -> Bool {
        let rtlLanguages = ["ar", "he", "fa", "ur", "yi"]
        return rtlLanguages.contains(locale.languageCode ?? "")
    }
    
    // MARK: - Cultural Adaptation Implementation
    
    public func adaptContent(for locale: Locale, content: ContentItem) -> AdaptedContent {
        let languageCode = locale.languageCode ?? "en"
        let rules = contentAdaptations[languageCode] ?? contentAdaptations["en"]!
        
        return AdaptedContent(
            originalContent: content,
            locale: locale,
            adaptedTitle: localizedString(for: content.titleKey, locale: locale),
            adaptedDescription: localizedString(for: content.descriptionKey, locale: locale),
            adaptedAudio: adaptAudioForLocale(content.audioContent, locale: locale, rules: rules),
            adaptedVisuals: adaptVisualsForLocale(content.visualContent, locale: locale, rules: rules),
            culturalNotes: getCulturalNotes(for: content, locale: locale),
            contentWarnings: getContentWarnings(for: content, locale: locale)
        )
    }
    
    public func getCulturalPreferences(for locale: Locale) -> CulturalPreferences {
        let languageCode = locale.languageCode ?? "en"
        return culturalPreferences[languageCode] ?? culturalPreferences["en"]!
    }
    
    public func validateCulturalSensitivity(content: ContentItem, locale: Locale) -> ValidationResult {
        let preferences = getCulturalPreferences(for: locale)
        let restrictions = getRegionalContentRestrictions(for: locale)
        
        var issues: [CulturalIssue] = []
        var warnings: [String] = []
        
        // Check against cultural preferences
        if preferences.avoidLoudSounds && content.audioContent.maxVolume > preferences.maxAcceptableVolume {
            issues.append(.loudSounds)
            warnings.append("Content may be too loud for cultural preferences in \(locale.displayName ?? "this region")")
        }
        
        if preferences.preferNatureSounds && !content.tags.contains("nature") {
            warnings.append("Natural sounds are preferred in \(locale.displayName ?? "this region")")
        }
        
        // Check against regional restrictions
        for restriction in restrictions {
            if content.tags.contains(restriction.restrictedTag) {
                issues.append(.restrictedContent)
                warnings.append("Content contains \(restriction.restrictedTag) which is restricted in \(locale.displayName ?? "this region")")
            }
        }
        
        return ValidationResult(
            isValid: issues.isEmpty,
            issues: issues,
            warnings: warnings,
            recommendedActions: generateRecommendedActions(for: issues, locale: locale)
        )
    }
    
    public func getRegionalContentRestrictions(for locale: Locale) -> [ContentRestriction] {
        let countryCode = locale.regionCode ?? "US"
        
        switch countryCode {
        case "CN": // China
            return [
                ContentRestriction(restrictedTag: "skeleton", reason: "Cultural sensitivity"),
                ContentRestriction(restrictedTag: "ghost", reason: "Cultural sensitivity")
            ]
        case "IN": // India
            return [
                ContentRestriction(restrictedTag: "cow", reason: "Religious sensitivity"),
                ContentRestriction(restrictedTag: "beef", reason: "Religious sensitivity")
            ]
        case "SA": // Saudi Arabia
            return [
                ContentRestriction(restrictedTag: "music", reason: "Religious restrictions"),
                ContentRestriction(restrictedTag: "dance", reason: "Cultural restrictions")
            ]
        default:
            return []
        }
    }
    
    // MARK: - Private Helper Methods
    
    private static func createSupportedLocales() -> [Locale] {
        let localeIdentifiers = [
            "en", "en-US", "en-GB", "en-AU", "en-CA",           // English variants
            "es", "es-ES", "es-MX", "es-AR", "es-CO",           // Spanish variants
            "fr", "fr-FR", "fr-CA", "fr-CH",                    // French variants
            "de", "de-DE", "de-AT", "de-CH",                    // German variants
            "it", "it-IT", "it-CH",                             // Italian variants
            "pt", "pt-PT", "pt-BR",                             // Portuguese variants
            "nl", "nl-NL", "nl-BE",                             // Dutch variants
            "ja", "ja-JP",                                      // Japanese
            "ko", "ko-KR",                                      // Korean
            "zh", "zh-CN", "zh-TW", "zh-HK",                    // Chinese variants
            "hi", "hi-IN",                                      // Hindi
            "ar", "ar-SA", "ar-EG", "ar-AE",                    // Arabic variants
            "ru", "ru-RU",                                      // Russian
            "pl", "pl-PL",                                      // Polish
            "sv", "sv-SE",                                      // Swedish
            "no", "no-NO",                                      // Norwegian
            "da", "da-DK",                                      // Danish
            "fi", "fi-FI",                                      // Finnish
            "he", "he-IL",                                      // Hebrew
            "th", "th-TH",                                      // Thai
            "vi", "vi-VN",                                      // Vietnamese
            "tr", "tr-TR",                                      // Turkish
            "uk", "uk-UA",                                      // Ukrainian
            "cs", "cs-CZ",                                      // Czech
            "hu", "hu-HU",                                      // Hungarian
            "ro", "ro-RO"                                       // Romanian
        ]
        
        return localeIdentifiers.map { Locale(identifier: $0) }
    }
    
    private static func loadLocalizedStrings() -> [String: [String: String]] {
        return [
            "en": loadEnglishStrings(),
            "es": loadSpanishStrings(),
            "fr": loadFrenchStrings(),
            "de": loadGermanStrings(),
            "ja": loadJapaneseStrings(),
            "ko": loadKoreanStrings(),
            "zh": loadChineseStrings(),
            "ar": loadArabicStrings(),
            "ru": loadRussianStrings(),
            // Add more languages as needed
        ]
    }
    
    private static func loadCulturalPreferences() -> [String: CulturalPreferences] {
        return [
            "en": CulturalPreferences(
                preferNatureSounds: true,
                avoidLoudSounds: false,
                maxAcceptableVolume: 0.8,
                preferredAudioLength: 1800, // 30 minutes
                colorPreferences: ColorPreferences(primary: .blue, secondary: .green),
                timeFormat: .twelve,
                dateFormat: .mdy
            ),
            "ja": CulturalPreferences(
                preferNatureSounds: true,
                avoidLoudSounds: true,
                maxAcceptableVolume: 0.6,
                preferredAudioLength: 3600, // 60 minutes
                colorPreferences: ColorPreferences(primary: .blue, secondary: .white),
                timeFormat: .twentyFour,
                dateFormat: .ymd
            ),
            "ar": CulturalPreferences(
                preferNatureSounds: true,
                avoidLoudSounds: false,
                maxAcceptableVolume: 0.7,
                preferredAudioLength: 1200, // 20 minutes
                colorPreferences: ColorPreferences(primary: .green, secondary: .gold),
                timeFormat: .twelve,
                dateFormat: .dmy
            ),
            // Add more cultural preferences
        ]
    }
    
    private static func loadContentAdaptations() -> [String: ContentAdaptationRules] {
        return [
            "en": ContentAdaptationRules(
                visualAdaptations: [],
                audioAdaptations: [],
                textAdaptations: []
            ),
            "ja": ContentAdaptationRules(
                visualAdaptations: [.reduceContrast, .addSubtleAnimations],
                audioAdaptations: [.reduceBass, .addSilentPauses],
                textAdaptations: [.usePoliteForm, .addHonorificPrefix]
            ),
            "ar": ContentAdaptationRules(
                visualAdaptations: [.flipHorizontally, .adjustForRTL],
                audioAdaptations: [],
                textAdaptations: [.rightAlign, .useArabicNumerals]
            ),
            // Add more adaptation rules
        ]
    }
    
    // MARK: - Localization String Loaders
    
    private static func loadEnglishStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "Forest Walk",
            "scene.forest.description": "Peaceful sounds of nature for your dog's relaxation",
            "scene.beach.title": "Beach Waves",
            "scene.beach.description": "Gentle ocean sounds to calm and soothe",
            "scene.city.title": "City Sounds",
            "scene.city.description": "Urban environments to help dogs adapt to city life",
            "settings.volume": "Volume",
            "settings.language": "Language",
            "settings.accessibility": "Accessibility",
            "privacy.title": "Privacy Settings",
            "privacy.data_use": "How we use your data",
            "privacy.cookies": "Cookie preferences",
            "subscription.title": "DogTV+ Premium",
            "subscription.features": "Unlock premium features for your furry friend",
            "error.network": "Network connection error",
            "error.audio": "Audio playback error",
            "loading.content": "Loading content...",
            "accessibility.play_button": "Play audio content",
            "accessibility.pause_button": "Pause audio content",
            "accessibility.volume_slider": "Adjust volume level"
        ]
    }
    
    private static func loadSpanishStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "Paseo por el Bosque",
            "scene.forest.description": "Sonidos pacíficos de la naturaleza para la relajación de tu perro",
            "scene.beach.title": "Olas de la Playa",
            "scene.beach.description": "Suaves sonidos del océano para calmar y tranquilizar",
            "scene.city.title": "Sonidos de la Ciudad",
            "scene.city.description": "Ambientes urbanos para ayudar a los perros a adaptarse a la vida en la ciudad",
            "settings.volume": "Volumen",
            "settings.language": "Idioma",
            "settings.accessibility": "Accesibilidad",
            "privacy.title": "Configuración de Privacidad",
            "privacy.data_use": "Cómo usamos tus datos",
            "privacy.cookies": "Preferencias de cookies",
            "subscription.title": "DogTV+ Premium",
            "subscription.features": "Desbloquea funciones premium para tu amigo peludo",
            "error.network": "Error de conexión de red",
            "error.audio": "Error de reproducción de audio",
            "loading.content": "Cargando contenido...",
            "accessibility.play_button": "Reproducir contenido de audio",
            "accessibility.pause_button": "Pausar contenido de audio",
            "accessibility.volume_slider": "Ajustar nivel de volumen"
        ]
    }
    
    private static func loadFrenchStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "Promenade en Forêt",
            "scene.forest.description": "Sons paisibles de la nature pour la relaxation de votre chien",
            "scene.beach.title": "Vagues de la Plage",
            "scene.beach.description": "Doux sons de l'océan pour calmer et apaiser",
            "scene.city.title": "Sons de la Ville",
            "scene.city.description": "Environnements urbains pour aider les chiens à s'adapter à la vie en ville",
            "settings.volume": "Volume",
            "settings.language": "Langue",
            "settings.accessibility": "Accessibilité",
            "privacy.title": "Paramètres de Confidentialité",
            "privacy.data_use": "Comment nous utilisons vos données",
            "privacy.cookies": "Préférences de cookies",
            "subscription.title": "DogTV+ Premium",
            "subscription.features": "Débloquez des fonctionnalités premium pour votre ami à fourrure",
            "error.network": "Erreur de connexion réseau",
            "error.audio": "Erreur de lecture audio",
            "loading.content": "Chargement du contenu...",
            "accessibility.play_button": "Lire le contenu audio",
            "accessibility.pause_button": "Mettre en pause le contenu audio",
            "accessibility.volume_slider": "Ajuster le niveau de volume"
        ]
    }
    
    private static func loadGermanStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "Waldspaziergang",
            "scene.forest.description": "Friedliche Naturgeräusche zur Entspannung Ihres Hundes",
            "scene.beach.title": "Meereswellen",
            "scene.beach.description": "Sanfte Meeresgeräusche zum Beruhigen und Besänftigen",
            "scene.city.title": "Stadtgeräusche",
            "scene.city.description": "Urbane Umgebungen, um Hunden bei der Anpassung an das Stadtleben zu helfen",
            "settings.volume": "Lautstärke",
            "settings.language": "Sprache",
            "settings.accessibility": "Barrierefreiheit",
            "privacy.title": "Datenschutzeinstellungen",
            "privacy.data_use": "Wie wir Ihre Daten verwenden",
            "privacy.cookies": "Cookie-Einstellungen",
            "subscription.title": "DogTV+ Premium",
            "subscription.features": "Premium-Funktionen für Ihren pelzigen Freund freischalten",
            "error.network": "Netzwerkverbindungsfehler",
            "error.audio": "Audio-Wiedergabefehler",
            "loading.content": "Inhalt wird geladen...",
            "accessibility.play_button": "Audio-Inhalt abspielen",
            "accessibility.pause_button": "Audio-Inhalt pausieren",
            "accessibility.volume_slider": "Lautstärke anpassen"
        ]
    }
    
    private static func loadJapaneseStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "森の散歩",
            "scene.forest.description": "愛犬のリラクゼーションのための平和な自然の音",
            "scene.beach.title": "海の波",
            "scene.beach.description": "心を落ち着かせる優しい海の音",
            "scene.city.title": "都市の音",
            "scene.city.description": "犬が都市生活に適応するのを助ける都市環境",
            "settings.volume": "音量",
            "settings.language": "言語",
            "settings.accessibility": "アクセシビリティ",
            "privacy.title": "プライバシー設定",
            "privacy.data_use": "データの使用方法",
            "privacy.cookies": "クッキー設定",
            "subscription.title": "DogTV+ プレミアム",
            "subscription.features": "毛むくじゃらの友達のためのプレミアム機能をアンロック",
            "error.network": "ネットワーク接続エラー",
            "error.audio": "オーディオ再生エラー",
            "loading.content": "コンテンツを読み込み中...",
            "accessibility.play_button": "オーディオコンテンツを再生",
            "accessibility.pause_button": "オーディオコンテンツを一時停止",
            "accessibility.volume_slider": "音量レベルを調整"
        ]
    }
    
    private static func loadKoreanStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "숲 산책",
            "scene.forest.description": "반려견의 휴식을 위한 평화로운 자연의 소리",
            "scene.beach.title": "해변 파도",
            "scene.beach.description": "진정시키고 달래는 부드러운 바다 소리",
            "scene.city.title": "도시 소리",
            "scene.city.description": "개들이 도시 생활에 적응하도록 돕는 도시 환경",
            "settings.volume": "볼륨",
            "settings.language": "언어",
            "settings.accessibility": "접근성",
            "privacy.title": "개인정보 설정",
            "privacy.data_use": "데이터 사용 방법",
            "privacy.cookies": "쿠키 기본 설정",
            "subscription.title": "DogTV+ 프리미엄",
            "subscription.features": "털복숭이 친구를 위한 프리미엄 기능 잠금 해제",
            "error.network": "네트워크 연결 오류",
            "error.audio": "오디오 재생 오류",
            "loading.content": "콘텐츠 로딩 중...",
            "accessibility.play_button": "오디오 콘텐츠 재생",
            "accessibility.pause_button": "오디오 콘텐츠 일시 정지",
            "accessibility.volume_slider": "볼륨 레벨 조정"
        ]
    }
    
    private static func loadChineseStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "森林漫步",
            "scene.forest.description": "让您的狗狗放松的宁静自然声音",
            "scene.beach.title": "海浪声",
            "scene.beach.description": "舒缓平静的温柔海洋声音",
            "scene.city.title": "城市声音",
            "scene.city.description": "帮助狗狗适应城市生活的都市环境",
            "settings.volume": "音量",
            "settings.language": "语言",
            "settings.accessibility": "无障碍功能",
            "privacy.title": "隐私设置",
            "privacy.data_use": "我们如何使用您的数据",
            "privacy.cookies": "Cookie偏好设置",
            "subscription.title": "DogTV+ 高级版",
            "subscription.features": "为您的毛茸茸朋友解锁高级功能",
            "error.network": "网络连接错误",
            "error.audio": "音频播放错误",
            "loading.content": "正在加载内容...",
            "accessibility.play_button": "播放音频内容",
            "accessibility.pause_button": "暂停音频内容",
            "accessibility.volume_slider": "调整音量级别"
        ]
    }
    
    private static func loadArabicStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "نزهة في الغابة",
            "scene.forest.description": "أصوات الطبيعة الهادئة لاسترخاء كلبك",
            "scene.beach.title": "أمواج الشاطئ",
            "scene.beach.description": "أصوات المحيط اللطيفة للتهدئة والسكينة",
            "scene.city.title": "أصوات المدينة",
            "scene.city.description": "البيئات الحضرية لمساعدة الكلاب على التكيف مع الحياة في المدينة",
            "settings.volume": "مستوى الصوت",
            "settings.language": "اللغة",
            "settings.accessibility": "إمكانية الوصول",
            "privacy.title": "إعدادات الخصوصية",
            "privacy.data_use": "كيف نستخدم بياناتك",
            "privacy.cookies": "تفضيلات ملفات تعريف الارتباط",
            "subscription.title": "DogTV+ المميز",
            "subscription.features": "فتح المميزات المتقدمة لصديقك ذو الفراء",
            "error.network": "خطأ في الاتصال بالشبكة",
            "error.audio": "خطأ في تشغيل الصوت",
            "loading.content": "جارٍ تحميل المحتوى...",
            "accessibility.play_button": "تشغيل المحتوى الصوتي",
            "accessibility.pause_button": "إيقاف المحتوى الصوتي مؤقتاً",
            "accessibility.volume_slider": "ضبط مستوى الصوت"
        ]
    }
    
    private static func loadRussianStrings() -> [String: String] {
        return [
            "app.name": "DogTV+",
            "scene.forest.title": "Лесная прогулка",
            "scene.forest.description": "Мирные звуки природы для расслабления вашей собаки",
            "scene.beach.title": "Морские волны",
            "scene.beach.description": "Нежные звуки океана для успокоения и умиротворения",
            "scene.city.title": "Городские звуки",
            "scene.city.description": "Городская среда, помогающая собакам адаптироваться к городской жизни",
            "settings.volume": "Громкость",
            "settings.language": "Язык",
            "settings.accessibility": "Доступность",
            "privacy.title": "Настройки конфиденциальности",
            "privacy.data_use": "Как мы используем ваши данные",
            "privacy.cookies": "Настройки файлов cookie",
            "subscription.title": "DogTV+ Премиум",
            "subscription.features": "Разблокируйте премиум-функции для вашего пушистого друга",
            "error.network": "Ошибка сетевого подключения",
            "error.audio": "Ошибка воспроизведения аудио",
            "loading.content": "Загрузка контента...",
            "accessibility.play_button": "Воспроизвести аудиоконтент",
            "accessibility.pause_button": "Приостановить аудиоконтент",
            "accessibility.volume_slider": "Настроить уровень громкости"
        ]
    }
    
    // MARK: - Content Adaptation Methods
    
    private func adaptAudioForLocale(_ audioContent: AudioContent, locale: Locale, rules: ContentAdaptationRules) -> AudioContent {
        var adaptedAudio = audioContent
        
        for adaptation in rules.audioAdaptations {
            switch adaptation {
            case .reduceBass:
                adaptedAudio.bassLevel *= 0.7
            case .addSilentPauses:
                adaptedAudio.pauseDuration += 2.0
            case .adjustTempo:
                adaptedAudio.tempo *= 0.9
            }
        }
        
        return adaptedAudio
    }
    
    private func adaptVisualsForLocale(_ visualContent: VisualContent, locale: Locale, rules: ContentAdaptationRules) -> VisualContent {
        var adaptedVisual = visualContent
        
        for adaptation in rules.visualAdaptations {
            switch adaptation {
            case .flipHorizontally:
                adaptedVisual.isFlippedHorizontally = true
            case .adjustForRTL:
                adaptedVisual.layoutDirection = .rightToLeft
            case .reduceContrast:
                adaptedVisual.contrast *= 0.8
            case .addSubtleAnimations:
                adaptedVisual.animationIntensity = 0.3
            }
        }
        
        return adaptedVisual
    }
    
    private func getCulturalNotes(for content: ContentItem, locale: Locale) -> [String] {
        let languageCode = locale.languageCode ?? "en"
        
        switch languageCode {
        case "ja":
            return ["This content has been adapted for Japanese cultural preferences with reduced audio intensity"]
        case "ar":
            return ["هذا المحتوى تم تكييفه للتفضيلات الثقافية العربية"]
        case "zh":
            return ["此内容已根据中国文化偏好进行调整"]
        default:
            return []
        }
    }
    
    private func getContentWarnings(for content: ContentItem, locale: Locale) -> [String] {
        let restrictions = getRegionalContentRestrictions(for: locale)
        var warnings: [String] = []
        
        for restriction in restrictions {
            if content.tags.contains(restriction.restrictedTag) {
                warnings.append("Content warning: \(restriction.reason)")
            }
        }
        
        return warnings
    }
    
    private func generateRecommendedActions(for issues: [CulturalIssue], locale: Locale) -> [String] {
        var actions: [String] = []
        
        for issue in issues {
            switch issue {
            case .loudSounds:
                actions.append("Reduce volume or switch to gentler content")
            case .restrictedContent:
                actions.append("Consider alternative content suitable for \(locale.displayName ?? "this region")")
            case .culturalMismatch:
                actions.append("Review cultural adaptation settings")
            }
        }
        
        return actions
    }
}

// MARK: - Supporting Data Structures

public struct Currency {
    let code: String
    let symbol: String
    let locale: Locale
}

public struct ContentItem {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let audioContent: AudioContent
    let visualContent: VisualContent
    let tags: [String]
}

public struct AudioContent {
    var bassLevel: Float
    var pauseDuration: TimeInterval
    var tempo: Float
    var maxVolume: Float
}

public struct VisualContent {
    var isFlippedHorizontally: Bool = false
    var layoutDirection: LayoutDirection = .leftToRight
    var contrast: Float = 1.0
    var animationIntensity: Float = 1.0
}

public enum LayoutDirection {
    case leftToRight
    case rightToLeft
}

public struct AdaptedContent {
    let originalContent: ContentItem
    let locale: Locale
    let adaptedTitle: String
    let adaptedDescription: String
    let adaptedAudio: AudioContent
    let adaptedVisuals: VisualContent
    let culturalNotes: [String]
    let contentWarnings: [String]
}

public struct CulturalPreferences {
    let preferNatureSounds: Bool
    let avoidLoudSounds: Bool
    let maxAcceptableVolume: Float
    let preferredAudioLength: TimeInterval
    let colorPreferences: ColorPreferences
    let timeFormat: TimeFormat
    let dateFormat: DateFormat
}

public struct ColorPreferences {
    let primary: Color
    let secondary: Color
}

public enum Color {
    case red, blue, green, yellow, orange, purple, white, black, gold
}

public enum TimeFormat {
    case twelve
    case twentyFour
}

public enum DateFormat {
    case mdy  // Month/Day/Year (US)
    case dmy  // Day/Month/Year (EU)
    case ymd  // Year/Month/Day (Asia)
}

public struct ContentAdaptationRules {
    let visualAdaptations: [VisualAdaptation]
    let audioAdaptations: [AudioAdaptation]
    let textAdaptations: [TextAdaptation]
}

public enum VisualAdaptation {
    case flipHorizontally
    case adjustForRTL
    case reduceContrast
    case addSubtleAnimations
}

public enum AudioAdaptation {
    case reduceBass
    case addSilentPauses
    case adjustTempo
}

public enum TextAdaptation {
    case rightAlign
    case useArabicNumerals
    case usePoliteForm
    case addHonorificPrefix
}

public struct ValidationResult {
    let isValid: Bool
    let issues: [CulturalIssue]
    let warnings: [String]
    let recommendedActions: [String]
}

public enum CulturalIssue {
    case loudSounds
    case restrictedContent
    case culturalMismatch
}

public struct ContentRestriction {
    let restrictedTag: String
    let reason: String
}

// MARK: - Localization Extensions
extension Locale {
    public var displayName: String? {
        return Locale.current.localizedString(forIdentifier: self.identifier)
    }
}
