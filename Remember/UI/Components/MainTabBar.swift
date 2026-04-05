// UI/Components/MainTabBar.swift
import SwiftUI

enum TabItem: Int, CaseIterable {
    case home       = 0
    case createTask = 1
    case users      = 2
    case chats      = 3
    case settings   = 4

    var title: String {
        switch self {
        case .home:       return "Berlen işler"
        case .createTask: return "Iş döretmek"
        case .users:      return "Ulanyjylar"
        case .chats:      return "Çatlar"
        case .settings:   return "Sazlamalar"
        }
    }

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

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22))
                            .foregroundColor(
                                selectedTab == tab
                                ? AppColors.primary
                                : AppColors.textHint
                            )
                            .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedTab)

                        Text(tab.title)
                            .font(.system(
                                size: 10,
                                weight: selectedTab == tab ? .semibold : .regular
                            ))
                            .foregroundColor(
                                selectedTab == tab
                                ? AppColors.primary
                                : AppColors.textHint
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.surface)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: -2)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    VStack {
        Spacer()
        MainTabBar(selectedTab: .constant(.home))
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
