//
//  Language.swift
import Foundation

enum Language: String, CaseIterable, Identifiable {
    case turkmen = "tk"     // Ana dil
    case turkish = "tr"
    case english = "en"
    case russian = "ru"
    
    var id: String { rawValue }
    
    var flag: String {
        switch self {
        case .turkmen: return "🇹🇲"
        case .turkish: return "🇹🇷"
        case .english: return "🇬🇧"
        case .russian: return "🇷🇺"
        }
    }
    
    var displayName: String {
        switch self {
        case .turkmen: return "Türkmençe"   // Ana dil
        case .turkish: return "Türkçe"
        case .english: return "İňlisçe"
        case .russian: return "Rusça"
        }
    }
}
