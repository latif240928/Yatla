// UI/Features/Home/Chat/ChatMediaGalleryView.swift
//
// İki sohbet katılımcısı arasındaki paylaşılan medya koleksiyonu — dizide
// paylaşılan tüm fotoğraf ve dosyalar, sekmeli galeri olarak sunulur.
// Şimdilik `Chat.messages` tarafından desteklenir (medya, mesaj metni +
// ek URL'lerinden çıkarılır). Arka uç gerçek bir ekler uç noktası
// sunduğunda, `ChatRepository.fetchAttachments(chatId:)` yerel filtrenin yerini alacaktır.

import SwiftUI

struct ChatMediaGalleryView: View {
    let chat: Chat
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Tab = .media

    enum Tab: String, CaseIterable, Identifiable {
        case media   = "Suratlar"
        case files   = "Faýllar"
        var id: String { rawValue }
    }

    /// Mock koleksiyonlar — arka uç bağlandığında bunları `ChatRepository`'ye
    /// yapılan gerçek sorgularla değiştirin.
    private var photoMessages: [ChatMessage] {
        chat.messages.filter { $0.text.lowercased().hasSuffix(".jpg")
            || $0.text.lowercased().hasSuffix(".jpeg")
            || $0.text.lowercased().hasSuffix(".png")
            || $0.text.lowercased().hasPrefix("[photo]")
        }
    }
    private var fileMessages: [ChatMessage] {
        chat.messages.filter { $0.text.lowercased().hasSuffix(".pdf")
            || $0.text.lowercased().hasSuffix(".doc")
            || $0.text.lowercased().hasSuffix(".docx")
            || $0.text.lowercased().hasPrefix("[file]")
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                appBar
                tabSwitcher
                content
            }
        }
        .navigationBarHidden(true)
    }

    private var appBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Media faýllary")
                    .font(AppFonts.aestetico(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(chat.participant.name)
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                }) {
                    Text(tab.rawValue)
                        .font(AppFonts.subheadline)
                        .foregroundColor(selectedTab == tab ? AppColors.textPrimary : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == tab ? AppColors.surfaceLight : Color.clear)
                        .cornerRadius(14)
                }
            }
        }
        .padding(4)
        .background(AppColors.surface)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.divider, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .media:  mediaGrid
        case .files:  filesList
        }
    }

    private var mediaGrid: some View {
        ScrollView {
            if photoMessages.isEmpty {
                emptyState(icon: "photo.on.rectangle", text: "Heniz surat alyşmadyňyz")
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(photoMessages) { msg in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppColors.surfaceAlt)
                            .frame(height: 112)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppColors.textHint)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    private var filesList: some View {
        ScrollView {
            if fileMessages.isEmpty {
                emptyState(icon: "doc.fill", text: "Heniz faýl alyşmadyňyz")
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(fileMessages) { msg in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.primaryLight)
                                    .frame(width: 42, height: 42)
                                Image(systemName: "doc.fill")
                                    .foregroundColor(AppColors.primary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(msg.text)
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                    .lineLimit(1)
                                Text(AppDateFormatters.dayMonthYearDot.string(from: msg.sentAt))
                                    .font(AppFonts.caption2)
                                    .foregroundColor(AppColors.textHint)
                            }
                            Spacer()
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    private func emptyState(icon: String, text: String) -> some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 80)
            Image(systemName: icon)
                .font(AppFonts.aestetico(size: 48))
                .foregroundColor(AppColors.textHint)
            Text(text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
