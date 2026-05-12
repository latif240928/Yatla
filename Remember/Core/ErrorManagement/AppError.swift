// Core/AppError.swift
import Foundation

enum AppError: LocalizedError {
    case emptyField
    case invalidPhone
    case invalidCode
    case shortCode
    case errorCode
    case emptyDepartment
    case networkError
    case unauthorized
    case notFound           
    case unknown
    case shortPassword

    var errorDescription: String? {
        switch self {
        case .emptyField:      return "Meýdan boş bolup bilmez"
        case .invalidPhone:    return "Telefon belgisi nädogry"
        case .invalidCode:     return "Kod 4 san bolmaly"
        case .shortCode:       return "Parol azyndan 6 simwol bolmaly"
        case .errorCode:       return "Parollar deň däl"
        case .emptyDepartment: return "Bölüm ady boş bolup bilmez"
        case .networkError:    return "Tor ýalňyşlygy"
        case .unauthorized:    return "Rugsat ýok"
        case .notFound:        return "Tapylmady"
        case .unknown:         return "Näbelli ýalňyşlyk"
        case .shortPassword:  return "Parol azyndan 8 simwol bolmaly"
                
        }
    }
}
