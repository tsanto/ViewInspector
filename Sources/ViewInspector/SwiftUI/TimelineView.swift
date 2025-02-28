import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TimelineView: KnownViewType {
        public static var typePrefix: String = "TimelineView"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func timelineView() throws -> InspectableView<ViewType.TimelineView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func timelineView(_ index: Int) throws -> InspectableView<ViewType.TimelineView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TimelineView: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return .empty }
        return .init(count: 1) { _ in
            return try view(for: .init(), parent: parent)
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    fileprivate static func view(for context: ViewType.TimelineView.Context, parent: UnwrappedView
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        let provider = try Inspector.cast(value: parent.content.view, type: ElementViewProvider.self)
        let view = try provider.view(context)
        let medium = parent.content.medium.resettingViewModifiers()
        let content = try Inspector.unwrap(content: Content(view, medium: medium))
        return try InspectableView<ViewType.ClassifiedView>(
            content, parent: parent, call: "contentView()")
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View == ViewType.TimelineView {
    
    func contentView(_ context: ViewType.TimelineView.Context = .init()
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        return try ViewType.TimelineView.view(for: context, parent: self)
    }
}

// MARK: -

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension ViewType.TimelineView {
    struct Context {
        public enum Cadence {
            case live, seconds, minutes
        }
        public let date: Date
        public let cadence: Cadence
        
        public init(date: Date = Date(), cadence: Cadence = .live) {
            self.date = date
            self.cadence = cadence
        }
        
        fileprivate var context32: Context32 { Context32(context: self) }
    }
    fileprivate struct Context32 {
        private let date: Date
        private let cadence: Context.Cadence
        private let filler: (Int64, Int64) = (0, 0)
        
        init(context: Context) {
            self.date = context.date
            self.cadence = context.cadence
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension TimelineView: ElementViewProvider {
    func view(_ element: Any) throws -> Any {
        typealias Builder = (Context) -> Content
        let builder = try Inspector.attribute(
            label: "content", value: self, type: Builder.self)
        let param = try Inspector.cast(
            value: element, type: ViewType.TimelineView.Context.self)
        let context = try Self.adapt(context: param)
        return builder(context)
    }
    
    static func adapt(context: ViewType.TimelineView.Context) throws -> Context {
        switch MemoryLayout<Context>.size {
        case 9:
            return try Inspector.unsafeMemoryRebind(value: context, type: Context.self)
        case 32:
            return try Inspector.unsafeMemoryRebind(value: context.context32, type: Context.self)
        default:
            fatalError(MemoryLayout<Context>.actualSize())
        }
    }
}
