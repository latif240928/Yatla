//
//  Department.swift
//  Remember
//
//  Created by Latif on 27.03.2026.
//

// Domain/Entities/Department.swift
import Foundation

struct Department: Identifiable, Hashable, Codable {
    let id: String
    var name: String


static let sahsy = Department(id: "sahsy", name: "Şahsy")

}

