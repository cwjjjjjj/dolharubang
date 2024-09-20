//
//  DolView.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/20/24.
//

import SceneKit
import SwiftUI


// MARK: 3D 돌 출력 뷰
struct DolView : UIViewRepresentable {
    
    
    //    @Binding var selectedFaceShape : FaceShape
    @Binding var selectedFace : Face
    @Binding var selectedFaceShape : FaceShape
    @Binding var selectedAccessory : Accessory
    @Binding var selectedSign : Sign
    @Binding var selectedMail : Mail
    @Binding var selectedNest : Nest
    @Binding var signText : String
    @Binding var sign : Bool
    
    // 돌 굴러가는 도중에 꾸미기 누르면 버그 발생해서 막기위함
    @Binding var enable : Bool
    
    class Coordinator: NSObject {
        var parent: DolView
        private var lastPanTranslation: CGPoint = .zero
        
        init(parent: DolView) {
            self.parent = parent
        }
        
        // 터치했을때의 액션
        @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
            let scnView = gestureRecognizer.view as! SCNView
            let location = gestureRecognizer.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: nil)
            
            if let hitResult = hitResults.first {
                let touchedNode = hitResult.node
                
                print("touchNode ", touchedNode)
                
                // 노드의 이름을 기반으로 터치된 노드를 확인합니다.
                if let parentNode = touchedNode.parent, parentNode.name == "\(parent.selectedSign) reference" {
                    print("터치된 노드의 부모 노드가 \(parent.selectedSign) reference입니다.")
                    parent.sign = true
                }
                
                if let parentNode = touchedNode.parent, parentNode.name == "\(parent.selectedMail) reference" {
                    print("터치된 노드의 부모 노드가 \(parent.selectedMail) reference입니다.")
                    let moveAction = SCNAction.moveBy(x: 0, y: 0, z: 3, duration: 1)
                    parentNode.runAction(moveAction)
                }
                
                if let parentNode = touchedNode.parent, parentNode.name == "\(parent.selectedFace)" {
                    print("터치된 노드의 부모 노드가 \(parent.selectedFace) reference입니다.")
                    
                    parent.enable = false
                    // 돌 굴러가유
                    // 노드가 회전할 때의 회전과 이동 애니메이션 정의
                    let rotateAction1 = SCNAction.rotate(by: -2 * .pi, around: SCNVector3(0, 0, 1), duration: 3)
                    let moveAction1 = SCNAction.moveBy(x: 4, y: 0, z: 0, duration: 3)
                    let actionGroup1 = SCNAction.group([rotateAction1, moveAction1])
                    let actionGroup2 = actionGroup1.reversed()
                    let reverseMoveSequence = SCNAction.sequence([actionGroup1, actionGroup2])
                    
                    // 수평으로 맞추기 위한 회전 액션 정의
                    let rotateToHorizontal = SCNAction.rotate(toAxisAngle: SCNVector4(0, 1, 0, 0), duration: 0.5)
                    
                    // 전체 액션 시퀀스 정의
                    let completeSequence = SCNAction.sequence([reverseMoveSequence, rotateToHorizontal])
                    
                    // 액션이 완료된 후 실행할 작업 정의
                    let completionAction = SCNAction.run { node in
                        print("액션이 완료되었습니다.")
                        self.parent.enable = true
                        // 액션이 끝나면 꾸미기 버튼 가능하게
                       }
                    
                    let finalSequence = SCNAction.sequence([completeSequence, completionAction])
                        
                    
                    // parentNode와 accessoryNode 모두에 액션 적용
                    parentNode.runAction(finalSequence)
                    
                    if let accessoryNode = scnView.scene?.rootNode.childNode(withName: "\(parent.selectedAccessory) reference", recursively: true) {
                        accessoryNode.runAction(completeSequence)
                    }
                }
            }
        }
        
        // 팬 제스처 핸들러 추가
        @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let scnView = gestureRecognizer.view as! SCNView
            
            if gestureRecognizer.state == .began {
                lastPanTranslation = translation
            }
            
            if gestureRecognizer.state == .changed {
                let deltaX = Float(translation.x - lastPanTranslation.x)
                let deltaY = Float(translation.y - lastPanTranslation.y)
                
                // X, Y축 회전 적용
                let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(deltaX * .pi / 180), z: 0, duration: 0.1)
                let rotationX = SCNAction.rotateBy(x: CGFloat(deltaY * .pi / 180), y: 0, z: 0, duration: 0.1)
                
                if let faceNode = scnView.scene?.rootNode.childNode(withName: "\(parent.selectedFaceShape) reference", recursively: true) {
                    faceNode.runAction(rotationY)
                    faceNode.runAction(rotationX)
                }
                
                if let accNode = scnView.scene?.rootNode.childNode(withName: "\(parent.selectedAccessory) reference", recursively: true) {
                    accNode.runAction(rotationY)
                    accNode.runAction(rotationX)
                }
                
                lastPanTranslation = translation
            } else if gestureRecognizer.state == .ended {
                // 제스처가 끝났을 때 노드를 수평으로 맞추는 액션 정의
                let resetRotation = SCNAction.rotate(toAxisAngle: SCNVector4(0, 1, 0, 0), duration: 10)
                
                if let faceNode = scnView.scene?.rootNode.childNode(withName: "\(parent.selectedFaceShape) reference", recursively: true) {
                    faceNode.runAction(resetRotation)
                }
                
                if let accNode = scnView.scene?.rootNode.childNode(withName: "\(parent.selectedAccessory) reference", recursively: true) {
                    accNode.runAction(resetRotation)
                }
            }
        }

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    
    // UI가 만들어질때 생성
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = loadScene(faceShape: selectedFaceShape)
        scnView.backgroundColor = UIColor.clear // SCNView의 배경을 투명하게 설정
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false // 기본 조명 자동 활성화 비활성화
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        
        // 탭 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
//         팬 제스처 인식기 추가
               let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
               scnView.addGestureRecognizer(panGesture)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
        // 씬이 로드되어 있다고 가정합니다.
        guard let scene = uiView.scene else {
            print("씬이 없습니다.")
            return
        }
        
        
        // 모든 노드 보이게 설정
        showAllNodes(rootNode: scene.rootNode)
        
        // showChild이 false일 때 child 노드만 보이게 설정
        if let parentNode = scene.rootNode.childNode(withName: "\(selectedFaceShape) reference", recursively: true) {
            moveNodeToPosition(node: parentNode, x: 0.0, y: 0.0, z: 0.0) // x, y, z 값은 원하는 위치로 설정
            // 선택한 얼굴형만 보이게
            hideAllNodesExcept(node: parentNode, rootNode: scene.rootNode)
            if let childNode = parentNode.childNode(withName: "\(selectedFace)", recursively: true) {
                showAllNodes(rootNode: parentNode)
                // 선택한 얼굴형중 선택한 표정만
                hideAllNodesExcept(node: childNode, rootNode: parentNode) // 선택 노드만 보이게 설정
                
            } else {
                print("\(selectedFace) 노드가 씬에 존재하지 않습니다.")
            }
        }
        
        // Accessory Node Hide On Off
        if let accessoryNode = scene.rootNode.childNode(withName: "Face" , recursively: true){
            if let childAccessoryNode = accessoryNode.childNode(withName: "\(selectedAccessory) reference", recursively: true) {
                // 선택한 얼굴형중 선택한 표정만black_glasses reference
                print("출력 \(selectedAccessory) reference")
                showAllNodes(rootNode: accessoryNode)
                hideAllNodesExcept(node: childAccessoryNode, rootNode: accessoryNode) // 선택 노드만 보이게 설정
                moveNodeToPosition(node: childAccessoryNode, x: 0.0, y: 0.0, z: 0.1) // x, y, z 값은 원하는 위치로 설정
            } else {
                print("\(selectedFace) 노드가 씬에 존재하지 않습니다.")
            }
        }
        
        // Sign Node Hide On Off
        if let signNode = scene.rootNode.childNode(withName: "Sign" , recursively: true){
            if let childSignNode = signNode.childNode(withName: "\(selectedSign) reference", recursively: true) {
                // 선택한 얼굴형중 선택한 표정만black_glasses reference
                print("출력 \(selectedSign) reference")
                showAllNodes(rootNode: signNode)
                hideAllNodesExcept(node: childSignNode, rootNode: signNode) // 선택 노드만 보이게 설정
                moveNodeToPosition(node: childSignNode, x: -1.1, y: 0.4, z: -0.15) // x, y, z 값은 원하는 위치로 설정
                
                
            } else {
                print("\(selectedFace) 노드가 씬에 존재하지 않습니다.")
            }
        }
        
        if let textNode = scene.rootNode.childNode(withName: "text" , recursively: true){
            print("textNode : ",textNode)
            updateTextNode(textNode, newText: signText)
            moveNodeToPosition(node: textNode, x: -1.3, y: 0.2, z: 0.5) // x, y, z 값은 원하는 위치로 설정
            
        }
        
        
        // Nest Node Hide On Off
        if let nestNode = scene.rootNode.childNode(withName: "Nest" , recursively: true){
            if let childNestNode = nestNode.childNode(withName: "\(selectedNest) reference", recursively: true) {
                // 선택한 얼굴형중 선택한 표정만 black_glasses reference
                print("출력 \(selectedNest) reference")
                showAllNodes(rootNode: nestNode)
                hideAllNodesExcept(node: childNestNode, rootNode: nestNode) // 선택 노드만 보이게 설정
                moveNodeToPosition(node: childNestNode, x: 0.0, y: -0.8, z: 0.0) // x, y, z 값은 원하는 위치로 설정
            } else {
                print("\(selectedNest) 노드가 씬에 존재하지 않습니다.")
            }
        }
        
       
        
        // Mail Node Hide On Off
        if let mailNode = scene.rootNode.childNode(withName: "Mail" , recursively: true){
            if let childMailNode = mailNode.childNode(withName: "\(selectedMail) reference", recursively: true) {
                // 선택한 얼굴형중 선택한 표정만black_glasses reference
                print("출력 \(selectedMail) reference")
                showAllNodes(rootNode: mailNode)
                hideAllNodesExcept(node: childMailNode, rootNode: mailNode) // 선택 노드만 보이게 설정
                moveNodeToPosition(node: childMailNode, x: 4.0, y: 1.0, z: -0.6) // x, y, z 값은 원하는 위치로 설정
            } else {
                print("\(selectedFace) 노드가 씬에 존재하지 않습니다.")
            }
        }
        
       
        
        print("어떤것이 Hidden인지")
        printNodeDetails(node: scene.rootNode)
        print("씬의 노드 출력 끝")
        
    }
}



func loadScene(faceShape : FaceShape) -> SCNScene {
    let scene = SCNScene(named: "Dols.scnassets/DolGroup.scn") ?? SCNScene()
    
    //    printNodeDetails(node: scene.rootNode)
    
    
    let accessoryNode = addAccessory()
    scene.rootNode.addChildNode(accessoryNode)
    
    let signNode = addSign()
    scene.rootNode.addChildNode(signNode)
    
    
    let mailNode = addMail()
    scene.rootNode.addChildNode(mailNode)
    
    let nestNode = addNest()
    scene.rootNode.addChildNode(nestNode)
    
//    for node in scene.rootNode.childNodes {
//        // MARK: 모델 크기 조절
//        node.scale = SCNVector3(x: 0.6, y: 0.6 , z: 0.6)
//        
//    }
    
    
    // shading 값 설정
    updateMaterialsToPhysicallyBased(for: scene)
    
    
    let textNode = addTextNode()
    scene.rootNode.addChildNode(textNode)
    

    let cameraNode = makeCamera()
    scene.rootNode.addChildNode(cameraNode)
    
    
    
    // HDRI 파일의 URL을 가져옵니다.
//    guard let hdrURL = Bundle.main.url(forResource: "straw_rolls_field_01_4k", withExtension: "hdr") else {
//        print("HDR 이미지 파일을 찾을 수 없습니다.")
//        return scene
//    }
//    
//    scene.lightingEnvironment.contents = hdrURL
    
//    guard let hdrURL = Bundle.main.url(forResource: "lythwood_field_4k", withExtension: "hdr") else {
//      print("HDR 이미지 파일을 찾을 수 없습니다.")
//      return scene
//    }
//    scene.lightingEnvironment.contents = hdrURL
//
//    scene.lightingEnvironment.intensity = 2.0 // 강도를 2배로 설정 (기본값은 1.0)
//    // HDRI 배경 회전 (예: Y축 기준 180도 회전)
//    let rotationMatrix = SCNMatrix4MakeRotation(Float.pi, 0, 1, 0)
//    scene.lightingEnvironment.contentsTransform = rotationMatrix
    
    
    
    // 면광원 조명 추가
    let areaLightNode = makeAreaLight(intensity: 9000, name: "areaLight", position: SCNVector3(-8, 8, 30), areaExtents: simd_float3(x: 15, y: 15, z: 1))
    scene.rootNode.addChildNode(areaLightNode)
    
    let areaLightNode2 = makeAreaLight(intensity: 6000, name: "areaLight2", position: SCNVector3(8, -8, 10), areaExtents: simd_float3(x: 7, y: 7, z: 1.0))
    scene.rootNode.addChildNode(areaLightNode2)
//
//   // 점광원 조명 추가, 빼면 어두워짐
//    let makeOmniLightNode = makeOmniLight()
//    scene.rootNode.addChildNode(makeOmniLightNode)
//    
//    let ambientLightNode = makeAmbientLight()
//    scene.rootNode.addChildNode(ambientLightNode)
//    
//    let directionLightNode = makeDirectionalLight(X: 10, Y: 1, Z: 150, intensity: 500, name: "directionLight")
//    scene.rootNode.addChildNode(directionLightNode)
//    
//    let spotLightNode = makeSpotLight()
//    scene.rootNode.addChildNode(spotLightNode)
    
    scene.rootNode.name = "model"
    

    
  
    
    return scene
}


