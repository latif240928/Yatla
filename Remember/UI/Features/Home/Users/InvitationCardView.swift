// UI/Features/Home/Users/InvitationCardView.swift
//
// ESKİ: `UI/Components/InvitationCard.swift` ile değiştirildi. Bu dosya,
// eski Xcode referanslarının hâlâ derlenmesi için boş bir saplama olarak
// bırakılmıştır. Projeden güvenle silinebilir — Xcode'da sağ tıklayın → Delete → Move to Trash.
import SwiftUI

@available(*, deprecated, renamed: "InvitationCard", message: "Use InvitationCard from UI/Components instead.")
struct InvitationCardView: View {
    let user: User
    let date: String
    var onAccept: () -> Void
    var onReject: () -> Void

    var body: some View {
        EmptyView()
    }
}
