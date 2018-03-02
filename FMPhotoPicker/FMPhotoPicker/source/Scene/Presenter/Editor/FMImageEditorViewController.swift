//
//  FMImageEditorViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMImageEditorViewController: UIViewController {
    
    @IBOutlet weak var topMenuTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMenuContainter: UIView!
    @IBOutlet weak var bottomMenuContainer: UIView!
    @IBOutlet weak var subMenuContainer: UIView!
    
    private let filterSubMenuView: FMFiltersListView
    public var scalingImageView: FMScalingImageView!
    public var photo: FMPhotoAsset
    private var originalThumb: UIImage
    private var originalImage: UIImage
    
    private var selectedFilter: FMFilterable?
    
    // MARK - Init
    public init(withPhoto photo: FMPhotoAsset, preloadImage: UIImage, originalThumb: UIImage) {
        self.photo = photo
        self.originalThumb = originalThumb
        self.originalImage = preloadImage
        
        self.filterSubMenuView = FMFiltersListView(withImage: originalThumb, appliedFilter: photo.getAppliedFilter())
        
        super.init(nibName: "FMImageEditorViewController", bundle: Bundle(for: FMImageEditorViewController.self))
        
        self.filterSubMenuView.didSelectFilter = { [unowned self] filter in
            self.selectedFilter = filter
            self.scalingImageView.image = filter.filter(image: self.originalImage)
        }
        
        self.view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subMenuContainer.addSubview(filterSubMenuView)
        filterSubMenuView.translatesAutoresizingMaskIntoConstraints = false
        filterSubMenuView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        filterSubMenuView.rightAnchor.constraint(equalTo: subMenuContainer.rightAnchor).isActive = true
        filterSubMenuView.leftAnchor.constraint(equalTo: subMenuContainer.leftAnchor).isActive = true
        filterSubMenuView.bottomAnchor.constraint(equalTo: subMenuContainer.bottomAnchor).isActive = true
        
        self.scalingImageView = FMScalingImageView(frame: self.view.frame)
        self.scalingImageView.delegate = self
        
        self.scalingImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scalingImageView.clipsToBounds = true
        self.scalingImageView.image = self.originalImage
        
//        self.photo.requestImage(in: self.view.frame.size, { [weak self] image in
//            guard let strongSelf = self,
//                let image = image else { return }
//            strongSelf.resizedImage = image
//            strongSelf.scalingImageView.image = image
//        })
        
        self.view.addSubview(self.scalingImageView)
        self.view.sendSubview(toBack: self.scalingImageView)
        
        self.view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimatedMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK -
    private func showAnimatedMenu() {
        topMenuTopConstraint.constant = topMenuContainter.frame.height
        bottomMenuBottomConstraint.constant = bottomMenuContainer.frame.height
        topMenuContainter.alpha = 0
        bottomMenuContainer.alpha = 0
        UIView.animate(withDuration: 0.375,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.topMenuContainter.alpha = 1
                        self.bottomMenuContainer.alpha = 1
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
        
        self.topMenuTopConstraint.constant = 0
        self.bottomMenuBottomConstraint.constant = 0
    }
    
    private func hideAnimatedMenu(completion: (() -> Void)?) {
        self.topMenuTopConstraint.constant = -self.topMenuContainter.frame.height
        self.bottomMenuBottomConstraint.constant = -self.bottomMenuContainer.frame.height
        UIView.animate(withDuration: 0.375,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.topMenuContainter.alpha = 0
                        self.bottomMenuContainer.alpha = 0
                        self.view.layoutIfNeeded()
        },
                       completion: { _ in
                        completion?()
        })
    }

    @IBAction func onTapDone(_ sender: Any) {
        if let filter = selectedFilter {
            photo.apply(filter: filter)
        }
        hideAnimatedMenu {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        hideAnimatedMenu {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension FMImageEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scalingImageView.imageView
    }
}
