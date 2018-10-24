//
//  FMPhotoPresenterViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/26.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import AVKit

class FMPhotoPresenterViewController: UIViewController {
    // MARK: Outlet
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var selectedContainer: UIView!
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var selectedIndex: UILabel!
    @IBOutlet weak var numberOfSelectedPhotoContainer: UIView!
    @IBOutlet weak var numberOfSelectedPhoto: UILabel!
    @IBOutlet weak var determineButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var transparentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var unsafeAreaBottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var unsafeAreaBottomView: UIView!
    
    // MARK: - Public
    public var swipeInteractionController: FMPhotoInteractionAnimator?
    
    public var didSelectPhotoHandler: ((Int) -> Void)?
    
    public var didDeselectPhotoHandler: ((Int) -> Void)?
    
    public var didMoveToViewControllerHandler: ((FMPhotoViewController, Int) -> Void)?
    
    public var didTapDetermine: (() -> Void)?
    
    public var bottomView: FMPresenterBottomView!
    
    // MARK: - Private
    private(set) var pageViewController: UIPageViewController!
    
    private var interactiveDismissal: Bool = false
    
    private var currentPhotoIndex: Int
    
    private var dataSource: FMPhotosDataSource
    
    private var config: FMPhotoPickerConfig
    
    private var bottomViewBottomConstraint: NSLayoutConstraint!
    
    private var currentPhotoViewController: FMPhotoViewController? {
        return pageViewController.viewControllers?.first as? FMPhotoViewController
    }
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = config.strings["present_title_photo_created_date_format"]
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(config: FMPhotoPickerConfig, dataSource: FMPhotosDataSource, initialPhotoIndex: Int) {
        self.config = config
        self.dataSource = dataSource
        self.currentPhotoIndex = initialPhotoIndex
        
        super.init(nibName: "FMPhotoPresenterViewController", bundle: Bundle(for: FMPhotoPresenterViewController.self))
        self.setupPageViewController(withInitialPhoto: self.dataSource.photo(atIndex: self.currentPhotoIndex))
    }
    
    private func setupPageViewController(withInitialPhoto initialPhoto: FMPhotoAsset? = nil) {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 16.0])
        self.pageViewController.view.frame = self.view.frame
        self.pageViewController.view.backgroundColor = .clear
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        
        if let photo = initialPhoto {
            self.changeToPhoto(photo: photo)
        } else if let photo = self.dataSource.photo(atIndex: 0) {
            self.changeToPhoto(photo: photo)
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedContainer.layer.cornerRadius = self.selectedContainer.frame.size.width / 2
        
        self.updateInfoBar()
        
        self.addChild(self.pageViewController)
        self.view.addSubview(pageViewController.view)
        self.view.sendSubviewToBack(pageViewController.view)
        
        
        // Init bottom view
        self.bottomView = FMPresenterBottomView(config: config)
        swipeInteractionController = FMPhotoInteractionAnimator(viewController: self)
        
        self.bottomView.touchBegan = { [unowned self] in
            self.swipeInteractionController?.disable()
        }
        self.bottomView.touchEnded = { [unowned self] in
            self.swipeInteractionController?.enable()
        }
        self.bottomView.onTapEditButton = { [unowned self] in
            guard let photo = self.dataSource.photo(atIndex: self.currentPhotoIndex),
                let vc = self.pageViewController.viewControllers?.first as? FMPhotoViewController,
                let originalThumb = photo.filterdThumb,
                let filteredImage = vc.getFilteredImage()
                else { return }
            let editorVC = FMImageEditorViewController(config: self.config,
                                                       fmPhotoAsset: photo,
                                                       filteredImage: filteredImage,
                                                       originalThumb: originalThumb)
            editorVC.didEndEditting = { [unowned self] viewDidUpdate in
                if let photoVC = self.pageViewController.viewControllers?.first as? FMPhotoViewController {
                    photoVC.reloadPhoto(complete: viewDidUpdate)
                }
            }
            self.present(editorVC, animated: false, completion: nil)
        }
        
        self.view.addSubview(bottomView)
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.bottomView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bottomViewBottomConstraint = self.bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        bottomViewBottomConstraint.isActive = true
        self.bottomView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        self.pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController.didMove(toParent: self)
        
        self.view.backgroundColor = kBackgroundColor
        
        self.numberOfSelectedPhotoContainer.layer.cornerRadius = self.numberOfSelectedPhotoContainer.frame.size.width / 2
        self.numberOfSelectedPhotoContainer.isHidden = true
        
        if config.selectMode == .single {
            selectedContainer.isHidden = true
            
            // alway show done button
            self.determineButton.isHidden = false
        } else {
            // in multiple mode done button only appear when at least one image has beem selected
            self.determineButton.isHidden = true
        }
        
        // set button title
        self.backButton.setTitle(config.strings["present_button_back"], for: .normal)
        self.backButton.titleLabel!.font = UIFont.systemFont(ofSize: config.titleFontSize)
        
        self.determineButton.setTitle(config.strings["picker_button_select_done"], for: .normal)
        self.determineButton.titleLabel!.font = UIFont.systemFont(ofSize: config.titleFontSize)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update bottom view for the first page that can not handled by PageViewControllerDelegate
        self.updateBottomView()
    }
    
    override func viewDidLayoutSubviews() {
        bottomView.updateFrames()
        
        if #available(iOS 11.0, *) {
            transparentViewHeightConstraint.constant = view.safeAreaInsets.top + 44 // 44 is the height of nav bar
            bottomViewBottomConstraint.constant = -view.safeAreaInsets.bottom
            
            unsafeAreaBottomViewHeightConstraint.constant = view.safeAreaInsets.bottom
            unsafeAreaBottomView.backgroundColor = .white
            unsafeAreaBottomView.alpha = 0.9
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
    }
    
    // MARK: - Update Views
    private func updateInfoBar() {
        let n = dataSource.numberOfSelectedPhoto()
        if self.config.selectMode == .multiple {
            if n > 0 {
                determineButton.isHidden = false
                numberOfSelectedPhotoContainer.isHidden = false
                numberOfSelectedPhoto.isHidden = false
                numberOfSelectedPhoto.text = "\(n)"
            } else {
                determineButton.isHidden = true
                numberOfSelectedPhotoContainer.isHidden = true
                numberOfSelectedPhoto.isHidden = true
            }
        } else {
            numberOfSelectedPhotoContainer.isHidden = true
            numberOfSelectedPhoto.isHidden = true
        
            determineButton.isHidden = false
        }
        
        // Update selection status
        if let selectedIndex = self.dataSource.selectedIndexOfPhoto(atIndex: self.currentPhotoIndex) {
            if self.config.selectMode == .multiple {
                self.selectedIndex.isHidden = false
                self.selectedIndex.text = "\(selectedIndex + 1)"
                self.selectedIcon.image = UIImage(named: "check_on", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            } else {
                self.selectedIndex.isHidden = true
                self.selectedIcon.image = UIImage(named: "single_check_on", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            }
        } else {
            self.selectedIndex.isHidden = true
            self.selectedIcon.image = UIImage(named: "check_off", in: Bundle(for: self.classForCoder), compatibleWith: nil)
        }
        
        // Update photo title
        if let photoAsset = self.dataSource.photo(atIndex: self.currentPhotoIndex),
            let creationDate = photoAsset.asset?.creationDate {
            self.photoTitle.text = self.formatter.string(from: creationDate)
        }
    }
    
    private func changeToPhoto(photo: FMPhotoAsset) {
        let photoViewController = initializaPhotoViewController(forPhoto: photo)
        self.pageViewController.setViewControllers([photoViewController], direction: .forward, animated: true, completion: nil)
        
        self.updateInfoBar()
    }
    
    private func initializaPhotoViewController(forPhoto photo: FMPhotoAsset) -> FMPhotoViewController {
        if photo.mediaType == .image {
            let imageViewController = FMImageViewController(withPhoto: photo, config: self.config)
            imageViewController.dataSource = self.dataSource
        
            return imageViewController
        } else {
            let videoViewController = FMVideoViewController(withPhoto: photo, config: self.config)
            videoViewController.dataSource = self.dataSource
            videoViewController.playerProgressDidChange = bottomView.playerProgressDidChange
            
            return videoViewController
        }
    }
    
    private func updateBottomView() {
        guard let fmAsset = dataSource.photo(atIndex: currentPhotoIndex) else { return }
        
        if fmAsset.mediaType == .video {
            bottomView.videoMode()
            fmAsset.requestVideoFrames { cgImages in
                if let asset = fmAsset.asset {
                    self.bottomView.resetPlaybackControl(cgImages: cgImages, duration: asset.duration)
                }
            }
        } else {
            bottomView.imageMode()
        }
    }
    
    // MARK: - Target Actions
    @IBAction func onTapClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onTapSelection(_ sender: Any) {
        if self.dataSource.selectedIndexOfPhoto(atIndex: self.currentPhotoIndex) == nil {
            self.didSelectPhotoHandler?(self.currentPhotoIndex)
        } else {
            self.didDeselectPhotoHandler?(currentPhotoIndex)
        }
        self.updateInfoBar()
    }
    
    @IBAction func onTapDetermine(_ sender: Any) {
        if config.selectMode == .single {
            // in single selection mode, tap on done button mean the current displaying image will be selected
            self.didSelectPhotoHandler?(self.currentPhotoIndex)
        }
        
        didTapDetermine?()
    }
    
}

// MARK: - UIPageViewControllerDataSource / UIPageViewControllerDelegate
extension FMPhotoPresenterViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let photoViewController = viewController as? FMPhotoViewController,
            let photoIndex = self.dataSource.index(ofPhoto: photoViewController.photo),
            let newPhoto = self.dataSource.photo(atIndex: photoIndex - 1) else {
            return nil
        }
        
        return self.initializaPhotoViewController(forPhoto: newPhoto)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let photoViewController = viewController as? FMPhotoViewController,
            let photoIndex = self.dataSource.index(ofPhoto: photoViewController.photo),
            let newPhoto = self.dataSource.photo(atIndex: photoIndex + 1) else {
                return nil
        }
        
        return self.initializaPhotoViewController(forPhoto: newPhoto)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
            let vc = pageViewController.viewControllers?.first as? FMPhotoViewController,
            let photoIndex = self.dataSource.index(ofPhoto: vc.photo)
            else { return }
        
        self.currentPhotoIndex = photoIndex
        self.updateInfoBar()
        self.didMoveToViewControllerHandler?(vc, photoIndex)
        self.updateBottomView()
        previousViewControllers.forEach { vc in
            guard let photoViewController = vc as? FMPhotoViewController else { return }
            photoViewController.photo.cancelAllRequest()
        }
    }
}
