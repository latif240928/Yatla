// UI/Features/Chats/ChatDetailView.swift
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ChatDetailView: View {
    let chat: Chat
    var currentChat: Chat? {
        viewModel.chats.first(where: { $0.id == chat.id })
    }
    @ObservedObject var viewModel: ChatsViewModel
    @EnvironmentObject private var container: DIContainer
    @Binding var isChatDetailActive: Bool
    @Environment(\.dismiss) private var dismiss

    private var lang: Language { container.appSettings.selectedLanguage }

    @State private var showAttachMenu: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil
    @State private var attachedFileURL: URL? = nil
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var showChatMenu: Bool = false
    @State private var isMuted: Bool = false
    @State private var showMutePicker: Bool = false
    @State private var showMediaGallery: Bool = false
    @State private var showPublicProfile: Bool = false
    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        ZStack {
            // Telegram tarzı yumuşak gradyan arka plan; balonlar düz bir renk
            // üzerinde durmuyor. Hem açık hem koyu varyantlar, metin kontrastını
            // rahat tutacak şekilde ayarlanmıştır.
            AppColors.chatBackgroundGradient.ignoresSafeArea()

            // Üç belirgin bölge — başlık, mesaj kaydırma, yazı alanı —
            // `safeAreaInset` ile sabitlenmiştir; böylece gradyan ekran
            // kenarlarına yaslanırken uygulama çubuğu / giriş çubuğu
            // durum çubuğu ve ana gösterge ile hizalı kalır (Telegram tarzı).
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

            if showAttachMenu {
                AppColors.overlay
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { showAttachMenu = false }
                    }
                VStack {
                    Spacer()
                    attachMenuPopup
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                }
            }

            if showChatMenu {
                AppColors.overlay.opacity(1.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) { showChatMenu = false }
                    }
                VStack {
                    Spacer()
                    chatMenuSheet
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        // Modern toolbar API, `safeAreaInset` ile eski
        // `.navigationBarHidden(true)` yöntemine göre daha uyumlu çalışır —
        // navigasyon çubuğunun üstte ayırdığı alanı gerçekten serbest bırakır.
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showChatMenu)
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.22)) {
                isChatDetailActive = false
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            showAttachMenu = false
            if case .success(let urls) = result, let url = urls.first {
                _ = url.startAccessingSecurityScopedResource()
                attachedFileURL = url
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhoto,
            matching: .images
        )
        .onChange(of: selectedPhoto) { _, newItem in
            showAttachMenu = false
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                }
            }
        }
        // MARK: - Sohbet menüsünden açılan sayfalar (sessize alma, medya vb.)
        .sheet(isPresented: $showMutePicker) {
            MutePickerSheet(
                isMuted: $isMuted,
                isPresented: $showMutePicker,
                onConfirm: { newValue in
                    isMuted = newValue
                    Task {
                        // Seçim gerçekten değiştiğinde mevcut toggle
                        // mekanizması üzerinden kalıcı hale getir.
                        if let liveChat = currentChat, liveChat.isMuted != newValue {
                            await viewModel.toggleMute(chat: liveChat)
                        }
                    }
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $showMediaGallery) {
            if let live = currentChat {
                NavigationStack { ChatMediaGalleryView(chat: live) }
            }
        }
        .fullScreenCover(isPresented: $showPublicProfile) {
            if let participant = currentChat?.participant {
                NavigationStack {
                    UserPublicProfileView(
                        user: participant,
                        departments: viewModel.departments,
                        stats: nil
                    )
                }
            }
        }
        .alert(
            L10n.string(.chatsConfirmDeleteTitle, language: lang),
            isPresented: $showDeleteConfirm
        ) {
            Button(L10n.string(.actionYes, language: lang), role: .destructive) {
                Task {
                    await viewModel.deleteChat(id: chat.id)
                    dismiss()
                }
            }
            Button(L10n.string(.actionNo, language: lang), role: .cancel) {}
        } message: {
            Text(L10n.string(.chatsConfirmDeleteMessage, language: lang))
        }
        .onAppear {
        // Yerel sessize alma durumunu repo'nun bildirdiği değerle eşitle —
        // menü ve sessize alma sayfası bu bayrağı okur.
            isMuted = currentChat?.isMuted ?? false
        }
    }

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
                        Text(String(currentChat?.participant.name.prefix(1).uppercased() ?? "?"))
                            .font(AppFonts.aestetico(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(currentChat?.participant.name ?? "")
                    .font(AppFonts.aestetico(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Circle()
                        .fill(AppColors.online)
                        .frame(width: 6, height: 6)
                    Text(L10n.string(.chatOnline, language: lang))
                        .font(AppFonts.aestetico(size: 11, weight: .medium))
                        .foregroundColor(AppColors.online)
                }
            }

            Spacer()

            HStack(spacing: 6) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showChatMenu = true
                    }
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 4, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    let messages = currentChat?.messages ?? []
                    let firstDate: Date = {
                        if let first = messages.first?.sentAt {
                            return first
                        } else {
                            return Date()
                        }
                    }()
                    let dateString = formatDate(firstDate)

                    Text(dateString)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textHint)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(AppColors.surfaceLight)
                        .cornerRadius(12)
                        .padding(.top, 14)
                        .padding(.bottom, 6)

                    ForEach(currentChat?.messages ?? []) { msg in
                        let isFromMe = (msg.sender.id == viewModel.currentUser.id)
                        MessageBubbleView(
                            message: msg,
                            isFromMe: isFromMe
                        )
                        .id(msg.id)
                    }

                    if let photoData = selectedPhotoData,
                       let uiImage = UIImage(data: photoData) {
                        attachmentPreview(image: uiImage)
                    } else if let fileURL = attachedFileURL {
                        filePreview(url: fileURL)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
            .onAppear {
                scrollProxy = proxy
                if let last = currentChat?.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onChange(of: currentChat?.messages.count) { _, _ in
                if let last = currentChat?.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func attachmentPreview(image: UIImage) -> some View {
        HStack {
            Spacer()
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Button(action: { selectedPhotoData = nil; selectedPhoto = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(AppFonts.aestetico(size: 22))
                        .foregroundColor(AppColors.textInverse)
                        .shadow(radius: 4)
                        .padding(6)
                }
            }
        }
        .padding(.trailing, 4)
    }

    private func filePreview(url: URL) -> some View {
        HStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: "doc.fill").foregroundColor(AppColors.primary)
                Text(url.lastPathComponent)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Button(action: { attachedFileURL = nil }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(AppColors.error)
                }
            }
            .padding(10)
            .background(AppColors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
        }
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showAttachMenu.toggle()
                }
            }) {
                Image(systemName: showAttachMenu ? "xmark" : "plus")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(showAttachMenu ? AppColors.textInverse : AppColors.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(
                            showAttachMenu
                            ? AppColors.error.opacity(0.8)
                            : AppColors.surfaceLight
                        )
                    )
                    .rotationEffect(.degrees(showAttachMenu ? 45 : 0))
                    .animation(.spring(response: 0.3), value: showAttachMenu)
            }

            TextField(L10n.string(.chatsTypeMessage, language: lang), text: $viewModel.messageText, axis: .vertical)
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

            // MARK: - Gönder Butonu (Mavi)
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                Task { await viewModel.sendMessage(to: chat.id) }
                selectedPhotoData = nil
                selectedPhoto = nil
                attachedFileURL = nil
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textInverse)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(
                            LinearGradient(
                                colors: [
                                    Color(light: "#3B82F6", dark: "#2563EB"),  // Mavi
                                    Color(light: "#2563EB", dark: "#1D4ED8")    // Koyu mavi
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
                    .shadow(color: AppColors.buttonActive.opacity(0.3), radius: 10, y: 3)  // Mavi shadow
            }
            .scaleEffect(viewModel.messageText.isEmpty && selectedPhotoData == nil && attachedFileURL == nil ? 0.88 : 1.0)
            .animation(.spring(response: 0.25), value: viewModel.messageText.isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        // Arka plan üst katman (ultraThinMaterial) tarafından yönetilir;
        // böylece giriş çubuğu sert bir blok yerine gradyanın içine gömülü hissedilir.
    }

    private var attachMenuPopup: some View {
        HStack(spacing: 16) {
            attachMenuItem(icon: "photo.fill", label: L10n.string(.chatPhoto, language: lang), color: .purple) {
                withAnimation { showAttachMenu = false }
                showPhotoPicker = true
            }
            attachMenuItem(icon: "doc.fill", label: L10n.string(.chatFile, language: lang), color: AppColors.primary) {
                withAnimation { showAttachMenu = false }
                showFilePicker = true
            }
            attachMenuItem(icon: "camera.fill", label: L10n.string(.chatCamera, language: lang), color: .orange) {
                withAnimation { showAttachMenu = false }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.surface)
                .shadow(color: AppColors.shadowColor(opacity: 0.15), radius: 20, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.divider, lineWidth: 1)
        )
    }

    private func attachMenuItem(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(color.opacity(0.18)).frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(AppFonts.aestetico(size: 22))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var chatMenuSheet: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(AppColors.divider)
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryLight)
                        .frame(width: 46, height: 46)
                    Text(String(currentChat?.participant.name.prefix(1).uppercased() ?? "?"))
                        .font(AppFonts.aestetico(size: 17, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentChat?.participant.name ?? "")
                        .font(AppFonts.aestetico(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(currentChat?.participant.phone ?? "")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Divider().background(AppColors.divider).padding(.horizontal, 20)

            VStack(spacing: 0) {
                // "Habarlarda gözleg" kaldırıldı — bu sürümde gerçek bir
                // işlevi yoktu ve menüyü kalabalık gösteriyordu.
                chatMenuItem(
                    icon: isMuted ? "bell.fill" : "bell.slash.fill",
                    label: isMuted ? L10n.string(.chatsUnmute, language: lang) : L10n.string(.chatsMute, language: lang),
                    color: .orange
                ) {
                    showChatMenu = false
                    // Kapanan menünün seçici sunumuyla çakışmaması için
                    // bir tık geciktir.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        showMutePicker = true
                    }
                }
                chatMenuItem(icon: "photo.on.rectangle", label: L10n.string(.chatsMediaFiles, language: lang), color: .purple) {
                    showChatMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        showMediaGallery = true
                    }
                }
                chatMenuItem(icon: "phone.fill", label: L10n.string(.chatsCallParticipant, language: lang), color: AppColors.success) {
                    showChatMenu = false
                    callPhoneNumber()
                }
                chatMenuItem(icon: "person.fill", label: L10n.string(.chatsViewProfile, language: lang), color: AppColors.info) {
                    showChatMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        showPublicProfile = true
                    }
                }
                chatMenuItem(icon: "trash.fill", label: L10n.string(.chatsDeleteChat, language: lang), color: AppColors.error, isDestructive: true) {
                    showChatMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        showDeleteConfirm = true
                    }
                }
            }
            .padding(.top, 8)

            Spacer().frame(height: 32)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.surface)
        )
        .shadow(color: AppColors.shadowColor(opacity: 0.2), radius: 20, y: -4)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    private func chatMenuItem(
        icon: String,
        label: String,
        color: Color,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(AppFonts.body)
                    .foregroundColor(isDestructive ? AppColors.error : AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textHint)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
        }
    }

    private func callPhoneNumber() {
        guard let phoneNumber = currentChat?.participant.phone else { return }
        let cleanedNumber = phoneNumber
            .filter { "0123456789+".contains($0) }
            .replacingOccurrences(of: " ", with: "")

        if let phoneURL = URL(string: "tel://\(cleanedNumber)"), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL)
        }
    }

    private func formatDate(_ date: Date) -> String {
        AppDateFormatters.monthDay.string(from: date)
    }
}
