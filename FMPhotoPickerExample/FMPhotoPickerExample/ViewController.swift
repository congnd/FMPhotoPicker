//
//  ViewController.swift
//  FMPhotoPickerExample
//
//  Created by c-nguyen on 2018/01/25.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import FMPhotoPicker

class ViewController: UIViewController, FMPhotoPickerViewControllerDelegate {
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        
    }
    
    @IBOutlet weak var selectMode: UISegmentedControl!
    @IBOutlet weak var allowImage: UISwitch!
    @IBOutlet weak var allowVideo: UISwitch!
    @IBOutlet weak var maxImageLB: UILabel!
    @IBOutlet weak var maxVideoLB: UILabel!
    
    private var maxImage: Int = 5
    private var maxVideo: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.maxImageLB.text = "\(self.maxImage)"
        self.maxVideoLB.text = "\(self.maxVideo)"
        
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
    
    @IBAction func open(_ sender: Any) {
        let selectMode: FMSelectMode = (self.selectMode.selectedSegmentIndex == 0 ? .single : .multiple)
        
        var mediaTypes = [FMMediaType]()
        if self.allowImage.isOn { mediaTypes.append(.image) }
        if self.allowVideo.isOn { mediaTypes.append(.video) }
        
        let config = FMPhotoPickerConfig(selectMode: selectMode,
                                         mediaTypes: mediaTypes,
                                         maxImage: self.maxImage,
                                         maxVideo: self.maxVideo)
        
        let vc = FMPhotoPickerViewController(config: config)
        vc.delegate = self
        self.present(vc, animated: true)
    }
}

