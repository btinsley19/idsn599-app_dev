//
//  ContentView.swift
//  ex5_polished
//
//  Created by Brian Tinsley on 9/25/25.
//

import SwiftUI
import SwiftData
import UserNotifications
import Charts
import AVFoundation

// MARK: - App State Manager
@MainActor
class AppState: ObservableObject {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
}

// MARK: - Main Content View (App Root)
struct ContentView: View {
    @State private var showSplash = true
    @StateObject private var appState = AppState()

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
            } else {
                if appState.isFirstLaunch {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }
        }
        .environmentObject(appState)
        .onAppear {
            // Show splash for 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - 1. Model (SwiftData)

@Model
final class DailyEntry {
    @Attribute(.unique) var date: Date
    var emotionScore: Int
    var energyScore: Int
    var productivityScore: Int
    var stressScore: Int
    var satisfactionScore: Int
    var nutritionScore: Int
    var sleepScore: Int
    var exerciseScore: Int
    var gratitudeScore: Int
    var socialConnectionScore: Int
    var influenceTags: [String] = []
    var journalText: String = ""
    @Relationship(deleteRule: .cascade)
    var reflections: [PromptEntry] = []
    var isComplete: Bool

    init(date: Date, emotionScore: Int = 5, energyScore: Int = 5, productivityScore: Int = 5, stressScore: Int = 5, satisfactionScore: Int = 5, nutritionScore: Int = 5, sleepScore: Int = 5, exerciseScore: Int = 5, gratitudeScore: Int = 5, socialConnectionScore: Int = 5, influenceTags: [String] = [], journalText: String = "", reflections: [PromptEntry] = [], isComplete: Bool = false) {
        self.date = date
        self.emotionScore = emotionScore
        self.energyScore = energyScore
        self.productivityScore = productivityScore
        self.stressScore = stressScore
        self.satisfactionScore = satisfactionScore
        self.nutritionScore = nutritionScore
        self.sleepScore = sleepScore
        self.exerciseScore = exerciseScore
        self.gratitudeScore = gratitudeScore
        self.socialConnectionScore = socialConnectionScore
        self.influenceTags = influenceTags
        self.journalText = journalText
        self.reflections = reflections
        self.isComplete = isComplete
    }
    
    var averageScore: Double {
        Double(emotionScore + energyScore + productivityScore + stressScore + satisfactionScore) / 5.0
    }
}

@Model
final class PromptEntry {
    var date: Date          // usually the same as DayEntry.date
    var category: String    // e.g. "🌱 Personal Growth"
    var prompt: String
    var answer: String

    init(date: Date, category: String, prompt: String, answer: String) {
        self.date = date
        self.category = category
        self.prompt = prompt
        self.answer = answer
    }
}

// MARK: - 2. ViewModels

@MainActor
class SettingsViewModel: ObservableObject {
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = true
    @AppStorage("soundEffectsEnabled") var soundEffectsEnabled: Bool = true
    @AppStorage("notificationTime") private var notificationTimeData: Data?

    var notificationTime: Date {
        get {
            guard let data = notificationTimeData,
                  let date = try? JSONDecoder().decode(Date.self, from: data) else {
                // Default to 8:00 AM, with a safe fallback to the current time if calendar fails.
                return Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
            }
            return date
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                notificationTimeData = data
                scheduleDailyNotification()
            }
        }
    }

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                self.scheduleDailyNotification()
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            // Execute completion on the main thread
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "DayStream Daily Check-in"
        content.body = "Time to reflect on your day. How are you feeling?"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                // Safely unwrap the optional hour and minute components to prevent a crash.
                print("Daily notification scheduled for \(dateComponents.hour ?? 0):\(String(format: "%02d", dateComponents.minute ?? 0))")
            }
        }
    }
}

/// A service to dynamically generate influence tags based on a DailyEntry's scores.
struct TagGenerationService {
    
    // Defines all possible dynamic tags and their generation rules.
    enum DynamicTag: String, CaseIterable {
        // Emotional / Mental State
        case calm = "Calm", joyful = "Joyful", content = "Content", grateful = "Grateful", inspired = "Inspired"
        case motivated = "Motivated", focused = "Focused", clearHeaded = "Clear-headed", distracted = "Distracted"
        case irritable = "Irritable", anxious = "Anxious", overwhelmed = "Overwhelmed", stressed = "Stressed"
        case lonely = "Lonely", bored = "Bored"
        
        // Lifestyle / Recovery
        case rested = "Rested", tired = "Tired", restDowntime = "Rest / Downtime", screenHeavy = "Screen-heavy"
        case overworked = "Overworked", balancedDay = "Balanced Day", timeInNature = "Time in Nature"
        case mindfulPresent = "Mindful / Present", creative = "Creative", playful = "Playful"
        
        // Social / Work Context
        case connected = "Connected", supported = "Supported", productiveDeepWork = "Productive Deep Work"
        case multitasking = "Multitasking", rushed = "Rushed"
        
        /// Checks if this tag is a candidate for a given entry based on its scores.
        func isCandidate(for entry: DailyEntry) -> Bool {
            switch self {
            // Emotional / Mental State
            case .calm: return entry.stressScore <= 3 && entry.emotionScore >= 6
            case .joyful: return entry.emotionScore >= 8 && entry.satisfactionScore >= 7
            case .content: return entry.emotionScore >= 6 && entry.stressScore <= 5
            case .grateful: return entry.gratitudeScore >= 7
            case .inspired: return entry.satisfactionScore >= 8 && entry.productivityScore >= 7
            case .motivated: return entry.energyScore >= 7 && entry.productivityScore >= 7
            case .focused: return entry.productivityScore >= 7 && entry.stressScore <= 5 // Simplified from original rules
            case .clearHeaded: return entry.stressScore <= 3 && entry.energyScore >= 6
            case .distracted: return entry.productivityScore <= 4 || entry.stressScore >= 7
            case .irritable: return entry.stressScore >= 7 && entry.emotionScore <= 4
            case .anxious: return entry.stressScore >= 8 && entry.energyScore >= 6
            case .overwhelmed: return entry.stressScore >= 8 && entry.productivityScore <= 5
            case .stressed: return entry.stressScore >= 7
            case .lonely: return entry.socialConnectionScore <= 3
            case .bored: return entry.emotionScore <= 4 && entry.productivityScore <= 4
                
            // Lifestyle / Recovery
            case .rested: return entry.sleepScore >= 7
            case .tired: return entry.sleepScore <= 3
            case .restDowntime: return entry.satisfactionScore >= 6 && entry.productivityScore <= 5
            case .screenHeavy: return entry.energyScore <= 5 && entry.productivityScore <= 5 && (entry.stressScore >= 6 ? Bool.random() : true)
            case .overworked: return entry.productivityScore >= 8 && entry.stressScore >= 7
            case .balancedDay: return entry.satisfactionScore >= 7 && entry.emotionScore >= 7 && entry.stressScore <= 5
            case .timeInNature: return entry.emotionScore >= 6 && entry.energyScore >= 6 && entry.satisfactionScore >= 6 && Bool.random()
            case .mindfulPresent: return entry.gratitudeScore >= 6 && entry.stressScore <= 4
            case .creative: return entry.energyScore >= 6 && entry.productivityScore >= 6 && entry.satisfactionScore >= 7
            case .playful: return entry.emotionScore >= 7 && entry.socialConnectionScore >= 6
                
            // Social / Work Context
            case .connected: return entry.socialConnectionScore >= 7
            case .supported: return entry.socialConnectionScore >= 6 && entry.gratitudeScore >= 6
            case .productiveDeepWork: return entry.productivityScore >= 8 && DynamicTag.focused.isCandidate(for: entry)
            case .multitasking: return entry.productivityScore >= 7 && entry.stressScore >= 6
            case .rushed: return entry.productivityScore >= 8 && entry.stressScore >= 8
            }
        }
    }
    
    // A few neutral tags to show when no specific suggestions are generated.
    private static let fallbackTags: [String] = ["Routine Day", "Quiet Day", "Just vibing"]
    
    /// Generates a list of suggested tags for a given entry.
    /// - Returns: An array of 3 to 5 randomly selected tag names from the valid candidates.
    static func generateSuggestedTags(for entry: DailyEntry) -> [String] {
        // 1. Generate the full list of candidate tags.
        var candidates = DynamicTag.allCases.filter { $0.isCandidate(for: entry) }.map { $0.rawValue }
        
        // 2. If no specific tags are generated, provide the fallbacks.
        if candidates.isEmpty {
            return fallbackTags
        }
        
        // 3. Determine how many tags to pick.
        let maxTags = 5
        let count = min(candidates.count, maxTags)
        
        // 4. Pick a random subset and return them.
        return Array(candidates.shuffled().prefix(count))
    }
}

class HapticManager {
    static let shared = HapticManager()
    @AppStorage("hapticFeedbackEnabled") private var _hapticsEnabled: Bool = true
    @AppStorage("soundEffectsEnabled") private var _soundEffectsEnabled: Bool = true

    // Public getter for other views to check the setting
    var hapticsEnabled: Bool { _hapticsEnabled }
    var soundEffectsEnabled: Bool { _soundEffectsEnabled }

    private init() {}

    // Note: UIImpactFeedbackGenerator is available on the main thread only in real SwiftUI apps.
    // Assuming this environment supports it via the main thread.
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func playSound(_ sound: SoundManager.Sound) {
        guard _soundEffectsEnabled else { return }
        SoundManager.shared.playSound(sound)
    }
}

// MARK: - 3. Views

// MARK: - Main Tab Structure
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]
    
    @State private var todayEntry: DailyEntry?
    
    var body: some View {
        Group {
            if let todayEntry {
                TabView {
                    DailyCheckInView(todayEntry: todayEntry)
                        .tabItem {
                            Label("Check-in", systemImage: "person.wave.2.fill")
                        }
                    
                    JournalPromptView(todayEntry: todayEntry)
                        .tabItem {
                            Label("Journal", systemImage: "book.closed.fill")
                        }
                    
                    InsightsView()
                        .tabItem {
                            Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
            } else {
                // Show a loading view while the entry is being prepared
                ProgressView("Preparing your day...")
            }
        }
        .onAppear(perform: loadOrCreateTodayEntry)
    }
    
    private func loadOrCreateTodayEntry() {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        if let existingEntry = entries.first(where: { calendar.isDate($0.date, inSameDayAs: todayStart) }) {
            todayEntry = existingEntry
        } else {
            let newEntry = DailyEntry(date: todayStart)
            modelContext.insert(newEntry)
            todayEntry = newEntry
        }
    }
}

// MARK: - Onboarding & Splash
struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.accentColor.opacity(0.1).ignoresSafeArea()
            Text("DayStream")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.accentColor)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var settingsVM = SettingsViewModel()
    @State private var tabSelection = 0

    var body: some View {
        VStack {
            TabView(selection: $tabSelection) {
                OnboardingPageView(
                    imageName: "sparkles",
                    title: "Welcome to DayStream",
                    description: "Your personal space for daily reflection and growth."
                )
                .tag(0)

                OnboardingPageView(
                    imageName: "slider.horizontal.3",
                    title: "Track Your Day",
                    description: "Quickly log your mood, energy, productivity, and more with intuitive sliders."
                )
                .tag(1)

                OnboardingPageView(
                    imageName: "chart.line.uptrend.xyaxis",
                    title: "Discover Insights",
                    description: "Visualize your trends, find patterns, and understand what influences your well-being."
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Spacer()

            if tabSelection == 2 {
                Button(action: {
                    // Request notification permission in the background
                    settingsVM.requestNotificationPermission { _ in }
                    
                    // Animate the transition to the main app
                    withAnimation {
                        appState.isFirstLaunch = false
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .transition(.scale.animation(.spring()))
            }
        }
        .padding()
    }
}

// MARK: - Tab 1: Daily Check-In
struct DailyCheckInView: View {
    @Bindable var todayEntry: DailyEntry // Changed to Bindable for scores update

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CheckInCardView(entry: todayEntry)
                    ScoreSlidersView(entry: todayEntry)
                    ContextSlidersView(entry: todayEntry)
                    InfluenceTaggerView(entry: todayEntry)
                    CompleteDayButton(entry: todayEntry)
                }
                .padding()
            }
            .navigationTitle("Today's Check-in")
            .background(Color(.systemGroupedBackground))
            .onChange(of: [todayEntry.emotionScore, todayEntry.energyScore, todayEntry.productivityScore, todayEntry.stressScore, todayEntry.satisfactionScore, todayEntry.nutritionScore, todayEntry.sleepScore, todayEntry.exerciseScore, todayEntry.gratitudeScore, todayEntry.socialConnectionScore]) {
                if todayEntry.isComplete { todayEntry.isComplete = false }
            }
            .onChange(of: todayEntry.influenceTags) {
                if todayEntry.isComplete { todayEntry.isComplete = false }
            }
        }
    }
}

struct CheckInCardView: View {
    var entry: DailyEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.date, style: .date)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                if entry.isComplete {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Complete")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .transition(.opacity.animation(.easeIn))
                }
            }
            Text(entry.isComplete ? "You've completed your entry for today. Great job!" : "How are you feeling today? Drag the sliders to reflect.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ScoreSlidersView: View {
    @Bindable var entry: DailyEntry
    
    var body: some View {
        VStack(spacing: 15) {
            ScoreSlider(label: "Emotion", systemImage: "face.smiling", value: $entry.emotionScore, color: .blue)
            ScoreSlider(label: "Energy", systemImage: "bolt.fill", value: $entry.energyScore, color: .orange)
            ScoreSlider(label: "Productivity", systemImage: "chart.bar.fill", value: $entry.productivityScore, color: .purple)
            ScoreSlider(label: "Stress", systemImage: "flame.fill", value: $entry.stressScore, color: .red)
            ScoreSlider(label: "Satisfaction", systemImage: "star.fill", value: $entry.satisfactionScore, color: .teal)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ContextSlidersView: View {
    @Bindable var entry: DailyEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Context")
                .font(.title3)
                .fontWeight(.semibold)
                .padding([.leading, .top])
            
            VStack(spacing: 15) {
                ScoreSlider(label: "Nutrition", systemImage: "leaf.fill", value: $entry.nutritionScore, color: .green)
                ScoreSlider(label: "Sleep", systemImage: "bed.double.fill", value: $entry.sleepScore, color: .indigo)
                ScoreSlider(label: "Exercise", systemImage: "figure.walk", value: $entry.exerciseScore, color: .cyan)
                ScoreSlider(label: "Gratitude", systemImage: "heart.fill", value: $entry.gratitudeScore, color: .pink)
                ScoreSlider(label: "Social", systemImage: "person.2.fill", value: $entry.socialConnectionScore, color: .yellow)
            }.padding()
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ScoreSlider: View {
    let label: String
    let systemImage: String
    @Binding var value: Int
    let color: Color

    private var gradient: LinearGradient {
        LinearGradient(colors: [color.opacity(0.3), color], startPoint: .leading, endPoint: .trailing)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                Text(label)
                    .font(.headline)
                Spacer()
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Slider(value: .init(get: { Double(value) }, set: { value = Int($0) }), in: 1...10, step: 1)
                .accentColor(color)
                .onChange(of: value) {
                    HapticManager.shared.impact(style: .soft)
                }
        }
    }
}

struct InfluenceTaggerView: View {
    @Bindable var entry: DailyEntry
    @State private var suggestedTags: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Suggested Tags")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom, 5)

            FlowLayout(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                // Display all suggested and already selected tags
                ForEach(Array(Set(suggestedTags + entry.influenceTags)).sorted(), id: \.self) { tag in
                    TagButton(tag: tag, isSelected: entry.influenceTags.contains(tag)) {
                        withAnimation(.spring()) {
                            HapticManager.shared.impact(style: .light)
                            if entry.influenceTags.contains(tag) {
                                entry.influenceTags.removeAll { $0 == tag }
                            } else {
                                entry.influenceTags.append(tag)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear(perform: generateTags)
        .onChange(of: [entry.emotionScore, entry.energyScore, entry.productivityScore, entry.stressScore, entry.satisfactionScore, entry.nutritionScore, entry.sleepScore, entry.exerciseScore, entry.gratitudeScore, entry.socialConnectionScore]) {
            generateTags()
        }
    }
    
    private func generateTags() {
        // 1. Always generate fresh suggestions based on the current slider values.
        let newSuggestions = TagGenerationService.generateSuggestedTags(for: entry)
        // 2. Update the local state to display these new suggestions.
        self.suggestedTags = newSuggestions
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct CompleteDayButton: View {
    @Bindable var entry: DailyEntry // Changed to Bindable
    @State private var hasBeenCompletedOnce = false

    var body: some View {
        Button(action: {
            withAnimation {
                entry.isComplete = true
                hasBeenCompletedOnce = true
            }
            if hapticsEnabled {
                HapticManager.shared.notification(type: .success)
            }
        }) {
            HStack {
                Image(systemName: "checkmark")
                Text(entry.isComplete ? "Update Day Entry" : "Complete Day Entry")
            }
            .font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(entry.isComplete ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(entry.isComplete)
        .scaleEffect(entry.isComplete ? 1.0 : 1.0) // Keep consistent size
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: entry.isComplete)
        .onAppear {
            hasBeenCompletedOnce = entry.isComplete
        }
    }
    private var hapticsEnabled: Bool {
        HapticManager.shared.hapticsEnabled
    }
}

// MARK: - Tab 2: Journal & Prompts
struct JournalPromptView: View {
    @Bindable var todayEntry: DailyEntry // Changed to Bindable
    @State private var mode: JournalMode = .quick
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
    enum JournalMode: String, CaseIterable {
        case quick = "Quick Journal"
        case guided = "Guided Prompts"
    }

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    audioPlayerManager.toggleMeditationSound()
                }) {
                    Label(audioPlayerManager.isPlaying ? "Stop Meditation" : "Play Meditation", systemImage: audioPlayerManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(audioPlayerManager.isPlaying ? .gray : .accentColor)
                .padding(.horizontal)
                .padding(.top)

                Picker("Journal Mode", selection: $mode) {
                    ForEach(JournalMode.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if mode == .quick {
                    QuickJournalView(entry: todayEntry)
                } else {
                    GuidedPromptView(entry: todayEntry)
                }
            }
            .navigationTitle("Reflect")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct QuickJournalView: View {
    @Bindable var entry: DailyEntry
    @State private var text: String
    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Jot down your thoughts from today.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding([.horizontal, .top])
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
            
            Button(action: saveJournal) {
                Label(isSaved ? "Saved!" : "Save Journal", systemImage: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
            }
            .font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSaved ? .green : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding([.horizontal, .bottom])
            .disabled(isSaved && text == entry.journalText)
        }
        .onChange(of: text) {
            isSaved = false
        }
    }
    
    init(entry: DailyEntry) {
        self.entry = entry
        _text = State(initialValue: entry.journalText)
    }
    
    private func saveJournal() {
        entry.journalText = text
        isSaved = true
        HapticManager.shared.notification(type: .success)
        HapticManager.shared.playSound(.success)
    }
}

struct GuidedPromptView: View {
    @Bindable var entry: DailyEntry
    
    // New, expanded list of prompts and categories
    private let promptCategories: [String: [String]] = [
        "🌱 Personal Growth": [
            "What’s something new I learned today?",
            "Where did I step outside my comfort zone?"
        ],
        "⚡ Habits & Health": [
            "How did sleep or nutrition affect me today?",
            "What habit am I proud of keeping (or breaking) today?"
        ],
        "🙏 Gratitude & Positivity": [
            "What made me smile today?",
            "Who am I thankful for right now?"
        ],
        "💭 Existential / Big Picture": [
            "What gives me a sense of purpose right now?",
            "What’s one question about life I sat with today?"
        ],
        "🎯 Short-Term / Productivity": [
            "What’s one task I could do tomorrow to feel accomplished?",
            "Did I spend my energy on what mattered most today?"
        ],
        "🔄 Reflection on Challenges": [
            "What was the hardest part of today?",
            "What did I avoid that I should face?"
        ],
        "🤝 Connection / Social": [
            "Did I connect meaningfully with anyone new today?",
            "Who do I want to reach out to tomorrow?"
        ]
    ]
    
    private var sortedCategories: [String] {
        promptCategories.keys.sorted()
    }
    
    var body: some View {
        List {
            ForEach(sortedCategories, id: \.self) { category in
                NavigationLink(destination: PromptDetailView(entry: entry, category: category, prompts: promptCategories[category] ?? [])) {
                    HStack {
                        Text(category)
                        Spacer()
                        if entry.reflections.first(where: { $0.category == category })?.answer.isEmpty == false {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                        }
                    }
                }
            }
        }
    }
}

struct PromptDetailView: View {
    @Bindable var entry: DailyEntry
    let category: String
    let prompts: [String]
    
    @State private var prompt: String
    @State private var answer: String
    @State private var isSaved: Bool = false
    
    init(entry: DailyEntry, category: String, prompts: [String]) {
        self.entry = entry
        self.category = category
        self.prompts = prompts
        
        // If a prompt was already answered for this category, load it. Otherwise, pick a new one.
        if let existingRecord = entry.reflections.first(where: { $0.category == category }) {
            _prompt = State(initialValue: existingRecord.prompt)
            _answer = State(initialValue: existingRecord.answer)
        } else {
            let randomPrompt = prompts.randomElement() ?? "No prompts available for this category."
            _prompt = State(initialValue: randomPrompt)
            _answer = State(initialValue: "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(prompt)
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            
            TextEditor(text: $answer)
                .scrollContentBackground(.hidden)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
            
            Button(action: save) {
                Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
            }
            .font(.headline).fontWeight(.bold)
            .frame(maxWidth: .infinity).padding()
            .background(isSaved ? .green : Color.accentColor)
            .foregroundColor(.white).cornerRadius(12)
            .disabled(isSaved || answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .navigationTitle(category)
        .background(Color(.systemGroupedBackground))
        .onChange(of: answer) { isSaved = false }
    }

    private func save() {
        if let i = entry.reflections.firstIndex(where: { $0.category == category }) {
            entry.reflections[i].prompt = prompt
            entry.reflections[i].answer = answer
        } else {
            let newPromptEntry = PromptEntry(date: entry.date, category: category, prompt: prompt, answer: answer)
            entry.reflections.append(newPromptEntry)
        }
        isSaved = true
        HapticManager.shared.notification(type: .success)
        HapticManager.shared.playSound(.success)
    }
}

// MARK: - Custom Flow Layout

/// A custom layout that arranges views in a flowing, left-to-right, top-to-bottom manner.
struct FlowLayout: Layout {
    var alignment: Alignment = .center
    var horizontalSpacing: CGFloat = 10
    var verticalSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if currentRowWidth + viewSize.width + horizontalSpacing > width {
                // Move to the next row
                height += rowHeight + verticalSpacing
                currentRowWidth = viewSize.width
                rowHeight = viewSize.height
            } else {
                // Add to the current row
                currentRowWidth += viewSize.width + horizontalSpacing
                rowHeight = max(rowHeight, viewSize.height)
            }
        }
        height += rowHeight // Add the last row's height
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)

            if x + viewSize.width > bounds.maxX {
                // Wrap to the next line
                x = bounds.minX
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }
            
            // Place the view
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            
            x += viewSize.width + horizontalSpacing
            rowHeight = max(rowHeight, viewSize.height)
        }
    }
}

// MARK: - Tab 3: Insights

struct InsightsView: View {
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]

    private var last7DaysEntries: [DailyEntry] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) else { return [] }
        
        return entries.filter { $0.date >= startDate && $0.date <= endDate && $0.isComplete }
    }
    
    private var consistencyStreak: Int {
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        // Use a Set for quick lookup of completed dates
        let completedDates = Set(entries.filter(\.isComplete).map { Calendar.current.startOfDay(for: $0.date) })
        
        while completedDates.contains(currentDate) {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    StreakTrackerView(streak: consistencyStreak)
                    
                    TrendsChartView(entries: last7DaysEntries)
                    
                    HistoryListView(entries: Array(entries.prefix(14)))
                }
                .padding()
            }
            .navigationTitle("Your Insights")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct StreakTrackerView: View {
    let streak: Int
    
    var body: some View {
        VStack {
            Text("\(streak)")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.accentColor)
            Text("Day Streak")
                .font(.title3)
                .fontWeight(.semibold)
            Text(streak > 0 ? "Keep up the great work!" : "Log your first day to start a streak.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct TrendsChartView: View {
    let entries: [DailyEntry]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("7-Day Score Trend")
                .font(.title3)
                .fontWeight(.semibold)
            
            Chart {
                ForEach(entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Avg Score", entry.averageScore)
                    )
                    .foregroundStyle(Color.accentColor)
                    
                    PointMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Avg Score", entry.averageScore)
                    )
                    .foregroundStyle(Color.accentColor)
                }
            }
            .chartYScale(domain: 1...10)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct HistoryListView: View {
    let entries: [DailyEntry]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent History")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if entries.isEmpty {
                    Text("No entries yet. Complete a check-in to see it here.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(entries) { entry in
                        NavigationLink(destination: DailyEntryDetailView(entry: entry)) {
                            HStack {
                                Text(entry.date, format: .dateTime.month().day())
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Avg: \(String(format: "%.1f", entry.averageScore))")
                                    .font(.subheadline)
                                Image(systemName: entry.isComplete ? "checkmark.circle.fill" : "x.circle.fill")
                                    .foregroundColor(entry.isComplete ? .green : .red)
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                            .foregroundColor(.primary) // Ensures text color is correct
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Detail View for History
struct DailyEntryDetailView: View {
    let entry: DailyEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Scores Section
                VStack(alignment: .leading) {
                    Text("Daily Scores")
                        .font(.title2).fontWeight(.bold)
                    VStack(spacing: 15) {
                        ScoreDetailView(label: "Emotion", value: entry.emotionScore, systemImage: "face.smiling", color: .blue)
                        ScoreDetailView(label: "Energy", value: entry.energyScore, systemImage: "bolt.fill", color: .orange)
                        ScoreDetailView(label: "Productivity", value: entry.productivityScore, systemImage: "chart.bar.fill", color: .purple)
                        ScoreDetailView(label: "Stress", value: entry.stressScore, systemImage: "flame.fill", color: .red)
                        ScoreDetailView(label: "Satisfaction", value: entry.satisfactionScore, systemImage: "star.fill", color: .teal)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Context Scores Section
                VStack(alignment: .leading) {
                    Text("Context Scores")
                        .font(.title2).fontWeight(.bold)
                    VStack(spacing: 15) {
                        ScoreDetailView(label: "Nutrition", value: entry.nutritionScore, systemImage: "leaf.fill", color: .green)
                        ScoreDetailView(label: "Sleep", value: entry.sleepScore, systemImage: "bed.double.fill", color: .indigo)
                        ScoreDetailView(label: "Exercise", value: entry.exerciseScore, systemImage: "figure.walk", color: .cyan)
                        ScoreDetailView(label: "Gratitude", value: entry.gratitudeScore, systemImage: "heart.fill", color: .pink)
                        ScoreDetailView(label: "Social", value: entry.socialConnectionScore, systemImage: "person.2.fill", color: .yellow)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Influence Tags Section
                if !entry.influenceTags.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Influences").font(.title2).fontWeight(.bold)
                        // Use FlowLayout directly for read-only display
                        FlowLayout(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                            ForEach(entry.influenceTags, id: \.self) { TagButton(tag: $0, isSelected: true, action: {}) }
                        }.padding(.top, 5)
                    }
                }
                
                // Journal Section
                if !entry.journalText.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Journal").font(.title2).fontWeight(.bold)
                        Text(entry.journalText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                
                // Prompt Section
                if !entry.reflections.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Guided Reflections").font(.title2).fontWeight(.bold)
                        ForEach(entry.reflections.sorted(by: { $0.category < $1.category })) { reflection in
                            Text(reflection.category).font(.headline).padding(.top)
                            Text(reflection.prompt).font(.subheadline).italic().foregroundColor(.secondary)
                            Text(reflection.answer)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(entry.date.formatted(date: .abbreviated, time: .omitted))
        .background(Color(.systemGroupedBackground))
    }
}

struct ScoreDetailView: View {
    let label: String, value: Int, systemImage: String, color: Color
    var body: some View {
        HStack {
            Image(systemName: systemImage).font(.headline).foregroundColor(color).frame(width: 25)
            Text(label).font(.headline)
            Spacer()
            Text("\(value)").font(.title3).fontWeight(.bold)
        }
    }
}


// MARK: - Tab 4: Settings
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Preferences")) {
                    Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedbackEnabled)
                    Toggle("Sound Effects", isOn: $viewModel.soundEffectsEnabled)
                }
                
                Section(header: Text("Notifications")) {
                    DatePicker("Daily Reminder Time", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Data Management")) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Delete All Data")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Are you sure?", isPresented: $showDeleteConfirmation) {
                Button("Delete All Data", role: .destructive) {
                    try? modelContext.delete(model: DailyEntry.self)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action cannot be undone and will permanently erase all of your reflection history.")
            }
        }
    }
}

// MARK: - Previews
#Preview {
    ContentView()
        .modelContainer(for: [DailyEntry.self, PromptEntry.self], inMemory: true)
}
