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
    
    private let config: FMPhotoPickerConfig
    
    public init(config: FMPhotoPickerConfig) {
        self.config = config
        super.init(nibName: "FMPhotoPickerViewController", bundle: Bundle(for: type(of: self)))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    // MARK: - Life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.dataSource == nil {
            self.requestAndFetchAssets()
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
        FMLoadingView.shared.show()
        
        var dict = [Int:UIImage]()

        DispatchQueue.global(qos: .userInitiated).async {
            let multiTask = DispatchGroup()
            for (index, element) in self.dataSource.getSelectedPhotos().enumerated() {
                multiTask.enter()
                element.requestFullSizePhoto() {
                    guard let image = $0 else { return }
                    dict[index] = image
                    multiTask.leave()
                }
            }
            multiTask.wait()
            
            let result = dict.sorted(by: { $0.key < $1.key }).map { $0.value }
            DispatchQueue.main.async {
                FMLoadingView.shared.hide()
                self.delegate?.fmPhotoPickerController(self, didFinishPickingPhotoWith: result)
            }
        }
    }
    
    // MARK: - Logic
    private func requestAndFetchAssets() {
        if Helper.canAccessPhotoLib() {
            self.fetchPhotos()
        } else {
            Helper.showDialog(in: self, ok: {
                Helper.requestAuthorizationForPhotoAccess(authorized: self.fetchPhotos, rejected: Helper.openIphoneSetting)
            })
        }
    }
    
    private func fetchPhotos() {
        let photoAssets = Helper.getAssets(allowMediaTypes: self.config.mediaTypes)
        let fmPhotoAssets = photoAssets.map { FMPhotoAsset(asset: $0) }
        self.dataSource = FMPhotosDataSource(photoAssets: fmPhotoAssets)
        
        self.imageCollectionView.reloadData()
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
                self.tryToAddPhotoToSelectedList(photoIndex: indexPath.item)
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
    
    /**
     Reload all photocells that behind the deselected photocell
     - parameters:
        - changedIndex: The index of the deselected photocell in the selected list
     */
    private func reloadAffectedCellByChangingSelection(changedIndex: Int) {
        let affectedList = self.dataSource.affectedSelectedIndexs(changedIndex: changedIndex)
        let indexPaths = affectedList.map { return IndexPath(row: $0, section: 0) }
        self.imageCollectionView.reloadItems(at: indexPaths)
    }
    
    /**
     Try to insert the photo at specify index to selectd list.
     If the current number of select image/video does not exceed the maximum number specified in the Config,
     the photo will be added to selected list. Otherwise, a warning dialog will be displayed and NOTHING will be added.
     */
    public func tryToAddPhotoToSelectedList(photoIndex index: Int) {
        guard let phMediaType = self.dataSource.mediaTypeForPhoto(atIndex: index),
            let fmMediaType = FMMediaType(withPHAssetMediaType: phMediaType) else { return }
        var canBeAdded = true
        switch fmMediaType {
        case .image:
            if self.dataSource.countSelectedPhoto(byType: .image) >= self.config.maxImageSelections {
                canBeAdded = false
                let warning = FMWarningView.shared
                warning.message = "画像は最大\(self.config.maxImageSelections)個まで選択できます。"
                warning.showAndAutoHide()
            }
        case .video:
            if self.dataSource.countSelectedPhoto(byType: .video) >= self.config.maxVideoSelections {
                canBeAdded = false
                let warning = FMWarningView.shared
                warning.message = "動画は最大\(self.config.maxVideoSelections)個まで選択できます。"
                warning.showAndAutoHide()
            }
        }
        
        if canBeAdded {
            self.dataSource.setSeletedForPhoto(atIndex: index)
            self.imageCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            self.updateControlBar()
        }
    }
}

extension FMPhotoPickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = FMPhotoPresenterViewController(dataSource: self.dataSource, initialPhotoIndex: indexPath.item)
        
        self.presentedPhotoIndex = indexPath.item
        
        vc.didSelectPhotoHandler = { photoIndex in
            self.tryToAddPhotoToSelectedList(photoIndex: photoIndex)
        }
        vc.didDeselectPhotoHandler = { photoIndex in
            if let selectedIndex = self.dataSource.selectedIndexOfPhoto(atIndex: photoIndex) {
                self.dataSource.unsetSeclectedForPhoto(atIndex: photoIndex)
                self.reloadAffectedCellByChangingSelection(changedIndex: selectedIndex)
                self.imageCollectionView.reloadItems(at: [IndexPath(row: photoIndex, section: 0)])
                self.updateControlBar()
            }
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
