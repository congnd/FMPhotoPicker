//
//  FMFiltersListView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit


class NoEffect: FMFilterable {
    func filter(image: UIImage) -> UIImage {
        return image
    }
    
    func filterName() -> String {
        return "Original"
    }
}

class FMFiltersListView: UIView {
    private let collectionView: UICollectionView
    private let image: UIImage
    private var filters: [FMFilterable]
    private var demoImages: [String:UIImage] = [:]
    private var selectedCellIndex: Int = 0
    
    public var didSelectFilter: (FMFilterable) -> Void = { _ in }
    
    
    init(withImage image: UIImage) {
        self.image = image
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 90)
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        filters = FMFilterName.allValues.map { return FMFilter(name: $0) }
        filters.insert(NoEffect(), at: 0)
        
        super.init(frame: .zero)
        
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        collectionView.register(FMFilterCell.classForCoder(), forCellWithReuseIdentifier: FMFilterCell.reussId)
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FMFiltersListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FMFilterCell.reussId, for: indexPath) as? FMFilterCell
            else { return UICollectionViewCell() }
        
        let filter = filters[indexPath.item]
        if let demo = demoImages[filter.filterName()] {
           cell.imageView.image = demo
        } else {
            let demo = filter.filter(image: image)
            demoImages[filter.filterName()] = demo
            cell.imageView.image = demo
        }
        
        cell.name.text = filters[indexPath.item].filterName()
        if indexPath.item == selectedCellIndex {
            cell.setSelected()
        }
        return cell
    }
    
    
}
extension FMFiltersListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = filters[indexPath.item]
        didSelectFilter(filter)
        
        (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? FMFilterCell)?.setDeselected()
        
        selectedCellIndex = indexPath.item
        (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? FMFilterCell)?.setSelected()
    }
}
