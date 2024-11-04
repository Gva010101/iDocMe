//MARK: стаый имедж пикер
//
//
//import SwiftUI
//import PhotosUI
//
//struct ImagePickerView: UIViewControllerRepresentable {
//    @ObservedObject var photoManager: PhotoManager
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var config = PHPickerConfiguration()
//        config.selectionLimit = 0 // 0 означает, что можно выбрать неограниченное количество фотографий
//        config.filter = .images // Фильтруем только изображения
//
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = context.coordinator // Назначаем делегата
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//
//    // Создаем координатор, который будет обрабатывать выбранные изображения
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var parent: ImagePickerView
//
//        init(_ parent: ImagePickerView) {
//            self.parent = parent
//        }
//
//        // Обработка выбранных изображений
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            for result in results {
//                // Получаем изображение из каждого выбранного результата
//                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
//                    if let image = image as? UIImage {
//                        DispatchQueue.main.async {
//                            // Сохраняем изображение через PhotoManager
//                            self.parent.photoManager.addImageFromGallery(image: image)
//                        }
//                    } else {
//                        print("Ошибка загрузки изображения: \(String(describing: error))")
//                    }
//                }
//            }
//            picker.dismiss(animated: true)
//        }
//    }
//}
//
//
