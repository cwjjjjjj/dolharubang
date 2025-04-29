import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode // SwiftUI에서 현재 뷰를 닫는 데 사용되는 presentationMode 환경 변수
    var sourceType: UIImagePickerController.SourceType // 사진을 선택할 소스 유형 (예: .photoLibrary, .camera)을 지정
    var onImagePicked: (UIImage) -> Void // 이미지를 선택한 후에 호출되는 클로저로, UIImage를 전달

    // SwiftUI와 UIKit 간 상호작용을 위한 중간자
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onImagePicked: onImagePicked) // Coordinator에 클로저 전달
    }

    // UIImagePickerController를 생성하고 초기화하여 반환하는 메서드
    // Context는 coordinator 프로퍼티를 통해 Coordinator 인스턴스에 대한 참조를 제공
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController() // 만들고
        picker.delegate = context.coordinator // 중간자 연결하고
        picker.sourceType = sourceType // 소스타입 결정해둔거 연결하고
        picker.allowsEditing = false // 수정가능 권한 
        return picker // 반환
    }

    // 업데이트용 함수 // 만약 sourceType, allowsEditing 등의 요소들이 바뀌어야 한다면 구현부에 구현 필요!
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { /* */}

    // 중간자 역할인 Coordinator 정의
    /*
     NSObject - Objective-C 기반의 UIImagePickerControllerDelegate 및 UINavigationControllerDelegate를 사용하기 위해 필요
     UIImagePickerControllerDelegate - 이미지 피커에서 발생하는 이벤트를 처리하기 위한 프로토콜(이미지 선택 및 취소 시의 수행 동작 처리)
     UINavigationControllerDelegate - 화면 전환을 제어하거나 상태를 모니터링하는 데 사용되는 프로토콜, 여기서는 UIImagePickerController가 내부적으로 UINavigationController를 기반으로 하기 때문에 채택
     */
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        var onImagePicked: (UIImage) -> Void

        init(_ parent: ImagePicker, onImagePicked: @escaping (UIImage) -> Void) {
            self.parent = parent
            self.onImagePicked = onImagePicked
        }

        // 이미지 고른 후의 동작
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image) // 클로저로 이미지 전달
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        // 취소 시의 동작
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
