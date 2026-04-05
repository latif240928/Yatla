import SwiftUI

private func formatDate(_ date: Date) -> String {
    let fmt = DateFormatter()
    fmt.dateFormat = "dd / MM / yyyy"
    return fmt.string(from: date)
}
