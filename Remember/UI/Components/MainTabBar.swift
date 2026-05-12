// UI/Components/MainTabBar.swift
import SwiftUI

enum TabItem: Int, CaseIterable {
    case home       = 0
    case createTask = 1
    case users      = 2
    case chats      = 3
    case settings   = 4

    var icon: String {
        switch self {
        case .home:       return "list.clipboard.fill"
        case .createTask: return "plus.square.fill"
        case .users:      return "person.2.fill"
        case .chats:      return "bubble.left.and.bubble.right.fill"
        case .settings:   return "gearshape.fill"
        }
    }
}

struct MainTabBar: View {
    @Binding var selectedTab: TabItem
    @EnvironmentObject private var container: DIContainer
    @Environment(\.layout) private var layout
    @Namespace private var tabAnimation

    private func tabTitle(_ tab: TabItem) -> String {
        let lang = container.appSettings.selectedLanguage
        switch tab {
        case .home:       return L10n.string(.tabHome, language: lang)
        case .createTask: return L10n.string(.tabMyTasks, language: lang)
        case .users:      return L10n.string(.tabUsers, language: lang)
        case .chats:      return L10n.string(.tabChats, language: lang)
        case .settings:   return L10n.string(.tabSettings, language: lang)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(AppFonts.aestetico(size: layout.value(compact: 22, regular: 24, wide: 26)))
                            .foregroundColor(
                                selectedTab == tab
                                ? AppColors.primary
                                : AppColors.textHint
                            )
                            .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedTab)

                        Text(tabTitle(tab))
                            .font(AppFonts.aestetico(size: layout.value(compact: 10, regular: 11, wide: 12),
                                                     weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(
                                selectedTab == tab
                                ? AppColors.primary
                                : AppColors.textHint
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, layout.value(compact: 10, regular: 12, wide: 14))
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(AppColors.primary.opacity(0.12))
                                .matchedGeometryEffect(id: "activeTab", in: tabAnimation)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 34)
                .fill(AppColors.surface)
                .shadow(
                    color: AppColors.primary.opacity(0.12),
                    radius: 16,
                    x: 0,
                    y: -4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34)
                .stroke(AppColors.divider, lineWidth: 1)
        )
        .frame(maxWidth: layout.isCompact ? .infinity : 560)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, layout.gutter)
        .padding(.bottom, 8)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    VStack {
        Spacer()
        MainTabBar(selectedTab: .constant(.home))
    }
    .background(AppColors.background)
    .environmentObject(DIContainer.shared)
}
