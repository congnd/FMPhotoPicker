//
//  FMImageEditorViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

let kContentFrameSpacing: CGFloat = 22.0
let kDefaultCropName: FMCrop = .ratioCustom

class FMImageEditorViewController: UIViewController {
    
    @IBOutlet weak var topMenuTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMenuContainter: UIView!
    @IBOutlet weak var bottomMenuContainer: UIView!
    @IBOutlet weak var subMenuContainer: UIView!
    
    @IBOutlet weak var filterMenuButton: UIButton!
    @IBOutlet weak var filterMenuIcon: UIImageView!
    
    @IBOutlet weak var cropMenuButton: UIButton!
    @IBOutlet weak var cropMenuIcon: UIImageView!
    
    public var didEndEditting: () -> Void = {}
    
    
    lazy private var filterSubMenuView: FMFiltersMenuView = {
       let filterSubMenuView = FMFiltersMenuView(withImage: originalThumb, appliedFilter: fmPhotoAsset.getAppliedFilter())
        filterSubMenuView.didSelectFilter = { [unowned self] filter in
            self.selectedFilter = filter
            FMLoadingView.shared.show()
            DispatchQueue.global(qos: .utility).async {
                let output = filter.filter(image: self.originalImage)
                DispatchQueue.main.sync {
                    self.cropView.image = output
                    FMLoadingView.shared.hide()
                }
            }
        }
        return filterSubMenuView
    }()
    
    lazy private var cropSubMenuView: FMCropMenuView = {
        let cropSubMenuView = FMCropMenuView(appliedCrop: selectedCrop)
        cropSubMenuView.didSelectCrop = { [unowned self] crop in
            self.selectedCrop = crop
            self.cropView.crop = crop
        }
        cropSubMenuView.didReceiveCropControl = { [unowned self] cropControl in
            if cropControl == .reset {
                self.cropView.reset()
            } else if cropControl == .rotate {
                self.cropView.rotate()
            }
        }
        return cropSubMenuView
    }()
    
    private var cropView: FMCropView!
    
    public var fmPhotoAsset: FMPhotoAsset
    
    // the original thumbnail image
    // used to preview filters
    private var originalThumb: UIImage
    
    // the full size image that is applied filter
    private var filteredImage: UIImage
    
    // the original image without any filter or crop
    private var originalImage: UIImage
    
    private var selectedFilter: FMFilterable?
    private var selectedCrop: FMCroppable = kDefaultCropName
    
    // MARK - Init
    public init(fmPhotoAsset: FMPhotoAsset, filteredImage: UIImage, originalThumb: UIImage) {
        self.fmPhotoAsset = fmPhotoAsset
        
        self.originalThumb = originalThumb
        
        // set to filteredImage until the load original image done
        self.originalImage = filteredImage
        
        self.filteredImage = filteredImage
        
        if let appliedCrop = self.fmPhotoAsset.getAppliedCrop() {
            selectedCrop = appliedCrop
        }
        selectedFilter = fmPhotoAsset.getAppliedFilter()
        
        super.init(nibName: "FMImageEditorViewController", bundle: Bundle(for: FMImageEditorViewController.self))
        
        self.view.backgroundColor = kBackgroundColor
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
            
            // convert crop/filter icon to tint
            let filterTintIcon = self.filterMenuIcon.image?.withRenderingMode(.alwaysTemplate)
            self.filterMenuIcon.image = filterTintIcon
            
            let cropTintIcon = self.cropMenuIcon.image?.withRenderingMode(.alwaysTemplate)
            self.cropMenuIcon.image = cropTintIcon
            
            // default color
            self.filterMenuButton.setTitleColor(kRedColor, for: .normal)
            self.filterMenuIcon.tintColor = kRedColor
            
            self.cropMenuButton.setTitleColor(kBlackColor, for: .normal)
            self.cropMenuIcon.tintColor = kBlackColor
            
            // get full size original image without any crop or filter applied
            self.fmPhotoAsset.requestFullSizePhoto(cropState: .original, filterState: .original) { [weak self] image in
                guard let strongSelf = self,
                    let image = image else { return }
                strongSelf.originalImage = image
            }
        }
        
        subMenuContainer.isHidden = true
        filterSubMenuView.isHidden = true
        cropSubMenuView.isHidden = true
        
        cropView = FMCropView(image: filteredImage,
                              appliedCrop: fmPhotoAsset.getAppliedCrop(),
                              appliedCropArea: fmPhotoAsset.getAppliedCropArea(),
                              zoomScale: fmPhotoAsset.getAppliedZoomScale())
        
        self.view.addSubview(self.cropView)
        self.view.sendSubview(toBack: self.cropView)
        
        self.view.backgroundColor = .black
        
        // hide the view until the crop view image is located
        view.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide top and bottom menu
        bottomMenuBottomConstraint.constant = -bottomMenuContainer.frame.height
        topMenuTopConstraint.constant = -topMenuContainter.frame.height
        
        // show filter mode by default
        // hide the crop corners before it is shown
        // dissable pan and pinch has no effect at this time
        // so we need call again in viewDidAppear to dissable them
        cropView.isCropping = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimatedMenu()
        
        // show filter menu by default
        showAnimatedFilterMenu()
        
        // restore crop image location from previous edditting session
        cropView.contentFrame = contentFrameFullScreen()
        cropView.restoreFromPreviousEdittingSection()
        
        // move image to center of contentFrame
        cropView.contentFrame = contentFrameFilter()
        cropView.moveCropBoxToAspectFillContentFrame()
        
        // show the view when the crop view image is located
        view.isHidden = false
        
        // dissable pan and pinch gestures
        cropView.isCropping = false
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
        // get crop data:
        let cropArea = cropView.getCropArea()
        
        fmPhotoAsset.apply(filter: selectedFilter,
                           crop: selectedCrop,
                           cropArea: cropArea,
                           zoomScale: cropView.scrollView.zoomScale)
        
        hideAnimatedMenu {
            self.dismiss(animated: false, completion: nil)
        }
        
        cropView.contentFrame = contentFrameFullScreen()
        cropView.moveCropBoxToAspectFillContentFrame()
        cropView.isCropping = false
        
        // notify PresenterViewController to update it's image
        didEndEditting()
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        hideAnimatedMenu {
            self.dismiss(animated: false, completion: nil)
        }
        
        cropView.contentFrame = contentFrameFullScreen()
        cropView.moveCropBoxToAspectFillContentFrame()
        cropView.isCropping = false
    }
    @IBAction func onTapOpenFilter(_ sender: Any) {
        filterMenuIcon.tintColor = kRedColor
        filterMenuButton.setTitleColor(kRedColor, for: .normal)
        cropMenuIcon.tintColor = kBlackColor
        cropMenuButton.setTitleColor(kBlackColor, for: .normal)
        
        showAnimatedFilterMenu()
        
        cropView.contentFrame = contentFrameFilter()
        cropView.moveCropBoxToAspectFillContentFrame()
        cropView.isCropping = false
        
        filterSubMenuView.image = cropView.getCroppedImage()
    }
    @IBAction func onTapOpenCrop(_ sender: Any) {
        cropMenuIcon.tintColor = kRedColor
        cropMenuButton.setTitleColor(kRedColor, for: .normal)
        filterMenuIcon.tintColor = kBlackColor
        filterMenuButton.setTitleColor(kBlackColor, for: .normal)
        
        showAnimatedCropMenu()
        
        cropView.contentFrame = contentFrameCrop()
        cropView.moveCropBoxToAspectFillContentFrame()
        cropView.isCropping = true
    }
    
    // MARK: - Animation
    private func showAnimatedCropMenu() {
        guard cropSubMenuView.isHidden == true else { return }
        
        subMenuContainer.isHidden = false
        cropSubMenuView.isHidden = false
        
        cropSubMenuView.alpha = 0
        UIView.animate(withDuration: kEnteringAnimationDuration,
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
        UIView.animate(withDuration: kEnteringAnimationDuration,
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
        UIView.animate(withDuration: kEnteringAnimationDuration,
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
        UIView.animate(withDuration: kLeavingAnimationDuration,
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
    
    // MARK: - Logics
    private func contentFrameCrop() -> CGRect {
        return CGRect(x: kContentFrameSpacing,
                      y: kContentFrameSpacing + topMenuContainter.frame.height,
                      width: view.bounds.width - 2 * kContentFrameSpacing,
                      height: view.bounds.height - topMenuContainter.frame.height - bottomMenuContainer.frame.height - subMenuContainer.frame.height - 2 * kContentFrameSpacing)
    }
    
    private func contentFrameFilter() -> CGRect {
        return CGRect(x: 0,
                      y: topMenuContainter.frame.height,
                      width: view.bounds.width,
                      height: view.bounds.height - topMenuContainter.frame.height - bottomMenuContainer.frame.height - subMenuContainer.frame.height)
    }
    
    private func contentFrameFullScreen() -> CGRect {
        return view.bounds
    }
}
