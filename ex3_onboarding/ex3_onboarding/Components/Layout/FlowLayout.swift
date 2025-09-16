//
//  FlowLayout.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct FlowLayout: Layout {
    var hSpacing: CGFloat = 8
    var vSpacing: CGFloat = 8
    var rowAlignment: HorizontalAlignment = .center  // use .leading if preferred

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        guard maxWidth.isFinite else {
            // fallback: stack vertically
            var totalH: CGFloat = 0
            var maxW: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                totalH += size.height
                maxW = max(maxW, size.width)
            }
            
            if subviews.count > 1 {
                totalH += CGFloat(subviews.count - 1) * vSpacing
            }
            
            return CGSize(width: maxW, height: totalH)
        }

        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineHeight: CGFloat = 0

        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if width == 0 || width + hSpacing + s.width <= maxWidth {
                width = (width == 0 ? s.width : width + hSpacing + s.width)
                lineHeight = max(lineHeight, s.height)
            } else {
                height += lineHeight + vSpacing
                width = s.width
                lineHeight = s.height
            }
        }
        height += lineHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var line: [Int] = []
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        func flushLine() {
            guard !line.isEmpty else { return }
            let extra = maxWidth - lineWidth
            let startX: CGFloat = {
                switch rowAlignment {
                case .leading: return 0
                case .center:  return extra / 2
                default:       return 0
                }
            }()
            var cursor = bounds.minX + startX
            for i in line {
                let s = subviews[i].sizeThatFits(.unspecified)
                subviews[i].place(at: CGPoint(x: cursor, y: bounds.minY + y),
                                  proposal: ProposedViewSize(width: s.width, height: s.height))
                cursor += s.width + hSpacing
            }
            y += lineHeight + vSpacing
            line.removeAll()
            lineWidth = 0
            lineHeight = 0
            x = 0
        }

        for i in subviews.indices {
            let s = subviews[i].sizeThatFits(.unspecified)
            if x == 0 || x + hSpacing + s.width <= maxWidth {
                if x == 0 { x = s.width } else { x += hSpacing + s.width }
                line.append(i)
                lineWidth = x
                lineHeight = max(lineHeight, s.height)
            } else {
                flushLine()
                x = s.width
                line.append(i)
                lineWidth = x
                lineHeight = s.height
            }
        }
        flushLine()
    }
}
