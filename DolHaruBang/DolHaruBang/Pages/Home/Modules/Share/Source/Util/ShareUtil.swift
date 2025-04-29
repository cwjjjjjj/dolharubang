//
//  ShareUtil.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/30/25.
//

import UIKit
// 추후 인스타 공유 함수
// 페이스북 개발자 계정 등록을하면 스토리 공유가 가능하다
func shareToInstagramStory(image: UIImage) {
    guard let imageData = image.pngData() else { return }
    let pasteboardItems: [String: Any] = [
        "com.instagram.sharedSticker.backgroundImage": imageData
    ]
    let pasteboardOptions = [
        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60*5)
    ]
    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)

    let instagramURL = URL(string: "instagram-stories://share")!
    if UIApplication.shared.canOpenURL(instagramURL) {
        UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
    } else {
        // 인스타그램이 설치되어 있지 않음
        // 알림 등 처리
    }
}
