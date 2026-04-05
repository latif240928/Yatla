//
//  CreateTask.swift
//  Remember
//
//  Created by Latif on 27.03.2026.
//

// Domain/Entities/CreateTask.swift
import Foundation

// Task doredilyan wagty doldurulmaly forma
struct CreateTask {
    var name: String = ""
    var mazmuny: String = ""
    var department: Department? = nil
    var assigneeIDs: [String] = []
    var endDate: Date = Date()
    var endTime: Date = Date()
    var files: [TaskFile] = []

    // Form dogrymy?
    var isValid: Bool {
        guard !name.isEmpty, department != nil else { return false }
        // Şahsy bolsa assignee hokman dal
        if department?.id == "sahsy" { return true }
        return !assigneeIDs.isEmpty
    }
}
