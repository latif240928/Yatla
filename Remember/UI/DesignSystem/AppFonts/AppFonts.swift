// UI/DesignSystem/Fonts/AppFonts.swift
import SwiftUI

struct AppFonts {
    // MARK: Headlines
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.custom("SFProDisplay-Bold", size: 28)
    static let title2 = Font.custom("SFProDisplay-Semibold", size: 22)
    static let title3 = Font.custom("SFProDisplay-Semibold", size: 20)
    
    // MARK: Body
    static let headline = Font.custom("SFProText-Semibold", size: 17)
    static let body = Font.custom("SFProText-Regular", size: 17)
    static let callout = Font.custom("SFProText-Regular", size: 16)
    static let subheadline = Font.custom("SFProText-Regular", size: 15)
    static let footnote = Font.custom("SFProText-Regular", size: 13)
    static let caption1 = Font.custom("SFProText-Regular", size: 12)
    static let caption2 = Font.custom("SFProText-Regular", size: 11)
    
    // MARK: Custom for your app
    static let taskName = Font.custom("SFProDisplay-Medium", size: 16)
    static let taskDescription = Font.custom("SFProText-Regular", size: 14)
    static let departmentName = Font.custom("SFProText-Medium", size: 14)
    static let statusText = Font.custom("SFProText-Semibold", size: 12)
}

// MARK: - Convenience Extension
extension Font {
    static let appLargeTitle = AppFonts.largeTitle
    static let appTitle1 = AppFonts.title1
    static let appTitle2 = AppFonts.title2
    static let appTitle3 = AppFonts.title3
    static let appHeadline = AppFonts.headline
    static let appBody = AppFonts.body
    static let appCallout = AppFonts.callout
    static let appSubheadline = AppFonts.subheadline
    static let appFootnote = AppFonts.footnote
    static let appCaption1 = AppFonts.caption1
    static let appCaption2 = AppFonts.caption2
}


enum AppRadius {
    static let button: CGFloat     = 12
    static let card: CGFloat       = 16
    static let smallCorner: CGFloat = 8
}

enum AppPadding {
    static let standard: CGFloat = 16
    static let large: CGFloat    = 24
}
