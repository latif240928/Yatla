// UI/Components/AuthFormSurface.swift
//
// Rounded frosted-card container shared by Registration / Sign-in / Account-setup
// form stacks (padding, shadow and stroke copied verbatim from feature views).

import SwiftUI

struct AuthFormSurface<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(AppSpacing.xl)
            .background(
                AppShape.cardShape
                    .fill(AppColors.surface)
                    .shadow(color: AppColors.shadowColor(opacity: 0.06), radius: 16, y: 6)
            )
            .overlay(
                AppShape.cardShape
                    .stroke(AppColors.divider, lineWidth: AppShape.Stroke.regular)
            )
    }
}
