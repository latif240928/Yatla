// Core/CurrentUserProvider.swift
import Foundation

//  backend gelende auth dan alynyar
enum CurrentUserProvider {
    static let user = User(
        id: "current-user",
        name: "Abdullatif Durdybayew",
        phone: "+993 62445524",
        departmentIds: ["dept-1"]
    )
}
