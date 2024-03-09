import SwiftUI

/// Картинка с возможностью кэширования
public struct CachedAsyncImage991<Content: View, Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let transition: AnyTransition
    private let placeholder: () -> Placeholder
    private let content: (UIImage) -> Content
    
    /// Инициализатор
    /// - Parameters:
    ///   - url: Ссылка на картинку
    ///   - transition: Переход из одного состояния в другое, по умолчанию `.opacity.combined(with: .scale)`
    ///   - content: Замыкание с готовой картинкой в формате `UIImage`
    ///   - placeholder: Замыкание для настройки вьюхи на случай отсутствия картинки (загрузка/ошибка)
    public init(
        url: URL?,
        transition: AnyTransition = .opacity.combined(with: .scale),
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.transition = transition
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: .init(url: url))
    }

    public var body: some View {
        ZStack {
            if let uiImage = loader.state?.uiImage {
                content(uiImage)
                    .transition(transition)
            } else {
                placeholder()
            }
        }
        .animation(.easeInOut, value: loader.state)
        .task { await loader.load() }
    }
}
