//
//  Stats.swift
// Domain/Entities/Stats.swift
import Foundation

struct Stats {
    let totalTasks:      Int
    let completedTasks:  Int
    let failedTasks:     Int
    let inProgressTasks: Int        // ✅ eklendi
    let returnedTasks:   Int        // ✅ eklendi
    let totalUsers:      Int
    let dailyTasks:      [Date: Int]

    // Hesaplanan yüzde
    var successRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }
}
