//
//  ButtonsImage.swift
//  iDocMe
//
//  Created by Vladimir Grishchenkov on 01.10.2024.
//

import Foundation
import SwiftUI

struct ButtonDelete: View {
    let fileName: String
    let onDelete: (String) -> Void

    var body: some View {
        Button(action: {
            withAnimation {
                onDelete(fileName)
            }
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
                .padding()
        }
    }
}








struct ButtonEdit: View {
    let fileName: String
    @ObservedObject var photoManager: PhotoManager

    var body: some View {
        // Получаем изображение
        if let image = photoManager.loadImage(named: fileName) {
            NavigationLink(destination: ImageEditorView(image: image) { editedImage in
                photoManager.replaceImage(named: fileName, with: editedImage)
            }) {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.blue)
                    .padding()
            }
        } else {
            // Альтернативное представление, если изображение отсутствует
            Button(action: {
                // Здесь можно обработать нажатие, если изображение отсутствует
                print("Изображение недоступно для редактирования")
            }) {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.gray) // Или другой цвет для недоступной кнопки
                    .padding()
            }
            .disabled(true) // Делаем кнопку неактивной
        }
    }
}



struct ButtonToAlbum: View {
    var body: some View {
        Button(action: {
        }) {
            Image(systemName: "rectangle.stack.badge.plus")
                .foregroundColor(.blue)
                .padding()
        }
        .buttonStyle(PlainButtonStyle()) 
    }
}
struct ButtonExportImage: View {
    var body: some View {
        Button(action: {
        }) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.blue)
                .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
struct ButtonChooseImage: View {
    var body: some View {
        Button(action: {
        }) {
            Image(systemName: "circle")
                .foregroundColor(.blue)
                .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

