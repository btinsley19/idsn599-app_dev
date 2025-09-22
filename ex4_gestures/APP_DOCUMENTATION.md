# Zen Garden App - Gesture-Based Mobile Application

## Overview
A SwiftUI-based iOS app that simulates a Japanese zen garden experience with interactive gesture controls. Users can draw patterns in sand using a rake tool and place/move garden items to create their own peaceful garden compositions.

## Purpose
This app was created as a class project to demonstrate iOS gesture recognition and SwiftUI development. It combines multiple gesture types (drag, long-press, pinch, rotation) to create an intuitive and meditative user experience.

## Core Functionality

### 1. Rake Drawing
- **Gesture**: Drag to draw
- **Functionality**: Creates triple-line rake patterns in the sand
- **Visual**: Embossed grooves with shadow/highlight effects
- **Implementation**: Canvas-based drawing with polyline offsetting for parallel tines

### 2. Garden Item Placement
- **Gesture**: Long-press (0.4s) on empty sand
- **Functionality**: Places random garden items at center of screen
- **Items**: 🌸 Flower (35%), 🪨 Rock (30%), 🌿 Grass (25%), 🍄 Mushroom (10%)
- **Variety**: Each item has randomized size (32-56pt) and rotation (-15° to +15°)

### 3. Item Manipulation
- **Gesture**: Long-press (0.15s) + drag on any garden item
- **Functionality**: Pick up and move items around the garden
- **Hit Detection**: Circular hit testing with radius = item size × 0.5
- **Feedback**: Haptic feedback on item selection

### 4. View Controls
- **Pinch Gesture**: Zoom in/out (0.7x to 1.6x scale)
- **Rotation Gesture**: Rotate the entire garden view
- **Coordinate System**: Proper inverse transformation for canvas-space interactions

## Technical Architecture

### Data Models
```swift
enum GardenKind: CaseIterable {
    case flower, rock, grass, mushroom
    var emoji: String // Returns corresponding emoji
}

struct GardenItem: Identifiable {
    let id = UUID()
    var kind: GardenKind
    var position: CGPoint
    var size: CGFloat
    var angle: Angle
    var tint: Color // Currently unused with emojis
}

struct RakePath: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var normal: CGVector // For parallel tine calculation
}
```

### State Management
- `@State private var paths: [RakePath]` - Stored rake patterns
- `@State private var currentPath: RakePath?` - Active drawing path
- `@State private var items: [GardenItem]` - Placed garden items
- `@State private var draggingItemIndex: Int?` - Currently dragged item
- `@State private var scale: CGFloat` - Zoom level
- `@State private var rotation: Angle` - View rotation
- `@State private var isRaking: Bool` - Track raking state to prevent conflicts

### Gesture System
1. **Rake Drawing**: Drag gesture with zero minimum distance for immediate response
2. **Item Drag**: High-priority long-press (0.25s) + drag sequence with 3pt minimum distance
3. **Item Placement**: Simultaneous long-press (0.4s) gesture that respects raking state
4. **View Controls**: Simultaneous pinch and rotation gestures
5. **Conflict Resolution**: State tracking prevents interference between gestures

### Visual Design
- **Sand Background**: Linear gradient with noise texture overlay
- **Rake Lines**: Triple parallel lines with embossed shadow/highlight
- **Garden Items**: Emoji-based with shadows and rotation
- **UI Elements**: Semi-transparent instruction text overlay

## Key Features

### Gesture Recognition
- **Multi-touch Support**: Handles multiple simultaneous gestures
- **Gesture Priority**: Item dragging takes precedence over rake drawing
- **State Management**: Prevents conflicts between different gesture types with improved state tracking
- **Mac Preview Compatible**: Optimized timing for Mac development environment
- **Improved Reliability**: Enhanced gesture detection with better minimum distance handling
- **Conflict Prevention**: Added raking state tracking to prevent interference with item placement

### Visual Effects
- **Embossed Rake Lines**: 3D-like appearance with shadows and highlights
- **Item Shadows**: Subtle drop shadows on all garden items
- **Smooth Animations**: Spring animations for item placement
- **Noise Texture**: Subtle sand texture overlay

### User Experience
- **Haptic Feedback**: Tactile responses for interactions
- **Intuitive Controls**: Natural gesture mappings
- **Visual Feedback**: Clear indication of interactive elements
- **Peaceful Aesthetic**: Calming color palette and smooth animations
- **Info Popup**: Accessible help with semi-transparent overlay and easy dismissal
- **Clear Canvas**: One-tap button to reset all rake patterns
- **Clean UI**: Top-mounted controls that don't interfere with drawing

## File Structure
```
ex4_gestures/
├── ContentView.swift          # Main app implementation
├── ex4_gesturesApp.swift      # App entry point
└── Assets.xcassets/          # App icons and assets
```

## Dependencies
- **SwiftUI**: Primary UI framework
- **CoreHaptics**: Haptic feedback system
- **No external libraries**: Pure SwiftUI implementation

## Development Notes
- **Target Platform**: iOS 18.5+
- **Development Environment**: Xcode 16+
- **Testing**: iPhone 16 Simulator
- **Gesture Timing**: Optimized for Mac preview responsiveness

## Usage Instructions
1. **Draw Patterns**: Drag finger across screen to create rake lines
2. **Add Items**: Long-press on empty sand to place random garden items
3. **Move Items**: Long-press and drag any garden item to reposition
4. **Zoom/Rotate**: Pinch to zoom, rotate to change viewing angle
5. **Clear Canvas**: Tap the trash button (top-right) to remove all rake patterns
6. **Get Help**: Tap the info button (top-left) to view detailed controls
7. **Create Art**: Combine rake patterns and garden items to design your zen garden

## Future Enhancement Possibilities
- Save/load garden compositions
- Different rake styles or patterns
- Weather effects (rain, wind)
- Sound effects for interactions
- Garden item customization
- Photo export functionality
- Multiplayer collaborative gardens

---
*Created as a mobile app development class project demonstrating iOS gesture recognition and SwiftUI development.*
