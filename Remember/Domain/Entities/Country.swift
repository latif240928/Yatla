import Foundation

struct Country: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let dialCode: String
    let flag: String
    
    static let all: [Country] = [
        Country(name: "Turkmenistan", dialCode: "+993", flag: "🇹🇲"),
        Country(name: "United States", dialCode: "+1", flag: "🇺🇸"),
        Country(name: "United Kingdom", dialCode: "+44", flag: "🇬🇧"),
        Country(name: "Germany", dialCode: "+49", flag: "🇩🇪"),
        Country(name: "France", dialCode: "+33", flag: "🇫🇷"),
        Country(name: "Russia", dialCode: "+7", flag: "🇷🇺"),
        Country(name: "Turkey", dialCode: "+90", flag: "🇹🇷"),
        Country(name: "Kazakhstan", dialCode: "+7", flag: "🇰🇿"),
        Country(name: "Uzbekistan", dialCode: "+998", flag: "🇺🇿"),
        Country(name: "China", dialCode: "+86", flag: "🇨🇳"),
        Country(name: "Japan", dialCode: "+81", flag: "🇯🇵"),
        Country(name: "India", dialCode: "+91", flag: "🇮🇳"),
        Country(name: "Brazil", dialCode: "+55", flag: "🇧🇷"),
        Country(name: "Canada", dialCode: "+1", flag: "🇨🇦"),
        Country(name: "Italy", dialCode: "+39", flag: "🇮🇹")
    ]
}
