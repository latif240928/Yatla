//
//  CurrentUserProvider.swift
//  Remember
//
//  Created by Latif on 04.04.2026.
//

// Core/CurrentUserProvider.swift
import Foundation

// Tek kaynak — backend gelince auth'dan alınır
enum CurrentUserProvider {
    static let user = User(
        id: "current-user",
        name: "Abdullatif Durdybayew",
        phone: "+993 62445524",
        departmentIds: ["dept-1"]
    )
}
