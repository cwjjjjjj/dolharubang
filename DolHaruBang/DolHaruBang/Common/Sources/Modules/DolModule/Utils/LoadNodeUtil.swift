//
//  LoadNodeUtil.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/2/24.
//

import SceneKit
import SwiftUI


// MARK: Acessory Node Add
func addAccessory() -> SCNNode {
    let scene = SCNScene(named: "Accessorys.scnassets/AccessoryGroup.scn") ?? SCNScene()
    scene.rootNode.name = "accessory"
    moveNodeToPosition(node: scene.rootNode, x: 0.0, y: 0.0, z: 0.0) // x, y, z 값은 원하는 위치로 설정
    return scene.rootNode
}

// MARK: Sign Node Add
func addSign() -> SCNNode {
    let scene = SCNScene(named: "Signs.scnassets/SignGroup.scn") ?? SCNScene()
    
    
    scene.rootNode.name = "sign"
    
    // 임시 : 모델 크기 조절 안되어있음
    for node in scene.rootNode.childNodes {
        // MARK: 모델 크기 조절
        node.scale = SCNVector3(x: 0.6, y: 0.6 , z: 0.6)

      }
    
    moveNodeToPosition(node: scene.rootNode, x: 0.0, y: 0.0, z: 0.0) // x, y, z 값은 원하는 위치로 설정
    return scene.rootNode
}

// MARK: Mail Node Add
func addMail() -> SCNNode {
    let scene = SCNScene(named: "Mails.scnassets/MailGroup.scn") ?? SCNScene()
    scene.rootNode.name = "mail"
    
    // 임시 : 모델 크기 조절 안되어있음
    for node in scene.rootNode.childNodes {
        // MARK: 모델 크기 조절
        node.scale = SCNVector3(x: 0.2, y: 0.2 , z: 0.2)

      }
    
    moveNodeToPosition(node: scene.rootNode, x: 0.0, y: 0.0, z: 0.0) // x, y, z 값은 원하는 위치로 설정
    return scene.rootNode
}

// MARK: 텍스트 노드 추가
func addTextNode() -> SCNNode{
    
    // extrusionDepth : Z축 방향으로 돌출된 텍스트 범위
            let scnText = SCNText()
            scnText.font = Font.uiFont(for: Font.signtext)
//            scnText.font = UIFont(name: "Helvetica Neue", size: 8)!
    
            scnText.firstMaterial?.diffuse.contents = UIColor.black
            scnText.containerFrame = CGRect(origin: .zero, size: CGSize(width: 70, height: 60))
            scnText.string = ""
            scnText.isWrapped = true
            scnText.extrusionDepth = 1.2
             // flatness : 텍스트의 부드러움을 결정함
//             scnText.flatness = CGFloat(1)
//            scnText.alignmentMode = CATextLayerAlignmentMode.natural.rawValue
             // SCNNode 생성
             let textNode = SCNNode(geometry: scnText)
    
      
             // 부모노드 기준으로 어디에 위치할지.
             textNode.eulerAngles = SCNVector3(0, 0, 0) // 텍스트가 정면을 바라보도록
             textNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
             textNode.name = "text"
             
             return textNode
}

// MARK: 모델 좌표 이동
func moveNodeToPosition(node: SCNNode, x: Float, y: Float, z: Float) {
    node.position = SCNVector3(x, y, z)
}

// MARK: 질감선택
func updateMaterialsToPhysicallyBased(for scene: SCNScene) {
    scene.rootNode.enumerateChildNodes { (node, _) in
        for material in node.geometry?.materials ?? [] {
            material.lightingModel = .physicallyBased
        }
    }
}
