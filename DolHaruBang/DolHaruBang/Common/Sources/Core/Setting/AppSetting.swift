//
//  AppSetting.swift
//  DolHaruBang
//
//  Created by 양희태 on 1/22/25.
//

import AVFoundation
import UIKit

class AppSettings: ObservableObject {
    static let shared = AppSettings()  // 싱글톤 인스턴스 추가
    
    @Published var isHapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticEnabled, forKey: "isHapticEnabled")
        }
    }
    
    @Published var isBGMEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBGMEnabled, forKey: "isBGMEnabled")
            if isBGMEnabled {
                AudioManager.shared.playBackgroundMusic()
            } else {
                AudioManager.shared.stopBackgroundMusic()
            }
        }
    }
    
    private init() {
        self.isHapticEnabled = UserDefaults.standard.bool(forKey: "isHapticEnabled")
        self.isBGMEnabled = UserDefaults.standard.bool(forKey: "isBGMEnabled")
    }
    
    func triggerHaptic() {
        guard isHapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
