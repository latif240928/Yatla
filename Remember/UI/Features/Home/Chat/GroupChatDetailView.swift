// UI/Features/Home/Chat/GroupChatDetailView.swift
//
// Departman genelinde grup sohbeti. Departmanın her üyesi buradaki mesajları
// görebilir ve yeni mesaj gönderebilir; gelen her balon gönderenin adıyla
// (balon başlığı) etiketlenir, böylece kimin ne söylediği açıkça belli olur.
//
// Bilinçli olarak `ChatDetailView`'dan daha hafiftir: katılımcı başına eylem
// menüsü yok, dosya/fotoğraf ekleri henüz yok — arka uç grup eklerini
// sunduğunda eklenecektir. Gönderme hattı aynı yapıdadır, bu yüzden gelecekte
// yapılacak bir düzenleme ile iki ekran `ChatThread` enum'u arkasında birleştirilebilir.

import SwiftUI

struct GroupChatDetailView: View {
    let groupId: String
    @ObservedObject var viewModel: ChatsViewModel
    @Binding var isChatDetailActive: Bool
    @Environment(\.dismiss) private var dismiss

    private var group: GroupChat? {
        viewModel.groupChats.first(where: { $0.id == groupId })
    }

    var body: some View {
        ZStack {
            AppColors.chatBackgroundGradient.ignoresSafeArea()

            // Bkz. ChatDetailView — her iki bölge de `safeAreaInset` ile
            // bağlanmıştır; böylece mesaj listesi ekran kenarlarına ulaşır
            // ve yazı alanı ana göstergeye yaslanır.
            messageList
                .safeAreaInset(edge: .top, spacing: 0) {
                    appBar
                        .background(.ultraThinMaterial)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(AppColors.divider.opacity(0.6))
                                .frame(height: 0.5)
                        }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    inputBar
                        .background(.ultraThinMaterial)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(AppColors.divider.opacity(0.6))
                                .frame(height: 0.5)
                        }
                }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.22)) {
                isChatDetailActive = false
            }
        }
    }

    // MARK: - Üst çubuk

    private var appBar: some View {
        HStack(spacing: 10) {
            Button(action: { dismiss() }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)

                    ZStack {
                        Circle()
                            .fill(AppColors.primaryLight)
                            .frame(width: 36, height: 36)
                        Image(systemName: "person.3.fill")
                            .font(AppFonts.aestetico(size: 16, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(group?.department.name ?? "Topar")
                    .font(AppFonts.aestetico(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text("\(group?.members.count ?? 0) agza")
                    .font(AppFonts.aestetico(size: 11, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    // MARK: - Mesaj listesi

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    let messages = group?.messages ?? []

                    if !messages.isEmpty {
                        Text(AppDateFormatters.monthDay.string(from: messages.first?.sentAt ?? Date()))
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textHint)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(AppColors.surfaceLight)
                            .cornerRadius(12)
                            .padding(.top, 14)
                            .padding(.bottom, 6)
                    }

                    ForEach(messages) { msg in
                        let isFromMe = (msg.sender.id == viewModel.currentUser.id)
                        MessageBubbleView(
                            message: msg,
                            isFromMe: isFromMe,
                            showSenderName: true   // 👈 grup bağlamı
                        )
                        .id(msg.id)
                    }

                    if messages.isEmpty {
                        VStack(spacing: 12) {
                            Spacer().frame(height: 80)
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(AppFonts.aestetico(size: 40))
                                .foregroundColor(AppColors.textHint)
                            Text("Heniz habar ýok")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                            Text("Ilkinji habary siz iberiň")
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textHint)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
            .onAppear {
                if let last = group?.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onChange(of: group?.messages.count) { _, _ in
                if let last = group?.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Giriş çubuğu

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Habar ýaz...", text: $viewModel.messageText, axis: .vertical)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1...5)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(AppColors.surface)
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppColors.border, lineWidth: 1)
                )

            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                Task { await viewModel.sendGroupMessage(to: groupId) }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textInverse)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(AppColors.messageFromMeGradient)
                    )
                    .shadow(color: AppColors.buttonActive.opacity(0.3), radius: 10, y: 3)
            }
            .scaleEffect(viewModel.messageText.isEmpty ? 0.88 : 1.0)
            .animation(.spring(response: 0.25), value: viewModel.messageText.isEmpty)
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        // Arka plan üst katman (ultraThinMaterial) tarafından sağlanır.
    }
}
