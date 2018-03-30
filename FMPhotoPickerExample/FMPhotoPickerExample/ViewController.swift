//
//  ViewController.swift
//  FMPhotoPickerExample
//
//  Created by c-nguyen on 2018/01/25.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import FMPhotoPicker

class ViewController: UIViewController, FMPhotoPickerViewControllerDelegate, FMImageEditorViewControllerDelegate {
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        previewImageView.image = photo
    }
    
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var selectMode: UISegmentedControl!
    @IBOutlet weak var allowImage: UISwitch!
    @IBOutlet weak var allowVideo: UISwitch!
    @IBOutlet weak var maxImageLB: UILabel!
    @IBOutlet weak var maxVideoLB: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    
    private var maxImage: Int = 5
    private var maxVideo: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.maxImageLB.text = "\(self.maxImage)"
        self.maxVideoLB.text = "\(self.maxVideo)"
        
        // video off by default
        self.allowVideo.isOn = false
        
        self.selectMode.selectedSegmentIndex = 1
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func downMaxImage(_ sender: Any) {
        if self.maxImage <= 1 { return }
        self.maxImage -= 1
        self.maxImageLB.text = "\(self.maxImage)"
    }
    @IBAction func upMaxImage(_ sender: Any) {
        if self.maxImage >= 100 { return }
        self.maxImage += 1
        self.maxImageLB.text = "\(self.maxImage)"
    }

    @IBAction func downMaxVideo(_ sender: Any) {
        if self.maxVideo <= 1 { return }
        self.maxVideo -= 1
        self.maxVideoLB.text = "\(self.maxVideo)"
    }
    @IBAction func upMaxVideo(_ sender: Any) {
        if self.maxVideo >= 100 { return }
        self.maxVideo += 1
        self.maxVideoLB.text = "\(self.maxVideo)"
    }
    
    func commonConfig() -> FMPhotoPickerConfig {
        let selectMode: FMSelectMode = (self.selectMode.selectedSegmentIndex == 0 ? .single : .multiple)
        
        var mediaTypes = [FMMediaType]()
        if self.allowImage.isOn { mediaTypes.append(.image) }
        if self.allowVideo.isOn { mediaTypes.append(.video) }
        
        var config = FMPhotoPickerConfig()
        
        config.selectMode = selectMode
        config.mediaTypes = mediaTypes
        config.maxImage = self.maxImage
        config.maxVideo = self.maxVideo
        
        // all available crops will be used
        config.availableCrops = []
        
        // all available filters will be used
        config.availableFilters = []
        
        return config
    }
    
    @IBAction func open(_ sender: Any) {
        let vc = FMPhotoPickerViewController(config: commonConfig())
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func openEditor(_ sender: Any) {
        let vc = FMImageEditorViewController(config: commonConfig(), sourceImage: previewImageView.image!)
        vc.delegate = self
        
        self.present(vc, animated: true)
    }
    
    @IBAction func openPickeInForceCrop(_ sender: Any) {
        var config = commonConfig()
        config.forceCropEnabled = true
        config.eclipsePreviewEnabled = true
        config.availableCrops = [FMCrop.ratioSquare]
        config.selectMode = .single
        
        let vc = FMPhotoPickerViewController(config: config)
        vc.delegate = self
        self.present(vc, animated: true)
    }
}

