//
//  Extensions.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/08/29.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import UIKit

extension NSObject {
    @nonobjc static var className: String {
        String(describing: self)
    }

    var className: String {
        type(of: self).className
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellType: T.Type) {
        let className = cellType.className
        register(cellType, forCellWithReuseIdentifier: className)
    }

    func register<T: UICollectionViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }

    func registerNib<T: UICollectionViewCell>(cellType: T.Type) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: className)
    }

    func registerNib<T: UICollectionViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { registerNib(cellType: $0) }
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as? T else {
            return T()
        }
        return cell
    }

    func dequeueReusableView<T: UICollectionReusableView>(for indexPath: IndexPath, of kind: String = UICollectionView.elementKindSectionHeader) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.className, for: indexPath) as? T else {
            return T()
        }
        return view
    }

    public func scrollToTop(animated: Bool = true) {
        setContentOffset(CGPoint.zero, animated: animated)
    }
}

extension UIView {
    // 角丸にする
    func allMaskCorner() {
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
    }
}
