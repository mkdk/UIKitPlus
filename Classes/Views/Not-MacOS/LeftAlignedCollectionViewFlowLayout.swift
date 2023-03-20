//
//  Created by Антон Лобанов on 23.09.2021.
//

#if !os(macOS)
import UIKit

public final class LeftAlignedCollectionViewFlowLayout: UCollectionViewFlowLayout {
	public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let collectionView = self.collectionView,
			  let superArray = super.layoutAttributesForElements(in: rect),
			  let attributes = NSArray(array: superArray, copyItems: true) as? [UICollectionViewLayoutAttributes]
		else {
			return nil
		}

		let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout

		var leftMargin = sectionInset.left
		var maxY: CGFloat = -1.0

		attributes.forEach { layoutAttribute in
			guard layoutAttribute.representedElementCategory == .cell,
				  layoutAttribute.indexPath.section == 0 else { return }

			if layoutAttribute.frame.origin.y >= maxY {
				leftMargin = sectionInset.left
			}

			layoutAttribute.frame.origin.x = leftMargin

			let interItemSpacing = delegate?.collectionView?(
				collectionView,
				layout: self,
				minimumInteritemSpacingForSectionAt: 0
			) ?? self.minimumInteritemSpacing

			leftMargin += layoutAttribute.frame.width + interItemSpacing

			maxY = max(layoutAttribute.frame.maxY, maxY)
		}

		return attributes
	}
}


#endif
