import SwiftUI
import VisionKit
import PhotosUI

struct ScanView: View {
    @ObservedObject private var photoManager = PhotoManager()
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var selectedImageName: String?
    @State private var showingEditor = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: Set<String> = [] // Массив для отслеживания выбранных изображений
    @State private var selectAll: Bool = false // Переменная для состояния "Выбрать все".
    let columnLayout = Array(repeating: GridItem(), count: 3)


    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationView {

            VStack {
                if photoManager.myImages.isEmpty {

                    Text("Сделайте фото или загрузите из библиотеки и они будут отображаться тут:")

                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                    //    .foregroundStyle(.white)

                    Spacer()
                } else {
                    ScrollView  {

                        VStack (alignment: .leading){
                            ForEach(photoManager.myImages.sorted{$0.uploadDate > $1.uploadDate}) { myImage in
                                HStack {
                                    if let image = photoManager.loadImage(named: myImage.fileName) {
                                        VStack {
                                            NavigationLink(destination: ImageEditorView(image: image) { editedImage in
                                                photoManager.replaceImage(named: myImage.fileName, with: editedImage)
                                            }) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(maxWidth: .infinity, maxHeight: 250, alignment: .trailing)
                                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                                    .shadow(radius: 5)
                                                Spacer()

                                            }
                                            .padding(.leading, 60)

                                            VStack(alignment: .leading) {
                                                Text("Загружено: \(dateFormatter.string(from: myImage.uploadDate))")
                                                    .foregroundColor(.gray)
                                                    .font(.subheadline)
                                                    .padding(.leading, 50)
                                            }
                                        }
                                    } else {

                                        Text("Изображение недоступно")
                                            .foregroundColor(.red)
                                    }

                                    VStack {
                                        ButtonDelete(fileName: myImage.fileName) { fileName in
                                            photoManager.deletePhoto(named: fileName)
                                        }
                                        .padding(.trailing, 15) // Смещаем кнопки левее

                                        ButtonEdit(fileName: myImage.fileName, photoManager: photoManager)
                                            .padding(.trailing, 15)

                                        Button(action: {
                                            if selectedImages.contains(myImage.fileName) {
                                                selectedImages.remove(myImage.fileName)
                                                print("1")

                                                if selectedImages.isEmpty {
                                                    selectAll = false
                                                }
                                            } else {
                                                selectedImages.insert(myImage.fileName)
                                                selectAll = true
                                                print("2")

                                            }
                                        }) {
                                            Image(systemName: selectedImages.contains(myImage.fileName) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(.blue)
                                                .font(.headline)
                                                .padding(.trailing)
                                        }


                                    }


                                }

                            }
                        }

                    }

                }

                HStack {
                    ClearPhotosButton(photoManager: photoManager)
                        .disabled(photoManager.myImages.isEmpty)
                    CameraButton(showingCamera: $showingCamera, photoManager: photoManager)
                    PhotosPickerView(selectedItems: $selectedItems, photoManager: photoManager)
                    Button(action: {
                         if selectAll {
                             // Снять выбор со всех
                             selectedImages.removeAll()
                         } else {
                             // Выбрать все
                             selectedImages = Set(photoManager.myImages.map { $0.fileName })
                         }
                         selectAll.toggle()
                     }) {
                         // Показать галочку, если все выбрано, и кружок, если не выбрано
                         Image(systemName: selectAll ? "checkmark.circle.fill" : "circle")
                             .font(.largeTitle)
                             .foregroundColor(.blue)
                     }
                     .padding()
                }
                .background(Color.gray)

                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
                .padding(5)

            }

            .onAppear {
                photoManager.loadSavedPhotos()

            }
            .background(Color.black)


        }

    }
}

#Preview {
    ContentView()
}
