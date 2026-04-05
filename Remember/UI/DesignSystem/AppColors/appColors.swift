// UI/DesignSystem/AppColors/appColors.swift
import SwiftUI

struct AppColors {
    // MARK: - Ana arka plan (Koyu lacivert tema - Figma)
    static let background     = Color(hex: "#0A1628")   // Sahypa arka planı
    static let surface        = Color(hex: "#0F1F35")   // Kart, field background
    static let surfaceAlt     = Color(hex: "#162A46")   // second surface
    static let surfaceLight   = Color(hex: "#1C3454")   // light syrface 

    // MARK: - Accent / Primary (Cyan)
    static let primary        = Color(hex: "#00E5FF")   // main accent renk
    static let primaryDark    = Color(hex: "#00B8D4")   // Pressed/hover yagdayy
    static let primaryLight   = Color(hex: "#00E5FF").opacity(0.15) // light glow

    // MARK: - Text renkleri
    static let textPrimary    = Color.white
    static let textSecondary  = Color(hex: "#8899AA")   // Açık silver
    static let textHint       = Color(hex: "#4A5F78")   // Has acyk, placeholder

    // MARK: - Serhet / Divider
    static let divider        = Color(hex: "#1C3454")
    static let border         = Color(hex: "#1C3454")
    static let borderFocused  = Color(hex: "#00E5FF")   // Focus yagdayynda cyan

    // MARK: - Status renkleri
    static let statusWaiting       = Color(hex: "#F59E0B")
    static let statusWaitingBG     = Color(hex: "#F59E0B").opacity(0.15)
    static let statusInProgress    = Color(hex: "#3B82F6")
    static let statusInProgressBG  = Color(hex: "#3B82F6").opacity(0.15)
    static let statusDone          = Color(hex: "#10B981")
    static let statusCancelled     = Color(hex: "#EF4444")
    static let statusCancelledBG   = Color(hex: "#EF4444").opacity(0.15)
    static let statusReturned      = Color(hex: "#EF4444")
    static let statusReturnedBG    = Color(hex: "#EF4444").opacity(0.15)

    // MARK: - System renkleri
    static let error          = Color(hex: "#EF4444")
    static let success        = Color(hex: "#10B981")
    static let warning        = Color(hex: "#F59E0B")

    // MARK: - Button renkleri
    static let buttonActive   = Color(hex: "#38BDF8")   // Cyan aktiw button
    static let buttonDanger   = Color(hex: "#EF4444")
    static let buttonSuccess  = Color(hex: "#10B981")
    static let buttonDisabled = Color(hex: "#1C3454")   // Goyy silver disabled

    // MARK: - silver tonlary
    static let grayDark       = Color(hex: "#3C3C43")
    static let grayMedium     = Color(hex: "#8E8E93")
}
