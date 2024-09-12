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
        if childNode != node && childNode.name != "camera"  && childNode.name != "ambientLight" && childNode.name != "areaLight" && childNode.name != "omniLight" && childNode.name != "directionLight" && childNode.name != "spotLight" && childNode.name != "accessory" && childNode.name != "sign" && childNode.name != "mail" && childNode.name != "text" && childNode.name != "nest"{
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
