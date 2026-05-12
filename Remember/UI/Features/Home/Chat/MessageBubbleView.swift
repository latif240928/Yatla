// UI/Features/Chats/MessageBubbleView.swift
import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    let isFromMe: Bool
    /// Grup sohbetlerinde gelen her balonun gönderen adıyla etiketlenmesi gerekir.
    /// Doğrudan sohbetlerde katılımcı zaten uygulama çubuğunda gösterilir,
    /// bu nedenle varsayılan olarak gizlidir.
    var showSenderName: Bool = false
    @State private var appeared: Bool = false

    private var timeString: String {
        AppDateFormatters.hourMinute.string(from: message.sentAt)
    }

    /// Her iki balon artık aynı şekli ve aynı gölge dilini kullanır —
    /// yalnızca gradyan değişir — böylece gelen ve giden mesajlar iki farklı
    /// görsel sistem yerine kardeş gibi hissedilir.
    @ViewBuilder
    private var bubbleBackground: some View {
        if isFromMe {
            LinearGradient(
                colors: [
                    Color(light: "#3B82F6", dark: "#2563EB"),
                    Color(light: "#2563EB", dark: "#1D4ED8")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [
                    AppColors.surface,
                    AppColors.surfaceLight
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isFromMe { Spacer(minLength: 60) }

            if !isFromMe {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryLight)
                        .frame(width: 28, height: 28)
                    Text(String(message.sender.name.prefix(1).uppercased()))
                        .font(AppFonts.aestetico(size: 11, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
                .padding(.bottom, 4)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))
            }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 3) {
                if showSenderName && !isFromMe {
                    Text(message.sender.name)
                        .font(AppFonts.aestetico(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(.leading, 6)
                }

                HStack(alignment: .bottom, spacing: 6) {
                    if isFromMe {
                        HStack(spacing: 3) {
                            Text(timeString)
                                .font(AppFonts.aestetico(size: 10))
                                .foregroundColor(AppColors.textInverse.opacity(0.7))
                            Image(systemName: message.isRead ? "checkmark.message.fill" : "checkmark")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.textInverse.opacity(0.85))
                        }
                        .padding(.bottom, 6)
                    }

                    Text(message.text)
                        .font(AppFonts.body)
                        .foregroundColor(isFromMe ? AppColors.textInverse : AppColors.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            bubbleBackground
                                .clipShape(ChatBubbleShape(isFromMe: isFromMe))
                        )
                        .overlay(
                            ChatBubbleShape(isFromMe: isFromMe)
                                .stroke(
                                    isFromMe
                                        ? Color.clear
                                        : AppColors.divider.opacity(0.6),
                                    lineWidth: 1
                                )
                        )
                        .shadow(
                            color: AppColors.shadowColor(opacity: isFromMe ? 0.18 : 0.06),
                            radius: isFromMe ? 8 : 4,
                            y: isFromMe ? 4 : 2
                        )
                        .scaleEffect(appeared ? 1.0 : 0.7, anchor: isFromMe ? .bottomTrailing : .bottomLeading)
                        .opacity(appeared ? 1.0 : 0)

                    if !isFromMe {
                        Text(timeString)
                            .font(AppFonts.aestetico(size: 10))
                            .foregroundColor(AppColors.textHint)
                            .padding(.bottom, 6)
                    }
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: isFromMe ? .trailing : .leading).combined(with: .opacity),
                removal: .opacity
            ))

            if !isFromMe { Spacer(minLength: 60) }
        }
        .padding(.vertical, 3)
        .onAppear {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.65)) {
                appeared = true
            }
        }
    }
}

// Sohbet mesaj balonunun özel şekli (yuvarlatılmış köşeler).
struct ChatBubbleShape: Shape {
    let isFromMe: Bool
    let radius: CGFloat = 18
    let tailRadius: CGFloat = 5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        if isFromMe {
            path.move(to: CGPoint(x: w - tailRadius, y: h))
            path.addLine(to: CGPoint(x: radius, y: h))
            path.addArc(center: CGPoint(x: radius, y: h - radius), radius: radius,
                        startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: radius))
            path.addArc(center: CGPoint(x: radius, y: radius), radius: radius,
                        startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
            path.addLine(to: CGPoint(x: w - radius, y: 0))
            path.addArc(center: CGPoint(x: w - radius, y: radius), radius: radius,
                        startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: w, y: h - tailRadius))
            path.addArc(center: CGPoint(x: w - tailRadius, y: h - tailRadius), radius: tailRadius,
                        startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        } else {
            path.move(to: CGPoint(x: tailRadius, y: h))
            path.addLine(to: CGPoint(x: w - radius, y: h))
            path.addArc(center: CGPoint(x: w - radius, y: h - radius), radius: radius,
                        startAngle: .degrees(90), endAngle: .degrees(0), clockwise: true)
            path.addLine(to: CGPoint(x: w, y: radius))
            path.addArc(center: CGPoint(x: w - radius, y: radius), radius: radius,
                        startAngle: .degrees(0), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(center: CGPoint(x: radius, y: radius), radius: radius,
                        startAngle: .degrees(270), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: h - tailRadius))
            path.addArc(center: CGPoint(x: tailRadius, y: h - tailRadius), radius: tailRadius,
                        startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
        }
        path.closeSubpath()
        return path
    }
}
