import Foundation
import SwiftUI
import Combine

/**
 * Gamification System for DogTV+
 * 
 * Comprehensive gamification and engagement system
 * Increases user motivation through rewards, achievements, and progress tracking
 * 
 * Features:
 * - Achievement system
 * - Reward points and badges
 * - Progress tracking
 * - Challenges and goals
 * - Leaderboards
 * - Streak tracking
 * - Milestone celebrations
 * - Social competition
 * - Personalized goals
 * - Engagement analytics
 * 
 * Gamification Elements:
 * - Daily challenges
 * - Weekly goals
 * - Monthly achievements
 * - Special events
 * - Community challenges
 * - Personal milestones
 * - Reward redemption
 * - Progress visualization
 */
public class GamificationSystem: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var userProgress: UserProgress = UserProgress()
    @Published public var achievements: [Achievement] = []
    @Published public var rewards: [Reward] = []
    @Published public var challenges: [Challenge] = []
    @Published public var leaderboards: [Leaderboard] = []
    @Published public var engagementMetrics: EngagementMetrics = EngagementMetrics()
    
    // MARK: - System Components
    private let achievementManager = AchievementManager()
    private let rewardManager = RewardManager()
    private let progressTracker = ProgressTracker()
    private let challengeManager = ChallengeManager()
    private let leaderboardManager = LeaderboardManager()
    private let analyticsManager = GamificationAnalyticsManager()
    
    // MARK: - Configuration
    private var gamificationConfig: GamificationConfiguration
    private var achievementConfig: AchievementConfiguration
    private var rewardConfig: RewardConfiguration
    
    // MARK: - Data Structures
    
    public struct UserProgress: Codable {
        var level: Int = 1
        var experience: Int = 0
        var experienceToNextLevel: Int = 100
        var totalPoints: Int = 0
        var streakDays: Int = 0
        var longestStreak: Int = 0
        var achievementsUnlocked: Int = 0
        var challengesCompleted: Int = 0
        var lastActivity: Date = Date()
        var progressPercentage: Float = 0.0
    }
    
    public struct Achievement: Codable, Identifiable {
        public let id = UUID()
        var title: String
        var description: String
        var category: AchievementCategory
        var icon: String
        var points: Int
        var isUnlocked: Bool = false
        var unlockDate: Date?
        var progress: Float = 0.0
        var maxProgress: Int = 1
        var rarity: AchievementRarity = .common
    }
    
    public enum AchievementCategory: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case milestone = "Milestone"
        case special = "Special"
        case community = "Community"
        case seasonal = "Seasonal"
        
        var description: String {
            switch self {
            case .daily: return "Daily achievements"
            case .weekly: return "Weekly challenges"
            case .monthly: return "Monthly goals"
            case .milestone: return "Important milestones"
            case .special: return "Special events"
            case .community: return "Community achievements"
            case .seasonal: return "Seasonal events"
            }
        }
    }
    
    public enum AchievementRarity: String, CaseIterable, Codable {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: String {
            switch self {
            case .common: return "gray"
            case .uncommon: return "green"
            case .rare: return "blue"
            case .epic: return "purple"
            case .legendary: return "orange"
            }
        }
        
        var multiplier: Float {
            switch self {
            case .common: return 1.0
            case .uncommon: return 1.5
            case .rare: return 2.0
            case .epic: return 3.0
            case .legendary: return 5.0
            }
        }
    }
    
    public struct Reward: Codable, Identifiable {
        public let id = UUID()
        var title: String
        var description: String
        var type: RewardType
        var value: Int
        var isClaimed: Bool = false
        var claimDate: Date?
        var expiresAt: Date?
        var icon: String
    }
    
    public enum RewardType: String, CaseIterable, Codable {
        case points = "Points"
        case badge = "Badge"
        case content = "Content"
        case feature = "Feature"
        case discount = "Discount"
        case exclusive = "Exclusive"
        
        var description: String {
            switch self {
            case .points: return "Experience points"
            case .badge: return "Achievement badge"
            case .content: return "Exclusive content"
            case .feature: return "Special feature"
            case .discount: return "Premium discount"
            case .exclusive: return "Exclusive reward"
            }
        }
    }
    
    public struct Challenge: Codable, Identifiable {
        public let id = UUID()
        var title: String
        var description: String
        var type: ChallengeType
        var goal: Int
        var currentProgress: Int = 0
        var reward: Reward
        var startDate: Date
        var endDate: Date
        var isCompleted: Bool = false
        var isActive: Bool = true
        var difficulty: ChallengeDifficulty = .easy
    }
    
    public enum ChallengeType: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case special = "Special"
        case community = "Community"
        case personal = "Personal"
        
        var description: String {
            switch self {
            case .daily: return "Daily challenge"
            case .weekly: return "Weekly challenge"
            case .monthly: return "Monthly challenge"
            case .special: return "Special event"
            case .community: return "Community challenge"
            case .personal: return "Personal goal"
            }
        }
    }
    
    public enum ChallengeDifficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
        
        var multiplier: Float {
            switch self {
            case .easy: return 1.0
            case .medium: return 1.5
            case .hard: return 2.0
            case .expert: return 3.0
            }
        }
        
        var color: String {
            switch self {
            case .easy: return "green"
            case .medium: return "yellow"
            case .hard: return "orange"
            case .expert: return "red"
            }
        }
    }
    
    public struct Leaderboard: Codable, Identifiable {
        public let id = UUID()
        var title: String
        var type: LeaderboardType
        var entries: [LeaderboardEntry] = []
        var timeFrame: TimeFrame = .weekly
        var lastUpdated: Date = Date()
    }
    
    public enum LeaderboardType: String, CaseIterable, Codable {
        case points = "Points"
        case achievements = "Achievements"
        case streaks = "Streaks"
        case challenges = "Challenges"
        case community = "Community"
        
        var description: String {
            switch self {
            case .points: return "Total points"
            case .achievements: return "Achievements unlocked"
            case .streaks: return "Longest streaks"
            case .challenges: return "Challenges completed"
            case .community: return "Community contribution"
            }
        }
    }
    
    public enum TimeFrame: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case allTime = "All Time"
    }
    
    public struct LeaderboardEntry: Codable, Identifiable {
        public let id = UUID()
        var username: String
        var score: Int
        var rank: Int
        var avatar: String?
        var lastActivity: Date
    }
    
    public struct EngagementMetrics: Codable {
        var dailyActiveUsers: Int = 0
        var averageSessionTime: TimeInterval = 0.0
        var completionRate: Float = 0.0
        var retentionRate: Float = 0.0
        var engagementScore: Float = 0.0
        var lastUpdated: Date = Date()
    }
    
    // MARK: - Initialization
    
    public init() {
        self.gamificationConfig = GamificationConfiguration()
        self.achievementConfig = AchievementConfiguration()
        self.rewardConfig = RewardConfiguration()
        
        setupGamificationSystem()
        print("GamificationSystem initialized")
    }
    
    // MARK: - Public Methods
    
    /// Award points to user
    public func awardPoints(_ points: Int, reason: String) async {
        let oldLevel = userProgress.level
        userProgress.experience += points
        userProgress.totalPoints += points
        
        // Check for level up
        while userProgress.experience >= userProgress.experienceToNextLevel {
            await levelUp()
        }
        
        await updateProgress()
        await checkAchievements()
        
        print("Awarded \(points) points for: \(reason)")
        
        if userProgress.level > oldLevel {
            await celebrateLevelUp()
        }
    }
    
    /// Unlock achievement
    public func unlockAchievement(_ achievement: Achievement) async {
        guard !achievement.isUnlocked else { return }
        
        var updatedAchievement = achievement
        updatedAchievement.isUnlocked = true
        updatedAchievement.unlockDate = Date()
        
        await MainActor.run {
            if let index = achievements.firstIndex(where: { $0.id == achievement.id }) {
                achievements[index] = updatedAchievement
            }
            userProgress.achievementsUnlocked += 1
        }
        
        // Award points for achievement
        let points = Int(Float(achievement.points) * achievement.rarity.multiplier)
        await awardPoints(points, reason: "Achievement: \(achievement.title)")
        
        await celebrateAchievement(updatedAchievement)
        
        print("Achievement unlocked: \(achievement.title)")
    }
    
    /// Update challenge progress
    public func updateChallengeProgress(_ challengeId: UUID, progress: Int) async {
        guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else { return }
        
        var challenge = challenges[index]
        challenge.currentProgress = progress
        
        if progress >= challenge.goal && !challenge.isCompleted {
            challenge.isCompleted = true
            await completeChallenge(challenge)
        }
        
        await MainActor.run {
            challenges[index] = challenge
        }
        
        print("Challenge progress updated: \(progress)/\(challenge.goal)")
    }
    
    /// Claim reward
    public func claimReward(_ reward: Reward) async throws {
        guard !reward.isClaimed else {
            throw GamificationError.rewardAlreadyClaimed
        }
        
        guard reward.expiresAt == nil || reward.expiresAt! > Date() else {
            throw GamificationError.rewardExpired
        }
        
        var updatedReward = reward
        updatedReward.isClaimed = true
        updatedReward.claimDate = Date()
        
        await MainActor.run {
            if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
                rewards[index] = updatedReward
            }
        }
        
        await applyReward(updatedReward)
        await celebrateReward(updatedReward)
        
        print("Reward claimed: \(reward.title)")
    }
    
    /// Start daily streak
    public func startDailyStreak() async {
        userProgress.streakDays += 1
        
        if userProgress.streakDays > userProgress.longestStreak {
            userProgress.longestStreak = userProgress.streakDays
        }
        
        await updateProgress()
        await checkStreakAchievements()
        
        print("Daily streak: \(userProgress.streakDays) days")
    }
    
    /// Break daily streak
    public func breakDailyStreak() async {
        userProgress.streakDays = 0
        await updateProgress()
        
        print("Daily streak broken")
    }
    
    /// Generate daily challenges
    public func generateDailyChallenges() async -> [Challenge] {
        let dailyChallenges = await challengeManager.generateDailyChallenges()
        
        await MainActor.run {
            challenges.append(contentsOf: dailyChallenges)
        }
        
        print("Generated \(dailyChallenges.count) daily challenges")
        
        return dailyChallenges
    }
    
    /// Get leaderboard
    public func getLeaderboard(_ type: LeaderboardType) async -> Leaderboard {
        let leaderboard = await leaderboardManager.getLeaderboard(type: type)
        
        await MainActor.run {
            if let index = leaderboards.firstIndex(where: { $0.type == type }) {
                leaderboards[index] = leaderboard
            } else {
                leaderboards.append(leaderboard)
            }
        }
        
        return leaderboard
    }
    
    /// Track user activity
    public func trackActivity(_ activity: UserActivity) async {
        await progressTracker.trackActivity(activity)
        
        // Check for achievements based on activity
        await checkActivityAchievements(activity)
        
        // Update engagement metrics
        await updateEngagementMetrics()
        
        print("Activity tracked: \(activity.type.rawValue)")
    }
    
    /// Get user statistics
    public func getUserStatistics() -> UserStatistics {
        return UserStatistics(
            level: userProgress.level,
            totalPoints: userProgress.totalPoints,
            achievementsUnlocked: userProgress.achievementsUnlocked,
            challengesCompleted: userProgress.challengesCompleted,
            currentStreak: userProgress.streakDays,
            longestStreak: userProgress.longestStreak,
            rank: calculateRank()
        )
    }
    
    // MARK: - Private Methods
    
    private func setupGamificationSystem() {
        // Configure system components
        achievementManager.configure(achievementConfig)
        rewardManager.configure(rewardConfig)
        progressTracker.configure(gamificationConfig)
        challengeManager.configure(gamificationConfig)
        leaderboardManager.configure(gamificationConfig)
        analyticsManager.configure(gamificationConfig)
        
        // Setup monitoring
        setupGamificationMonitoring()
    }
    
    private func setupGamificationMonitoring() {
        // Monitor daily streaks
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
            self?.checkDailyStreak()
        }
        
        // Monitor challenge expiration
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkChallengeExpiration()
        }
    }
    
    private func levelUp() async {
        userProgress.level += 1
        userProgress.experience -= userProgress.experienceToNextLevel
        userProgress.experienceToNextLevel = calculateNextLevelExperience()
        
        await checkLevelAchievements()
    }
    
    private func calculateNextLevelExperience() -> Int {
        return userProgress.level * 100 + (userProgress.level - 1) * 50
    }
    
    private func updateProgress() {
        userProgress.progressPercentage = Float(userProgress.experience) / Float(userProgress.experienceToNextLevel)
        userProgress.lastActivity = Date()
    }
    
    private func checkAchievements() async {
        let unlockedAchievements = await achievementManager.checkAchievements(userProgress: userProgress)
        
        for achievement in unlockedAchievements {
            await unlockAchievement(achievement)
        }
    }
    
    private func checkActivityAchievements(_ activity: UserActivity) async {
        let activityAchievements = await achievementManager.checkActivityAchievements(activity: activity)
        
        for achievement in activityAchievements {
            await unlockAchievement(achievement)
        }
    }
    
    private func checkLevelAchievements() async {
        let levelAchievements = await achievementManager.checkLevelAchievements(level: userProgress.level)
        
        for achievement in levelAchievements {
            await unlockAchievement(achievement)
        }
    }
    
    private func checkStreakAchievements() async {
        let streakAchievements = await achievementManager.checkStreakAchievements(streak: userProgress.streakDays)
        
        for achievement in streakAchievements {
            await unlockAchievement(achievement)
        }
    }
    
    private func completeChallenge(_ challenge: Challenge) async {
        await MainActor.run {
            userProgress.challengesCompleted += 1
        }
        
        // Award challenge reward
        await applyReward(challenge.reward)
        
        await celebrateChallengeCompletion(challenge)
    }
    
    private func applyReward(_ reward: Reward) async {
        switch reward.type {
        case .points:
            await awardPoints(reward.value, reason: "Reward: \(reward.title)")
        case .badge:
            await unlockBadge(reward.title)
        case .content:
            await unlockContent(reward.title)
        case .feature:
            await unlockFeature(reward.title)
        case .discount:
            await applyDiscount(reward.value)
        case .exclusive:
            await unlockExclusive(reward.title)
        }
    }
    
    private func unlockBadge(_ badgeName: String) async {
        // Unlock badge functionality
        print("Badge unlocked: \(badgeName)")
    }
    
    private func unlockContent(_ contentName: String) async {
        // Unlock exclusive content
        print("Content unlocked: \(contentName)")
    }
    
    private func unlockFeature(_ featureName: String) async {
        // Unlock special feature
        print("Feature unlocked: \(featureName)")
    }
    
    private func applyDiscount(_ discountValue: Int) async {
        // Apply discount to premium features
        print("Discount applied: \(discountValue)%")
    }
    
    private func unlockExclusive(_ exclusiveName: String) async {
        // Unlock exclusive reward
        print("Exclusive unlocked: \(exclusiveName)")
    }
    
    private func celebrateLevelUp() async {
        // Trigger level up celebration
        print("🎉 Level up! Now level \(userProgress.level)")
    }
    
    private func celebrateAchievement(_ achievement: Achievement) async {
        // Trigger achievement celebration
        print("🏆 Achievement unlocked: \(achievement.title)")
    }
    
    private func celebrateReward(_ reward: Reward) async {
        // Trigger reward celebration
        print("🎁 Reward claimed: \(reward.title)")
    }
    
    private func celebrateChallengeCompletion(_ challenge: Challenge) async {
        // Trigger challenge completion celebration
        print("✅ Challenge completed: \(challenge.title)")
    }
    
    private func checkDailyStreak() {
        // Check if user has been active today
        let calendar = Calendar.current
        let lastActivity = userProgress.lastActivity
        
        if !calendar.isDateInToday(lastActivity) {
            Task {
                await breakDailyStreak()
            }
        }
    }
    
    private func checkChallengeExpiration() {
        let now = Date()
        
        for (index, challenge) in challenges.enumerated() {
            if challenge.endDate < now && challenge.isActive {
                challenges[index].isActive = false
            }
        }
    }
    
    private func updateEngagementMetrics() {
        Task {
            let metrics = await analyticsManager.getEngagementMetrics()
            await MainActor.run {
                engagementMetrics = metrics
            }
        }
    }
    
    private func calculateRank() -> Int {
        // Calculate user rank based on total points
        return 1 // Placeholder
    }
}

// MARK: - Supporting Classes

class AchievementManager {
    func configure(_ config: AchievementConfiguration) {
        // Configure achievement manager
    }
    
    func checkAchievements(userProgress: UserProgress) async -> [Achievement] {
        // Check for unlocked achievements
        return []
    }
    
    func checkActivityAchievements(activity: UserActivity) async -> [Achievement] {
        // Check for activity-based achievements
        return []
    }
    
    func checkLevelAchievements(level: Int) async -> [Achievement] {
        // Check for level-based achievements
        return []
    }
    
    func checkStreakAchievements(streak: Int) async -> [Achievement] {
        // Check for streak-based achievements
        return []
    }
}

class RewardManager {
    func configure(_ config: RewardConfiguration) {
        // Configure reward manager
    }
}

class ProgressTracker {
    func configure(_ config: GamificationConfiguration) {
        // Configure progress tracker
    }
    
    func trackActivity(_ activity: UserActivity) async {
        // Track user activity
    }
}

class ChallengeManager {
    func configure(_ config: GamificationConfiguration) {
        // Configure challenge manager
    }
    
    func generateDailyChallenges() async -> [Challenge] {
        // Generate daily challenges
        return [
            Challenge(
                title: "Watch 3 videos",
                description: "Watch 3 different videos today",
                type: .daily,
                goal: 3,
                reward: Reward(
                    title: "Daily Watcher",
                    description: "Complete daily watching challenge",
                    type: .points,
                    value: 50,
                    icon: "play.circle"
                ),
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                difficulty: .easy
            )
        ]
    }
}

class LeaderboardManager {
    func configure(_ config: GamificationConfiguration) {
        // Configure leaderboard manager
    }
    
    func getLeaderboard(type: LeaderboardType) async -> Leaderboard {
        // Get leaderboard for type
        return Leaderboard(
            title: "\(type.rawValue) Leaderboard",
            type: type,
            entries: []
        )
    }
}

class GamificationAnalyticsManager {
    func configure(_ config: GamificationConfiguration) {
        // Configure analytics manager
    }
    
    func getEngagementMetrics() async -> EngagementMetrics {
        // Get engagement metrics
        return EngagementMetrics()
    }
}

// MARK: - Supporting Data Structures

public struct GamificationConfiguration {
    var pointsMultiplier: Float = 1.0
    var streakBonus: Float = 1.5
    var achievementBonus: Float = 2.0
    var challengeRewards: [String: Int] = [:]
}

public struct AchievementConfiguration {
    var autoUnlock: Bool = true
    var notificationEnabled: Bool = true
    var celebrationEnabled: Bool = true
}

public struct RewardConfiguration {
    var autoClaim: Bool = false
    var expirationEnabled: Bool = true
    var notificationEnabled: Bool = true
}

public struct UserActivity: Codable {
    var type: ActivityType
    var timestamp: Date
    var duration: TimeInterval?
    var metadata: [String: Any]
}

public enum ActivityType: String, CaseIterable, Codable {
    case watchVideo = "Watch Video"
    case completeChallenge = "Complete Challenge"
    case unlockAchievement = "Unlock Achievement"
    case shareContent = "Share Content"
    case inviteFriend = "Invite Friend"
    case dailyLogin = "Daily Login"
}

public struct UserStatistics: Codable {
    let level: Int
    let totalPoints: Int
    let achievementsUnlocked: Int
    let challengesCompleted: Int
    let currentStreak: Int
    let longestStreak: Int
    let rank: Int
}

// MARK: - Error Types

public enum GamificationError: Error, LocalizedError {
    case rewardAlreadyClaimed
    case rewardExpired
    case insufficientPoints
    case challengeNotFound
    case achievementNotFound
    
    public var errorDescription: String? {
        switch self {
        case .rewardAlreadyClaimed:
            return "Reward has already been claimed"
        case .rewardExpired:
            return "Reward has expired"
        case .insufficientPoints:
            return "Insufficient points for this action"
        case .challengeNotFound:
            return "Challenge not found"
        case .achievementNotFound:
            return "Achievement not found"
        }
    }
} 