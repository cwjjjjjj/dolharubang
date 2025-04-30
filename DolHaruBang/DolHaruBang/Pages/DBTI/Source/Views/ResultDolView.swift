import SceneKit
import SwiftUI


// MARK: 3D 돌 출력 뷰
struct ResultDolView : UIViewRepresentable {
    
    var selectedFaceShape : FaceShape
    
    // UI가 만들어질때 생성
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = loadScene(faceShape: selectedFaceShape)
        scnView.backgroundColor = UIColor.clear // SCNView의 배경을 투명하게 설정
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false // 기본 조명 자동 활성화 비활성화
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        
        return scnView
    }
    
    
    // MARK: UpdateView
    func updateUIView(_ uiView: SCNView, context: Context) {
        
        // 씬이 로드되어 있다고 가정합니다.
        guard let scene = uiView.scene else {
            print("씬이 없습니다.")
            return
        }
        
        // 모든 노드 보이게 설정
        showAllNodes(rootNode: scene.rootNode)
        
        // showChild이 false일 때 child 노드만 보이게 설정
        if let parentNode = scene.rootNode.childNode(withName: "\(selectedFaceShape)", recursively: true) {
            moveNodeToPosition(node: parentNode, x: 0.0, y: 0.0, z: 0.0) // x, y, z 값은 원하는 위치로 설정
            // 선택한 얼굴형만 보이게
            hideAllNodesExcept(node: parentNode, rootNode: scene.rootNode)
//            if let childNode = parentNode.childNode(withName: "\(selectedFaceShape)", recursively: true) {
//                showAllNodes(rootNode: parentNode)
//                // 선택한 얼굴형중 선택한 표정만
//                hideAllNodesExcept(node: childNode, rootNode: parentNode) // 선택 노드만 보이게 설정
//            } else {
//                print("\(selectedFaceShape) 노드가 씬에 존재하지 않습니다.")
//            }
        }
        
        
    }
    
    func loadScene(faceShape : FaceShape) -> SCNScene {
        let scene = SCNScene(named: "Dols.scnassets/\(faceShape).scn") ?? SCNScene()
        
        // shading 값 설정
        updateMaterialsToPhysicallyBased(for: scene)
        
        
        let cameraNode = makeCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        
        // 면광원 조명 추가
        let areaLightNode = makeAreaLight(intensity: 9000, name: "areaLight", position: SCNVector3(-8, 8, 30), areaExtents: simd_float3(x: 15, y: 15, z: 1))
        scene.rootNode.addChildNode(areaLightNode)
        
        let areaLightNode2 = makeAreaLight(intensity: 6000, name: "areaLight2", position: SCNVector3(8, -8, 10), areaExtents: simd_float3(x: 7, y: 7, z: 1.0))
        scene.rootNode.addChildNode(areaLightNode2)
        
        
        scene.rootNode.name = "model"
    
        
        return scene
    }
}
