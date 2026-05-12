// UI/DesignSystem/Fonts/AppFonts.swift
import SwiftUI
import UIKit

struct AppFonts {
    private enum Aestetico {
        static let regular = "Aestetico-Regular"
        static let medium = "Aestetico-Medium"
        static let semibold = "Aestetico-Semibold"
        static let bold = "Aestetico-Bold"
    }
    
    private static func custom(_ fontName: String, size: CGFloat, fallbackWeight: Font.Weight) -> Font {
        if UIFont(name: fontName, size: size) != nil {
            return .custom(fontName, size: size)
        }
        return .system(size: size, weight: fallbackWeight)
    }
    
    static func aestetico(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = Aestetico.bold
        case .semibold:
            fontName = Aestetico.semibold
        case .medium:
            fontName = Aestetico.medium
        default:
            fontName = Aestetico.regular
        }
        
        return custom(fontName, size: size, fallbackWeight: weight)
    }
    
    // MARK: Headlines
    static let largeTitle = custom(Aestetico.bold, size: 34, fallbackWeight: .bold)
    static let title1 = custom(Aestetico.bold, size: 28, fallbackWeight: .bold)
    static let title2 = custom(Aestetico.semibold, size: 22, fallbackWeight: .semibold)
    static let deptitle = custom(Aestetico.bold, size: 23, fallbackWeight: .bold)
    static let title3 = custom(Aestetico.bold, size: 18, fallbackWeight: .bold)
    
    // MARK: Body
    static let headline = custom(Aestetico.semibold, size: 17, fallbackWeight: .semibold)
    static let body = custom(Aestetico.regular, size: 17, fallbackWeight: .regular)
    static let callout = custom(Aestetico.regular, size: 16, fallbackWeight: .regular)
    static let subheadline = custom(Aestetico.bold, size: 14, fallbackWeight: .bold)
    static let footnote = custom(Aestetico.regular, size: 13, fallbackWeight: .regular)
    static let caption1 = custom(Aestetico.regular, size: 12, fallbackWeight: .regular)
    static let caption2 = custom(Aestetico.regular, size: 11, fallbackWeight: .regular)
    static let caption3 = custom(Aestetico.bold, size: 11, fallbackWeight: .bold)
    
    // MARK: Custom for your app
    static let taskName = custom(Aestetico.medium, size: 16, fallbackWeight: .medium)
    static let taskDescription = custom(Aestetico.regular, size: 14, fallbackWeight: .regular)
    static let departmentName = custom(Aestetico.medium, size: 14, fallbackWeight: .medium)
    static let statusText = custom(Aestetico.semibold, size: 18, fallbackWeight: .semibold)
}

// MARK: - Kolaylık uzantısı
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
