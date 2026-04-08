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
    @Environment(\.dismiss) private var dismiss

    // Attachment
    @State private var showAttachMenu: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil
    @State private var attachedFileURL: URL? = nil

    // Scroll
    @State private var scrollProxy: ScrollViewProxy? = nil

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                appBar
                Divider().background(AppColors.divider)
                messageList
                Divider().background(AppColors.divider)
                inputBar
            }

            // Attach menü overlay
            if showAttachMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.spring()) { showAttachMenu = false } }

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
        }
        .navigationBarHidden(true)
        // File importer
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
        // Photo picker
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhoto,
            matching: .images
        )
        .onChange(of: selectedPhoto) { newItem in
            showAttachMenu = false
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedPhotoData = data
                }
            }
        }
    }

    // MARK: - AppBar
    private var appBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.25))
                            .frame(width: 34, height: 34)
                        Text(String(currentChat?.participant.name.prefix(1) ?? "?"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(currentChat?.participant.name ?? "")
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                Text("Online")
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.primary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "phone")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(AppColors.surface)
                        .cornerRadius(10)
                }
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(AppColors.surface)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Message List
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 4) {
                    // Tarih etiketi
                    Text(formatDate(currentChat?.messages.first?.sentAt ?? Date()))
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textHint)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(AppColors.surface.opacity(0.8))
                        .cornerRadius(12)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    ForEach(currentChat?.messages ?? []) { msg in
                        MessageBubbleView(
                            message: msg,
                            isFromMe: msg.sender.id == viewModel.currentUser.id
                        )
                        .id(msg.id)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    // Attachment preview (henüz gönderilmeden)
                    if let photoData = selectedPhotoData,
                       let uiImage = UIImage(data: photoData) {
                        attachmentPreview(image: uiImage)
                    } else if let fileURL = attachedFileURL {
                        filePreview(url: fileURL)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .onAppear {
                scrollProxy = proxy
                if let last = currentChat?.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onChange(of: currentChat?.messages.count) { _ in
                if let last = currentChat?.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Attachment Preview (göndermeden önce)
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
                        .font(.system(size: 22))
                        .foregroundColor(.white)
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
                Image(systemName: "doc.fill")
                    .foregroundColor(AppColors.primary)
                Text(url.lastPathComponent)
                    .font(AppFonts.caption1)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Button(action: { attachedFileURL = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.error)
                }
            }
            .padding(10)
            .background(AppColors.surface)
            .cornerRadius(12)
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 10) {

                // Attach butonu
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showAttachMenu.toggle()
                    }
                }) {
                    Image(systemName: showAttachMenu ? "xmark" : "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
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

                // TextField
                TextField("Habar ýaz...", text: $viewModel.messageText, axis: .vertical)
                    .font(AppFonts.body)
                    .foregroundColor(.white)
                    .lineLimit(1...5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(AppColors.surface)
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )

                // Gönder butonu
                Button(action: {
                    Task { await viewModel.sendMessage(to: chat.id) }
                    selectedPhotoData = nil
                    selectedPhoto = nil
                    attachedFileURL = nil
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 17))
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
                        .shadow(color: AppColors.primary.opacity(0.35), radius: 8, y: 2)
                }
                .scaleEffect(viewModel.messageText.isEmpty && selectedPhotoData == nil && attachedFileURL == nil ? 0.9 : 1.0)
                .animation(.spring(response: 0.25), value: viewModel.messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppColors.background)
    }

    // MARK: - Attach Menu Popup
    private var attachMenuPopup: some View {
        HStack(spacing: 16) {
            // Galereya
            attachMenuItem(
                icon: "photo.fill",
                label: "Surat",
                color: .purple
            ) {
                withAnimation { showAttachMenu = false }
                showPhotoPicker = true
            }

            // Faýl
            attachMenuItem(
                icon: "doc.fill",
                label: "Faýl",
                color: AppColors.primary
            ) {
                withAnimation { showAttachMenu = false }
                showFilePicker = true
            }

            // Kamera
            attachMenuItem(
                icon: "camera.fill",
                label: "Kamera",
                color: .orange
            ) {
                withAnimation { showAttachMenu = false }
                // Kamera açma — isteğe göre eklenebilir
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.surface)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
        )
    }

    private func attachMenuItem(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM d"
        return fmt.string(from: date)
    }
}

// MARK: - Message Bubble
struct MessageBubbleView: View {
    let message: ChatMessage
    let isFromMe: Bool

    // Simüle: mesaj gönderildi → 1 tik, ulaştı → 2 tik, okundu → 2 tik mavi
    // Gerçek uygulamada bu değerler ChatMessage modeline eklenir
    private var messageStatus: MessageStatus {
        guard isFromMe else { return .none }
        // Gerçek status için message.status kullanılabilir
        // Şimdilik gönderilmiş = delivered varsayıyoruz
        return .delivered
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isFromMe { Spacer(minLength: 50) }

            // Karşı taraf avatarı
            if !isFromMe {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .frame(width: 28, height: 28)
                    Text(String(message.sender.name.prefix(1)))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
                .padding(.bottom, 18)
            }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 3) {
                // Bubble
                Text(message.text)
                    .font(AppFonts.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isFromMe
                                  ? AppColors.primary.opacity(0.85)
                                  : AppColors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isFromMe ? Color.clear : AppColors.divider,
                                lineWidth: 1
                            )
                    )

                // Zaman + Tik
                HStack(spacing: 4) {
                    Text(formatTime(message.sentAt))
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textHint)

                    if isFromMe {
                        MessageTicks(status: messageStatus)
                    }
                }
                .padding(.horizontal, 4)
            }

            if !isFromMe { Spacer(minLength: 50) }
        }
        .padding(.vertical, 2)
    }

    private func formatTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}

// MARK: - Message Status Ticks
enum MessageStatus {
    case none       // karşı tarafın mesajı
    case sent       // gönderildi (1 tik)
    case delivered  // ulaştı (2 tik gri)
    case read       // okundu (2 tik mavi/renkli)
}

struct MessageTicks: View {
    let status: MessageStatus

    var body: some View {
        switch status {
        case .none:
            EmptyView()

        case .sent:
            // Tek tik
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(AppColors.textHint)

        case .delivered:
            // Çift tik — gri
            doubleCheck(color: AppColors.textHint)

        case .read:
            // Çift tik — mavi (fill)
            doubleCheck(color: AppColors.primary)
        }
    }

    private func doubleCheck(color: Color) -> some View {
        HStack(spacing: -4) {
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
        }
    }
}


