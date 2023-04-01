import SwiftUI
import CachedAsyncImage991

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        List {
            ForEach(viewModel.images) { model in
                HStack(spacing: 16) {
                    CachedAsyncImage991(url: model.url) { image in
                        Image(uiImage: image)
                            .resizable()
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    Text(model.title)
                }
            }
        }
        .task { await viewModel.getImages() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
