import SwiftUI
import CoreHaptics

// MARK: - Models

enum GardenKind: CaseIterable {
    case flower, rock, grass, mushroom
    
    var emoji: String {
        switch self {
        case .flower: return "🌸"
        case .rock: return "🪨"
        case .grass: return "🌿"
        case .mushroom: return "🍄"
        }
    }
}

struct GardenItem: Identifiable {
    let id = UUID()
    var kind: GardenKind
    var position: CGPoint
    var size: CGFloat
    var angle: Angle
    var tint: Color
}

struct RakePath: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    /// Unit-length vector roughly perpendicular to the user's drag direction at path start.
    var normal: CGVector
}

// MARK: - View

struct ContentView: View {
    @State private var paths: [RakePath] = []
    @State private var currentPath: RakePath? = nil
    @State private var items: [GardenItem] = []
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Angle = .degrees(0)
    @State private var engine: CHHapticEngine?
    @State private var draggingItemIndex: Int? = nil
    @State private var isRaking: Bool = false // Track if currently raking to prevent conflicts
    @State private var showInfoPopup: Bool = false // Show/hide info popup
    @State private var draggingFromMenu: GardenKind? = nil // Track what's being dragged from menu


    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sand background
                sandBackground
                    .overlay(noiseOverlay.blendMode(.overlay).opacity(0.08))

                // Rake grooves (triple lines with emboss)
                Canvas { ctx, _ in
                    let stroke = StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                    let groove = Color.black.opacity(0.08)
                    let highlight = Color.white.opacity(0.25)
                    let shadow = Color.black.opacity(0.18)

                    // Equidistant tine spacing (center ↔ side)
                    let tineOffset: CGFloat = 10

                    func drawTriple(for points: [CGPoint]) {
                        guard points.count > 1 else { return }

                        // Build strictly equidistant offset polylines using local normals
                        let left  = offsetPolyline(points, by: +tineOffset)
                        let right = offsetPolyline(points, by: -tineOffset)

                        for poly in [left, points, right] {
                            var path = Path(); path.addLines(poly)

                            // Emboss (shadow/main/highlight)
                            var sp = path; sp = sp.applying(.init(translationX: 1, y: 1))
                            ctx.stroke(sp,   with: .color(shadow),   style: stroke)
                            ctx.stroke(path, with: .color(groove),   style: stroke)
                            var hp = path; hp = hp.applying(.init(translationX: -1, y: -1))
                            ctx.stroke(hp,   with: .color(highlight), style: stroke)
                        }
                    }

                    for rake in paths { drawTriple(for: rake.points) }
                    if let rake = currentPath { drawTriple(for: rake.points) }
                }
                .scaleEffect(scale)
                .rotationEffect(rotation)
                .drawingGroup()
                .contentShape(Rectangle())
                .gesture(dragToRake(in: geo))
                .simultaneousGesture(
                    MagnificationGesture().onChanged { value in
                        scale = clamp(scale * value, 0.7, 1.6)
                    }
                )
                .simultaneousGesture(
                    RotationGesture().onChanged { angle in
                        rotation = angle
                    }
                )

                // Garden items
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    GardenItemView(item: item)
                        .position(item.position)
                        .scaleEffect(scale)
                        .rotationEffect(rotation)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: items.count)
                        .gesture(
                            DragGesture(coordinateSpace: .local)
                                .onChanged { value in
                                    // Skip if we're currently raking
                                    if isRaking { return }
                                    
                                    if draggingItemIndex == nil {
                                        draggingItemIndex = index
                                        hapticSoft()
                                    }
                                    
                                    if draggingItemIndex == index {
                                        // Convert transformed coordinates back to canvas space
                                        let canvasPosition = inverseTransform(value.location, in: geo)
                                        items[index].position = canvasPosition
                                        print("Dragging item \(index) to canvas: \(canvasPosition)") // Debug
                                    }
                                }
                                .onEnded { _ in
                                    print("Finished dragging item \(index)") // Debug
                                    draggingItemIndex = nil
                                }
                        )
                }

                // Top controls - separate layer with no gestures
                VStack {
                    HStack {
                        Spacer()
                        
                        // Clear canvas button
                        Button(action: {
                            print("Clear canvas button tapped!") // Debug
                            clearCanvas()
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(.red.opacity(0.8)))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Info button
                        Button(action: {
                            print("Info button tapped!") // Debug
                            showInfoPopup = true
                        }) {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(.blue.opacity(0.8)))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60) // More padding to avoid status bar
                    
                    Spacer()
                }
                .allowsHitTesting(true) // Ensure buttons can receive touches
                
                // Bottom item menu - always visible
                VStack {
                    Spacer()
                    
                    bottomItemMenu(geo: geo)
                        .padding(.bottom, 40) // Safe area padding
                        .padding(.horizontal, 20)
                }
                
                // Info popup
                if showInfoPopup {
                    infoPopup
                        .zIndex(2000) // Ensure popup is above everything
                }
            }
            .onAppear { prepareHaptics() }
            .background(Color(.systemBackground))
        }
        .ignoresSafeArea()
    }

    // MARK: - Sand + Noise

    private var sandBackground: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.1, saturation: 0.18, brightness: 0.98),
                Color(hue: 0.1, saturation: 0.22, brightness: 0.93),
                Color(hue: 0.1, saturation: 0.25, brightness: 0.88)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var noiseOverlay: some View {
        Rectangle()
            .fill(ImagePaint(image: Image(uiImage: NoiseImage.shared.uiImage), scale: 0.5))
    }

    // MARK: - Gestures

    private func dragToRake(in geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                // Skip if we're currently dragging an item
                if draggingItemIndex != nil { return }
                
                let p = inverseTransform(value.location, in: geo)

                // Start new path
                if currentPath == nil {
                    currentPath = RakePath(points: [p], normal: .init(dx: 0, dy: -1))
                    isRaking = true
                    print("Started raking") // Debug
                    hapticTap()
                    return
                }

                // Append point if we've moved enough distance
                if var c = currentPath {
                    if let last = c.points.last {
                        let dx = p.x - last.x, dy = p.y - last.y
                        let distanceSquared = dx*dx + dy*dy
                        
                        // More lenient distance check for smoother drawing
                        if distanceSquared >= 1.0 {
                            c.points.append(p)
                            currentPath = c
                        }
                    } else {
                        c.points.append(p)
                        currentPath = c
                    }
                }
            }
            .onEnded { _ in
                print("Finished raking") // Debug
                // Save path if it has at least 2 points
                if let c = currentPath, c.points.count >= 2 { 
                    paths.append(c) 
                }
                currentPath = nil
                isRaking = false
                print("isRaking set to false") // Debug
            }
    }






    // MARK: - Haptics

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do { engine = try CHHapticEngine(); try engine?.start() } catch { }
    }

    private func hapticTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func hapticSoft() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - Geometry Utils

    /// Convert a point from view space into canvas space by applying the inverse of rotation+scale around the view center.
    private func inverseTransform(_ p: CGPoint, in geo: GeometryProxy) -> CGPoint {
        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        
        // Translate to center
        let vx = p.x - center.x
        let vy = p.y - center.y
        
        // Only apply inverse transformation if scale/rotation are significant
        guard abs(scale - 1.0) > 0.01 || abs(rotation.radians) > 0.01 else {
            return p
        }
        
        // Inverse rotation
        let a = -rotation.radians
        let cosA = cos(a), sinA = sin(a)
        let rx = vx * cosA - vy * sinA
        let ry = vx * sinA + vy * cosA
        
        // Inverse scale with better precision
        let safeScale = max(scale, 0.001) // Prevent division by zero
        let sx = rx / safeScale
        let sy = ry / safeScale
        
        // Back to canvas coords
        return CGPoint(x: sx + center.x, y: sy + center.y)
    }
    
    /// Convert a screen-space point to canvas space (you already have inverseTransform)
    /// We’ll reuse that in the gesture; no change needed here.

    
    


    
    
    /// Offsets a polyline by a constant distance using per-vertex normals.
    ///
    /// For each vertex i, compute tangent from prev→next (with clamping at ends),
    /// take its perpendicular as the normal, then offset the vertex by ±distance.
    /// This keeps the left/right tines equidistant even on curves.
    func offsetPolyline(_ pts: [CGPoint], by distance: CGFloat) -> [CGPoint] {
        guard pts.count > 1 else { return pts }

        var out: [CGPoint] = []
        out.reserveCapacity(pts.count)

        for i in pts.indices {
            let p  = pts[i]
            let p0 = i == 0 ? pts[i] : pts[i - 1]
            let p1 = i == pts.count - 1 ? pts[i] : pts[i + 1]

            // Tangent = normalized (p1 - p0)
            var tx = p1.x - p0.x
            var ty = p1.y - p0.y
            let L = max(sqrt(tx*tx + ty*ty), 0.0001)
            tx /= L; ty /= L

            // Normal = perpendicular to tangent
            let nx = -ty
            let ny =  tx

            out.append(CGPoint(x: p.x + nx * distance, y: p.y + ny * distance))
        }
        return out
    }



    /// Offset a polyline by a constant vector distance in canvas space.
    private func offsetPoints(_ points: [CGPoint], by v: CGVector, distance: CGFloat) -> [CGPoint] {
        let dx = v.dx * distance
        let dy = v.dy * distance
        return points.map { CGPoint(x: $0.x + dx, y: $0.y + dy) }
    }

    private func vector(from p0: CGPoint, to p1: CGPoint) -> CGVector {
        CGVector(dx: p1.x - p0.x, dy: p1.y - p0.y)
    }
    private func length(_ v: CGVector) -> CGFloat { sqrt(v.dx*v.dx + v.dy*v.dy) }
    private func unit(_ v: CGVector) -> CGVector {
        let L = max(length(v), 0.0001)
        return CGVector(dx: v.dx / L, dy: v.dy / L)
    }
    private func perp(_ v: CGVector) -> CGVector { CGVector(dx: -v.dy, dy: v.dx) }

    private func clamp(_ x: CGFloat, _ a: CGFloat, _ b: CGFloat) -> CGFloat { min(max(x, a), b) }
    
    // MARK: - UI Actions
    
    private func clearCanvas() {
        print("Clear canvas button tapped!") // Debug
        paths.removeAll()
        currentPath = nil
        isRaking = false // Reset raking state
        hapticSoft()
    }
    
    private func addItemToCanvas(kind: GardenKind, at globalLocation: CGPoint? = nil, in geo: GeometryProxy? = nil) {
        print("Adding \(kind.emoji) to canvas") // Debug
        
        // If location is provided, use it; otherwise use center
        let itemLocation: CGPoint
        if let globalLocation = globalLocation, let geo = geo {
            // Convert global screen coordinates to canvas coordinates using proper transformation
            let canvasPosition = inverseTransform(globalLocation, in: geo)
            itemLocation = canvasPosition
            print("Converted global \(globalLocation) to canvas \(itemLocation)") // Debug
        } else {
            itemLocation = CGPoint(x: 200, y: 300) // Default center
        }
        
        items.append(createGardenItem(kind: kind, at: itemLocation))
        print("Item added at position: \(itemLocation), total items: \(items.count)") // Debug
        hapticSoft()
    }
    
    private func createGardenItem(kind: GardenKind, at point: CGPoint) -> GardenItem {
        let size = CGFloat.random(in: 32...56)
        let angle = Angle.degrees(Double.random(in: -15...15))
        return GardenItem(kind: kind, position: point, size: size, angle: angle, tint: .clear)
    }
    
    // MARK: - Bottom Item Menu
    
    private func bottomItemMenu(geo: GeometryProxy) -> some View {
        HStack(spacing: 20) {
            ForEach(GardenKind.allCases, id: \.self) { kind in
                DraggableItemButton(kind: kind) { location in
                    addItemToCanvas(kind: kind, at: location, in: geo)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(radius: 10)
        )
    }
    
    // MARK: - Info Popup
    
    private var infoPopup: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    showInfoPopup = false
                }
            
            // Popup content
            VStack(spacing: 20) {
                HStack {
                    Text("Zen Garden Controls")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { showInfoPopup = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(icon: "hand.draw", title: "Rake Patterns", description: "Drag your finger across the sand to create beautiful rake patterns")
                    
                    InfoRow(icon: "rectangle.bottomthird.inset.filled", title: "Add Garden Items", description: "Drag items from the bottom menu (🌸🪨🌿🍄) to place them on the canvas")
                    
                    InfoRow(icon: "hand.point.up", title: "Move Items", description: "Simply drag any garden item to reposition it")
                    
                    InfoRow(icon: "magnifyingglass", title: "Zoom & Rotate", description: "Pinch to zoom in/out, rotate to change viewing angle")
                    
                    InfoRow(icon: "trash", title: "Clear Canvas", description: "Tap the red trash button to clear all rake patterns")
                }
                
                Spacer()
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 60)
        }
        .animation(.easeInOut(duration: 0.3), value: showInfoPopup)
    }
    
    // MARK: - Random Garden Item Generator
    
    private func randomGardenItem(at point: CGPoint) -> GardenItem {
        // Weighted variety: flowers (35%), rocks (30%), grass (25%), mushrooms (10%)
        let roll = Double.random(in: 0...1)
        let kind: GardenKind =
            roll < 0.35 ? .flower :
            roll < 0.65 ? .rock :
            roll < 0.90 ? .grass : .mushroom

        let size = CGFloat.random(in: 32...56)
        let angle = Angle.degrees(Double.random(in: -15...15))
        
        return GardenItem(kind: kind, position: point, size: size, angle: angle, tint: .clear)
    }
}

// MARK: - Garden Item Views

struct GardenItemView: View {
    let item: GardenItem
    var body: some View {
        Text(item.kind.emoji)
            .font(.system(size: item.size))
            .rotationEffect(item.angle)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 6)
    }
}

// MARK: - Info Row Component

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Draggable Item Button Component

struct DraggableItemButton: View {
    let kind: GardenKind
    let onDrop: (CGPoint) -> Void
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(kind.emoji)
                .font(.system(size: 32))
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                .scaleEffect(isDragging ? 1.2 : 1.0)
                .offset(dragOffset)
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            isDragging = true
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            isDragging = false
                            dragOffset = .zero
                            
                            // Add item at drop location using global coordinates
                            let dropLocation = value.location
                            print("Dropped \(kind.emoji) at global location: \(dropLocation)")
                            onDrop(dropLocation)
                        }
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
            
            Text(kindName(for: kind))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 60, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.secondary.opacity(0.2), lineWidth: 1)
                )
        )
        .opacity(isDragging ? 0.8 : 1.0)
    }
    
    private func kindName(for kind: GardenKind) -> String {
        switch kind {
        case .flower: return "Flower"
        case .rock: return "Rock"
        case .grass: return "Grass"
        case .mushroom: return "Mushroom"
        }
    }
}


// MARK: - Procedural Noise Image

final class NoiseImage {
    static let shared = NoiseImage()
    let uiImage: UIImage

    private init() {
        let size = 64
        let bpp = 4, row = bpp * size
        var data = [UInt8](repeating: 0, count: size * size * bpp)
        for y in 0..<size {
            for x in 0..<size {
                let i = (y * size + x) * bpp
                let n = UInt8.random(in: 100...155)
                data[i+0] = n; data[i+1] = n; data[i+2] = n; data[i+3] = 35
            }
        }
        let cf = CFDataCreate(nil, data, data.count)!
        let provider = CGDataProvider(data: cf)!
        let cg = CGImage(
            width: size, height: size,
            bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: row,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent
        )!
        uiImage = UIImage(cgImage: cg)
    }
}


#Preview {
    ContentView()
}
