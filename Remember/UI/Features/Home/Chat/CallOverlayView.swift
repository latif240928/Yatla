//
//  CallOverlayView.swift
//  Remember
//
//  Oluşturan: Latif — 02.05.2026.
//
//  Sesli/görüntülü arama benzeri tam ekran örtü: katılımcı bilgisi,
//  arama süresi, sessiz / dinamik kontrolleri ve kapatma düğmesi.
//

import SwiftUI

struct CallOverlayView: View {
    let participant: User?
    let onEnd: () -> Void

    @State private var isMuted: Bool = false
    @State private var isSpeaker: Bool = false
    @State private var callDuration: Int = 0
    @State private var timer: Timer? = nil
    @State private var callState: CallState = .calling

    /// Arama henüz bağlanmadı veya süre sayılıyor.
    enum CallState { case calling, connected }

    var body: some View {
        ZStack {
            // Arka plan gradient ve dekoratif daireler
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.09, blue: 0.15),
                    Color(red: 0.12, green: 0.08, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.42, green: 0.22, blue: 0.72).opacity(0.08))
                .frame(width: 350, height: 350)
                .offset(x: -80, y: -180)

            Circle()
                .fill(AppColors.primary.opacity(0.06))
                .frame(width: 280, height: 280)
                .offset(x: 120, y: 200)

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Çağrı beklenirken genişleyen halka animasyonu
                    if callState == .calling {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(AppColors.primary.opacity(0.15 - Double(i) * 0.04), lineWidth: 1)
                                .frame(width: CGFloat(100 + i * 36), height: CGFloat(100 + i * 36))
                                .scaleEffect(callState == .calling ? 1.05 : 1.0)
                                .animation(
                                    .easeInOut(duration: 1.4)
                                    .repeatForever()
                                    .delay(Double(i) * 0.4),
                                    value: callState
                                )
                        }
                    }

                    Circle()
                        .fill(AppColors.primary.opacity(0.2))
                        .frame(width: 96, height: 96)

                    Text(String(participant?.name.prefix(1).uppercased() ?? "?"))
                        .font(AppFonts.aestetico(size: 36, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
                .padding(.bottom, 28)

                Text(participant?.name ?? "")
                    .font(AppFonts.aestetico(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                Text(callState == .calling ? "Jaň edilýär..." : formatDuration(callDuration))
                    .font(AppFonts.aestetico(size: 14, weight: .medium))
                    .foregroundColor(callState == .calling ? AppColors.textSecondary : AppColors.primary)
                    .padding(.bottom, 8)

                if let phone = participant?.phone {
                    Text(phone)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textHint)
                }

                Spacer()

                // Alt kontrol çubuğu: mikrofon, kapat, hoparlör
                HStack(spacing: 32) {
                    callControlButton(
                        icon: isMuted ? "mic.slash.fill" : "mic.fill",
                        label: isMuted ? "Ses aç" : "Sessiz",
                        color: isMuted ? AppColors.error : AppColors.surfaceLight
                    ) { isMuted.toggle() }

                    Button(action: {
                        timer?.invalidate()
                        onEnd()
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppColors.error)
                                .frame(width: 68, height: 68)
                                .shadow(color: AppColors.error.opacity(0.5), radius: 16, y: 4)
                            Image(systemName: "phone.down.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }

                    callControlButton(
                        icon: isSpeaker ? "speaker.wave.3.fill" : "speaker.fill",
                        label: "Dinamik",
                        color: isSpeaker ? AppColors.primary : AppColors.surfaceLight
                    ) { isSpeaker.toggle() }
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        // Demo: 3 sn sonra bağlandı kabul et ve süre sayacını başlat
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { callState = .connected }
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    callDuration += 1
                }
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    private func callControlButton(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(color).frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                Text(label)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
