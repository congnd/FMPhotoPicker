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
    
    lazy private var filterSubMenuView: FMFiltersMenuView = {
       return FMFiltersMenuView(withImage: originalThumb, appliedFilter: photo.getAppliedFilter())
    }()
    
    lazy private var cropSubMenuView: FMCropMenuView = {
      return FMCropMenuView()
    }()
    
    public var scalingImageView: FMScalingImageView!
    private var cropView: FMCropView!
    
    public var photo: FMPhotoAsset
    private var originalThumb: UIImage
    private var originalImage: UIImage
    
    private var selectedFilter: FMFilterable?
    
    // MARK - Init
    public init(withPhoto photo: FMPhotoAsset, preloadImage: UIImage, originalThumb: UIImage) {
        self.photo = photo
        self.originalThumb = originalThumb
        self.originalImage = preloadImage
        
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
        
        DispatchQueue.main.async {
            self.filterSubMenuView.insert(toView: self.subMenuContainer)
            self.cropSubMenuView.insert(toView: self.subMenuContainer)
        }
        
        subMenuContainer.isHidden = true
        filterSubMenuView.isHidden = true
        cropSubMenuView.isHidden = true
        
        self.scalingImageView = FMScalingImageView(frame: self.view.frame)
        self.scalingImageView.delegate = self
        
        self.scalingImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scalingImageView.clipsToBounds = true
        self.scalingImageView.image = self.originalImage
        
        cropView = FMCropView()
        view.addSubview(cropView)
        view.sendSubview(toBack: cropView)
        
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
        cropView.moveCropBoxToAspectFillContentFrame()
    }
    
    override func viewDidLayoutSubviews() {
        cropView.frame = view.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool { return true }

    // MARK: - IBActions
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
    @IBAction func onTapOpenFilter(_ sender: Any) {
        showAnimatedFilterMenu()
    }
    @IBAction func onTapOpenCrop(_ sender: Any) {
        showAnimatedCropMenu()
    }
    
    // MARK: - Animation
    private func showAnimatedCropMenu() {
        guard cropSubMenuView.isHidden == true else { return }
        
        subMenuContainer.isHidden = false
        cropSubMenuView.isHidden = false
        
        cropSubMenuView.alpha = 0
        UIView.animate(withDuration: 0.375,
                       animations: {
                        self.cropSubMenuView.alpha = 1
                        self.filterSubMenuView.alpha = 0
        },
                       completion: { _ in
                        self.subMenuContainer.backgroundColor = .white
                        self.filterSubMenuView.isHidden = true
        })
    }
    
    private func showAnimatedFilterMenu() {
        guard filterSubMenuView.isHidden == true else { return }
        
        subMenuContainer.isHidden = false
        filterSubMenuView.isHidden = false
        
        filterSubMenuView.alpha = 0
        UIView.animate(withDuration: 0.375,
                       animations: {
                        self.filterSubMenuView.alpha = 1
                        self.cropSubMenuView.alpha = 0
        },
                       completion: { _ in
                        self.subMenuContainer.backgroundColor = .white
                        self.cropSubMenuView.isHidden = true
        })
    }
    
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
                        self.subMenuContainer.alpha = 0
                        self.view.layoutIfNeeded()
        },
                       completion: { _ in
                        completion?()
        })
    }
}

extension FMImageEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scalingImageView.imageView
    }
}
