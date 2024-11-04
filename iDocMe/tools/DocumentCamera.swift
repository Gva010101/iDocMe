


import Foundation
import SwiftUI
import VisionKit

@available(iOS 15, *)

public struct DocumentCamera: UIViewControllerRepresentable {

    public init(
        resultAction: @escaping ResultAction
    ) {
        self.resultAction = resultAction
    }

    public typealias ResultAction = (Result<VNDocumentCameraScan, Error>) -> Void
    private let resultAction: ResultAction

    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(resultAction: resultAction)
    }

    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    public class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let resultAction: ResultAction

        public init(resultAction: @escaping ResultAction) {
            self.resultAction = resultAction
        }

        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            resultAction(.success(scan))
        }

        public func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            resultAction(.failure(error))
        }

        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            resultAction(.failure(NSError(domain: "Document scan cancelled", code: -1, userInfo: nil)))
        }
    }
}
