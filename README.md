# FMPhotoPicker


## Installation

Insert the following line in your Carthfile:
```
git "git@github.com:tribalmedia/FMPhotoPicker.git"
```
and run `carthage update FMPhotoPicker`


## Usage
Create a configuration object
```
let config = FMPhotoPickerConfig(mediaTypes: [.image], maxImageSelections: 10, maxVideoSelections: 10)
```

Create a new FMPhotoPicker instance and set delegate
```
let picker = FMPhotoPickerViewController(config: config)
picker.delegate = self // an instance of UIViewController
self.present(picker, animated: true)
```

ImplementFMPhotoPickerDelegate protocol to handle selected images
```
fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage])
```
