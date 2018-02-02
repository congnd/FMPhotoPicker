//
//  FMPhotoPresenterViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/26.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMPhotoPresenterViewController: UIViewController {
    
    private(set) var pageViewController: UIPageViewController!
    private var currentPhoto: FMPhotoAsset?
    private var dataSource: FMPhotosDataSource
    private var currentPhotoViewController: FMPhotoViewController? {
        return pageViewController.viewControllers?.first as? FMPhotoViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(photos: [FMPhotoAsset], initialPhotoIndex: Int) {
        self.dataSource = FMPhotosDataSource(photos: photos)
        super.init(nibName: "FMPhotoPresenterViewController", bundle: Bundle(for: FMPhotoPresenterViewController.self))
        self.initialSetup(withInitialPhoto: self.dataSource.photo(atIndex: initialPhotoIndex))
    }
    
    private func initialSetup(withInitialPhoto initialPhoto: FMPhotoAsset?) {
        self.setupPageViewController(withInitialPhoto: initialPhoto)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(pageViewController.view)
        self.view.sendSubview(toBack: pageViewController.view)
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pageViewController.didMove(toParentViewController: self)
    }
    
    private func setupPageViewController(withInitialPhoto initialPhoto: FMPhotoAsset? = nil) {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])
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
        
        // TODO: update photo info
    }
    
    private func initializaPhotoViewController(forPhoto photo: FMPhotoAsset) -> FMPhotoViewController {
        return FMPhotoViewController(withPhoto: photo)
    }
    
    // MARK: - Target Actions
    @IBAction func onTapClose(_ sender: Any) {
        self.dismiss(animated: true)
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
}
