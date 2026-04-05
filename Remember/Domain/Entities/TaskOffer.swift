//
//  TaskOffer.swift
import Foundation

struct TaskOffer: Identifiable {
    let id: String
    let fromUser: User          // ← senin User modelin
    let title: String
    let description: String
    let sentAt: Date
    var status: TaskOfferStatus
}

enum TaskOfferStatus {
    case pending
    case accepted
    case rejected
}
