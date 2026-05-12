//
//  Profile.swift
import Foundation

struct Profile {
    var name: String
    let phone: String
    var password: String
    /// Yerel dosya (`file://…`) veya uzaktan avatar adresi. `nil` ise baş harfler kullanılır.
    var imageURL: String?
    /// Kullanıcının bağlı olduğu departman kimlikleri; `User.departmentIds` ile uyumlu — ayarlar ekranı yeniden çekmeden rozet çizer.
    var departmentIds: [String] = []
}
