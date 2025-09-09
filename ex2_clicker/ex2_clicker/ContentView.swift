// brian tinsley
// exercise 2 clicker game
// created 9/8/25
// idsn 599

import SwiftUI

// main content view of the app
struct ContentView: View {
    var body: some View {
        SkylineView()
    }
}


// building type and their ui/logic presets
// basically it just sets parameters based on the selected building type
// enum = a type with a fixed set of cases (.house, .business, .skyscraper).
// String raw value = each case has a string rawValue ("house", "business", "skyscraper").
// CaseIterable = you get BuildingType.allCases for free (used to build the menu).
// going to use this later when we makebuilding
enum BuildingType: String, CaseIterable, Identifiable {
    case house, business, skyscraper
    var id: String { rawValue } // unique id for menus/forEach

    // label shown in the selector menu
    var label: String {
        switch self {
        case .house: return "🏠 House"
        case .business: return "🏢 Business"
        case .skyscraper: return "🏙️ Skyscraper"
        }
    }

    // size choices for different silhouettes
    var widthOptions: [CGFloat] {
        switch self {
        case .house: return [18, 20, 22, 24]
        case .business: return [34, 40, 46, 54]
        case .skyscraper: return [26, 30, 34, 38, 42]
        }
    }
    var heightRange: ClosedRange<Int> {
        switch self {
        case .house: return 60...110
        case .business: return 120...180
        case .skyscraper: return 200...320
        }
    }
    // target grid rows and columns for windows
    var windowColsRange: ClosedRange<Int> {
        switch self {
        case .house: return 2...3
        case .business: return 3...5
        case .skyscraper: return 4...6
        }
    }
    var windowRowsRange: ClosedRange<Int> {
        switch self {
        case .house: return 2...4
        case .business: return 3...6
        case .skyscraper: return 6...10
        }
    }

    // economy impact per new building (randomized each add)
    // adds jobs or people sometimes both
    var housingDelta: Int {
        switch self {
        case .house: return Int.random(in: 2...8)      // each house adds 2–8 residents
        case .business: return 0                       // businesses add jobs, not residents
        case .skyscraper: return Int.random(in: 10...50) // skyscrapers add many residents
        }
    }
    var jobsDelta: Int {
        switch self {
        case .house: return 0                           // houses don’t create jobs
        case .business: return Int.random(in: 4...16)   // businesses add some jobs
        case .skyscraper: return Int.random(in: 20...60) // skyscrapers add many jobs
        }
    }
}


// economy state used by the circular gauge
enum EconomyState {
    case balanced
    case unemployment(Double) // 0...1 (rate)
    case shortage(Double)     // 0...1 (rate)
}


// main game view background, controls, counters, skyline
struct SkylineView: View {
    // bunch of variables to keep track of
    // list of buildings
    @State private var buildings: [Building] = []
    @State private var lastAddedID: UUID? = nil
    // selected type, starts as house
    @State private var selectedType: BuildingType = .house
    // economy counters
    @State private var housing: Int = 0
    @State private var jobs: Int = 0
    // economy status text shown under the meter
    private var statusText: String {
        if housing == jobs { return "Balanced economy" }
        if housing > jobs  { return "Unemployment: \(housing - jobs) people without jobs" }
        return "Labor shortage: \(jobs - housing) open jobs"
    }
    // milestone thresholds and labels (by population/housing)
    private let milestones: [(threshold: Int, label: String)] = [
        (40,  "🏡 Suburb founded!"),
        (100,  "🌆 Small city created!"),
        (200, "🏙️ Big city emerging!"),
        (400, "🌉 Metropolitan hub!"),
        (800, "🌐 Massive megacity!")
    ]
    // current milestone banner (persists until next tier)
    @State private var currentMilestone: (threshold: Int, label: String)? = nil
    // color for the status message
    private var statusColor: Color {
        if housing == jobs { return .green.opacity(0.9) }
        if housing > jobs  { return .red }
        return .blue
    }
    // compute gauge state from housing vs jobs numbers
    private var economyState: EconomyState {
        // variable for unemployment = extra people / housing range 0-1
        let unemp = housing > 0 ? Double(max(housing - jobs, 0)) / Double(max(housing, 1)) : 0
        // variable for shortage = open jobs / jobs range 0-1
        let shortage = jobs > 0 ? Double(max(jobs - housing, 0)) / Double(max(jobs, 1)) : 0

        if unemp > 0 { return .unemployment(unemp) }
        if shortage > 0 { return .shortage(shortage) }
        return .balanced
    }

    
    // main view hierarchy
    var body: some View {
        ZStack {
            // background gradient
            // use #colorLiteral for color selection
            LinearGradient(
                colors: [
                    Color(#colorLiteral(red: 1, green: 0.86, blue: 0.32, alpha: 1)),
                    Color(#colorLiteral(red: 1, green: 0.63, blue: 0.19, alpha: 1)),
                    Color(#colorLiteral(red: 0.4, green: 0.12, blue: 0.45, alpha: 1))
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // sun glow
            Circle()
                .fill(.yellow.opacity(0.6))
                .frame(width: 140, height: 140)
                .offset(x: -120, y: -260)
                .blur(radius: 6)

            VStack(spacing: 12) {
                // building selector + add button
                HStack(spacing: 12) {
                    // this part shows what you see when opened
                    Menu {
                        // grab each building type case
                        ForEach(BuildingType.allCases) { t in
                            // tapping that button sets it to selected type of building
                            Button(t.label) { selectedType = t }
                        }
                        // this is the closed appearence of the menu which should show the selected one
                    } label: {
                        HStack(spacing: 8) {
                            Text(selectedType.label)
                            Image(systemName: "chevron.down").font(.subheadline).opacity(0.7)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                    }

                    // add building button
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            // call makebuilding when clicked
                            let b = makeBuilding(of: selectedType) // create silhouette + windows
                            // add it too list held in skylineview
                            buildings.append(b)
                            // enable auto scroll
                            // add the last added building id
                            lastAddedID = b.id
                            // update numbers and the milestone and economy status
                            applyEconomyImpact(for: selectedType)
                        }
                    } label: {
                        Text("Add Building")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .padding(.top, 40)

                // counters row
                // fill in the numbers
                HStack(spacing: 24) {
                    Label("Housing: \(housing)", systemImage: "house.fill")
                    Label("Jobs: \(jobs)", systemImage: "briefcase.fill")
                }
                .font(.headline)
                .padding(.horizontal, 16)
                
                // circular gauge for unemployment/shortage/balanced economy
                EconomyGauge(state: economyState)

                // status line precomputed in variables for syklineview
                Text(statusText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(statusColor)
                    .padding(.bottom, 4)

                // persistent milestone banner to shos latest one reached
                // the if / let is only if the milestone is not nil where it starts
                if let m = currentMilestone {
                    Text(m.label)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        // simple pop when it changes
                        .transition(.scale.combined(with: .opacity))
                }

                // scrollable skyline horizontal
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(alignment: .bottom, spacing: 6) {
                            // loop through each building
                            // weird format here but its an identifiable so we do implicit return
                            ForEach(buildings) { b in
                                // create building view for each
                                BuildingView(building: b).id(b.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 24)
                        .frame(minHeight: 260, alignment: .bottom)
                    }
                    // on a change scroll to the right when new building added
                    .onChange(of: lastAddedID) { oldValue, newValue in
                        guard let id = newValue else { return } // guard means get out if its empty
                        withAnimation(.easeOut) {
                            proxy.scrollTo(id, anchor: .trailing)
                        }
                    }

                }

                Spacer(minLength: 0)
            }
        }
        // start blank so dont start with stuff
//        .onAppear {
//            // seed a mix
//            for _ in 0..<4 { addSeed(.house) }
//            for _ in 0..<3 { addSeed(.business) }
//            for _ in 0..<2 { addSeed(.skyscraper) }
//            lastAddedID = buildings.last?.id
//        }
    }

    // helper function to add a seeded building and apply economy (kept for future use)
//    private func addSeed(_ type: BuildingType) {
//        let b = makeBuilding(of: type)
//        buildings.append(b)
//        applyEconomyImpact(for: type)
//    }

    // helper function to update housing/jobs and set milestone when crossing thresholds
    private func applyEconomyImpact(for type: BuildingType) {
        let oldHousing = housing

        housing += type.housingDelta
        jobs    += type.jobsDelta

        // check any crossed milestones (old < threshold <= new)
        let crossed = milestones.filter { oldHousing < $0.threshold && housing >= $0.threshold }
        if let newest = crossed.last {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // update milestone
                currentMilestone = newest
            }
        }
    }

    // helper function to create a new building with randomized size/grid/lights
    private func makeBuilding(of type: BuildingType) -> Building {
        let w = type.widthOptions.randomElement()!
        let h = CGFloat(Int.random(in: type.heightRange))
        let cols = Int.random(in: type.windowColsRange)
        let rows = Int.random(in: type.windowRowsRange)
        let p = Double.random(in: 0.25...0.65)
        return Building(type: type, width: w, height: h, windowCols: cols, windowRows: rows, lightProbability: p)
    }
}



// this is the data structure for a single building, like a building 'class'
// needs to be identifiable for swiftUI lists
struct Building: Identifiable {
    let id = UUID()
    let type: BuildingType
    let width: CGFloat
    let height: CGFloat
    let windowCols: Int
    let windowRows: Int
    let lightProbability: Double
}


// draws a building silhouette + window grid that fits inside it
// this is the visual component of a building
struct BuildingView: View {
    let building: Building

    // rounded corner radius
    private let corner: CGFloat = 3

    var body: some View {
        ZStack(alignment: .top) {
            // black silhouette
            RoundedRectangle(cornerRadius: corner)
                .fill(Color.black)
                .overlay(
                    GeometryReader { proxy in
                        // layout constants inside the silhouette
                        let padH: CGFloat = 6
                        let padV: CGFloat = 10
                        let spacing: CGFloat = 3

                        // available area for windows after padding
                        let availW = max(0, proxy.size.width - padH * 2)
                        let availH = max(0, proxy.size.height - padV * 2)

                        // target rows/cols from the model
                        let targetRows = max(1, building.windowRows)
                        let targetCols = max(1, building.windowCols)

                        // enforce minimum window size by shrinking grid if needed
                        let minCellW: CGFloat = 5
                        let minCellH: CGFloat = 6
                        let maxColsThatFit = max(1, Int((availW + spacing) / (minCellW + spacing)))
                        let maxRowsThatFit = max(1, Int((availH + spacing) / (minCellH + spacing)))
                        let rows = min(targetRows, maxRowsThatFit)
                        let cols = min(targetCols, maxColsThatFit)

                        // compute final cell size to fill evenly
                        let cellW = (availW - CGFloat(cols - 1) * spacing) / CGFloat(cols)
                        let cellH = (availH - CGFloat(rows - 1) * spacing) / CGFloat(rows)

                        // grid of windows (randomly lit)
                        VStack(spacing: spacing) {
                            ForEach(0..<rows, id: \.self) { _ in
                                HStack(spacing: spacing) {
                                    ForEach(0..<cols, id: \.self) { _ in
                                        Rectangle()
                                        // use helper function to flip light on / off
                                            .fill(Bool.random(probability: building.lightProbability)
                                                  ? Color.yellow.opacity(0.85)
                                                  : Color.black.opacity(0.6))
                                            .frame(width: cellW, height: cellH)
                                            .cornerRadius(1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, padH)
                        .padding(.vertical, padV)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                )
        }
        // fixed silhouette size
        .frame(width: building.width, height: building.height)
        // clip everything inside
        .clipShape(RoundedRectangle(cornerRadius: corner))
        // small drop shadow
        .shadow(radius: 4, y: 2)
    }
}


// circular gauge showing imbalance severity
struct EconomyGauge: View {
    let state: EconomyState

    // normalized 0...1 rate for the arc fill
    private var rate: Double {
        switch state {
        case .balanced: return 0
        case .unemployment(let r), .shortage(let r): return max(0, min(1, r))
        }
    }

    // label under the gauge
    private var title: String {
        switch state {
        case .balanced: return "Balanced"
        case .unemployment: return "Unemployment"
        case .shortage: return "Labor Shortage"
        }
    }

    // color by state
    private var color: Color {
        let tol = 0.02
        switch state {
        case .balanced: return .green
        case .unemployment(let r): return r < tol ? .green : .red
        case .shortage(let r):     return r < tol ? .green : .blue
        }
    }


    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // track circle
                Circle()
                    .stroke(Color.white.opacity(0.20), lineWidth: 8)

                // progress arc from top
                Circle()
                    .trim(from: 0, to: CGFloat(rate))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                // percent text in the center
                Text(rate == 0 ? "0%" : "\(Int(round(rate*100)))%")
                    .font(.subheadline.monospacedDigit())
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            .frame(width: 80, height: 80)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// helpers: random boolean with a given probability (used for lit windows)
extension Bool {
    static func random(probability p: Double) -> Bool {
        Double.random(in: 0...1) < max(0, min(1, p))
    }
}

// swiftui preview for xcode canvas
#Preview {
    ContentView()
}
