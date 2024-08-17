//
//  DolView.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/17/24.
//

import SwiftUI
import SceneKit

struct DolView: UIViewRepresentable {
    let objName: String
    let objExtension: String
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // 카메라 제어 비활성화
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear // 배경색을 투명하게 설정

        let scene = SCNScene()
        
        // .obj 파일 로드
        if let objURL = Bundle.main.url(forResource: objName, withExtension: objExtension) {
            let node = SCNNode()

            do {
                let objScene = try SCNScene(url: objURL, options: nil)
                
                for childNode in objScene.rootNode.childNodes {
                    node.addChildNode(childNode)
                }
            } catch {
                print("Failed to load .obj file: \(error)")
            }

            // 모델의 크기 조정 (초기 확대)
            node.scale = SCNVector3(x: 2, y: 2, z: 2) // 원하는 값으로 조정

            scene.rootNode.addChildNode(node)
        } else {
            print("Failed to find .obj file in the bundle")
        }

        // 카메라 설정
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5) // 카메라 위치 조정
        cameraNode.camera?.automaticallyAdjustsZRange = true // Z축 자동 조정 활성화
        scene.rootNode.addChildNode(cameraNode)

        sceneView.scene = scene
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // 업데이트 로직 (필요한 경우 구현)
    }
}
