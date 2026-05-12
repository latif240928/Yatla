// DEBUG derlemelerinde ekranın üstünde yüzen küçük rozet: geliştiriciye şunları gösterir:
//
//   • Hangi `API_ENV` aktif (mock / local / dev / staging / prod)
//   • Çözümlenmiş taban URL
//   • Sunucuya erişilebilirlik (yeşil / kırmızı nokta)
//   • Son `/health` denemesinin gecikmesi
//
// Rozete dokununca test yenilenir. RELEASE'de tamamen derlenmez; son kullanıcı görmez.
import SwiftUI

#if DEBUG

struct DebugAPIBadge: View {
    @State private var snapshot: NetworkService.HealthSnapshot?
    @State private var isProbing = false
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            pill
            if expanded { detailCard }
        }
        .padding(.trailing, 8)
        .task { await probe() }
    }

    private var pill: some View {
        Button(action: { expanded.toggle() }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(envLabel)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                if let ms = snapshot?.latencyMs, snapshot?.reachable == true {
                    Text("\(ms)ms")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private var detailCard: some View {
        VStack(alignment: .trailing, spacing: 6) {
            row("baseURL", snapshot?.baseURL.absoluteString ?? "—")
            row("status", snapshot?.summary ?? "probing…")
            HStack(spacing: 8) {
                Button {
                    Task { await probe() }
                } label: {
                    Label("Re-probe", systemImage: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(isProbing)
            }
        }
        .padding(10)
        .frame(maxWidth: 260, alignment: .trailing)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private func row(_ key: String, _ value: String) -> some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(key.uppercased())
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Durum

    private var envLabel: String {
        APIEnvironment.current.displayName
    }

    private var statusColor: Color {
        guard let snapshot else { return .yellow }
        return snapshot.reachable ? .green : .red
    }

    private func probe() async {
        guard !isProbing else { return }
        isProbing = true
        let result = await NetworkService.shared.healthCheck()
        snapshot = result
        isProbing = false
    }
}

#endif
