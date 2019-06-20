//
//  FMFiltersMenuView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMFiltersMenuView: UIView {
    private let collectionView: UICollectionView
    private var availableFilters: [FMFilterable]
    private var demoImages: [String:UIImage] = [:]
    private var selectedCellIndex: Int = 0
    private var isObservingCollectionView = true
    
    public var didSelectFilter: (FMFilterable) -> Void = { _ in }
    
    public var image: UIImage {
        didSet {
            demoImages.removeAll()
            collectionView.reloadData()
        }
    }
    
    init(withImage image: UIImage, appliedFilter: FMFilterable?, availableFilters: [FMFilterable]) {
        self.image = image
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 64)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.availableFilters = availableFilters.count == 0 ? kDefaultAvailableFilters : availableFilters
        
        super.init(frame: .zero)
        
        if let index = self.availableFilters.firstIndex(where: { return $0.filterName() == appliedFilter?.filterName() }) {
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
        collectionView.contentInset = UIEdgeInsets(top: 0,left: 14,bottom: 0,right: 14)
        
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        isObservingCollectionView = true
        
        self.backgroundColor = .clear
        collectionView.backgroundColor = .clear
    }
    
    func insert(toView parenetView: UIView) {
        parenetView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        rightAnchor.constraint(equalTo: parenetView.rightAnchor).isActive = true
        leftAnchor.constraint(equalTo: parenetView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parenetView.bottomAnchor).isActive = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            collectionView.removeObserver(self, forKeyPath: "contentSize")
            isObservingCollectionView = false
            
            collectionView.scrollToItem(at: IndexPath(row: self.selectedCellIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if isObservingCollectionView {
            print("FM-Warning: Deinit instance of FMFiltersMenuView before removing observer. Trying to remove running observer...")
            collectionView.removeObserver(self, forKeyPath: "contentSize")
            print("FM-OK: Running observer has been removed.")
        }
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
