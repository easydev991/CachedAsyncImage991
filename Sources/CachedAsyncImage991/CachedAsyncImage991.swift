import SwiftUI
import OSLog

/// Картинка с возможностью кэширования
public struct CachedAsyncImage991<Content: View, Placeholder: View>: View {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CachedAsyncImage991",
        category: "ImageLoader"
    )
    private let cache = ImageCacheService.shared
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
            if let uiImage {
                content(uiImage)
                    .transition(transition)
            } else {
                placeholder
            }
        }
        .animation(.easeInOut, value: currentState)
        .task { await getImage() }
    }
    
    private var uiImage: UIImage? {
        if let url, let cachedImage = cache[url] {
            cachedImage
        } else if let uiImage = currentState?.uiImage {
            uiImage
        } else {
            nil
        }
    }
    
    private func getImage() async {
        guard let url else {
            logger.debug("Пропускаем загрузку, потому что нет ссылки")
            return
        }
        guard uiImage == nil else {
            logger.debug("Пропускаем загрузку, потому что картинка уже есть")
            return
        }
        if let image = cache[url], currentState?.uiImage != image {
            logger.debug("Используем картинку из кэша по URL: \(url, privacy: .public)")
            currentState = .ready(image)
            return
        }
        currentState = .loading
        logger.debug("Загружаем картинку по URL: \(url, privacy: .public)")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                cache[url] = loadedImage
                currentState = .ready(loadedImage)
                logger.debug("Успешно загрузили по URL: \(url, privacy: .public)")
            } else {
                logger.error("Не удалось создать картинку из Data")
                currentState = .error
            }
        } catch {
            let errorCode = (error as NSError).code
            if errorCode == -999 {
                logger.debug("Отменяем загрузку по URL: \(url, privacy: .public)")
            } else {
                logger.error(
                    """
                    Не удалось загрузить по URL: \(url, privacy: .public)
                    Ошибка: \(error.localizedDescription, privacy: .public)
                    Код: \(errorCode, privacy: .public)
                    """
                )
            }
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
