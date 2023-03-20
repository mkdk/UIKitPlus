#if !os(macOS)
import Foundation
import UIKit

extension UICollectionView {
    @discardableResult
    func register(
        _ viewClass: Supplementable.Type,
        _ kind: String
    ) -> Self {
        register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewClass.reuseIdentifier)
        return self
    }

    func dequeueReusableSupplementaryView<T: Supplementable>(
        _ viewClass: T.Type,
        ofKind elementKind: String,
        for indexPath: IndexPath
    ) -> T {
        dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: viewClass.reuseIdentifier,
            for: indexPath
        ) as! T
    }

    @discardableResult
    public func register(_ cellClass: Cellable.Type...) -> Self {
        cellClass.forEach { register($0, forCellWithReuseIdentifier: $0.reuseIdentifier) }
        return self
    }
    
    public func dequeueReusableCell<T: Cellable>(with class: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: `class`.reuseIdentifier, for: indexPath) as! T
    }
}
#endif
