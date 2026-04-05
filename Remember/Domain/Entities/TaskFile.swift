//
//  TaskFile.swift
struct TaskFile: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let format: String
    let url: String
}
