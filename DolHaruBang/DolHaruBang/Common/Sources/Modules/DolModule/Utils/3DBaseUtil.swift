//
//  3DBaseUtil.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/2/24.
//

import SceneKit


// MARK: 특정 노드 숨기는 로직
func hideAllNodesExcept(node: SCNNode, rootNode: SCNNode) {
    
    for childNode in rootNode.childNodes {
        if childNode != node && childNode.name != "camera"  && childNode.name != "ambientLight" && childNode.name != "areaLight" && childNode.name != "omniLight" && childNode.name != "directionLight" && childNode.name != "areaLight2" && childNode.name  != "spotLight" && childNode.name != "accessory" && childNode.name != "sign" && childNode.name != "mail" && childNode.name != "text" && childNode.name != "nest"{
            childNode.isHidden = true
        }
    }
}

func showAllNodes(rootNode: SCNNode) {
    // 현재 노드의 숨김 상태를 해제합니다.
       rootNode.isHidden = false
       
       // 현재 노드의 자식 노드들에 대해서도 재귀적으로 호출합니다.
       for childNode in rootNode.childNodes {
           showAllNodes(rootNode: childNode)
       }
}



func printNodeDetails(node: SCNNode, depth: Int = 0) {
    // 현재 노드의 이름과 깊이를 출력합니다.
    let indentation = String(repeating: "  ", count: depth)
    print("\(indentation)Node name: \(node.name ?? "Unnamed")")
    print("\(indentation)  IsHidden: \(node.isHidden)")
    // 노드의 지오메트리가 있으면 지오메트리의 정보를 출력합니다.
    if let geometry = node.geometry {
        print("\(indentation)  Geometry: \(geometry.name ?? "Unnamed")")
        for material in geometry.materials {
            if let color = material.diffuse.contents as? UIColor {
//                print("\(indentation)    Material color: \(color)")
            }
        }
    }
    
    // 자식 노드가 있으면 자식 노드를 재귀적으로 탐색합니다.
    for childNode in node.childNodes {
        printNodeDetails(node: childNode, depth: depth + 1)
    }
}


func updateTextNode(_ textNode: SCNNode, newText: String) {
    // 텍스트 노드에서 geometry를 SCNText로 변환
    if let scnText = textNode.geometry as? SCNText {
        // 텍스트 내용을 변경
        scnText.string = newText
    } else {
        print("텍스트 노드의 geometry가 SCNText가 아닙니다.")
    }
}

func applyMaterial(to node: SCNNode, with material: SCNMaterial) {
    if let geometry = node.geometry {
        geometry.materials = [material]
    }
    for child in node.childNodes {
        applyMaterial(to: child, with: material)
    }
}


func captureSceneImage(scene: SCNScene, size: CGSize, selectedFaceShape: String, selectedFace: String) -> UIImage? {
    // 1. SCNRenderer 설정
    let renderer = SCNRenderer(device: nil, options: nil)

    // 2. 새로운 SCNScene 생성 (Nest와 childNode만 포함할 장면)
    let newScene = SCNScene()

    // 3. 기존 scene에서 Nest와 childNode만 가져오기
    if let parentNode = scene.rootNode.childNode(withName: "\(selectedFaceShape) reference", recursively: true),
       let childNode = parentNode.childNode(withName: "\(selectedFace)", recursively: true),
       let light = scene.rootNode.childNode(withName: "areaLight", recursively: true),
       let light2 = scene.rootNode.childNode(withName: "areaLight2", recursively: true) {

        // 노드 복제
        let newChildNode = childNode.clone()
        let newlightNode = light.clone()
        let newlight2Node = light2.clone()

        // 새로운 장면에 추가
        newScene.rootNode.addChildNode(newChildNode)
        newScene.rootNode.addChildNode(newlightNode)
        newScene.rootNode.addChildNode(newlight2Node)
    }

    // 4. 새 장면을 렌더링할 SCNRenderer에 설정
    renderer.scene = newScene

    // 5. 캡처할 스케일 설정
    let scale = UIScreen.main.scale
    let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)

    // 6. SCNRenderer를 사용하여 새 장면을 이미지로 렌더링
    let snapshot = renderer.snapshot(atTime: 0, with: scaledSize, antialiasingMode: .multisampling2X)

    // 7. SCNScene 삭제 (새 장면과 참조된 노드들 해제)
    renderer.scene = nil  // SCNRenderer에서 참조 해제
    newScene.rootNode.childNodes.forEach { $0.removeFromParentNode() }  // 루트 노드에서 모든 자식 노드 제거

    return snapshot
}
