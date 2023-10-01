import SwiftUI
import CachedAsyncImage991

struct Model: Identifiable, Codable {
    let id: Int
    let url: String
    var finalURL: URL? { .init(string: url) }
}

struct ContentView: View {
    @State private var images = [Model]()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(images) { model in
                    CachedAsyncImage991(url: model.finalURL) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                }
                .frame(height: 150)
            }
        }
        .task { await getImages() }
    }

    private func getImages() async {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos"),
              let (data, _) = try? await URLSession.shared.data(for: .init(url: url)),
              let decodedArray = try? JSONDecoder().decode([Model].self, from: data)
        else { return }
        images = decodedArray
    }
}

#Preview { ContentView() }
