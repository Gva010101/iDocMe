import SwiftUI
import CoreImage
import Photos



// создаю структуру для хранения состояния изображения и его параметров
//в ней будут содержаться картинка, фильтр, значаение контраста и позиция слайдера
struct EditingState {
    var image: UIImage
    var contrastValue: Float
    var isBlackAndWhiteFilterApplied: Bool
    var sliderPosition: Float
}
struct ImageEditorView: View {
    @State private var originalImage: UIImage
    @State private var currentImage: UIImage
    @State private var contrastValue: Float = 1.0
    @State private var isBlackAndWhiteFilterApplied: Bool = false
    @State private var showingCropper = false
    @State private var blackAndWhiteImage: UIImage?

    //инициализирую историю изменений
    //создаю пустой массив для хранения изменений и индех текущего шага в истории ничнаем с 0
    @State private var editingHistory: [EditingState] = []
    @State private var currentStepIndex = 0
    @State private var currentScale: CGFloat = 1


    

    @Environment(\.presentationMode) var presentationMode

    let ciContext = CIContext()
    var onSave: (UIImage) -> Void

    //создаю инициализаую двух параметров с image и onSave. а после иницциализирую нудные свойства свойства такие как оригинал, выбранное метод сохранения  и массив истории
    init(image: UIImage, onSave: @escaping (UIImage) -> Void) {
        self._originalImage = State(initialValue: image.adjustedForOrientation())
        self._currentImage = State(initialValue: image.adjustedForOrientation())
        self.onSave = onSave
        _editingHistory = State(initialValue: [EditingState(image: image.adjustedForOrientation(), contrastValue: 1.0, isBlackAndWhiteFilterApplied: false, sliderPosition: 1.0)]) // Инициализация истории
    }

    var body: some View {
        VStack {
            Image(uiImage: currentImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
          


            HStack {
                Button("Оригинал") {
                    resetToOriginal()
                }

                .padding()

                Button("Фильтр 1: Черно-белый с контрастом") {
                    applyBlackAndWhiteFilter()

                }
                .padding()

                Button(action: {
                    showingCropper = true

                }) {
                    Image(systemName: "crop.rotate")
                    //  .font(.system(size: 42.0))
                        .imageScale(.large)
                }
                .padding()
                .sheet(isPresented: $showingCropper) {
                    CropViewControllerWrapper(image: currentImage) { croppedImage in
                        currentImage = croppedImage.adjustedForOrientation()
                        isBlackAndWhiteFilterApplied = false
                        blackAndWhiteImage = nil
                        saveCurrentState() // Сохранение результата кадрирования в историю
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }

            if isBlackAndWhiteFilterApplied {
                Slider(value: $contrastValue, in: 0.0...2.0, step: 0.2, onEditingChanged: { editing in
                    if !editing {
                        saveCurrentState() // Сохранение состояния после завершения редактирования ползунка
                    }
                }) {
                    Text("Контраст")
                }
                .tint(.gray)
                .padding(.horizontal, 20)
                .onChange(of: contrastValue) { a, b in
                    applySaturationToBlackAndWhiteImage()
                }
            }

            HStack {


                Button(action: undoAction) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .disabled(currentStepIndex == 0) // Отключаем, если нет предыдущих шагов

                Button(action: redoAction) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(currentStepIndex >= editingHistory.count - 1) // Отключаем, если нет шагов для повтора
            }
            .padding()

            Button("Сохранить изображение") {
                saveImage()
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }

    // Сохранение текущего состояния изображения и параметров фильтров в историю
    private func saveCurrentState() {
        let newState = EditingState(image: currentImage, contrastValue: contrastValue, isBlackAndWhiteFilterApplied: isBlackAndWhiteFilterApplied, sliderPosition: contrastValue)

        // Сравниваем новое состояние с текущим, чтобы избежать избыточных сохранений
        if editingHistory.isEmpty || !isSameState(editingHistory[currentStepIndex], newState) {
            if currentStepIndex < editingHistory.count - 1 {
                // Удаляем старую историю, если были отменены действия
                editingHistory = Array(editingHistory.prefix(currentStepIndex + 1))

                print("ee")
            }
            editingHistory.append(newState)
            currentStepIndex = editingHistory.count - 1
            print("SAVE HISTORY currentStepIndex =\(currentStepIndex), editingHistory.count = \(editingHistory.count)")
        }
    }
//перезаписывание состояния
    private func isSameState(_ state1: EditingState, _ state2: EditingState) -> Bool {
        return state1.contrastValue == state2.contrastValue &&
        state1.isBlackAndWhiteFilterApplied == state2.isBlackAndWhiteFilterApplied &&
        state1.image.pngData() == state2.image.pngData() &&
        state1.sliderPosition == state2.sliderPosition
    }


     //Функция для отмены последнего действия
        private func undoAction() {
            guard currentStepIndex > 0 else { return }
            currentStepIndex -= 1
            applyEditingState(editingHistory[currentStepIndex])
            print("undoAction назад")
        }
    
        // Функция для повтора действия
        private func redoAction() {
            guard currentStepIndex < editingHistory.count - 1 else { return }
            currentStepIndex += 1
            applyEditingState(editingHistory[currentStepIndex])
            print("redoAction вперед")
        }
    
        // Применение определенного состояния редактирования
        private func applyEditingState(_ state: EditingState) {
            currentImage = state.image
            contrastValue = state.contrastValue
            isBlackAndWhiteFilterApplied = state.isBlackAndWhiteFilterApplied
            blackAndWhiteImage = isBlackAndWhiteFilterApplied ? state.image : nil
        }

    // Сброс всех изменений
    private func resetToOriginal() {
        currentImage = originalImage
        blackAndWhiteImage = nil
        contrastValue = 1.0
        isBlackAndWhiteFilterApplied = false
        saveCurrentState() // Сохранение оригинального состояния
    }

    // Применение черно-белого фильтра
    private func applyBlackAndWhiteFilter() {
        guard let ciImage = CIImage(image: currentImage) else { return }
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0.0, forKey: kCIInputSaturationKey) // Убираем цвет
        filter?.setValue(1.0, forKey: kCIInputContrastKey) // Начальный контраст

        if let outputImage = filter?.outputImage, let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) {
            let bwImage = UIImage(cgImage: cgImage).fixedOrientation()
            blackAndWhiteImage = bwImage
            currentImage = bwImage
            isBlackAndWhiteFilterApplied = true
            contrastValue = 1.0
            saveCurrentState() // Сохраняем изменение в историю
        }
    }

    // Применение изменения контраста к черно-белому изображению
    private func applySaturationToBlackAndWhiteImage() {
        guard let bwImage = blackAndWhiteImage, let ciImage = CIImage(image: bwImage) else { return }
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(contrastValue, forKey: kCIInputContrastKey)

        if let finalOutputImage = contrastFilter?.outputImage,
           let cgImage = ciContext.createCGImage(finalOutputImage, from: finalOutputImage.extent) {
            DispatchQueue.main.async {
                self.currentImage = UIImage(cgImage: cgImage).fixedOrientation()
            }
        }
    }

    // Сохранение текущего изображения
    private func saveImage() {
        onSave(currentImage)
        print("AAAAA currentStepIndex = \(currentStepIndex)  editingHistory. count - 1 \(editingHistory.count - 1)")
    }
}

// Метод для исправления ориентации изображений
extension UIImage {
    func adjustedForOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }

    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}

