//
//  FMPhotoPickerViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/23.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import Photos

// MARK: - Delegate protocol
public protocol FMPhotoPickerViewControllerDelegate: class {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage])
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith assets: [PHAsset])
}

public extension FMPhotoPickerViewControllerDelegate {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {}
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith assets: [PHAsset]) {}
}

public class FMPhotoPickerViewController: UIViewController {
    // MARK: - Outlet
    private weak var imageCollectionView: UICollectionView!
    private weak var numberOfSelectedPhotoContainer: UIView!
    private weak var numberOfSelectedPhoto: UILabel!
    private weak var doneButton: UIButton!
    private weak var cancelButton: UIButton!
    
    // MARK: - Public
    public weak var delegate: FMPhotoPickerViewControllerDelegate? = nil
    
    // MARK: - Private
    
    // Index of photo that is currently displayed in PhotoPresenterViewController.
    // Track this to calculate the destination frame for dismissal animation
    // from PhotoPresenterViewController to this ViewController
    private var presentedPhotoIndex: Int?

    private let config: FMPhotoPickerConfig
    
    // The controller for multiple select/deselect
    private lazy var batchSelector: FMPhotoPickerBatchSelector = {
        return FMPhotoPickerBatchSelector(viewController: self, collectionView: self.imageCollectionView, dataSource: self.dataSource)
    }()
    
    private var dataSource: FMPhotosDataSource! {
        didSet {
            if self.config.selectMode == .multiple {
                // Enable batchSelector in multiple selection mode only
                self.batchSelector.enable()
            }
        }
    }
    
    // MARK: - Init
    public init(config: FMPhotoPickerConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.dataSource == nil {
            self.requestAndFetchAssets()
        }
    }
    
    public override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        initializeViews()
        setupView()
    }
    
    // MARK: - Setup View
    private func setupView() {
        self.imageCollectionView.register(FMPhotoPickerImageCollectionViewCell.self, forCellWithReuseIdentifier: FMPhotoPickerImageCollectionViewCell.reuseId)
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.delegate = self
        
        self.numberOfSelectedPhotoContainer.isHidden = true
        self.doneButton.isHidden = true
        
        // set button title
        self.cancelButton.setTitle(config.strings["picker_button_cancel"], for: .normal)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: config.titleFontSize)
        self.doneButton.setTitle(config.strings["picker_button_select_done"], for: .normal)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: config.titleFontSize)
    }
    
    @objc private func onTapCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc private func onTapDone(_ sender: Any) {
        processDetermination()
    }
    
    // MARK: - Logic
    private func requestAndFetchAssets() {
        if Helper.canAccessPhotoLib() {
            self.fetchPhotos()
        } else {
            let okAction = UIAlertAction(
                title: config.strings["permission_button_ok"],
                style: .default) { (_) in
                    Helper.requestAuthorizationForPhotoAccess(authorized: self.fetchPhotos, rejected: Helper.openIphoneSetting)
            }

            let cancelAction = UIAlertAction(
                title: config.strings["permission_button_cancel"],
                style: .cancel,
                handler: nil)

            Helper.showDialog(
                in: self,
                okAction: okAction,
                cancelAction: cancelAction,
                title: config.strings["permission_dialog_title"],
                message: config.strings["permission_dialog_message"]
                )
        }
    }
    
    private func fetchPhotos() {
        let photoAssets = Helper.getAssets(allowMediaTypes: self.config.mediaTypes)
        var forceCropType: FMCroppable? = nil
        if config.forceCropEnabled, let firstCrop = config.availableCrops?.first {
            forceCropType = firstCrop
        }
        let fmPhotoAssets = photoAssets.map { FMPhotoAsset(asset: $0, forceCropType: forceCropType) }
        self.dataSource = FMPhotosDataSource(photoAssets: fmPhotoAssets)
        
        if self.dataSource.numberOfPhotos > 0 {
            self.imageCollectionView.reloadData()
            self.imageCollectionView.selectItem(at: IndexPath(row: self.dataSource.numberOfPhotos - 1, section: 0),
                                                animated: false,
                                                scrollPosition: .bottom)
        }
    }
    
    public func updateControlBar() {
        if self.dataSource.numberOfSelectedPhoto() > 0 {
            self.doneButton.isHidden = false
            if self.config.selectMode == .multiple {
                self.numberOfSelectedPhotoContainer.isHidden = false
                self.numberOfSelectedPhoto.text = "\(self.dataSource.numberOfSelectedPhoto())"
            }
        } else {
            self.doneButton.isHidden = true
            self.numberOfSelectedPhotoContainer.isHidden = true
        }
    }
    
    private func processDetermination() {
        if config.shouldReturnAsset {
            let assets = dataSource.getSelectedPhotos().compactMap { $0.asset }
            delegate?.fmPhotoPickerController(self, didFinishPickingPhotoWith: assets)
            return
        }

        FMLoadingView.shared.show()
        
        var dict = [Int:UIImage]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let multiTask = DispatchGroup()
            for (index, element) in self.dataSource.getSelectedPhotos().enumerated() {
                multiTask.enter()
                element.requestFullSizePhoto(cropState: .edited, filterState: .edited) {
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
}

// MARK: - UICollectionViewDataSource
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
        
        cell.loadView(photoAsset: photoAsset,
                      selectMode: self.config.selectMode,
                      selectedIndex: self.dataSource.selectedIndexOfPhoto(atIndex: indexPath.item))
        cell.onTapSelect = { [unowned self, unowned cell] in
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
    
    /**
     Reload all photocells that behind the deselected photocell
     - parameters:
        - changedIndex: The index of the deselected photocell in the selected list
     */
    public func reloadAffectedCellByChangingSelection(changedIndex: Int) {
        let affectedList = self.dataSource.affectedSelectedIndexs(changedIndex: changedIndex)
        let indexPaths = affectedList.map { return IndexPath(row: $0, section: 0) }
        self.imageCollectionView.reloadItems(at: indexPaths)
    }
    
    /**
     Try to insert the photo at specify index to selectd list.
     In Single selection mode, it will remove all the previous selection and add new photo to the selected list.
     In Multiple selection mode, If the current number of select image/video does not exceed the maximum number specified in the Config,
     the photo will be added to selected list. Otherwise, a warning dialog will be displayed and NOTHING will be added.
     */
    public func tryToAddPhotoToSelectedList(photoIndex index: Int) {
        if self.config.selectMode == .multiple {
            guard let fmMediaType = self.dataSource.mediaTypeForPhoto(atIndex: index) else { return }

            var canBeAdded = true
            
            switch fmMediaType {
            case .image:
                if self.dataSource.countSelectedPhoto(byType: .image) >= self.config.maxImage {
                    canBeAdded = false
                    let warning = FMWarningView.shared
                    warning.message = String(format: config.strings["picker_warning_over_image_select_format"]!, self.config.maxImage)
                    warning.showAndAutoHide()
                }
            case .video:
                if self.dataSource.countSelectedPhoto(byType: .video) >= self.config.maxVideo {
                    canBeAdded = false
                    let warning = FMWarningView.shared
                    warning.message = String(format: config.strings["picker_warning_over_video_select_format"]!, self.config.maxVideo)
                    warning.showAndAutoHide()
                }
            case .unsupported:
                break
            }
            
            if canBeAdded {
                self.dataSource.setSeletedForPhoto(atIndex: index)
                self.imageCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                self.updateControlBar()
            }
        } else {  // single selection mode
            var indexPaths = [IndexPath]()
            self.dataSource.getSelectedPhotos().forEach { photo in
                guard let photoIndex = self.dataSource.index(ofPhoto: photo) else { return }
                indexPaths.append(IndexPath(row: photoIndex, section: 0))
                self.dataSource.unsetSeclectedForPhoto(atIndex: photoIndex)
            }
            
            self.dataSource.setSeletedForPhoto(atIndex: index)
            indexPaths.append(IndexPath(row: index, section: 0))
            self.imageCollectionView.reloadItems(at: indexPaths)
            self.updateControlBar()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FMPhotoPickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = FMPhotoPresenterViewController(config: self.config, dataSource: self.dataSource, initialPhotoIndex: indexPath.item)
        
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
        vc.didTapDone = {
            self.processDetermination()
        }
        
        vc.view.frame = self.view.frame
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
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

private extension FMPhotoPickerViewController {
    func initializeViews() {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        let headerSeparator = UIView()
        headerSeparator.backgroundColor = kBorderColor
        
        headerSeparator.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerSeparator)
        NSLayoutConstraint.activate([
            headerSeparator.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            headerSeparator.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            headerSeparator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerSeparator.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        let menuContainer = UIView()
        
        menuContainer.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(menuContainer)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                menuContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                menuContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            ])
        }
        NSLayoutConstraint.activate([
            menuContainer.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            menuContainer.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            menuContainer.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            menuContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let cancelButton = UIButton(type: .system)
        self.cancelButton = cancelButton
        cancelButton.setTitleColor(kBlackColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onTapCancel(_:)), for: .touchUpInside)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        menuContainer.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.leftAnchor.constraint(equalTo: menuContainer.leftAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: menuContainer.centerYAnchor),
        ])
        
        let doneButton = UIButton(type: .system)
        self.doneButton = doneButton
        doneButton.setTitleColor(kBlackColor, for: .normal)
        doneButton.addTarget(self, action: #selector(onTapDone(_:)), for: .touchUpInside)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        menuContainer.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.rightAnchor.constraint(equalTo: menuContainer.rightAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: menuContainer.centerYAnchor),
            doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
        ])
        
        let numberOfSelectedPhotoContainer = UIView()
        self.numberOfSelectedPhotoContainer = numberOfSelectedPhotoContainer
        numberOfSelectedPhotoContainer.layer.cornerRadius = 14
        numberOfSelectedPhotoContainer.layer.masksToBounds = true
        numberOfSelectedPhotoContainer.backgroundColor = kRedColor
        
        numberOfSelectedPhotoContainer.translatesAutoresizingMaskIntoConstraints = false
        menuContainer.addSubview(numberOfSelectedPhotoContainer)
        NSLayoutConstraint.activate([
            numberOfSelectedPhotoContainer.rightAnchor.constraint(equalTo: doneButton.leftAnchor, constant: -16),
            numberOfSelectedPhotoContainer.centerYAnchor.constraint(equalTo: menuContainer.centerYAnchor),
            numberOfSelectedPhotoContainer.heightAnchor.constraint(equalToConstant: 28),
            numberOfSelectedPhotoContainer.widthAnchor.constraint(equalToConstant: 28),
        ])
        
        let numberOfSelectedPhoto = UILabel()
        self.numberOfSelectedPhoto = numberOfSelectedPhoto
        numberOfSelectedPhoto.font = .systemFont(ofSize: 15)
        numberOfSelectedPhoto.textColor = .white
        numberOfSelectedPhoto.textAlignment = .center
        
        numberOfSelectedPhoto.translatesAutoresizingMaskIntoConstraints = false
        numberOfSelectedPhotoContainer.addSubview(numberOfSelectedPhoto)
        NSLayoutConstraint.activate([
            numberOfSelectedPhoto.topAnchor.constraint(equalTo: numberOfSelectedPhotoContainer.topAnchor),
            numberOfSelectedPhoto.rightAnchor.constraint(equalTo: numberOfSelectedPhotoContainer.rightAnchor),
            numberOfSelectedPhoto.bottomAnchor.constraint(equalTo: numberOfSelectedPhotoContainer.bottomAnchor),
            numberOfSelectedPhoto.leftAnchor.constraint(equalTo: numberOfSelectedPhotoContainer.leftAnchor),
        ])
        
        let imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: FMPhotoPickerImageCollectionViewLayout())
        self.imageCollectionView = imageCollectionView
        imageCollectionView.backgroundColor = .clear
        
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageCollectionView)
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: menuContainer.bottomAnchor),
            imageCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
    }
}
