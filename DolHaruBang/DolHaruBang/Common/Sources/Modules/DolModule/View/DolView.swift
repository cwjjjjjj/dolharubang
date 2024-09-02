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
    @Binding var signText : String
    @Binding var sign : Bool
    
    class Coordinator: NSObject {
        var parent: DolView
        
        init(parent: DolView) {
            self.parent = parent
        }
        
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
                    // 필요한 액션을 수행합니다.
                    // 예: 부모 노드의 애니메이션 실행 또는 색상 변경 등
                    parent.sign = true
                }
                
                if let parentNode = touchedNode.parent, parentNode.name == "\(parent.selectedMail) reference" {
                    print("터치된 노드의 부모 노드가 \(parent.selectedMail) reference입니다.")
                    // 필요한 액션을 수행합니다.
                    // 예: 부모 노드의 애니메이션 실행 또는 색상 변경 등
                    let moveAction = SCNAction.moveBy(x: 0, y: 0, z: 3, duration: 1)
                    parentNode.runAction(moveAction)
                }
                
                if let parentNode = touchedNode.parent, parentNode.name == "\(parent.selectedFace)" {
                    print("터치된 노드의 부모 노드가 \(parent.selectedFace) reference입니다.")
                    // 예: 부모 노드의 애니메이션 실행 또는 색상 변경 등
                    
                    // 오른쪽 구르기
                    let rotateAction1 = SCNAction.rotate(by: -2 * .pi , around: SCNVector3(0, 0, 1), duration: 3)
                    let moveAction1 = SCNAction.moveBy(x: 4, y: 0, z: 0, duration: 3)
                    
                    //                        let reversedAction1 = rotateAction1.reversed()
                    //                        let reversedAction2 = moveAction1.reversed()
                    
                    // 여러 액션을 담아서 runAction 시킬 수 있다
                    let actionGroup1 = SCNAction.group([rotateAction1, moveAction1])
                    let actionGroup2 = actionGroup1.reversed()
                    
                    //                        let reverseActionGroup = SCNAction.group([reversedAction1, reversedAction2])
                    
                    let reverseMoveSequence = SCNAction.sequence([actionGroup1, actionGroup2])
                    
                    parentNode.runAction(reverseMoveSequence)
                    
                    
                    if let AceesoryNode = scnView.scene?.rootNode.childNode(withName: "\(parent.selectedAccessory) reference", recursively: true) {
                        AceesoryNode.runAction(reverseMoveSequence)
                    }
                    
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
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false // 기본 조명 자동 활성화 비활성화
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        
        // 탭 제스처 인식기 추가
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        print("업데이트")
        
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
                moveNodeToPosition(node: childSignNode, x: -1.4, y: 1.0, z: -0.7) // x, y, z 값은 원하는 위치로 설정
            } else {
                print("\(selectedFace) 노드가 씬에 존재하지 않습니다.")
            }
        }
        
        if let textNode = scene.rootNode.childNode(withName: "text" , recursively: true){
            // 선택한 얼굴형중 선택한 표정만black_glasses reference
            print("textnode", textNode)
            moveNodeToPosition(node: textNode, x: -1.4, y: 1.0, z: 1) // x, y, z 값은 원하는 위치로 설정
            
        }
        
        
        // Mail Node Hide On Off
        if let mailNode = scene.rootNode.childNode(withName: "Mail" , recursively: true){
            if let childMailNode = mailNode.childNode(withName: "\(selectedMail) reference", recursively: true) {
                // 선택한 얼굴형중 선택한 표정만black_glasses reference
                print("출력 \(selectedMail) reference")
                showAllNodes(rootNode: mailNode)
                hideAllNodesExcept(node: childMailNode, rootNode: mailNode) // 선택 노드만 보이게 설정
                moveNodeToPosition(node: childMailNode, x: 5.0, y: 1.0, z: -0.7) // x, y, z 값은 원하는 위치로 설정
            } else {
                print("\(selectedFace) 노드가 씬에 존재하지 않습니다.")
            }
        }
        
        if let textNode = scene.rootNode.childNode(withName: "text" , recursively: true){
            print("textNode : ",textNode)
            updateTextNode(textNode, newText: signText)
            moveNodeToPosition(node: textNode, x: -0.8, y: 0, z: -0.2) // x, y, z 값은 원하는 위치로 설정
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
    
  
    
    for node in scene.rootNode.childNodes {
        // MARK: 모델 크기 조절
        node.scale = SCNVector3(x: 0.6, y: 0.6 , z: 0.6)
        
    }
    
    let textNode = addTextNode()
    scene.rootNode.addChildNode(textNode)
    
    
    // shading 값 설정
    updateMaterialsToPhysicallyBased(for: scene)
    
    // 환경 조명 추가
    let ambientLightNode = makeAmbientLight()
    scene.rootNode.addChildNode(ambientLightNode)
    scene.rootNode.name = "model"
    
    // HDRI 파일의 URL을 가져옵니다.
    guard let hdrURL = Bundle.main.url(forResource: "lythwood_field_4k", withExtension: "hdr") else {
        print("HDR 이미지 파일을 찾을 수 없습니다.")
        return scene
    }
    
    scene.lightingEnvironment.contents = hdrURL
    
    
    return scene
}


