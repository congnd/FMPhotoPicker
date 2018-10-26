![FMPhotoPicker](https://i.imgur.com/xrIZy0S.jpg)

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

FMPhotoPicker is a modern, simple and zero-dependency photo picker with an elegant and customizable image editor

## Features
- [x] Support both single and multiple selection
- [x] Support batch selection/deselection by swipe gesture
- [x] Support preview
- [x] Support simple image editor with filter and cropping functions
- [x] Support force crop mode
- [x] Support rounded image preview
- [x] Support adding self-define cropping
- [x] Support adding self-define filter
- [x] Support video player
- [x] Support custom confirmation view
- [x] Support language customization
 
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
An array that indicates the media types to be accessed by the picker controller.  
Type: `[FMMediaType]`  
Default: `[.image, .video]`

- <a name="ref-select-mode"></a>`selectMode`    
Photo selection mode that can be in `single` or `multiple` mode.  
Type: : `FMSelectMode`  
Default is `multiple`

- <a name="ref-max-image"></a>`maxImage`    
The maximum number of images can be selected. 
Type: `Int`  
Default: `10`

- <a name="ref-max-video"></a>`maxVideo`    
The maximum number of videos can be selected.  
Type: `Int`   
Default is `10`

- <a name="ref-available-filters"></a>`availableFilters`    
Filters that are used in editor.  
FMPhotoEditor provides some default filters that will be fit to you.  
Type: `[FMFilterable]`  
Default: all filters are provided by FMPhotoPicker.

- <a name="ref-available-crops"></a>`availableCrops`    
Cropping that is used in editor.  
FMPhotoEditor provides some default crops that will be fit to you.  
Type: `[FMCroppable]`  
Default: all crops provided by FMPhotoPicker.

- <a name="ref-alert-controller"></a>`alertController`    
An alert controller to show the confirmation view to an user with 2 options: Ok or Cancel.  
Type: `FMAlertable`   
Default: `FMAlert`

- <a name="ref-forc-crop-enabled"></a>`forceCropEnabled`    
A bool value that indicates whether force mode is enabled.  
If `true` is set, only the first crop in the `availableCrops` is used in the editor.  
And that crop's ration becomes force crop ratio.  
Type: `FMAlertable`  
Default: `false`

- <a name="ref-eclipse-preview-enabled"></a>`eclipsePreviewEnabled`    
A bool value that indicates whether the preview of image should be displayed in rounded image.  
Type: `Bool`
Default: `false`

- <a name="ref-strings"></a>`strings`    
A dictionary that allows you to customize language for your app.    
For details, see `FMPhotoPickerConfig.swift`   
Type: `Dictionary`

## Customization
### Custom filter
You can freely create your own filter by implementing the `FMFilterable` protocol.
```swift
public protocol FMFilterable {
    func filter(image: UIImage) -> UIImage
    func filterName() -> String
}
```
Be careful that the filterName is used to determine whether the two filters are the same.  
Make sure that your filter's names are not duplicated, especially with the default filters that you want to use.

### Custom cropping 
Similar as filter function, FMPhotoPicker provides the capability to use your own cropping by implementing the `FMCroppable` protocol.
```swift
public protocol FMCroppable {
    func crop(image: UIImage, toRect rect: CGRect) -> UIImage
    func name(string: [String: String]) -> String
    func icon() -> UIImage
    func ratio() -> FMCropRatio?
}
```
The `func name(strings: [String: String]) -> String` will receive the strings configuration from configuration object.
It allows you customize the cropping while keeping all your language setting in only one place.

The `name()` method is also used as identifier for the cropping.  
Thus, make sure you do not have any duplicate of the cropping name.

### Custom alert view controller
You can use your own view style for the confirmation view by implementing the `FMAlertable` protocol.
```swift
public protocol FMAlertable {
    func show(in viewController: UIViewController, ok: @escaping () -> Void, cancel: @escaping () -> Void)
}
```

## Apps using FMPhotoPicker
<a href="https://funmee.jp"><img src="https://i.imgur.com/l2mz2qE.png" width="100"></a>

## Author
`<code>` with ❤️ by Tribal Media House

## License
FMPhotoPicker is released under the MIT license. See LICENSE for details.
