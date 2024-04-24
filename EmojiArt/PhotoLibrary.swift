//
//  PhotoLibrary.swift
//  EmojiArt
//
//  Created by 落殇 on 2024/4/16.
//

import SwiftUI
import PhotosUI

struct PhotoLibrary: UIViewControllerRepresentable {
    var handlePickedImage: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator{
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = PHPickerFilter.images
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // do nothing
    }
    
    class Coordinator:NSObject, PHPickerViewControllerDelegate{
        private var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let pickedPhotoItemProvider = results.first?.itemProvider,
                    pickedPhotoItemProvider.canLoadObject(ofClass: UIImage.self)
            else { return handlePickedImage(nil) }
            
            pickedPhotoItemProvider.loadObject(ofClass: UIImage.self) { [] photo, error in
                // 注意loadObject会在后台线程异步执行，而更新图片属于UI操作，所以我们需要将相关代码包在
                // `DispatchQueue.main.async`中，不然虽然图片会设置成功，但是在应用退出之后就会消失，还原会旧图片。
                DispatchQueue.main.async {
                    self.handlePickedImage(photo as? UIImage)
                }
            }
        }
    }
}

