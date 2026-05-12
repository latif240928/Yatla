// Sohbet sessize alındı mı? — hafif seçici sayfası. Sohbet menüsünden "Sessizleştir" ile açılır;
// iki seçenek ve tek onay düğmesi ile modal hissi vermeden karar verilir.
import SwiftUI

struct MutePickerSheet: View {
    @Binding var isMuted: Bool
    @Binding var isPresented: Bool
    var onConfirm: (Bool) -> Void

    @State private var localChoice: Bool

    init(isMuted: Binding<Bool>, isPresented: Binding<Bool>, onConfirm: @escaping (Bool) -> Void) {
        self._isMuted = isMuted
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        self._localChoice = State(initialValue: isMuted.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetGrabber(bottomPadding: 16)

            Text("Bildiriş sazlamasy")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, 4)

            Text("Bu çat üçin sesli ýa-da sessiz tertibi saýlaň")
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 22)

            VStack(spacing: 10) {
                option(
                    icon: "bell.fill",
                    title: "Sesli",
                    subtitle: "Habar gelende ses çalsyn",
                    color: AppColors.success,
                    selected: !localChoice
                ) {
                    localChoice = false
                }
                option(
                    icon: "bell.slash.fill",
                    title: "Sessiz",
                    subtitle: "Bildiriş geler, ýöne ses çalmaz",
                    color: .orange,
                    selected: localChoice
                ) {
                    localChoice = true
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 18)

            HStack(spacing: 10) {
                SheetOutlineActionButton(title: "Goý-bolsun") { isPresented = false }

                SheetGradientActionButton(title: "Saýlamak", isEnabled: true) {
                    onConfirm(localChoice)
                    isPresented = false
                }
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.bottom, 22)
        }
        .background(AppColors.surface.ignoresSafeArea())
    }

    private func option(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(AppFonts.aestetico(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    Text(subtitle)
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(selected ? AppColors.primary : AppColors.divider, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(14)
            .background(
                AppShape.buttonShape
                    .fill(AppColors.surfaceLight.opacity(selected ? 1 : 0.55))
            )
            .overlay(
                AppShape.buttonShape
                    .stroke(
                        selected ? AppColors.primary.opacity(0.5) : AppColors.divider,
                        lineWidth: selected ? AppShape.Stroke.focused : AppShape.Stroke.regular
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
