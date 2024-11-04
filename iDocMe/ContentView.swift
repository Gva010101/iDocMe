//
//  ContentView.swift
//  iDocMe
//
//  Created by Vladimir Grishchenkov on 20.08.2024.
//
/*Улучшение асинхронности: Для загрузки, сохранения и удаления фотографий можно использовать DispatchQueue, чтобы операции с файловой системой не блокировали основной поток.

 Обработка ошибок:

 Добавь больше сообщений об ошибках или UI-индикацию, чтобы пользователю было ясно, когда что-то пошло не так при сохранении или загрузке изображений.
 Оптимизация интерфейса:

 Если в приложении будут использоваться большие изображения, стоит подумать об оптимизации их отображения и кешировании, чтобы приложение оставалось отзывчивым.
*/
import SwiftUI

struct ContentView: View {
    init() {
        // Настраиваем фон и стиль TabBar через UIKit
        let appearance = UITabBarAppearance()
    //    appearance.backgroundColor = UIColor.systemGray6 // Цвет фона таббара
     //   UITabBar.appearance().standardAppearance = appearance


        // Это нужно для поддержки настройки фона в iOS 15+
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView {
            ScanView()
                .tabItem {
                    Label("Скан", systemImage: "scanner")
                }
            Albums()
                .tabItem {
                    Label("Альбомы", systemImage: "photo")
                }
            UserSettings()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
        .accentColor(.blue) // Цвет активных иконок и текста
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

