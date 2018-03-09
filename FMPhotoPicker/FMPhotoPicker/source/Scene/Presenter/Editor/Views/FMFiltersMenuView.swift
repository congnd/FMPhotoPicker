//
//  FMFiltersMenuView.swift
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

class FMFiltersMenuView: UIView {
    private let collectionView: UICollectionView
    private let image: UIImage
    private var availableFilters: [FMFilterable]
    private var demoImages: [String:UIImage] = [:]
    private var selectedCellIndex: Int = 0
    
    public var didSelectFilter: (FMFilterable) -> Void = { _ in }
    
    
    init(withImage image: UIImage, appliedFilter: FMFilterable?) {
        self.image = image
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 90)
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        availableFilters = FMFilterName.allValues.map { return FMFilter(name: $0) }
        availableFilters.insert(NoEffect(), at: 0)
        
        super.init(frame: .zero)
        
        if let index = self.availableFilters.index(where: { return $0.filterName() == appliedFilter?.filterName() }) {
            self.selectedCellIndex = index
        }
        
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
        
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
    }
    
    func insert(toView parenetView: UIView) {
        parenetView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 90).isActive = true
        rightAnchor.constraint(equalTo: parenetView.rightAnchor).isActive = true
        leftAnchor.constraint(equalTo: parenetView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parenetView.bottomAnchor).isActive = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            collectionView.removeObserver(self, forKeyPath: "contentSize")
            collectionView.scrollToItem(at: IndexPath(row: self.selectedCellIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FMFiltersMenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FMFilterCell.reussId, for: indexPath) as? FMFilterCell
            else { return UICollectionViewCell() }
        
        let filter = availableFilters[indexPath.item]
        if let demo = demoImages[filter.filterName()] {
           cell.imageView.image = demo
        } else {
            let demo = filter.filter(image: image)
            demoImages[filter.filterName()] = demo
            cell.imageView.image = demo
        }
        
        cell.name.text = availableFilters[indexPath.item].filterName()
        if indexPath.item == selectedCellIndex {
            cell.setSelected()
        }
        return cell
    }
    
    
}
extension FMFiltersMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = availableFilters[indexPath.item]
        
        let prevSelectedCellIndex = selectedCellIndex
        
        selectedCellIndex = indexPath.item
        (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? FMFilterCell)?.setSelected()
        
        collectionView.reloadItems(at: [IndexPath(row: prevSelectedCellIndex, section: 0)])
        
        didSelectFilter(filter)
    }
}