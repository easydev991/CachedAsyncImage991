import SwiftUI

/// Картинка с возможностью кэширования
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let transition: AnyTransition
    private let placeholder: () -> Placeholder
    private let content: (UIImage) -> Content

    public init(
        url: URL?,
        transition: AnyTransition = .opacity.combined(with: .scale),
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.transition = transition
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: .init(url: url, cache: Environment(\.imageCache).wrappedValue))
    }

    public var body: some View {
        ZStack {
            if let result = loader.image {
                content(result)
                    .transition(transition)
            } else {
                placeholder()
            }
        }
        .animation(.easeInOut, value: loader.isLoading)
        .task { await loader.load() }
    }
}
