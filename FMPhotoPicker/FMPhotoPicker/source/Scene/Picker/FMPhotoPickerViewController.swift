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
    
    private lazy var batchSelector: FMPhotoPickerBatchSelector = {
        return FMPhotoPickerBatchSelector(viewController: self, collectionView: self.imageCollectionView, dataSource: self.dataSource)
    }()
    
    private var dataSource: FMPhotosDataSource! {
        didSet {
            self.batchSelector.enable()
        }
    }
    
    public weak var delegate: FMPhotoPickerViewControllerDelegate? = nil
    
    private var presentedPhotoIndex: Int?
    
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
        if self.dataSource == nil {
            self.fetchPhotos()
        } else {
            self.imageCollectionView.reloadData()
            self.updateControlBar()
        }
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
//        var result = [UIImage]()
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            let multiTask = DispatchGroup()
//            self.selectedPhotoIndexes.forEach() {
//                multiTask.enter()
//                _ = Helper.getPhoto(by: self.photoAssets[$0].asset, in: self.defaultSize) { image in
//                    guard let image = image else { return }
//                    result.append(image)
//                    multiTask.leave()
//                }
//            }
//
//            multiTask.wait()
//
//            DispatchQueue.main.async {
//                self.delegate?.fmPhotoPickerController(self, didFinishPickingPhotoWith: result)
//            }
//        }
    }
    
    // MARK: - Logic
    private func fetchPhotos() {
        Helper.attemptRequestPhotoLibAccess(dialogPresenter: self, ok: { [weak self] in
            let fetchResult = PHAsset.fetchAssets(with: self?.fetchOptions)
            
            guard let strongSelf = self, fetchResult.count > 0 else { return }
            var photoAssets = [FMPhotoAsset]()
            fetchResult.enumerateObjects() { asset, index, _ in
                photoAssets.append(FMPhotoAsset(asset: asset, key: "\(index)"))
            }
            strongSelf.dataSource = FMPhotosDataSource(photoAssets: photoAssets)
            
            self!.imageCollectionView.reloadData()
        })
    }
}

extension FMPhotoPickerViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let total = self.dataSource?.numberOfPhotos {
            return total
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FMPhotoPickerImageCollectionViewCell.reuseId, for: indexPath) as? FMPhotoPickerImageCollectionViewCell,
            let photoAsset = self.dataSource.photo(atIndex: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.loadView(photoAsset: photoAsset, selectedIndex: self.dataSource.selectedIndexOfPhoto(atIndex: indexPath.item))
        cell.onTapSelect = {
            if let selectedIndex = self.dataSource.selectedIndexOfPhoto(atIndex: indexPath.item) {
                self.dataSource.unsetSeclectedForPhoto(atIndex: indexPath.item)
                cell.performSelectionAnimation(selectedIndex: nil)
                self.reloadAffectedCellByChangingSelection(changedIndex: selectedIndex)
            } else {
                self.dataSource.setSeletedForPhoto(atIndex: indexPath.item)
                cell.performSelectionAnimation(selectedIndex: self.dataSource.numberOfSelectedPhoto() - 1)
            }
            self.updateControlBar()
        }
        
        return cell
    }
    
    public func updateControlBar() {
        if self.dataSource.numberOfSelectedPhoto() > 0 {
            self.numberOfSelectedPhotoContainer.isHidden = false
            self.numberOfSelectedPhoto.text = "\(self.dataSource.numberOfSelectedPhoto())"
        } else {
            self.numberOfSelectedPhotoContainer.isHidden = true
        }
    }
    
    private func reloadAffectedCellByChangingSelection(changedIndex: Int) {
        let affectedList = self.dataSource.affectedSelectedIndexs(changedIndex: changedIndex)
        let indexPaths = affectedList.map { return IndexPath(row: $0, section: 0) }
        self.imageCollectionView.reloadItems(at: indexPaths)
    }
}

extension FMPhotoPickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FMPhotoPickerImageCollectionViewCell else { return }
        let vc = FMPhotoPresenterViewController(dataSource: self.dataSource, initialPhotoIndex: indexPath.item)
        
        self.presentedPhotoIndex = indexPath.item
        
        vc.didSelectPhotoHandler = { photoIndex in
            self.imageCollectionView.reloadItems(at: [IndexPath(row: photoIndex, section: 0)])
            self.updateControlBar()
        }
        vc.didDeselectPhotoHandler = { photoIndex in
            self.imageCollectionView.reloadItems(at: [IndexPath(row: photoIndex, section: 0)])
            self.updateControlBar()
        }
        vc.didMoveToViewControllerHandler = { vc, photoIndex in
            self.presentedPhotoIndex = photoIndex
        }
        
        vc.view.frame = self.view.frame
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: true)
    }
}

extension FMPhotoPickerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = FMZoomInAnimationController()
        animationController.getOriginFrame = self.getOriginFrameForTransition
        return animationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let photoPresenterViewController = dismissed as? FMPhotoPresenterViewController else { return nil }
        let animationController = FMZoomOutAnimationController(interactionController: photoPresenterViewController.swipeInteractionController)
        animationController.getDestFrame = self.getOriginFrameForTransition
        return animationController
    }
    
    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? FMZoomOutAnimationController,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        
        interactionController.animator = animator
        return interactionController
    }
    
    func getOriginFrameForTransition() -> CGRect {
        guard let presentedPhotoIndex = self.presentedPhotoIndex,
            let cell = self.imageCollectionView.cellForItem(at: IndexPath(row: presentedPhotoIndex, section: 0))
            else {
                return CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.size.width, height: self.view.frame.size.width)
        }
        return cell.convert(cell.bounds, to: self.view)
    }
}
