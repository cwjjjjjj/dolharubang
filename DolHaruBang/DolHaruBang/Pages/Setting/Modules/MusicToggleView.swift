//
//  MusicToggleView.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/29/25.
//


import SwiftUI

struct MusicToggleView: View {
    @AppStorage("isBGMMusicOn") var isBGMMusicOn: Bool = true

        var body: some View {
            Toggle("", isOn: $isBGMMusicOn)
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "A5CD3B")))
                .onChange(of: isBGMMusicOn) {
                    DispatchQueue.main.async {
                        if isBGMMusicOn {
                            AudioManager.shared.playBackgroundMusic()
                        } else {
                            AudioManager.shared.stopBackgroundMusic()
                        }
                    }
                }
        }
    
}
