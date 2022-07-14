import Foundation

struct Service: Codable {
    let name: String?
    let description: String?
    let link: String?
    let icon_url: String?
    
    var getUrlOfLink: URL? {
        URL(string: link ?? "")
    }
    
    var getUrlOfImage: URL? {
        URL(string: icon_url ?? "")
    }
    
    var unwrappedName: String {
        name ?? "Неизвестное имя"
    }
    
    var unwrappedDescription: String {
        description ?? "Описание отсутсвует"
    }
}

struct Response: Codable {
    var body: Services
    
    struct Services: Codable {
        var services = [Service]()
    }
}
