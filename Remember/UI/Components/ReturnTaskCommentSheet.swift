// UI/Components/ReturnTaskCommentSheet.swift
//
// Görev oluşturucusu "Barlanmaly işler" içindeki bir gönderimde
// "Yzyna gaýtarmak" butonuna bastığında görüntülenen alt sayfa.
// İş geri gönderilmeden önce oluşturucu neyin yanlış olduğunu
// açıklamalıdır, bu yüzden bu sayfa boş olmayan bir yorum toplar
// ve `onSend` geri çağrımı aracılığıyla iletir.
import SwiftUI

struct ReturnTaskCommentSheet: View {
    let assigneeName: String
    var onCancel: () -> Void
    var onSend: (String) -> Void
    @EnvironmentObject private var container: DIContainer

    @State private var comment: String = ""
    @FocusState private var focused: Bool

    private var lang: Language { container.appSettings.selectedLanguage }

    private var isValid: Bool {
        !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetGrabber(bottomPadding: 16)

            Text(L10n.string(.returnSheetTitle, language: lang))
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, 4)

            Text("\(assigneeName) — \(L10n.string(.returnSheetSubtitle, language: lang))")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 18)

            commentEditor
                .padding(.horizontal, 20)

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                SheetOutlineActionButton(title: L10n.string(.returnSheetCancel, language: lang), action: onCancel)

                SheetDestructiveActionButton(title: L10n.string(.returnSheetSend, language: lang), isEnabled: isValid) {
                    onSend(comment)
                }
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColors.surface.ignoresSafeArea())
        .onAppear { focused = true }
    }

    private var commentEditor: some View {
        ZStack(alignment: .topLeading) {
            if comment.isEmpty {
                Text(L10n.string(.returnSheetPlaceholder, language: lang))
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textHint)
                    .padding(14)
            }
            TextEditor(text: $comment)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .focused($focused)
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(minHeight: 130, maxHeight: 200)
        }
        .background(AppColors.surfaceLight)
        .clipShape(AppShape.inputShape)
        .overlay(
            AppShape.inputShape
                .stroke(
                    focused ? AppColors.borderFocused : AppColors.divider,
                    lineWidth: focused ? AppShape.Stroke.focused : AppShape.Stroke.regular
                )
        )
        .animation(.easeInOut(duration: 0.18), value: focused)
    }
}

#Preview {
    Color.black.opacity(0.3)
        .sheet(isPresented: .constant(true)) {
            ReturnTaskCommentSheet(
                assigneeName: "Haknazar Haljanow",
                onCancel: {},
                onSend: { _ in }
            )
            .presentationDetents([.medium])
        }
}
