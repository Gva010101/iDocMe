
//
//  ButtonView.swift
//  iDocMe
//
//  Created by Vladimir Grishchenkov on 02.10.2024.
//
import Foundation
import SwiftUI
import PhotosUI

struct CameraButton: View {
    @Binding var showingCamera: Bool
    var photoManager: PhotoManager

    var body: some View {
        Button(action: {
            showingCamera = true
        }) {
            Image(systemName: "camera")

                .symbolVariant(.circle.fill)  // Добавление варианта символа
                .imageScale(.large)           // Использование крупного масштаба для символа
                .font(.system(size: 44))      // Увеличение размера через шрифт
                .foregroundColor(.blue)       // Цвет символа
            
                .padding()
                
        }
        .sheet(isPresented: $showingCamera) {
            DocumentCamera { result in
                switch result {
                case .success(let scan):
                    photoManager.saveScannedDocuments(scan)
                case .failure(let error):
                    print("Error scanning documents: \(error)")
                }
                showingCamera = false
            }
        }
    }
}


struct PhotosPickerView: View {
    @Binding var selectedItems: [PhotosPickerItem]
    @ObservedObject var photoManager: PhotoManager

    var body: some View {
        PhotosPicker(selection: $selectedItems, matching: .images) {

            Image(systemName: "photo.on.rectangle.angled")

                .symbolVariant(.circle.fill)  // Добавление варианта символа
                .imageScale(.large)           // Использование крупного масштаба для символа
                .font(.system(size: 44))      // Увеличение размера через шрифт
                .foregroundColor(.blue)       // Цвет символа
                .padding()
            
        }
        
        .onChange(of: selectedItems) {oldname, newItems in
            for item in newItems {
                Task {
                    await loadImage(from: item)
                }
            }
            selectedItems = []
        }
    }

    private func loadImage(from item: PhotosPickerItem) async {
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            photoManager.addImageFromGallery(image: image)
        }
    }
}

struct ClearPhotosButton: View {
    var photoManager: PhotoManager

    var body: some View {
        Button(action: {
            photoManager.clearPhotos()
        }) {
            Image(systemName: "trash.circle")
                .imageScale(.large)           // Использование крупного масштаба для символа
                .font(.system(size: 44))      // Увеличение размера через шрифт
                .foregroundColor(.red)       // Цвет символа
                
                .padding()
        }
        
    }
}

#Preview {
    ScanView()
}

//MARK: old buttons
////  ButtonView.swift
////  iDocMe
////
////  Created by Vladimir Grishchenkov on 02.10.2024.
////
//import Foundation
//import SwiftUI
//import PhotosUI
//
//
//struct CameraButton: View {
//    @Binding var showingCamera: Bool
//    var photoManager: PhotoManager
//
//    var body: some View {
//        Button(action: {
//            showingCamera = true
//        }) {
//            Label("Сделайте фото", systemImage: "scanner")
//                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
//                .font(.system(.title, design: .rounded, weight: .light))
//                .foregroundColor(.blue)
//                .background(Capsule().stroke(.blue, lineWidth: 2))
//        }
//        .sheet(isPresented: $showingCamera) {
//            DocumentCamera { result in
//                switch result {
//                case .success(let scan):
//                    photoManager.saveScannedDocuments(scan)
//                case .failure(let error):
//                    print("Error scanning documents: \(error)")
//                }
//                showingCamera = false
//            }
//        }
//    }
//}
//
//
//
//struct PhotosPickerView: View {
//    @Binding var selectedItems: [PhotosPickerItem]
//    @ObservedObject var photoManager: PhotoManager
//
//    var body: some View {
//        PhotosPicker(selection: $selectedItems, matching: .images) {
//            Label("Добавить изображение", systemImage: "photo.on.rectangle.angled")
//                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
//                .font(.system(.title, design: .rounded, weight: .light))
//                .foregroundColor(.blue)
//                .background(Capsule().stroke(.blue, lineWidth: 2))
//
//        }
//        .onChange(of: selectedItems) {oldname, newItems in
//            for item in newItems {
//                Task {
//                    await loadImage(from: item)
//                }
//            }
//            selectedItems = []
//        }
//    }
//
//    private func loadImage(from item: PhotosPickerItem) async {
//        if let data = try? await item.loadTransferable(type: Data.self),
//           let image = UIImage(data: data) {
//            photoManager.addImageFromGallery(image: image)
//        }
//    }
//}
//
//struct ClearPhotosButton: View {
//    var photoManager: PhotoManager
//
//    var body: some View {
//        Button(action: {
//            photoManager.clearPhotos()
//        }) {
//            Label("Удалите изображения", systemImage: "trash")
//                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
//                .font(.system(.title, design: .rounded, weight: .light))
//                .foregroundColor(.blue)
//                .background(Capsule().stroke(.blue, lineWidth: 2))
//        }
//    }
//}

