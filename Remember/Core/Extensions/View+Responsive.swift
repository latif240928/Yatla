// Core/Extensions/View+Responsive.swift
import SwiftUI

extension View {
    /// Standard horizontal page padding driven by `LayoutMetrics.gutter`.
    func pageHorizontalPadding() -> some View {
        modifier(PageHorizontalPaddingModifier())
    }

    /// Standard vertical inter-section spacing driven by `LayoutMetrics`.
    func pageSpacing() -> some View {
        modifier(PageSpacingModifier())
    }

    /// Adaptive padding that respects current layout class.
    func responsivePadding(_ edges: Edge.Set = .all) -> some View {
        modifier(ResponsivePaddingModifier(edges: edges))
    }
}

private struct PageHorizontalPaddingModifier: ViewModifier {
    @Environment(\.layout) private var layout
    func body(content: Content) -> some View {
        content.padding(.horizontal, layout.gutter)
    }
}

private struct PageSpacingModifier: ViewModifier {
    @Environment(\.layout) private var layout
    func body(content: Content) -> some View {
        content.padding(.vertical, layout.spacing)
    }
}

private struct ResponsivePaddingModifier: ViewModifier {
    let edges: Edge.Set
    @Environment(\.layout) private var layout

    func body(content: Content) -> some View {
        content.padding(edges, layout.gutter)
    }
}
