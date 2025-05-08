import SwiftUI
import UIKit
import KakaoSDKShare
import KakaoSDKTemplate

// UIKit 공유 시트 (인스타그램 등 기본 공유용)
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareView: View {
    @Binding var showPopup: Bool
    @Binding var DolImage: UIImage

    @State private var isShareSheetPresented = false
    @State private var shareItems: [Any] = []
    @State private var showSaveAlert = false
    @State private var isKakaoErrorAlert = false
    @State private var kakaoErrorMsg = ""

    var body: some View {
        VStack(alignment: .center, spacing: 12) {

            HStack {
                Text("돌 공유하기")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 118)

                Spacer()

                Button(action: {
                    showPopup = false
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 24)
            }
            .padding(.top, 20)

            VStack {
                Image(uiImage: DolImage)
                    .resizable()
                    .scaledToFit()
            }
            .background(Color.gray.opacity(0.2))
            .frame(width: 272, height: 272)
            .cornerRadius(15)
            .padding(10)

            HStack(spacing: 8) {
                Spacer()
                // 카카오톡 공유
                Button(action: {
                    shareToKakao(image: DolImage)
                }) {
                    Image("kakao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                // 이미지 저장
                Button(action: {
                    UIImageWriteToSavedPhotosAlbum(DolImage, nil, nil, nil)
                    showSaveAlert = true
                }) {
                    Image("image_download")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(width: 320, height: 400)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .sheet(isPresented: $isShareSheetPresented) {
            ActivityView(activityItems: shareItems)
        }
        .alert(isPresented: $showSaveAlert) {
            Alert(title: Text("저장 완료"), message: Text("이미지가 사진 앨범에 저장되었습니다."), dismissButton: .default(Text("확인")))
        }
        .alert(isPresented: $isKakaoErrorAlert) {
            Alert(title: Text("카카오톡 공유 실패"), message: Text(kakaoErrorMsg), dismissButton: .default(Text("확인")))
        }
    }

    // MARK: - 카카오톡 공유 함수
    func shareToKakao(image: UIImage) {
        // 1. 카카오톡 설치 여부 확인
        guard ShareApi.isKakaoTalkSharingAvailable() else {
            kakaoErrorMsg = "카카오톡이 설치되어 있지 않습니다."
            isKakaoErrorAlert = true
            return
        }
        // 2. 이미지 업로드
        ShareApi.shared.imageUpload(image: image) { result, error in
            if let error = error {
                kakaoErrorMsg = error.localizedDescription
                isKakaoErrorAlert = true
                return
            }
            guard let url = result?.infos.original.url else {
                kakaoErrorMsg = "이미지 업로드에 실패했습니다."
                isKakaoErrorAlert = true
                return
            }
            // 3. 템플릿 생성 (imageUrl이 description보다 먼저!)
            let content = Content(
                title: "돌 하루방 공유",
                imageUrl: url, // 반드시 업로드된 URL
                description: "내 돌을 카카오톡으로 공유해요!",
                link: Link(
                    webUrl: URL(string: "https://naver.com")!,
                    mobileWebUrl: URL(string: "https://naver.com")!
                )
            )
            let template = FeedTemplate(content: content)
            // 4. 카카오톡 공유 실행
            ShareApi.shared.shareDefault(templatable: template) { shareResult, error in
                if let error = error {
                    kakaoErrorMsg = error.localizedDescription
                    isKakaoErrorAlert = true
                    return
                }
                if let shareUrl = shareResult?.url {
                    UIApplication.shared.open(shareUrl)
                }
            }
        }
    }
}

// 인스타 스토리 공유 함수
// 페북 개발자 계정 필요
//func shareToInstagramStory(image: UIImage) {
//    guard let imageData = image.pngData() else { return }
//    let pasteboardItems: [String: Any] = [
//        "com.instagram.sharedSticker.backgroundImage": imageData
//    ]
//    let pasteboardOptions = [
//        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60*5)
//    ]
//    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
//
//    let instagramURL = URL(string: "instagram-stories://share")!
//    if UIApplication.shared.canOpenURL(instagramURL) {
//        UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
//    } else {
//        // 인스타그램이 설치되어 있지 않음
//        // 알림 등 처리
//    }
//}

// 인스타그램 스토리공유 버튼 ( DM공유는 외부 사진 공유 불가. )
//                Button(action: {
//                    shareToInstagramStory(image: DolImage)
//                }) {
//                    Image("instagram")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                }
