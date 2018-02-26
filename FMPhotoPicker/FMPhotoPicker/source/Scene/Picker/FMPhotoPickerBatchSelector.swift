//
//  FMPhotoPickerBatchSelector.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/07.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import UIKit

enum SelectionTrending {
    case set
    case unset
    
    func reverse() -> SelectionTrending {
        if self == .set {
            return .unset
        }
        return .set
    }
}

struct PanSelection {
    // The index path of the cell that was panned over
    var indexPath: IndexPath
    
    // The selection state before changed
    var originalSelection: Bool
}

class FMPhotoPickerBatchSelector: NSObject {
    private unowned let viewController: FMPhotoPickerViewController
    private let collectionView: UICollectionView
    private let dataSource: FMPhotosDataSource
    
    // an index path of cell that be tapped by pan began event
    private var indexPathOfBeganTap: IndexPath?
    
    // an index pathh of previous cell when user's finger move to an other cell
    private var prevIndexPath: IndexPath?
    
    // reverse of the first tapped cell selection status
    private var selectionTrending: SelectionTrending = .set
    
    // the list of affected cell index path
    private var panSelections = [PanSelection]()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(sender:)))
        return pan
    }()
    
    init(viewController: FMPhotoPickerViewController, collectionView: UICollectionView, dataSource: FMPhotosDataSource) {
        self.viewController = viewController
        self.collectionView = collectionView
        self.dataSource = dataSource
        super.init()
    }
    
    public func enable() {
        self.viewController.view.addGestureRecognizer(self.panGesture)
    }
    
    
    @objc private func panGestureHandler(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.indexPathOfBeganTap = self.cellIndexPathForPan(pan: sender)
            self.prevIndexPath = indexPathOfBeganTap
            
            if let cellIndexPathOfBeganTap = self.indexPathOfBeganTap {
                let selectedIndex = self.dataSource.selectedIndexOfPhoto(atIndex: cellIndexPathOfBeganTap.item)
                
                if let selectedIndex = selectedIndex {
                    self.selectionTrending = .unset
                    self.dataSource.unsetSeclectedForPhoto(atIndex: cellIndexPathOfBeganTap.item)
                    self.viewController.reloadAffectedCellByChangingSelection(changedIndex: selectedIndex)
                    self.viewController.updateControlBar()
                } else {
                    self.selectionTrending = .set
                    self.viewController.tryToAddPhotoToSelectedList(photoIndex: cellIndexPathOfBeganTap.item)
                }
                self.collectionView.reloadItems(at: [cellIndexPathOfBeganTap])
            }
        } else if sender.state == .ended {
            self.indexPathOfBeganTap = nil
            self.prevIndexPath = nil
            self.panSelections.removeAll()
        } else {
            self.processPanEvent(pan: sender)
        }
    }
    
    private func processPanEvent(pan: UIPanGestureRecognizer) {
        guard let indexPathOfBeganTap  = self.indexPathOfBeganTap,
            let currentIndexPath = self.cellIndexPathForPan(pan: pan),
            let prevIndexPath = self.prevIndexPath,
            prevIndexPath != currentIndexPath
            else { return }
        
        var panSelectionsTobeChanged = [PanSelection]()
        var panSelectionsTobeReset = [PanSelection]()
        
        if currentIndexPath.item >= indexPathOfBeganTap.item {
            if currentIndexPath.item > prevIndexPath.item {
                if prevIndexPath.item > indexPathOfBeganTap.item {
                    panSelectionsTobeChanged = self.createPanSelectionRange(fromIndex: prevIndexPath.item + 1, toIndex: currentIndexPath.item)
                } else {
                    panSelectionsTobeChanged = self.createPanSelectionRange(fromIndex: indexPathOfBeganTap.item + 1, toIndex: currentIndexPath.item)
                    panSelectionsTobeReset = self.getPanSelectionsTobeResetFromPrevSection(fromIndex: prevIndexPath.item, toIndex: indexPathOfBeganTap.item - 1)
                }
            } else {
                panSelectionsTobeReset = self.getPanSelectionsTobeResetFromPrevSection(fromIndex: currentIndexPath.item + 1, toIndex: prevIndexPath.item)
            }
        } else {
            if currentIndexPath.item < prevIndexPath.item {
                if prevIndexPath.item > indexPathOfBeganTap.item {
                    panSelectionsTobeChanged = self.createPanSelectionRange(fromIndex: currentIndexPath.item, toIndex: indexPathOfBeganTap.item - 1)
                    panSelectionsTobeReset = self.getPanSelectionsTobeResetFromPrevSection(fromIndex: indexPathOfBeganTap.item + 1, toIndex: prevIndexPath.item)
                } else {
                    panSelectionsTobeChanged = self.createPanSelectionRange(fromIndex: currentIndexPath.item, toIndex: prevIndexPath.item - 1)
                }
            } else {
                panSelectionsTobeReset = self.getPanSelectionsTobeResetFromPrevSection(fromIndex: prevIndexPath.item, toIndex: currentIndexPath.item - 1)
            }
        }
        
        self.resetSelectionState(of: panSelectionsTobeReset)
        self.reloadCells(in: panSelectionsTobeReset)
        self.removeFromPrevSection(panSelectionsTobeReset: panSelectionsTobeReset)
        
        
        self.changeSelectionState(of: panSelectionsTobeChanged, by: self.selectionTrending)
        self.reloadCells(in: panSelectionsTobeChanged)
        self.panSelections.append(contentsOf: panSelectionsTobeChanged)
        
        // Reload all selected photocells
        // In fact, we do NOT need to reload all selected photocells
        // But in most cases, the cost to find all the affected cells by current changing selection is higher than the cost to refresh all
        self.viewController.reloadAffectedCellByChangingSelection(changedIndex: 0)
        
        self.viewController.updateControlBar()
        
        self.prevIndexPath = currentIndexPath
    }
    
    
    /**
     Change selection status of all Photo in dataSource that are listed in panSelections by SelectionTrending
     */
    private func changeSelectionState(of panSelections: [PanSelection], by trend: SelectionTrending) {
        panSelections.forEach { panSelection in
            if trend == .set {
                self.viewController.tryToAddPhotoToSelectedList(photoIndex: panSelection.indexPath.item)
            } else {
                self.dataSource.unsetSeclectedForPhoto(atIndex: panSelection.indexPath.item)
            }
        }
    }
    
    private func resetSelectionState(of panSelections: [PanSelection]) {
        panSelections.forEach { panSelection in
            if panSelection.originalSelection {
                self.dataSource.setSeletedForPhoto(atIndex: panSelection.indexPath.item)
            } else {
                self.dataSource.unsetSeclectedForPhoto(atIndex: panSelection.indexPath.item)
            }
        }
    }
    
    /**
     Reload all affected cells
     */
    private func reloadCells(in panSelections: [PanSelection]) {
        var indexPaths = [IndexPath]()
        panSelections.forEach { indexPaths.append($0.indexPath) }
        self.collectionView.reloadItems(at: indexPaths)
    }
    
    /**
     Return PanSelections that need to be reset
     */
    private func getPanSelectionsTobeResetFromPrevSection(fromIndex: Int, toIndex: Int) -> [PanSelection] {
        if toIndex < fromIndex { return [] }
        
        var result = [PanSelection]()
        for index in fromIndex...toIndex {
            let found = self.panSelections.index(where: { $0.indexPath.item == index })
            if let found = found {
                result.append(self.panSelections[found])
            }
        }
        return result
    }
    
    /**
     Remove all element of PanSelections from previous affected cells
     */
    private func removeFromPrevSection(panSelectionsTobeReset: [PanSelection]) {
        panSelectionsTobeReset.forEach { panSelection in
            if let found = self.panSelections.index(where: { $0.indexPath == panSelection.indexPath }) {
                self.panSelections.remove(at: found)
            }
        }
    }
    
    
    /**
     Create a new affected index path range
     */
    private func createPanSelectionRange(fromIndex: Int, toIndex: Int) -> [PanSelection] {
        if toIndex < fromIndex { return [] }
        
        var result = [PanSelection]()
        for index in fromIndex...toIndex {
            let indexPath = IndexPath(row: index, section: 0)
            let selection = self.dataSource.selectedIndexOfPhoto(atIndex: index) == nil ? false : true
            result.append(PanSelection(indexPath: indexPath, originalSelection: selection))
        }
        return result
    }
    
    private func cellIndexPathForPan(pan: UIPanGestureRecognizer) -> IndexPath? {
        return self.collectionView.indexPathForItem(at: pan.location(in: self.collectionView))
    }
}
