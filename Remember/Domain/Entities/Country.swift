// Kayıt ekranı telefon seçici için ülke listesi (yaklaşık 200 kayıt).
// Sıra: varsayılan Türkmenistan ilk, ardından alfabetik — arama tek tuşla hızlı bulsun diye.
//
// `flag` Unicode bölgesel göstergeler kullanır (ek sprite gerekmez); sistem fontu her boyutta çizer.
// `id` UUID'dir; aynı `dialCode`'u paylaşan girişler olabilir (ör. ABD/Kanada +1).
//
// Yardımcılar:
//   `Country.all`            — TM sabit başta, tam alfabetik liste.
//   `Country.matches(query:)` — ad, kod veya ISO 3166 alpha-2 ile arama (ör. "TR").

import Foundation

struct Country: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let dialCode: String
    let flag: String
    let iso2: String

    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.iso2 == rhs.iso2 && lhs.dialCode == rhs.dialCode
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(iso2)
        hasher.combine(dialCode)
    }
}

extension Country {

    /// Ad, ülke kodu veya ISO 3166 alpha-2 ile serbest metin aramasına uyuyorsa `true`.
    func matches(query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return true }
        return name.lowercased().contains(q)
            || dialCode.lowercased().contains(q)
            || iso2.lowercased().contains(q)
    }

    static let `default`: Country = .turkmenistan
    static let turkmenistan = Country(name: "Türkmenistan", dialCode: "+993", flag: "🇹🇲", iso2: "TM")

    /// Tam liste (Türkmenistan en başta sabit).
    static let all: [Country] = ([turkmenistan] + Country.alphabetical)
        .reduce(into: [Country]()) { acc, country in
            // Türkmenistan hem başta hem alfabetik listede; çift eklenmesin (arama yine bulsun).
            if !acc.contains(country) {
                acc.append(country)
            }
        }

    /// Alfabetik sıralı liste; tip yüklenirken bir kez oluşturulur.
    fileprivate static let alphabetical: [Country] = raw.sorted {
        $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
    }

    private static let raw: [Country] = [
        Country(name: "Afghanistan", dialCode: "+93", flag: "🇦🇫", iso2: "AF"),
        Country(name: "Albania", dialCode: "+355", flag: "🇦🇱", iso2: "AL"),
        Country(name: "Algeria", dialCode: "+213", flag: "🇩🇿", iso2: "DZ"),
        Country(name: "Andorra", dialCode: "+376", flag: "🇦🇩", iso2: "AD"),
        Country(name: "Angola", dialCode: "+244", flag: "🇦🇴", iso2: "AO"),
        Country(name: "Antigua and Barbuda", dialCode: "+1268", flag: "🇦🇬", iso2: "AG"),
        Country(name: "Argentina", dialCode: "+54", flag: "🇦🇷", iso2: "AR"),
        Country(name: "Armenia", dialCode: "+374", flag: "🇦🇲", iso2: "AM"),
        Country(name: "Australia", dialCode: "+61", flag: "🇦🇺", iso2: "AU"),
        Country(name: "Austria", dialCode: "+43", flag: "🇦🇹", iso2: "AT"),
        Country(name: "Azerbaijan", dialCode: "+994", flag: "🇦🇿", iso2: "AZ"),
        Country(name: "Bahamas", dialCode: "+1242", flag: "🇧🇸", iso2: "BS"),
        Country(name: "Bahrain", dialCode: "+973", flag: "🇧🇭", iso2: "BH"),
        Country(name: "Bangladesh", dialCode: "+880", flag: "🇧🇩", iso2: "BD"),
        Country(name: "Barbados", dialCode: "+1246", flag: "🇧🇧", iso2: "BB"),
        Country(name: "Belarus", dialCode: "+375", flag: "🇧🇾", iso2: "BY"),
        Country(name: "Belgium", dialCode: "+32", flag: "🇧🇪", iso2: "BE"),
        Country(name: "Belize", dialCode: "+501", flag: "🇧🇿", iso2: "BZ"),
        Country(name: "Benin", dialCode: "+229", flag: "🇧🇯", iso2: "BJ"),
        Country(name: "Bhutan", dialCode: "+975", flag: "🇧🇹", iso2: "BT"),
        Country(name: "Bolivia", dialCode: "+591", flag: "🇧🇴", iso2: "BO"),
        Country(name: "Bosnia and Herzegovina", dialCode: "+387", flag: "🇧🇦", iso2: "BA"),
        Country(name: "Botswana", dialCode: "+267", flag: "🇧🇼", iso2: "BW"),
        Country(name: "Brazil", dialCode: "+55", flag: "🇧🇷", iso2: "BR"),
        Country(name: "Brunei", dialCode: "+673", flag: "🇧🇳", iso2: "BN"),
        Country(name: "Bulgaria", dialCode: "+359", flag: "🇧🇬", iso2: "BG"),
        Country(name: "Burkina Faso", dialCode: "+226", flag: "🇧🇫", iso2: "BF"),
        Country(name: "Burundi", dialCode: "+257", flag: "🇧🇮", iso2: "BI"),
        Country(name: "Cambodia", dialCode: "+855", flag: "🇰🇭", iso2: "KH"),
        Country(name: "Cameroon", dialCode: "+237", flag: "🇨🇲", iso2: "CM"),
        Country(name: "Canada", dialCode: "+1", flag: "🇨🇦", iso2: "CA"),
        Country(name: "Cape Verde", dialCode: "+238", flag: "🇨🇻", iso2: "CV"),
        Country(name: "Central African Republic", dialCode: "+236", flag: "🇨🇫", iso2: "CF"),
        Country(name: "Chad", dialCode: "+235", flag: "🇹🇩", iso2: "TD"),
        Country(name: "Chile", dialCode: "+56", flag: "🇨🇱", iso2: "CL"),
        Country(name: "China", dialCode: "+86", flag: "🇨🇳", iso2: "CN"),
        Country(name: "Colombia", dialCode: "+57", flag: "🇨🇴", iso2: "CO"),
        Country(name: "Comoros", dialCode: "+269", flag: "🇰🇲", iso2: "KM"),
        Country(name: "Congo", dialCode: "+242", flag: "🇨🇬", iso2: "CG"),
        Country(name: "Costa Rica", dialCode: "+506", flag: "🇨🇷", iso2: "CR"),
        Country(name: "Croatia", dialCode: "+385", flag: "🇭🇷", iso2: "HR"),
        Country(name: "Cuba", dialCode: "+53", flag: "🇨🇺", iso2: "CU"),
        Country(name: "Cyprus", dialCode: "+357", flag: "🇨🇾", iso2: "CY"),
        Country(name: "Czechia", dialCode: "+420", flag: "🇨🇿", iso2: "CZ"),
        Country(name: "Democratic Republic of the Congo", dialCode: "+243", flag: "🇨🇩", iso2: "CD"),
        Country(name: "Denmark", dialCode: "+45", flag: "🇩🇰", iso2: "DK"),
        Country(name: "Djibouti", dialCode: "+253", flag: "🇩🇯", iso2: "DJ"),
        Country(name: "Dominica", dialCode: "+1767", flag: "🇩🇲", iso2: "DM"),
        Country(name: "Dominican Republic", dialCode: "+1809", flag: "🇩🇴", iso2: "DO"),
        Country(name: "Ecuador", dialCode: "+593", flag: "🇪🇨", iso2: "EC"),
        Country(name: "Egypt", dialCode: "+20", flag: "🇪🇬", iso2: "EG"),
        Country(name: "El Salvador", dialCode: "+503", flag: "🇸🇻", iso2: "SV"),
        Country(name: "Equatorial Guinea", dialCode: "+240", flag: "🇬🇶", iso2: "GQ"),
        Country(name: "Eritrea", dialCode: "+291", flag: "🇪🇷", iso2: "ER"),
        Country(name: "Estonia", dialCode: "+372", flag: "🇪🇪", iso2: "EE"),
        Country(name: "Eswatini", dialCode: "+268", flag: "🇸🇿", iso2: "SZ"),
        Country(name: "Ethiopia", dialCode: "+251", flag: "🇪🇹", iso2: "ET"),
        Country(name: "Fiji", dialCode: "+679", flag: "🇫🇯", iso2: "FJ"),
        Country(name: "Finland", dialCode: "+358", flag: "🇫🇮", iso2: "FI"),
        Country(name: "France", dialCode: "+33", flag: "🇫🇷", iso2: "FR"),
        Country(name: "Gabon", dialCode: "+241", flag: "🇬🇦", iso2: "GA"),
        Country(name: "Gambia", dialCode: "+220", flag: "🇬🇲", iso2: "GM"),
        Country(name: "Georgia", dialCode: "+995", flag: "🇬🇪", iso2: "GE"),
        Country(name: "Germany", dialCode: "+49", flag: "🇩🇪", iso2: "DE"),
        Country(name: "Ghana", dialCode: "+233", flag: "🇬🇭", iso2: "GH"),
        Country(name: "Greece", dialCode: "+30", flag: "🇬🇷", iso2: "GR"),
        Country(name: "Grenada", dialCode: "+1473", flag: "🇬🇩", iso2: "GD"),
        Country(name: "Guatemala", dialCode: "+502", flag: "🇬🇹", iso2: "GT"),
        Country(name: "Guinea", dialCode: "+224", flag: "🇬🇳", iso2: "GN"),
        Country(name: "Guinea-Bissau", dialCode: "+245", flag: "🇬🇼", iso2: "GW"),
        Country(name: "Guyana", dialCode: "+592", flag: "🇬🇾", iso2: "GY"),
        Country(name: "Haiti", dialCode: "+509", flag: "🇭🇹", iso2: "HT"),
        Country(name: "Honduras", dialCode: "+504", flag: "🇭🇳", iso2: "HN"),
        Country(name: "Hong Kong", dialCode: "+852", flag: "🇭🇰", iso2: "HK"),
        Country(name: "Hungary", dialCode: "+36", flag: "🇭🇺", iso2: "HU"),
        Country(name: "Iceland", dialCode: "+354", flag: "🇮🇸", iso2: "IS"),
        Country(name: "India", dialCode: "+91", flag: "🇮🇳", iso2: "IN"),
        Country(name: "Indonesia", dialCode: "+62", flag: "🇮🇩", iso2: "ID"),
        Country(name: "Iran", dialCode: "+98", flag: "🇮🇷", iso2: "IR"),
        Country(name: "Iraq", dialCode: "+964", flag: "🇮🇶", iso2: "IQ"),
        Country(name: "Ireland", dialCode: "+353", flag: "🇮🇪", iso2: "IE"),
        Country(name: "Israel", dialCode: "+972", flag: "🇮🇱", iso2: "IL"),
        Country(name: "Italy", dialCode: "+39", flag: "🇮🇹", iso2: "IT"),
        Country(name: "Ivory Coast", dialCode: "+225", flag: "🇨🇮", iso2: "CI"),
        Country(name: "Jamaica", dialCode: "+1876", flag: "🇯🇲", iso2: "JM"),
        Country(name: "Japan", dialCode: "+81", flag: "🇯🇵", iso2: "JP"),
        Country(name: "Jordan", dialCode: "+962", flag: "🇯🇴", iso2: "JO"),
        Country(name: "Kazakhstan", dialCode: "+7", flag: "🇰🇿", iso2: "KZ"),
        Country(name: "Kenya", dialCode: "+254", flag: "🇰🇪", iso2: "KE"),
        Country(name: "Kiribati", dialCode: "+686", flag: "🇰🇮", iso2: "KI"),
        Country(name: "Kosovo", dialCode: "+383", flag: "🇽🇰", iso2: "XK"),
        Country(name: "Kuwait", dialCode: "+965", flag: "🇰🇼", iso2: "KW"),
        Country(name: "Kyrgyzstan", dialCode: "+996", flag: "🇰🇬", iso2: "KG"),
        Country(name: "Laos", dialCode: "+856", flag: "🇱🇦", iso2: "LA"),
        Country(name: "Latvia", dialCode: "+371", flag: "🇱🇻", iso2: "LV"),
        Country(name: "Lebanon", dialCode: "+961", flag: "🇱🇧", iso2: "LB"),
        Country(name: "Lesotho", dialCode: "+266", flag: "🇱🇸", iso2: "LS"),
        Country(name: "Liberia", dialCode: "+231", flag: "🇱🇷", iso2: "LR"),
        Country(name: "Libya", dialCode: "+218", flag: "🇱🇾", iso2: "LY"),
        Country(name: "Liechtenstein", dialCode: "+423", flag: "🇱🇮", iso2: "LI"),
        Country(name: "Lithuania", dialCode: "+370", flag: "🇱🇹", iso2: "LT"),
        Country(name: "Luxembourg", dialCode: "+352", flag: "🇱🇺", iso2: "LU"),
        Country(name: "Macao", dialCode: "+853", flag: "🇲🇴", iso2: "MO"),
        Country(name: "Madagascar", dialCode: "+261", flag: "🇲🇬", iso2: "MG"),
        Country(name: "Malawi", dialCode: "+265", flag: "🇲🇼", iso2: "MW"),
        Country(name: "Malaysia", dialCode: "+60", flag: "🇲🇾", iso2: "MY"),
        Country(name: "Maldives", dialCode: "+960", flag: "🇲🇻", iso2: "MV"),
        Country(name: "Mali", dialCode: "+223", flag: "🇲🇱", iso2: "ML"),
        Country(name: "Malta", dialCode: "+356", flag: "🇲🇹", iso2: "MT"),
        Country(name: "Marshall Islands", dialCode: "+692", flag: "🇲🇭", iso2: "MH"),
        Country(name: "Mauritania", dialCode: "+222", flag: "🇲🇷", iso2: "MR"),
        Country(name: "Mauritius", dialCode: "+230", flag: "🇲🇺", iso2: "MU"),
        Country(name: "Mexico", dialCode: "+52", flag: "🇲🇽", iso2: "MX"),
        Country(name: "Micronesia", dialCode: "+691", flag: "🇫🇲", iso2: "FM"),
        Country(name: "Moldova", dialCode: "+373", flag: "🇲🇩", iso2: "MD"),
        Country(name: "Monaco", dialCode: "+377", flag: "🇲🇨", iso2: "MC"),
        Country(name: "Mongolia", dialCode: "+976", flag: "🇲🇳", iso2: "MN"),
        Country(name: "Montenegro", dialCode: "+382", flag: "🇲🇪", iso2: "ME"),
        Country(name: "Morocco", dialCode: "+212", flag: "🇲🇦", iso2: "MA"),
        Country(name: "Mozambique", dialCode: "+258", flag: "🇲🇿", iso2: "MZ"),
        Country(name: "Myanmar", dialCode: "+95", flag: "🇲🇲", iso2: "MM"),
        Country(name: "Namibia", dialCode: "+264", flag: "🇳🇦", iso2: "NA"),
        Country(name: "Nauru", dialCode: "+674", flag: "🇳🇷", iso2: "NR"),
        Country(name: "Nepal", dialCode: "+977", flag: "🇳🇵", iso2: "NP"),
        Country(name: "Netherlands", dialCode: "+31", flag: "🇳🇱", iso2: "NL"),
        Country(name: "New Zealand", dialCode: "+64", flag: "🇳🇿", iso2: "NZ"),
        Country(name: "Nicaragua", dialCode: "+505", flag: "🇳🇮", iso2: "NI"),
        Country(name: "Niger", dialCode: "+227", flag: "🇳🇪", iso2: "NE"),
        Country(name: "Nigeria", dialCode: "+234", flag: "🇳🇬", iso2: "NG"),
        Country(name: "North Korea", dialCode: "+850", flag: "🇰🇵", iso2: "KP"),
        Country(name: "North Macedonia", dialCode: "+389", flag: "🇲🇰", iso2: "MK"),
        Country(name: "Norway", dialCode: "+47", flag: "🇳🇴", iso2: "NO"),
        Country(name: "Oman", dialCode: "+968", flag: "🇴🇲", iso2: "OM"),
        Country(name: "Pakistan", dialCode: "+92", flag: "🇵🇰", iso2: "PK"),
        Country(name: "Palau", dialCode: "+680", flag: "🇵🇼", iso2: "PW"),
        Country(name: "Palestine", dialCode: "+970", flag: "🇵🇸", iso2: "PS"),
        Country(name: "Panama", dialCode: "+507", flag: "🇵🇦", iso2: "PA"),
        Country(name: "Papua New Guinea", dialCode: "+675", flag: "🇵🇬", iso2: "PG"),
        Country(name: "Paraguay", dialCode: "+595", flag: "🇵🇾", iso2: "PY"),
        Country(name: "Peru", dialCode: "+51", flag: "🇵🇪", iso2: "PE"),
        Country(name: "Philippines", dialCode: "+63", flag: "🇵🇭", iso2: "PH"),
        Country(name: "Poland", dialCode: "+48", flag: "🇵🇱", iso2: "PL"),
        Country(name: "Portugal", dialCode: "+351", flag: "🇵🇹", iso2: "PT"),
        Country(name: "Qatar", dialCode: "+974", flag: "🇶🇦", iso2: "QA"),
        Country(name: "Romania", dialCode: "+40", flag: "🇷🇴", iso2: "RO"),
        Country(name: "Russia", dialCode: "+7", flag: "🇷🇺", iso2: "RU"),
        Country(name: "Rwanda", dialCode: "+250", flag: "🇷🇼", iso2: "RW"),
        Country(name: "Saint Kitts and Nevis", dialCode: "+1869", flag: "🇰🇳", iso2: "KN"),
        Country(name: "Saint Lucia", dialCode: "+1758", flag: "🇱🇨", iso2: "LC"),
        Country(name: "Saint Vincent and the Grenadines", dialCode: "+1784", flag: "🇻🇨", iso2: "VC"),
        Country(name: "Samoa", dialCode: "+685", flag: "🇼🇸", iso2: "WS"),
        Country(name: "San Marino", dialCode: "+378", flag: "🇸🇲", iso2: "SM"),
        Country(name: "Sao Tome and Principe", dialCode: "+239", flag: "🇸🇹", iso2: "ST"),
        Country(name: "Saudi Arabia", dialCode: "+966", flag: "🇸🇦", iso2: "SA"),
        Country(name: "Senegal", dialCode: "+221", flag: "🇸🇳", iso2: "SN"),
        Country(name: "Serbia", dialCode: "+381", flag: "🇷🇸", iso2: "RS"),
        Country(name: "Seychelles", dialCode: "+248", flag: "🇸🇨", iso2: "SC"),
        Country(name: "Sierra Leone", dialCode: "+232", flag: "🇸🇱", iso2: "SL"),
        Country(name: "Singapore", dialCode: "+65", flag: "🇸🇬", iso2: "SG"),
        Country(name: "Slovakia", dialCode: "+421", flag: "🇸🇰", iso2: "SK"),
        Country(name: "Slovenia", dialCode: "+386", flag: "🇸🇮", iso2: "SI"),
        Country(name: "Solomon Islands", dialCode: "+677", flag: "🇸🇧", iso2: "SB"),
        Country(name: "Somalia", dialCode: "+252", flag: "🇸🇴", iso2: "SO"),
        Country(name: "South Africa", dialCode: "+27", flag: "🇿🇦", iso2: "ZA"),
        Country(name: "South Korea", dialCode: "+82", flag: "🇰🇷", iso2: "KR"),
        Country(name: "South Sudan", dialCode: "+211", flag: "🇸🇸", iso2: "SS"),
        Country(name: "Spain", dialCode: "+34", flag: "🇪🇸", iso2: "ES"),
        Country(name: "Sri Lanka", dialCode: "+94", flag: "🇱🇰", iso2: "LK"),
        Country(name: "Sudan", dialCode: "+249", flag: "🇸🇩", iso2: "SD"),
        Country(name: "Suriname", dialCode: "+597", flag: "🇸🇷", iso2: "SR"),
        Country(name: "Sweden", dialCode: "+46", flag: "🇸🇪", iso2: "SE"),
        Country(name: "Switzerland", dialCode: "+41", flag: "🇨🇭", iso2: "CH"),
        Country(name: "Syria", dialCode: "+963", flag: "🇸🇾", iso2: "SY"),
        Country(name: "Taiwan", dialCode: "+886", flag: "🇹🇼", iso2: "TW"),
        Country(name: "Tajikistan", dialCode: "+992", flag: "🇹🇯", iso2: "TJ"),
        Country(name: "Tanzania", dialCode: "+255", flag: "🇹🇿", iso2: "TZ"),
        Country(name: "Thailand", dialCode: "+66", flag: "🇹🇭", iso2: "TH"),
        Country(name: "Timor-Leste", dialCode: "+670", flag: "🇹🇱", iso2: "TL"),
        Country(name: "Togo", dialCode: "+228", flag: "🇹🇬", iso2: "TG"),
        Country(name: "Tonga", dialCode: "+676", flag: "🇹🇴", iso2: "TO"),
        Country(name: "Trinidad and Tobago", dialCode: "+1868", flag: "🇹🇹", iso2: "TT"),
        Country(name: "Tunisia", dialCode: "+216", flag: "🇹🇳", iso2: "TN"),
        Country(name: "Turkey", dialCode: "+90", flag: "🇹🇷", iso2: "TR"),
        Country(name: "Türkmenistan", dialCode: "+993", flag: "🇹🇲", iso2: "TM"),
        Country(name: "Tuvalu", dialCode: "+688", flag: "🇹🇻", iso2: "TV"),
        Country(name: "Uganda", dialCode: "+256", flag: "🇺🇬", iso2: "UG"),
        Country(name: "Ukraine", dialCode: "+380", flag: "🇺🇦", iso2: "UA"),
        Country(name: "United Arab Emirates", dialCode: "+971", flag: "🇦🇪", iso2: "AE"),
        Country(name: "United Kingdom", dialCode: "+44", flag: "🇬🇧", iso2: "GB"),
        Country(name: "United States", dialCode: "+1", flag: "🇺🇸", iso2: "US"),
        Country(name: "Uruguay", dialCode: "+598", flag: "🇺🇾", iso2: "UY"),
        Country(name: "Uzbekistan", dialCode: "+998", flag: "🇺🇿", iso2: "UZ"),
        Country(name: "Vanuatu", dialCode: "+678", flag: "🇻🇺", iso2: "VU"),
        Country(name: "Vatican City", dialCode: "+379", flag: "🇻🇦", iso2: "VA"),
        Country(name: "Venezuela", dialCode: "+58", flag: "🇻🇪", iso2: "VE"),
        Country(name: "Vietnam", dialCode: "+84", flag: "🇻🇳", iso2: "VN"),
        Country(name: "Yemen", dialCode: "+967", flag: "🇾🇪", iso2: "YE"),
        Country(name: "Zambia", dialCode: "+260", flag: "🇿🇲", iso2: "ZM"),
        Country(name: "Zimbabwe", dialCode: "+263", flag: "🇿🇼", iso2: "ZW")
    ]
}
