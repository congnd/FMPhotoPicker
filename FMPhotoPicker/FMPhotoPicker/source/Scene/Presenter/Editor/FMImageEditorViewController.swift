//
//  FMImageEditorViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

let kContentFrameSpacing: CGFloat = 22.0

// MARK: - Delegate protocol
public protocol FMImageEditorViewControllerDelegate: class {
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage)
}

public class FMImageEditorViewController: UIViewController {
    
    @IBOutlet weak var topMenuTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var transparentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMenuContainter: UIView!
    @IBOutlet weak var bottomMenuContainer: UIView!
    @IBOutlet weak var subMenuContainer: UIView!
    
    @IBOutlet weak var filterMenuButton: UIButton!
    
    @IBOutlet weak var cropMenuButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var unsafeAreaBottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var unsafeAreaBottomView: UIView!
    
    public var didEndEditting: (@escaping () -> Void) -> Void = { _ in }
    public var delegate: FMImageEditorViewControllerDelegate?
    
    private let isAnimatedPresent: Bool
    
    lazy private var filterSubMenuView: FMFiltersMenuView = {
        let filterSubMenuView = FMFiltersMenuView(withImage: originalThumb.resize(toSizeInPixel: kFilterPreviewImageSize),
                                                  appliedFilter: fmPhotoAsset.getAppliedFilter(),
                                                  availableFilters: config.availableFilters)
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
        let cropSubMenuView = FMCropMenuView(appliedCrop: selectedCrop, availableCrops: config.availableCrops, config: config)
        cropSubMenuView.didSelectCrop = { [unowned self] crop in
            self.selectedCrop = crop
            self.cropView.crop = crop
        }
        cropSubMenuView.didReceiveCropControl = { [unowned self] cropControl in
            switch cropControl {
            case .resetAll:
                self.cropView.resetAll()
            case .rotate:
                self.cropView.rotate()
            case .resetFrameWithoutChangeRatio:
                self.cropView.resetFrameWithoutChangeRatio()
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
    
    private var selectedFilter: FMFilterable
    private var selectedCrop: FMCroppable
    
    private var config: FMPhotoPickerConfig
    
    // MARK - Init
    public init(config: FMPhotoPickerConfig, fmPhotoAsset: FMPhotoAsset, filteredImage: UIImage, originalThumb: UIImage) {
        self.config = config
        
        self.fmPhotoAsset = fmPhotoAsset
        
        self.originalThumb = originalThumb
        
        // set to filteredImage until the load original image done
        self.originalImage = filteredImage
        
        self.filteredImage = filteredImage
        
        selectedFilter = fmPhotoAsset.getAppliedFilter()
        selectedCrop = fmPhotoAsset.getAppliedCrop()
        
        isAnimatedPresent = false
        
        super.init(nibName: "FMImageEditorViewController", bundle: Bundle(for: FMImageEditorViewController.self))
        
        self.view.backgroundColor = kBackgroundColor
    }
    
    public init(config: FMPhotoPickerConfig, sourceImage: UIImage) {
        self.config = config
        
        let forceCropType = config.forceCropEnabled ? config.availableCrops.first! : nil
        let fmPhotoAsset = FMPhotoAsset(sourceImage: sourceImage, forceCropType: forceCropType)
        self.fmPhotoAsset = fmPhotoAsset
        
        self.originalThumb = sourceImage
        
        self.originalImage = sourceImage
        self.filteredImage = sourceImage
        
        selectedFilter = fmPhotoAsset.getAppliedFilter()
        selectedCrop = fmPhotoAsset.getAppliedCrop()
        
        isAnimatedPresent = true
        
        super.init(nibName: "FMImageEditorViewController", bundle: Bundle(for: FMImageEditorViewController.self))
        
        fmPhotoAsset.requestThumb { image in
            self.originalThumb = image!
        }
        
        self.view.backgroundColor = kBackgroundColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - Life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        topMenuContainter.isHidden = true
        subMenuContainer.isHidden = true
        filterSubMenuView.isHidden = true
        cropSubMenuView.isHidden = true
        
        cropView = FMCropView(image: filteredImage,
                              appliedCrop: fmPhotoAsset.getAppliedCrop(),
                              appliedCropArea: fmPhotoAsset.getAppliedCropArea())
        cropView.foregroundView.eclipsePreviewEnabled = self.config.eclipsePreviewEnabled
        
        self.view.addSubview(self.cropView)
        self.view.sendSubviewToBack(self.cropView)
        
        DispatchQueue.main.async {
            self.filterSubMenuView.insert(toView: self.subMenuContainer)
            self.cropSubMenuView.insert(toView: self.subMenuContainer)
            
            // convert crop/filter icon to tint
            let filterTintIcon = self.filterMenuButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            self.filterMenuButton.setImage(filterTintIcon, for: .normal)
            
            let cropTintIcon = self.cropMenuButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            self.cropMenuButton.setImage(cropTintIcon, for: .normal)
            
            // default color
            self.filterMenuButton.setTitleColor(kRedColor, for: .normal)
            self.filterMenuButton.tintColor = kRedColor
            
            self.cropMenuButton.setTitleColor(kBlackColor, for: .normal)
            self.cropMenuButton.tintColor = kBlackColor
            
            // get full size original image without any crop or filter applied
            self.fmPhotoAsset.requestFullSizePhoto(cropState: .original, filterState: .original) { [weak self] image in
                guard let strongSelf = self,
                    let image = image else { return }
                strongSelf.originalImage = image
                strongSelf.cropView.foregroundView.compareView.image = image
            }
        }
        
        if !isAnimatedPresent {
            // Hide entire view view until the crop view image is located
            // Because the crop view's frame is restore when view did appear
            // It's neccssary to hide the initial view until the view's position restore is completed
            // It will make the transition become more natural and smooth
            view.isHidden = true
        }
        
        // set buttons title
        cancelButton.setTitle(config.strings["editor_button_cancel"], for: .normal)
        cancelButton.titleLabel!.font = UIFont.systemFont(ofSize: config.titleFontSize)
        
        doneButton.setTitle(config.strings["editor_button_done"], for: .normal)
        doneButton.titleLabel!.font = UIFont.systemFont(ofSize: config.titleFontSize)
        
        filterMenuButton.setTitle(config.strings["editor_menu_filter"], for: .normal)
        filterMenuButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: config.titleFontSize)
        
        cropMenuButton.setTitle(config.strings["editor_menu_crop"], for: .normal)
        cropMenuButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: config.titleFontSize)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
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
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // show top menu before animation
        topMenuContainter.isHidden = false
        
        showAnimatedMenu()
        
        // show filter menu by default
        showAnimatedFilterMenu()
        
        // restore crop image location from previous edditting session
        cropView.contentFrame = contentFrameFullScreen()
        cropView.restoreFromPreviousEdittingSection()
        
        // move image to center of contentFrame
        cropView.contentFrame = contentFrameFilter()
        cropView.moveCropBoxToAspectFillContentFrame()
        
        // show view the crop view image is re-located
        if !isAnimatedPresent {
            view.isHidden = false
        }
        
        // dissable pan and pinch gestures
        cropView.isCropping = false
    }
    
    override public func viewDidLayoutSubviews() {
        cropView.frame = view.frame
        
        if #available(iOS 11.0, *) {
            transparentViewHeightConstraint.constant = view.safeAreaInsets.top + 44
            
            unsafeAreaBottomViewHeightConstraint.constant = view.safeAreaInsets.bottom
            unsafeAreaBottomView.backgroundColor = .white
            unsafeAreaBottomView.alpha = 0.9
        } else {
            unsafeAreaBottomViewHeightConstraint.constant = 0
        }
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - IBActions
    @IBAction func onTapDone(_ sender: Any) {
        cropView.isCropping = false
        
        cropView.contentFrame = contentFrameFullScreen()
        cropView.moveCropBoxToAspectFillContentFrame() {
            // get crop data:
            let cropArea = self.cropView.getCropArea()
            
            self.fmPhotoAsset.apply(filter: self.selectedFilter,
                                    crop: self.selectedCrop,
                                    cropArea: cropArea)

            if let delegate = self.delegate {
                // In case that FMImageEditorViewController is used as standard-alone tool
                self.fmPhotoAsset.requestFullSizePhoto(cropState: .edited, filterState: .edited) { image in
                    if let image = image {
                        delegate.fmImageEditorViewController(self, didFinishEdittingPhotoWith: image)
                    }
                }
            } else {
                // notify PresenterViewController to update it's image
                self.didEndEditting() {
                    self.dismiss(animated: self.isAnimatedPresent)
                }
            }
        }
        
        self.hideAnimatedMenu() {}
    }
    
    @IBAction func onTapCancel(_ sender: Any) {
        let doCancelBlock = {
            self.cropView.isCropping = false
            
            self.cropView.contentFrame = self.contentFrameFullScreen()
            self.cropView.moveCropBoxToAspectFillContentFrame()
            self.hideAnimatedMenu {
                self.dismiss(animated: self.isAnimatedPresent, completion: nil)
            }
        }
        
        if fmPhotoAsset.getAppliedFilter().filterName() == selectedFilter.filterName() &&
            cropView.getCropArea().isApproximatelyEqual(to: fmPhotoAsset.getAppliedCropArea()) {
            doCancelBlock()
        } else {
            config.alertController.show(in: self, ok: doCancelBlock, cancel: {})
        }
    }
    @IBAction func onTapOpenFilter(_ sender: Any) {
        filterMenuButton.tintColor = kRedColor
        filterMenuButton.setTitleColor(kRedColor, for: .normal)
        cropMenuButton.tintColor = kBlackColor
        cropMenuButton.setTitleColor(kBlackColor, for: .normal)
        
        showAnimatedFilterMenu()
        
        cropView.contentFrame = contentFrameFilter()
        cropView.moveCropBoxToAspectFillContentFrame()
        cropView.isCropping = false
        
        // enable foreground touches to control show/hide compareView
        cropView.foregroundView.isEnabledTouches = true
        
        filterSubMenuView.image = cropView.getCroppedThumbImage()
    }
    @IBAction func onTapOpenCrop(_ sender: Any) {
        cropMenuButton.tintColor = kRedColor
        cropMenuButton.setTitleColor(kRedColor, for: .normal)
        filterMenuButton.tintColor = kBlackColor
        filterMenuButton.setTitleColor(kBlackColor, for: .normal)
        
        showAnimatedCropMenu()
        
        cropView.contentFrame = contentFrameCrop()
        cropView.moveCropBoxToAspectFillContentFrame()
        cropView.isCropping = true
        
        // disable foreground touches to return control to scrollview
        cropView.foregroundView.isEnabledTouches = false
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
//                        self.subMenuContainer.backgroundColor = .white
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
//                        self.subMenuContainer.backgroundColor = .white
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
                      y: kContentFrameSpacing + transparentViewHeightConstraint.constant,
                      width: view.bounds.width - 2 * kContentFrameSpacing,
                      height: view.bounds.height - transparentViewHeightConstraint.constant - bottomMenuContainer.frame.height - subMenuContainer.frame.height - unsafeAreaBottomViewHeightConstraint.constant - 2 * kContentFrameSpacing)
    }
    
    private func contentFrameFilter() -> CGRect {
        return CGRect(x: 0,
                      y: transparentViewHeightConstraint.constant,
                      width: view.bounds.width,
                      height: view.bounds.height - transparentViewHeightConstraint.constant - bottomMenuContainer.frame.height - subMenuContainer.frame.height - unsafeAreaBottomViewHeightConstraint.constant)
    }
    
    private func contentFrameFullScreen() -> CGRect {
        return view.bounds
    }
}
