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
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var controlBarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Public
    public var swipeInteractionController: FMPhotoInteractionAnimator?
    
    public var didSelectPhotoHandler: ((Int) -> Void)?
    
    public var didDeselectPhotoHandler: ((Int) -> Void)?
    
    public var didMoveToViewControllerHandler: ((FMPhotoViewController, Int) -> Void)?
    
    public var bottomView: FMPresenterBottomView!
    
    // MARK: - Private
    private(set) var pageViewController: UIPageViewController!
    
    private var interactiveDismissal: Bool = false
    
    private var currentPhotoIndex: Int
    
    private var dataSource: FMPhotosDataSource
    
    private var selectMode: FMSelectMode!
    
    private var currentPhotoViewController: FMPhotoViewController? {
        return pageViewController.viewControllers?.first as? FMPhotoViewController
    }
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(selectMode: FMSelectMode, dataSource: FMPhotosDataSource, initialPhotoIndex: Int) {
        self.selectMode = selectMode
        self.dataSource = dataSource
        self.currentPhotoIndex = initialPhotoIndex
        
        super.init(nibName: "FMPhotoPresenterViewController", bundle: Bundle(for: FMPhotoPresenterViewController.self))
        self.setupPageViewController(withInitialPhoto: self.dataSource.photo(atIndex: self.currentPhotoIndex))
    }
    
    private func setupPageViewController(withInitialPhoto initialPhoto: FMPhotoAsset? = nil) {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])
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
    
    deinit {
        print("deinit FMPhotoPresenterViewController")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.keyWindow else { return }
            if window.safeAreaInsets.top > 0 {
                // iPhone X
                self.controlBarHeightConstraint.constant = 88
            }
        }
        
        self.selectedContainer.layer.cornerRadius = self.selectedContainer.frame.size.width / 2
        
        self.updateInfoBar()
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(pageViewController.view)
        self.view.sendSubview(toBack: pageViewController.view)
        
        
        // Init bottom view
        self.bottomView = FMPresenterBottomView()
        swipeInteractionController = FMPhotoInteractionAnimator(viewController: self)
        
        self.bottomView.touchBegan = { [unowned self] in
            self.swipeInteractionController?.disable()
        }
        self.bottomView.touchEnded = { [unowned self] in
            self.swipeInteractionController?.enable()
        }
        self.bottomView.onTapEditButton = { [unowned self] in
            let editorVC = FMImageEditorViewController(selectMode: self.selectMode, dataSource: self.dataSource, initialPhotoIndex: self.currentPhotoIndex)
            self.present(editorVC, animated: false, completion: nil)
        }
        
        self.view.addSubview(bottomView)
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.bottomView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.bottomView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController.didMove(toParentViewController: self)
        
        self.view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update bottom view for the first page that can not handled by PageViewControllerDelegate
        self.updateBottomView()
    }
    
    override func viewDidLayoutSubviews() {
        bottomView.updateFrames()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
    }
    
    // MARK: - Update Views
    private func updateInfoBar() {
        // Update selection status
        if let selectedIndex = self.dataSource.selectedIndexOfPhoto(atIndex: self.currentPhotoIndex) {
            
            self.selectedContainer.isHidden = false
            if self.selectMode == .multiple {
                self.selectedIndex.text = "\(selectedIndex + 1)"
                self.selectedIcon.image = UIImage(named: "check_on", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            } else {
                self.selectedIndex.isHidden = true
                self.selectedIcon.image = UIImage(named: "single_check_on", in: Bundle(for: self.classForCoder), compatibleWith: nil)
            }

            UIView.performWithoutAnimation {
                self.selectButton.setTitle("選択解除", for: .normal)
                self.selectButton.layoutIfNeeded()
            }
        } else {
            self.selectedContainer.isHidden = true
            UIView.performWithoutAnimation {
                self.selectButton.setTitle("選択", for: .normal)
                self.selectButton.layoutIfNeeded()
            }
        }
        
        // Update photo title
        if let photoAsset = self.dataSource.photo(atIndex: self.currentPhotoIndex),
            let creationDate = photoAsset.asset.creationDate {
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
            let imageViewController = FMImageViewController(withPhoto: photo)
            imageViewController.dataSource = self.dataSource
        
            return imageViewController
        } else {
            let videoViewController = FMVideoViewController(withPhoto: photo)
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
                self.bottomView.resetPlaybackControl(cgImages: cgImages, duration: fmAsset.asset.duration)
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
