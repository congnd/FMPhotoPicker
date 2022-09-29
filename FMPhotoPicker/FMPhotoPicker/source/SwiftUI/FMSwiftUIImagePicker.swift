//
//  Created by Rob Jonson on 29/09/2022.
//

import Foundation
import SwiftUI
import HSHelpers

@available(iOS 15.0, *)
public struct FMSwiftUIImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    var config: FMPhotoPickerConfig
    @Binding var selectedImage: UIImage?
    @Binding var selectedImages: [UIImage]
    
    public init(config: FMPhotoPickerConfig = FMPhotoPickerConfig(),
                selectedImage: Binding<UIImage?>
    ) {
        self.config = config
        self.config.selectMode = .single
        self._selectedImage = selectedImage
        self._selectedImages = .constant([])
    }
    
    public init(config: FMPhotoPickerConfig = FMPhotoPickerConfig(),
                selectedImages: Binding<[UIImage]>
    ) {
        self.config = config
        self.config.selectMode = .multiple
        self._selectedImage = .constant(nil)
        self._selectedImages = selectedImages
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<FMSwiftUIImagePicker>) -> FMPhotoPickerViewController {

        let imagePicker = FMPhotoPickerViewController(config: config)
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }

    public func updateUIViewController(_ uiViewController: FMPhotoPickerViewController, context: UIViewControllerRepresentableContext<FMSwiftUIImagePicker>) {

    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final public class Coordinator: NSObject, FMPhotoPickerViewControllerDelegate {

        var parent: FMSwiftUIImagePicker

        init(_ parent: FMSwiftUIImagePicker) {
            self.parent = parent
        }

        public func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
            
            if let image = photos.first {
                parent.selectedImage = image
            }
            parent.selectedImages = photos

            picker.dismiss(animated: true) {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
