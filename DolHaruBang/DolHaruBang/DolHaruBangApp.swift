//
//  DolHaruBangApp.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/28/24.
//

import SwiftUI
import AVFoundation
import KakaoSDKAuth
import KakaoSDKCommon
import ComposableArchitecture
import HapticsManager

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        KakaoSDK.initSDK(appKey: "647eae58ed750bd954a023e3d08e96b3")
        
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}

@main
struct DolHaruBangApp: App {    
    @StateObject private var userManager = UserManager()
    //    let persistenceController = PersistenceController.shared
    
    init() {
        UserDefaults.haptics.register(defaults: [
            HapticUserDefaultsKey.hapticEffectsEnabled : true
        ])
        KakaoSDK.initSDK(appKey: "647eae58ed750bd954a023e3d08e96b3")
    }
    
    var body: some Scene {
        WindowGroup {
//            PointView( store: Store(initialState: LoginFeature.State()) { LoginFeature() })
            Demo(store: Store(initialState: NavigationFeature.State()) { NavigationFeature() }) { nav in
                EntryPointView( nav: nav, store: Store(initialState: LoginFeature.State()) { LoginFeature() })
            }
                .onAppear {
                // 저장된 설정값 확인 후 재생/정지
                let isMusicOn = UserDefaults.standard.bool(forKey: "isBGMMusicOn")
                if isMusicOn {
                    AudioManager.shared.playBackgroundMusic()
                } else {
                    AudioManager.shared.stopBackgroundMusic()
                }
            }

                .environmentObject(userManager)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        let handled = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

// 어플리케이션의 생명 주기를 관리함
/*
 UIResponder - 이벤트 처리 클래스
 UIApplicationDelegate - 이벤트 처리 메서드가 정의되어 있는 프로토콜을 준수
 */

// 앱이 실행되고 초기화 될 때 호출되는 메서드 from UIApplicationDelegate
/*
 실행중인 UIApplication을 받아서 실행 성공여부를 반환
 didFinishLaunchingWithOptions의 경우 UIApplication.LaunchOptionsKey의 배열 타입으로 어플이 어떤 경유로 시작됐는지에 대한 정보를 담고 있음
 */
class AppDelegate: UIResponder, UIApplicationDelegate {
    // kakao
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        KakaoSDK.initSDK(appKey: "647eae58ed750bd954a023e3d08e96b3")
        
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return false
    }
    
    
}

