//
//  ChatDetailView.swift
//  Remember
//
//  Created by Latif on 31.03.2026.
//

// UI/Features/Chats/ChatDetailView.swift
import SwiftUI


struct ChatDetailView: View {
    let chat: Chat
    var currentChat: Chat? {
        viewModel.chats.first(where: { $0.id == chat.id })
    }
    @ObservedObject var viewModel: ChatsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // AppBar
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text(currentChat?.participant.name ?? "")
                                .font(AppFonts.subheadline)
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "phone")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(AppColors.surface)
                            .cornerRadius(10)
                    }
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(AppColors.surface)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider().background(AppColors.divider)

                // Mesajlar
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Tarih etiketi
                            Text(formatDate(currentChat?.messages.first?.sentAt ?? Date()))
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textHint)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(AppColors.surface)
                                .cornerRadius(12)
                                .padding(.top, 16)

                            ForEach(currentChat?.messages ?? []) { msg in
                                MessageBubble(
                                    message: msg,
                                    isFromMe: msg.sender.id == viewModel.currentUser.id
                                )
                                .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    .onAppear {
                        if let last = currentChat?.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                Divider().background(AppColors.divider)

                // Input alanı
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $viewModel.messageText)
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppColors.surface)
                        .cornerRadius(24)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppColors.divider, lineWidth: 1))

                    // Dosya butonu
                    Button(action: {}) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(AppColors.surfaceLight)
                            .cornerRadius(22)
                    }

                    // Gönder butonu
                    Button(action: {
                        Task { await viewModel.sendMessage(to: chat.id) }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primaryDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationBarHidden(true)
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM d"
        return fmt.string(from: date)
    }
}
