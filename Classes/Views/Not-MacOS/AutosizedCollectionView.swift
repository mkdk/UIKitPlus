//
//  Created by Антон Лобанов on 23.09.2021.
//

#if !os(macOS)
import UIKit

public final class AutosizedCollectionView: UCollectionView {
	public override func reloadData() {
		super.reloadData()
		self.invalidateIntrinsicContentSize()
	}

	public override var intrinsicContentSize: CGSize {
		let s = self.collectionViewLayout.collectionViewContentSize
		return CGSize(width: max(s.width, 1), height: max(s.height,1))
	}
}

#endif
