import Foundation

final class ContentViewModel: ObservableObject {
    @Published var images = [ImageModel]()

    @MainActor
    func getImages() async {
        guard images.isEmpty else { return }
        if let url = URL(string: "https://jsonplaceholder.typicode.com/photos"),
           let (data, _) = try? await URLSession.shared.data(for: .init(url: url)),
           let decodedArray = try? JSONDecoder().decode([ImageModel].self, from: data) {
            images = decodedArray
        }
    }
}

extension ContentViewModel {
    struct ImageModel: Identifiable, Codable {
        let id: Int
        let title, stringURL: String

        var url: URL? { .init(string: stringURL) }

        enum CodingKeys: String, CodingKey {
            case id, title
            case stringURL = "url"
        }
    }
}
