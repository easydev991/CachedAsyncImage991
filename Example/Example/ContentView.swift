import SwiftUI
import CachedAsyncImage991

struct Product: Decodable, Identifiable {
    let id: Int
    let title: String
    let images: [String]
}

struct ProductsResponse: Decodable {
    let products: [Product]
}

struct Model: Identifiable, Decodable {
    var id = UUID().uuidString
    let url: String
}

struct ContentView: View {
    @State private var images = [Model]()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(images) { model in
                    CachedAsyncImage991(stringURL: model.url) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(height: 150)
            }
        }
        .task { await fetchProductImages() }
    }
    
    func fetchProductImages() async {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: .init(url: url))
            let productsResponse = try JSONDecoder().decode(ProductsResponse.self, from: data)
            let allImages = productsResponse.products.flatMap { $0.images }
            self.images = allImages.map { .init(url: $0) }
        } catch {
            print("Ошибка: \(error.localizedDescription)")
        }
    }
}

#Preview { ContentView() }
