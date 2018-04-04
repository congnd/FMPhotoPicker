![FMPhotoPicker](/resources/FMPhotoPicker.jpg)

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

FMPhotoPicker is a modern, simple, zero-dependency photo picker with an image editor written in Swift for iOS

## Features
- [x] Supports both single and multiple selection
- [x] Supports batch selection/deselection by swipe gesture
- [x] Supports preview
- [x] Supports simple image editor with filter and crop functions
- [x] Supports force crop mode
- [x] Supports preview in eclipse bound
- [x] Supports add self-define crop
- [x] Supports add self-define filter
- [x] Supports video player
- [x] Supports customize confirmation view
- [] Supports customize language

## Requirements
- iOS 9.0+

## Installation

Insert the following line in your Carthfile:
```
git "git@github.com:tribalmedia/FMPhotoPicker.git"
```
and run `carthage update FMPhotoPicker`


## Usage
#### Create a configuration object
```
var config = FMPhotoPickerConfig()
```
For details, see [Configuration](#configuration)

### Picker
```
let picker = FMPhotoPickerViewController(config: config)
picker.delegate = self
self.present(picker, animated: true)
```

### Editor
```
let editor = FMImageEditorViewController(config: config, sourceImage: image)
editor.delegate = self
self.present(editor, animated: true)
```

## Delegation methods
- Implement FMPhotoPickerViewControllerDelegate protocol to handle selected images  
```
func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage])
```

- Implement FMImageEditorViewControllerDelegate protocol to handle ouput image
```
func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage)
```

## Configuration
#### The configuration supports the following parameters:
- [`mediaTypes`](#ref-media-types)
- [`selectMode`](#ref-select-mode)
- [`maxImage`](#ref-max-image)
- [`maxVideo`](#ref-max-video)
- [`availableFilters`](#ref-available-vilters)
- [`availableCrops`](#ref-available-crops)
- [`alertController`](#ref-alert-controller)
- [`forceCropEnabled`](#ref-force-cropEnabled)
- [`eclipsePreviewEnabled`](#ref-eclipse-preview-enabled)

#### Reference
- `mediaTypes` <a name="ref-media-types"></a>  
An array indicating the media types to be accessed by the picker controller.  
Type: `[FMMediaType]`  
Default: `[.image, .video]`

- `selectMode`  <a name="ref-select-mode"></a>  
Photo selection mode. It can be `single` or `multiple` mode.  
Type: : `FMSelectMode`  
Default is `multiple`

- `maxImage`  <a name="ref-max-image"></a>  
The maximum number of image can be selected. 
Type: `Int`  
Default: `10`

- `maxVideo`  <a name="ref-max-video"></a>  
The maximum number of video can be selected.  
Type: `Int`
Default is `10`

- `availableFilters`  <a name="ref-available-filters"></a>  
Filters that will be used in editor.  
FMPhotoEditor provides some default filters that will be fit to you.  
Type: `[FMFilterable]`  
Default: all filters provided by FMPhotoPicker.

- `availableCrops`  <a name="ref-available-crops"></a>  
Crop that will be used in editor.  
FMPhotoEditor provides some default crops that will be fit to you.  
Type: `[FMCroppable]`  
Default: all crops provided by FMPhotoPicker.

- `alertController`  <a name="ref-alert-controller"></a>  
An alert controller to show confirmation view to user with 2 options: Ok or Cancel.  
Type: `FMAlertable`
Default: `FMAlert`

- `forceCropEnabled`  <a name="ref-forc-crop-enabled"></a>  
A bool value indecating whether force mode is enabled.  
If set to `true`, only the first crop in the `availableCrops` will be used in the editor.  
And that crop's ration will become force crop ratio.  
Type: `FMAlertable`  
Default: `false`

- `eclipsePreviewEnabled`  <a name="ref-eclipse-preview-enabled"></a>  
A bool value indicating whether an image in preview screen should be displayed in eclipse bound.  
Type: `Bool`
Default: `false`

## Customization
### Custom filter
You can freely create your own filter by implement the `FMFilterable` protocol.
```
public protocol FMFilterable {
    func filter(image: UIImage) -> UIImage
    func filterName() -> String
}
```
Becareful that the filterName will be used to determine whether two filters is the same.  
Make sure that your filter's names is not duplicate with each other and with the default filters that you want to used.

### Custom crop 
Like filter fuction, FMPhotoPicker provides capability to use your own crop by implement the `FMCroppable` protocol.
```
public protocol FMCroppable {
    func crop(image: UIImage, toRect rect: CGRect) -> UIImage
    func name() -> String
    func icon() -> UIImage
    func ratio() -> FMCropRatio?
}
```
the `name()` method also will be used as indentical for the crop.  
So make sure you don't have any duplicate crop's name.

### Custom alert view controller
You can use your own view style for the confirmation view by implement the `FMAlertable` protocol.
```
public protocol FMAlertable {
    func show(in viewController: UIViewController, ok: @escaping () -> Void, cancel: @escaping () -> Void)
}
```

## Apps using FMPhotoPicker
<a href="https://funmee.jp"><img src="resources/funmee.png" width="100"></a>

## Author
Made by Tribal Media House with ❤️

## License
FMPhotoPicker is released under the MIT license. See LICENSE for details.