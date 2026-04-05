// UI/Features/Settings/StatsView.swift
import SwiftUI

struct StatsView: View {
    @ObservedObject var vm: SettingsViewModel

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {

                   
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Jemi Task",   value: vm.stats.totalTasks,      color: AppColors.primary)
                        StatCard(title: "Tamamlanan",  value: vm.stats.completedTasks,  color: .green)
                        StatCard(title: "Başarmadyk",  value: vm.stats.failedTasks,     color: .red)
                        StatCard(title: "Ulanyjylar",  value: vm.stats.totalUsers,      color: .orange)
                    }

                    
                    if vm.stats.totalTasks > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tamamlanma derejesi")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.textSecondary)

                            let ratio = Double(vm.stats.completedTasks) / Double(vm.stats.totalTasks)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.surfaceLight)
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.primary)
                                        .frame(width: geo.size.width * ratio, height: 12)
                                }
                            }
                            .frame(height: 12)

                            Text("\(Int(ratio * 100))%")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                    }

                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Günlük Tasklar")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        let dailyItems = vm.stats.dailyTasks.keys.sorted()

                        if dailyItems.isEmpty {
                            Text("Heniz maglumat ýok")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textHint)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(dailyItems, id: \.self) { date in
                                HStack {
                                    Text(date, style: .date)
                                        .font(AppFonts.body)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(vm.stats.dailyTasks[date] ?? 0) task")
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.primary)
                                }
                                .padding(.vertical, 4)
                                Divider().background(AppColors.divider)
                            }
                        }
                    }
                    .padding(16)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Statistika")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.refreshStats() }
    }
}
