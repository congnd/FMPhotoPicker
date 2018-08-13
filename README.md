![FMPhotoPicker](/resources/FMPhotoPicker.jpg)

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

FMPhotoPicker is a modern, simple and zero-dependency photo picker with an image editor written in Swift for iOS

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
- [x] Supports customize language

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
```swift
var config = FMPhotoPickerConfig()
```
For details, see [Configuration](#configuration)

### Picker
```swift
let picker = FMPhotoPickerViewController(config: config)
picker.delegate = self
self.present(picker, animated: true)
```
*From iOS 10, you have to add the `Privacy - Photo Library Usage Description` into your Info.plist file.*

### Editor
```swift
let editor = FMImageEditorViewController(config: config, sourceImage: image)
editor.delegate = self
self.present(editor, animated: true)
```

## Delegation methods
- Implement FMPhotoPickerViewControllerDelegate protocol to handle selected images  
```swift
func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage])
```

- Implement FMImageEditorViewControllerDelegate protocol to handle ouput image
```swift
func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage)
```

## Configuration
#### The configuration supports the following parameters:
- [`mediaTypes`](#ref-media-types)
- [`selectMode`](#ref-select-mode)
- [`maxImage`](#ref-max-image)
- [`maxVideo`](#ref-max-video)
- [`availableFilters`](#ref-available-filters)
- [`availableCrops`](#ref-available-crops)
- [`alertController`](#ref-alert-controller)
- [`forceCropEnabled`](#ref-force-crop-enabled)
- [`eclipsePreviewEnabled`](#ref-eclipse-preview-enabled)
- [`strings`](#ref-strings)

#### Reference
- <a name="ref-media-types"></a>`mediaTypes`   
An array indicating the media types to be accessed by the picker controller.  
Type: `[FMMediaType]`  
Default: `[.image, .video]`

- <a name="ref-select-mode"></a>`selectMode`    
Photo selection mode. It can be `single` or `multiple` mode.  
Type: : `FMSelectMode`  
Default is `multiple`

- <a name="ref-max-image"></a>`maxImage`    
The maximum number of image can be selected. 
Type: `Int`  
Default: `10`

- <a name="ref-max-video"></a>`maxVideo`    
The maximum number of video can be selected.  
Type: `Int`   
Default is `10`

- <a name="ref-available-filters"></a>`availableFilters`    
Filters that will be used in editor.  
FMPhotoEditor provides some default filters that will be fit to you.  
Type: `[FMFilterable]`  
Default: all filters provided by FMPhotoPicker.

- <a name="ref-available-crops"></a>`availableCrops`    
Crop that will be used in editor.  
FMPhotoEditor provides some default crops that will be fit to you.  
Type: `[FMCroppable]`  
Default: all crops provided by FMPhotoPicker.

- <a name="ref-alert-controller"></a>`alertController`    
An alert controller to show confirmation view to user with 2 options: Ok or Cancel.  
Type: `FMAlertable`   
Default: `FMAlert`

- <a name="ref-forc-crop-enabled"></a>`forceCropEnabled`    
A bool value indecating whether force mode is enabled.  
If set to `true`, only the first crop in the `availableCrops` will be used in the editor.  
And that crop's ration will become force crop ratio.  
Type: `FMAlertable`  
Default: `false`

- <a name="ref-eclipse-preview-enabled"></a>`eclipsePreviewEnabled`    
A bool value indicating whether an image in preview screen should be displayed in eclipse bound.  
Type: `Bool`
Default: `false`

- <a name="ref-strings"></a>`strings`    
A dictionary allows you custom language for your app.    
For details, see `FMPhotoPickerConfig.swift`   
Type: `Dictionary`

## Customization
### Custom filter
You can freely create your own filter by implement the `FMFilterable` protocol.
```swift
public protocol FMFilterable {
    func filter(image: UIImage) -> UIImage
    func filterName() -> String
}
```
Becareful that the filterName will be used to determine whether two filters is the same.  
Make sure that your filter's names is not duplicate with each other and with the default filters that you want to used.

### Custom crop 
Like filter fuction, FMPhotoPicker provides capability to use your own crop by implement the `FMCroppable` protocol.
```swift
public protocol FMCroppable {
    func crop(image: UIImage, toRect rect: CGRect) -> UIImage
    func name(string: [String: String]) -> String
    func icon() -> UIImage
    func ratio() -> FMCropRatio?
}
```
The `func name(strings: [String: String]) -> String` will receive the strings configuration from configuration object.
It allows you custom crop while keep all your language setting in only one place.

the `name()` method also will be used as indentical for the crop.  
So make sure you don't have any duplicate crop's name.

### Custom alert view controller
You can use your own view style for the confirmation view by implement the `FMAlertable` protocol.
```swift
public protocol FMAlertable {
    func show(in viewController: UIViewController, ok: @escaping () -> Void, cancel: @escaping () -> Void)
}
```

## Apps using FMPhotoPicker
<a href="https://funmee.jp"><img src="resources/funmee.png" width="100"></a>

## Author
`<code>` with ❤️ by Tribal Media House

## License
FMPhotoPicker is released under the MIT license. See LICENSE for details.