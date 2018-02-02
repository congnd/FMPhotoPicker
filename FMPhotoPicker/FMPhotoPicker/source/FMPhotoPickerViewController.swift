//
//  FMPhotoPickerViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/23.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import Photos

public protocol FMPhotoPickerViewControllerDelegate: class {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage])
}

public class FMPhotoPickerViewController: UIViewController {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var numberOfSelectedPhotoContainer: UIView!
    @IBOutlet weak var numberOfSelectedPhoto: UILabel!
    
    @IBOutlet weak var controlbarConstraintTop: NSLayoutConstraint!
    
    lazy var photoAssets = [FMPhotoAsset]()
    private var selectedPhotoIndexes = [Int]()
    
    private let defaultSize = CGSize(width: 1000, height: 2000)
    private var selectedCell: FMPhotoPickerImageCollectionViewCell?
    
    public weak var delegate: FMPhotoPickerViewControllerDelegate? = nil
    
    internal lazy var fetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    override public func loadView() {
        if let view = UINib(nibName: "FMPhotoPickerViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    // MARK: - Life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchPhotos()
    }
    
    // MARK: - Setup View
    private func setupView() {
        let reuseCellNib = UINib(nibName: "FMPhotoPickerImageCollectionViewCell", bundle: Bundle(for: self.classForCoder))
        self.imageCollectionView.register(reuseCellNib, forCellWithReuseIdentifier: "FMPhotoPickerImageCollectionViewCell")
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.delegate = self
        
        self.numberOfSelectedPhotoContainer.layer.cornerRadius = self.numberOfSelectedPhotoContainer.frame.size.width / 2
        self.numberOfSelectedPhotoContainer.isHidden = true
    }
    
    // MARK: - Target Actions
    @IBAction func onTapDismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onTapNextStep(_ sender: Any) {
        var result = [UIImage]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let multiTask = DispatchGroup()
            self.selectedPhotoIndexes.forEach() {
                multiTask.enter()
                _ = Helper.getPhoto(by: self.photoAssets[$0].asset, in: self.defaultSize) { image in
                    guard let image = image else { return }
                    result.append(image)
                    multiTask.leave()
                }
            }
            
            multiTask.wait()
            
            DispatchQueue.main.async {
                self.delegate?.fmPhotoPickerController(self, didFinishPickingPhotoWith: result)
            }
        }
    }
    
    // MARK: - Logic
    private func fetchPhotos() {
        Helper.attemptRequestPhotoLibAccess(dialogPresenter: self, ok: { [weak self] in
            let fetchResult = PHAsset.fetchAssets(with: self?.fetchOptions)
            
            guard self != nil, fetchResult.count > 0 else { return }
            
            fetchResult.enumerateObjects() { asset, index, _ in
                self!.photoAssets.append(FMPhotoAsset(asset: asset, key: "\(index)"))
            }
            self!.imageCollectionView.reloadData()
        })
    }
}

//extension FMPhotoPickerViewController: UIGestureRecognizerDelegate {
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}

extension FMPhotoPickerViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoAssets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FMPhotoPickerImageCollectionViewCell.reuseId, for: indexPath) as! FMPhotoPickerImageCollectionViewCell
        let photoAsset = photoAssets[indexPath.item]
        let selectedIndex = self.selectedPhotoIndexes.index(of: indexPath.item)
        cell.loadView(photoAsset: photoAsset, selectedIndex: selectedIndex)
        cell.onTapSelect = {
            if let selectedIndex = self.selectedPhotoIndexes.index(where: { $0 == indexPath.item }) {
                self.selectedPhotoIndexes.remove(at: selectedIndex)
                cell.performSelectionAnimation(selectedIndex: nil)
                self.reloadAffectedCellByChangingSelection(changedIndex: selectedIndex)
            } else {
                self.selectedPhotoIndexes.append(indexPath.item)
                cell.performSelectionAnimation(selectedIndex: self.selectedPhotoIndexes.count - 1)
            }
            self.updateControlBar()
        }
        
        return cell
    }
    
    private func updateControlBar() {
        if selectedPhotoIndexes.count > 0 {
            self.numberOfSelectedPhotoContainer.isHidden = false
            self.numberOfSelectedPhoto.text = "\(self.selectedPhotoIndexes.count)"
        } else {
            self.numberOfSelectedPhotoContainer.isHidden = true
        }
    }
    
    private func reloadAffectedCellByChangingSelection(changedIndex: Int) {
        let affectedList = self.selectedPhotoIndexes[changedIndex...]
        affectedList.forEach {
            guard let cell = self.imageCollectionView.cellForItem(at: IndexPath(row: $0, section: 0)) as? FMPhotoPickerImageCollectionViewCell else { return }
            cell.performSelectionAnimation(selectedIndex: self.selectedPhotoIndexes.index(of: $0))
        }
    }
}

extension FMPhotoPickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FMPhotoPickerImageCollectionViewCell else { return }
        self.selectedCell = cell
        let vc = FMPhotoPresenterViewController(photos: self.photoAssets, initialPhotoIndex: indexPath.item)
        vc.transitioningDelegate = self
        self.present(vc, animated: true)
    }
}

extension FMPhotoPickerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let cell = self.selectedCell else { return nil }
        return FMZoomInAnimationController(originFrame: cell.convert(cell.bounds, to: self.view))
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let cell = self.selectedCell else { return nil }
        return FMZoomOutAnimationController(destinationFrame: cell.convert(cell.bounds, to: self.view))
    }
}
