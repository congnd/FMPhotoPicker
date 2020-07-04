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
    private weak var photoTitle: UILabel!
    private weak var selectedContainer: UIView!
    private weak var selectedIcon: UIImageView!
    private weak var selectedIndex: UILabel!
    private weak var numberOfSelectedPhotoContainer: UIView!
    private weak var numberOfSelectedPhoto: UILabel!
    private weak var doneButton: UIButton!
    private weak var backButton: UIButton!
    private weak var bottomViewContainer: UIView!
    
    // MARK: - Public
    public var swipeInteractionController: FMPhotoInteractionAnimator?
    
    public var didSelectPhotoHandler: ((Int) -> Void)?
    
    public var didDeselectPhotoHandler: ((Int) -> Void)?
    
    public var didMoveToViewControllerHandler: ((FMPhotoViewController, Int) -> Void)?
    
    public var didTapDone: (() -> Void)?
    
    public var bottomView: FMPresenterBottomView!
    
    // MARK: - Private
    private(set) var pageViewController: UIPageViewController!
    
    private var interactiveDismissal: Bool = false
    
    private var currentPhotoIndex: Int
    
    private var dataSource: FMPhotosDataSource
    
    private var config: FMPhotoPickerConfig
    
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
        
        super.init(nibName: nil, bundle: .current)
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
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        setupView()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedContainer.layer.cornerRadius = self.selectedContainer.frame.size.width / 2
        
        self.updateInfoBar()
        
        self.addChild(self.pageViewController)
        self.view.addSubview(pageViewController.view)
        self.view.sendSubviewToBack(pageViewController.view)
        
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
        
        self.pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController.didMove(toParent: self)
        
        self.view.backgroundColor = kBackgroundColor
        
        self.numberOfSelectedPhotoContainer.isHidden = true
        
        if config.selectMode == .single {
            selectedContainer.isHidden = true
            
            // alway show done button
            self.doneButton.isHidden = false
        } else {
            // in multiple mode done button only appear when at least one image has beem selected
            self.doneButton.isHidden = true
        }
        
        // set button title
        self.backButton.setTitle(config.strings["present_button_back"], for: .normal)
        self.backButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: config.titleFontSize)
        
        self.doneButton.setTitle(config.strings["picker_button_select_done"], for: .normal)
        self.doneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: config.titleFontSize)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update bottom view for the first page that can not handled by PageViewControllerDelegate
        self.updateBottomView()
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
                doneButton.isHidden = false
                numberOfSelectedPhotoContainer.isHidden = false
                numberOfSelectedPhoto.isHidden = false
                numberOfSelectedPhoto.text = "\(n)"
            } else {
                doneButton.isHidden = true
                numberOfSelectedPhotoContainer.isHidden = true
                numberOfSelectedPhoto.isHidden = true
            }
        } else {
            numberOfSelectedPhotoContainer.isHidden = true
            numberOfSelectedPhoto.isHidden = true
        
            doneButton.isHidden = false
        }
        
        // Update selection status
        if let selectedIndex = self.dataSource.selectedIndexOfPhoto(atIndex: self.currentPhotoIndex) {
            if self.config.selectMode == .multiple {
                self.selectedIndex.isHidden = false
                self.selectedIndex.text = "\(selectedIndex + 1)"
                self.selectedIcon.image = UIImage(named: "check_on", in: .current, compatibleWith: nil)
            } else {
                self.selectedIndex.isHidden = true
                self.selectedIcon.image = UIImage(named: "single_check_on", in: .current, compatibleWith: nil)
            }
        } else {
            self.selectedIndex.isHidden = true
            self.selectedIcon.image = UIImage(named: "check_off", in: .current, compatibleWith: nil)
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
            bottomViewContainer.isHidden = false
            
            fmAsset.requestVideoFrames { cgImages in
                if let asset = fmAsset.asset {
                    self.bottomView.resetPlaybackControl(cgImages: cgImages, duration: asset.duration)
                }
            }
        } else {
            bottomView.imageMode()
            bottomViewContainer.isHidden = config.availableFilters == nil && config.availableCrops == nil
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
    
    @IBAction func onTapDone(_ sender: Any) {
        if config.selectMode == .single {
            // in single selection mode, tap on done button mean the current displaying image will be selected
            self.didSelectPhotoHandler?(self.currentPhotoIndex)
        }
        
        didTapDone?()
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

private extension FMPhotoPresenterViewController {
    func setupView() {
//        private weak var unsafeAreaBottomViewHeightConstraint: NSLayoutConstraint!
//        private weak var unsafeAreaBottomView: UIView!
        
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
        
        let backButton = UIButton(type: .custom)
        self.backButton = backButton
        backButton.setTitleColor(kBlackColor, for: .normal)
        backButton.setImage(UIImage(named: "icon_back", in: .current, compatibleWith: nil), for: .normal)
        backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -4)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        backButton.addTarget(self, action: #selector(onTapClose(_:)), for: .touchUpInside)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        menuContainer.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: menuContainer.leftAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: menuContainer.centerYAnchor),
        ])
        
        let photoTitle = UILabel()
        self.photoTitle = photoTitle
        photoTitle.textColor = kBlackColor
        photoTitle.font = .boldSystemFont(ofSize: 16)
        
        photoTitle.translatesAutoresizingMaskIntoConstraints = false
        menuContainer.addSubview(photoTitle)
        NSLayoutConstraint.activate([
            photoTitle.centerXAnchor.constraint(equalTo: menuContainer.centerXAnchor),
            photoTitle.centerYAnchor.constraint(equalTo: menuContainer.centerYAnchor),
        ])
        
        let doneButton = UIButton(type: .custom)
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
        
        let selectedContainer = UIView()
        self.selectedContainer = selectedContainer
        
        selectedContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedContainer)
        NSLayoutConstraint.activate([
            selectedContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            selectedContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            selectedContainer.widthAnchor.constraint(equalToConstant: 28),
            selectedContainer.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        let selectedIcon = UIImageView()
        self.selectedIcon = selectedIcon
        
        selectedIcon.translatesAutoresizingMaskIntoConstraints = false
        selectedContainer.addSubview(selectedIcon)
        NSLayoutConstraint.activate([
            selectedIcon.topAnchor.constraint(equalTo: selectedContainer.topAnchor),
            selectedIcon.rightAnchor.constraint(equalTo: selectedContainer.rightAnchor),
            selectedIcon.bottomAnchor.constraint(equalTo: selectedContainer.bottomAnchor),
            selectedIcon.leftAnchor.constraint(equalTo: selectedContainer.leftAnchor),
        ])
        
        let selectedButton = UIButton(type: .custom)
        selectedButton.addTarget(self, action: #selector(onTapSelection(_:)), for: .touchUpInside)
        
        selectedButton.translatesAutoresizingMaskIntoConstraints = false
        selectedContainer.addSubview(selectedButton)
        NSLayoutConstraint.activate([
            selectedButton.topAnchor.constraint(equalTo: selectedContainer.topAnchor, constant: -10),
            selectedButton.rightAnchor.constraint(equalTo: selectedContainer.rightAnchor, constant: -10),
            selectedButton.bottomAnchor.constraint(equalTo: selectedContainer.bottomAnchor, constant: -10),
            selectedButton.leftAnchor.constraint(equalTo: selectedContainer.leftAnchor, constant: -10),
        ])
        
        let selectedIndex = UILabel()
        self.selectedIndex = selectedIndex
        selectedIndex.textColor = .white
        selectedIndex.textAlignment = .center
        selectedIndex.font = .systemFont(ofSize: 17)
        
        selectedIndex.translatesAutoresizingMaskIntoConstraints = false
        selectedContainer.addSubview(selectedIndex)
        NSLayoutConstraint.activate([
            selectedIndex.topAnchor.constraint(equalTo: selectedContainer.topAnchor),
            selectedIndex.rightAnchor.constraint(equalTo: selectedContainer.rightAnchor),
            selectedIndex.bottomAnchor.constraint(equalTo: selectedContainer.bottomAnchor),
            selectedIndex.leftAnchor.constraint(equalTo: selectedContainer.leftAnchor),
        ])
        
        let bottomViewContainer = UIView()
        self.bottomViewContainer = bottomViewContainer
        bottomViewContainer.backgroundColor = .white
        
        bottomViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomViewContainer)
        NSLayoutConstraint.activate([
            bottomViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        bottomView = FMPresenterBottomView(config: config)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomViewContainer.addSubview(bottomView)
        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: bottomViewContainer.topAnchor),
            bottomView.leftAnchor.constraint(equalTo: bottomViewContainer.leftAnchor),
            bottomView.rightAnchor.constraint(equalTo: bottomViewContainer.rightAnchor),
        ])
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                bottomView.bottomAnchor.constraint(equalTo: bottomViewContainer.bottomAnchor),
            ])
        }
    }
}
