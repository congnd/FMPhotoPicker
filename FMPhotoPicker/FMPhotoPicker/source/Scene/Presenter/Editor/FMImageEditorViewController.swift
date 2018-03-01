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
    private var originalImage: UIImage
    private var resizedImage: UIImage
    
    // MARK - Init
    public init(withPhoto photo: FMPhotoAsset, preloadImage: UIImage, thumbImage: UIImage) {
        self.photo = photo
        self.originalImage = preloadImage
        self.resizedImage = self.originalImage
        self.filterSubMenuView = FMFiltersListView(withImage: thumbImage)
        
        super.init(nibName: "FMImageEditorViewController", bundle: Bundle(for: FMImageEditorViewController.self))
        
        self.filterSubMenuView.didSelectFilter = { [unowned self] filter in
            self.scalingImageView.image = filter.filter(image: self.resizedImage)
        }
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
        
        self.photo.requestImage(in: self.view.frame.size, { [unowned self] image in
            guard let image = image else { return }
            self.resizedImage = image
            self.scalingImageView.image = image
        })
        
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

    @IBAction func onTapCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}

extension FMImageEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scalingImageView.imageView
    }
}
