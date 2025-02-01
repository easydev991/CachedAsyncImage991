import SwiftUI
import OSLog

/// Картинка с возможностью кэширования
public struct CachedAsyncImage991<Content: View, Placeholder: View>: View {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CachedAsyncImage991",
        category: "View"
    )
    private let loader: ImageLoaderProtocol = ImageLoader()
    private let transition: AnyTransition
    private let placeholder: Placeholder
    private let content: (UIImage) -> Content
    private let url: URL?
    @State private var currentState: CurrentState?
    
    /// Инициализатор с `URL`
    /// - Parameters:
    ///   - url: Ссылка на картинку в формате `URL`
    ///   - transition: Переход из одного состояния в другое, по умолчанию `.opacity.combined(with: .scale)`
    ///   - content: Замыкание с готовой картинкой в формате `UIImage`
    ///   - placeholder: Замыкание для настройки вьюхи на случай отсутствия картинки (загрузка/ошибка)
    public init(
        url: URL?,
        transition: AnyTransition = .opacity.combined(with: .scale),
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: () -> Placeholder = { ProgressView() }
    ) {
        self.url = url
        self.transition = transition
        self.content = content
        self.placeholder = placeholder()
    }
    
    /// Инициализатор со строкой
    /// - Parameters:
    ///   - stringURL: Ссылка на картинку в формате `String`
    ///   - transition: Переход из одного состояния в другое, по умолчанию `.opacity.combined(with: .scale)`
    ///   - content: Замыкание с готовой картинкой в формате `UIImage`
    ///   - placeholder: Замыкание для настройки вьюхи на случай отсутствия картинки (загрузка/ошибка)
    public init(
        stringURL url: String?,
        transition: AnyTransition = .opacity.combined(with: .scale),
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: () -> Placeholder = { ProgressView() }
    ) {
        self.url = if let url { URL(string: url) } else { nil }
        self.transition = transition
        self.content = content
        self.placeholder = placeholder()
    }

    public var body: some View {
        ZStack {
            if let currentImage {
                content(currentImage)
                    .transition(transition)
            } else {
                placeholder
            }
        }
        .animation(.easeInOut, value: currentState)
        .task { await getImage() }
    }
    
    private var currentImage: UIImage? {
        if let cached = loader.getCachedImage(for: url) {
            cached
        } else {
            currentState?.uiImage
        }
    }
    
    private func getImage() async {
        guard currentImage == nil else {
            return
        }
        guard currentState != .loading else {
            return
        }
        currentState = .loading
        do {
            let image = try await loader.loadImage(for: url)
            currentState = .ready(image)
        } catch {
            logger.error("\(error.localizedDescription)")
            currentState = .error
        }
    }
    
    enum CurrentState: Equatable {
        case loading
        case ready(UIImage)
        case error
        var uiImage: UIImage? {
            if case let .ready(uiImage) = self { uiImage } else { nil }
        }
    }
}
