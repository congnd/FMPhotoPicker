//
//  FMPhotoPresenterViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/26.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMPhotoPresenterViewController: UIViewController {
    
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var selectedContainer: UIView!
    @IBOutlet weak var selectedIndex: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    private var interactiveDismissal: Bool = false
    
    var swipeInteractionController: FMPhotoInteractionAnimator?
    
    var didSelectPhotoHandler: ((Int) -> Void)?
    var didDeselectPhotoHandler: ((Int) -> Void)?
    var didMoveToViewControllerHandler: ((FMPhotoViewController, Int) -> Void)?
    
    private(set) var pageViewController: UIPageViewController!
    private var currentPhotoIndex: Int
    private var dataSource: FMPhotosDataSource
    private var currentPhotoViewController: FMPhotoViewController? {
        return pageViewController.viewControllers?.first as? FMPhotoViewController
    }
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(dataSource: FMPhotosDataSource, initialPhotoIndex: Int) {
        self.dataSource = dataSource
        self.currentPhotoIndex = initialPhotoIndex
        super.init(nibName: "FMPhotoPresenterViewController", bundle: Bundle(for: FMPhotoPresenterViewController.self))
        self.initialSetup()
    }
    
    private func initialSetup() {
        self.setupPageViewController(withInitialPhoto: self.dataSource.photo(atIndex: self.currentPhotoIndex))
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedContainer.layer.cornerRadius = self.selectedContainer.frame.size.width / 2
        
        self.updateInfoBar()
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(pageViewController.view)
        self.view.sendSubview(toBack: pageViewController.view)
        self.pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController.didMove(toParentViewController: self)
        
        swipeInteractionController = FMPhotoInteractionAnimator(viewController: self)
        self.view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    }
    
    private func updateInfoBar() {
        // Update selection status
        if let selectedIndex = self.dataSource.selectedIndexOfPhoto(atIndex: self.currentPhotoIndex) {
            self.selectedIndex.text = "\(selectedIndex + 1)"
            self.selectedContainer.isHidden = false
            UIView.performWithoutAnimation {
                self.selectButton.setTitle("選択削除", for: .normal)
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
    
    private func changeToPhoto(photo: FMPhotoAsset) {
        let photoViewController = initializaPhotoViewController(forPhoto: photo)
        self.pageViewController.setViewControllers([photoViewController], direction: .forward, animated: true, completion: nil)
        
        self.updateInfoBar()
    }
    
    private func initializaPhotoViewController(forPhoto photo: FMPhotoAsset) -> FMPhotoViewController {
        let photoViewController = FMPhotoViewController(withPhoto: photo)
        photoViewController.dataSource = self.dataSource
        return photoViewController
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
        previousViewControllers.forEach { vc in
            guard let photoViewController = vc as? FMPhotoViewController else { return }
            photoViewController.photo.cancelAllRequest()
        }
    }
}
