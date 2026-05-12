// UI/Components/SheetChrome.swift
//
// Shared sheet chrome pieces (grab bar + footer actions) used across modal
// sheets so styling stays identical everywhere and future tweaks happen once.

import SwiftUI

// MARK: - Tutamacı

struct SheetGrabber: View {
    var topPadding: CGFloat = 10
    var bottomPadding: CGFloat = 8

    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(AppColors.textHint.opacity(0.5))
            .frame(width: 40, height: 5)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }
}

// MARK: - Alt düğmeler (çerçeveli ve dolu varyantlar)

/// Light filled + border — cancel / dismiss rows in sheets.
struct SheetOutlineActionButton: View {
    let title: String
    var height: CGFloat = 48
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    AppShape.buttonShape
                        .fill(AppColors.surfaceLight)
                )
                .overlay(
                    AppShape.buttonShape
                        .stroke(AppColors.divider, lineWidth: AppShape.Stroke.regular)
                )
        }
        .buttonStyle(.plain)
    }
}

/// Brand gradient CTA — e.g. confirm in mute / invite sheets.
struct SheetGradientActionButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    AppShape.buttonShape
                        .fill(
                            isEnabled
                                ? AnyShapeStyle(AppColors.messageFromMeGradient)
                                : AnyShapeStyle(AppColors.buttonDisabled)
                        )
                )
                .shadow(
                    color: isEnabled ? AppColors.primary.opacity(0.25) : .clear,
                    radius: 10,
                    y: 4
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

/// Solid error-toned CTA — e.g. return task with comment.
struct SheetDestructiveActionButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    AppShape.buttonShape
                        .fill(isEnabled ? AppColors.error : AppColors.buttonDisabled)
                )
                .shadow(
                    color: isEnabled ? AppColors.error.opacity(0.25) : .clear,
                    radius: 10,
                    y: 4
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.18), value: isEnabled)
    }
}
