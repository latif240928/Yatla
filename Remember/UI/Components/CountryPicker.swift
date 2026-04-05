import SwiftUI
import Foundation

// MARK: - Component
struct CountryPicker: View {
    @Binding var selectedCountry: Country
    @State private var isPresented = false
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return Country.all
        } else {
            return Country.all.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        Button(action: {
            isPresented = true
        }) {
            HStack(spacing: 4) {
                Text(selectedCountry.flag)
                    .font(.system(size: 20))
                Text(selectedCountry.dialCode)
                    .font(AppFonts.body)
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
        }
        .sheet(isPresented: $isPresented) {
            NavigationView {
                Group {
                    if filteredCountries.isEmpty {
                        VStack {
                            Spacer()
                            Text("Tapylmady")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        List(filteredCountries) { country in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                selectedCountry = country
                                isPresented = false
                            }) {
                                HStack {
                                    Text(country.flag)
                                    Text(country.name)
                                    
                                    Spacer()
                                    
                                    Text(country.dialCode)
                                        .foregroundColor(.gray)
                                    
                                    if selectedCountry.id == country.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                        .listStyle(.plain)
                    }
                }
                .searchable(text: $searchText)
                .navigationTitle("Yurt Saylan")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Yap") {
                            isPresented = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    CountryPickerPreviewWrapper()
}

struct CountryPickerPreviewWrapper: View {
    @State private var selectedCountry: Country = Country.all.first!
    
    var body: some View {
        VStack(spacing: 20) {
            CountryPicker(selectedCountry: $selectedCountry)
            
            VStack(spacing: 6) {
                Text("Saylanan yurt")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(selectedCountry.flag) \(selectedCountry.name) \(selectedCountry.dialCode)")
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
