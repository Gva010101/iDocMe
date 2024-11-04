


import Foundation
import SwiftUI
import TOCropViewController



struct CropViewControllerWrapper: UIViewControllerRepresentable {
    var image: UIImage
    var onCrop: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = context.coordinator

        return cropViewController
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {}

    class Coordinator: NSObject, TOCropViewControllerDelegate {
        var parent: CropViewControllerWrapper

        init(_ parent: CropViewControllerWrapper) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            parent.onCrop(image)
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
}
