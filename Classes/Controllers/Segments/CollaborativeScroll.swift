//
//  Created by Антон Лобанов on 20.02.2021.
//

import UIKit

public protocol CollaborativeScroll: UIScrollView, UIGestureRecognizerDelegate {}

open class CollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate, CollaborativeScroll
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}

open class CollaborativeCollectionView: UICollectionView, UIGestureRecognizerDelegate, CollaborativeScroll
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}

open class CollaborativeTableView: UITableView, UIGestureRecognizerDelegate, CollaborativeScroll
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer.view is UIScrollView
    }
}
