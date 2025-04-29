//
//  AudioManager.swift
//  DolHaruBang
//
//  Created by 양희태 on 1/22/25.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}  // 싱글톤 패턴을 위한 private init
    
    func playBackgroundMusic() {
        guard let path = Bundle.main.path(forResource: "SpringHasCome", ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1  // 무한 반복
            audioPlayer?.volume = 0.6
            audioPlayer?.play()
        } catch {
            print("배경음악 재생 실패: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
