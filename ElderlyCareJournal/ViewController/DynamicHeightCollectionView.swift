//
//  DynamicHeightCollectionView.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-10.
//

import UIKit

class DynamicHeightCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }

}
