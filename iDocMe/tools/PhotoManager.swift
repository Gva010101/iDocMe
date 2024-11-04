// Pho// PhotoManager.swift
import Foundation
import VisionKit
import UIKit
import SwiftUI
import CoreImage
import Photos

class PhotoManager: NSObject, ObservableObject {
    static let shared = PhotoManager() // Добавлен синглтон для использования PhotoManager.shared

    // Структура Photo для хранения информации об изображениях
    struct MyImage: Identifiable {
        var id: String { fileName } // Используем имя файла как уникальный идентификатор
        let fileName: String
        var uploadDate: Date // Дата загрузки изображения
    }

    @Published var myImages: [MyImage] = [] // Массив объектов Photo

    // Метод для сохранения отсканированных документов
    func saveScannedDocuments(_ scan: VNDocumentCameraScan) {
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Error at page \(pageIndex): Failed to create JPEG data")
                continue
            }
            let fileName = UUID().uuidString + ".jpg"
            let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: filePath)
                let newImage = MyImage(fileName: fileName, uploadDate: Date())
                myImages.append(newImage) // Добавляем фото с датой загрузки
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }

    // Метод для добавления изображения из галереи
    func addImageFromGallery(image: UIImage) {
        print("Добавление изображения в PhotoManager")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Ошибка: не удалось создать JPEG данные")
            return
        }

        let fileName = UUID().uuidString + ".jpg"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        print("Путь для сохранения файла: \(filePath.path)")

        do {
            try imageData.write(to: filePath)
            print("Изображение сохранено по пути: \(filePath.path)")
            let newImage = MyImage(fileName: fileName, uploadDate: Date()) // Создаем объект Photo
            myImages.append(newImage) // Добавляем новое фото в список
        } catch {
            print("Ошибка при сохранении изображения: \(error)")
        }

        print("Текущие изображения: \(myImages)")
    }

    // Метод для загрузки всех сохранённых фотографий
    func loadSavedPhotos() {
        let fileManager = FileManager.default
        let documentsDirectory = getDocumentsDirectory()

        do {
            // Получаем все файлы в директории документов
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: [.creationDateKey])
            print("Все файлы в директории: \(files)")

            // Загрузка файлов без сортировки
            myImages = files.filter { $0.pathExtension == "jpg" }.compactMap { fileURL in
                let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
                let creationDate = attributes?[.creationDate] as? Date ?? Date()
                return MyImage(fileName: fileURL.lastPathComponent, uploadDate: creationDate)
            }

            print("Загруженные изображения без сортировки: \(myImages)")
        } catch {
            print("Ошибка загрузки сохранённых изображений: \(error)")
        }
    }

    // Метод для сохранения изображения
    func saveImage(_ image: UIImage) {
        print("saveImage func")

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let fileName = UUID().uuidString + ".jpg"
            let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try imageData.write(to: filePath)
                let newImage = MyImage(fileName: fileName, uploadDate: Date()) // Создаём объект Photo
                myImages.append(newImage)
                print("Изображение сохранено: \(fileName) по пути \(filePath)")
            } catch {
                print("Ошибка сохранения изображения: \(error)")
            }
        } else {
            print("Ошибка: не удалось создать JPEG данные")
        }
    }

    // Метод для загрузки изображения по имени файла
    func loadImage(named: String) -> UIImage? {
        print("loadImage func")

        let filePath = getDocumentsDirectory().appendingPathComponent(named)
        return UIImage(contentsOfFile: filePath.path)
    }

    // Метод для удаления изображения
    func deletePhoto(named: String) {
        let filePath = getDocumentsDirectory().appendingPathComponent(named)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: filePath)
            myImages.removeAll { $0.fileName == named }
            print("Фото удалено: \(named)")
        } catch {
            print("Ошибка удаления фото: \(error)")
        }
    }

    // Метод для очистки всех изображений
    func clearPhotos() {
        myImages.forEach { image in
            deletePhoto(named: image.fileName)
        }
    }

    func replaceImage(named: String, with image: UIImage) {
        let filePath = getDocumentsDirectory().appendingPathComponent(named)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: filePath)
                print("Изображение перезаписано: \(named)")
            } catch {
                print("Ошибка перезаписи изображения: \(error)")
            }
        } else {
            print("Ошибка: не удалось создать JPEG данные")
        }
    }

    // Получаем директорию документов
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}





