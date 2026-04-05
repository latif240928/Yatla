import SwiftUI

struct LanguageMenu: View {
    @Binding var selectedLanguage: String
    
    var body: some View {
        Menu {
            Button("Türkmen") { selectedLanguage = "TM" }
            Button("Türkçe")  { selectedLanguage = "TR" }
            Button("Русский") { selectedLanguage = "RU" }
            Button("English") { selectedLanguage = "EN" }
        } label: {
            Text(selectedLanguage)
                .font(.headline)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.25))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding(.top, 10)
        .padding(.trailing, 20)
    }
}




struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content
    
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}


#Preview("Language Menu") {
    StatefulPreviewWrapper("TM") { binding in
        ZStack {
            AppColors.background.ignoresSafeArea() 
            
            VStack {
                HStack {
                    Spacer()
                    LanguageMenu(selectedLanguage: binding)
                }
                Spacer()
            }
        }
    }
}
