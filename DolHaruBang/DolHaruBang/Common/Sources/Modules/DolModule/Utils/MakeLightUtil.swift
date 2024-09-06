//
//  lightNodeUtil.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/2/24.
//

import SceneKit

// MARK: 조명관련 함수들
func makeAmbientLight() -> SCNNode{
    let ambientLightNode = SCNNode()
    let ambientLight = SCNLight()
    ambientLight.type = .ambient
    ambientLight.intensity = 3000 // 환경 조명 강도 조절
    ambientLightNode.light = ambientLight
    ambientLightNode.name = "ambientLight"
    return ambientLightNode
}

func makeSpotLight() -> SCNNode{
    let spotLightNode = SCNNode()
    let spotLight = SCNLight()
    spotLight.type = .spot
    spotLight.intensity = 1000
    spotLight.color = UIColor(white: 1.0, alpha: 1.0) // 빛의 색상 원색
    
    // 그림자 설정
    spotLight.castsShadow = true
    spotLight.automaticallyAdjustsShadowProjection = true
    spotLight.maximumShadowDistance = 20.0 // 그림자가 보이는 최대 거리
    spotLight.orthographicScale = 10.0 // 조명 투영의 크기 (상황에 맞게 조정)
    spotLight.shadowMapSize = CGSize(width: 2048, height: 2048) // 그림자 맵 해상도
    spotLight.shadowMode = .deferred // 그림자 모드 설정 (Deferred는 더 좋은 품질을 제공합니다)
    spotLight.shadowSampleCount = 128 // 그림자 샘플 수 (더 높은 수치일수록 품질이 향상됨)
    spotLight.shadowRadius = 20.0 // 그림자의 흐림 정도
    spotLight.shadowBias = 5.0 // 그림자 편향 (섬세하게 조정하여 그림자 부풀림을 방지)
    spotLight.zNear = 1 // 그림자의 시작 거리
    spotLight.zFar = 1000 // 그림자의 끝 거리
    spotLight.shadowColor = UIColor.black.withAlphaComponent(0.36)// 그림자의 색상과 투명도
     
    spotLight.spotInnerAngle = 30 // 스팟 라이트의 내부 각도
    spotLight.spotOuterAngle = 60 // 스팟 라이트의 외부 각도
    
    spotLightNode.light = spotLight
    spotLightNode.name = "spotLight"
    
    // 조명을 모델 위쪽 배치
    spotLightNode.position = SCNVector3(x: 0, y: 10, z: 0) // 모델 아래쪽에 위치하도록 설정
    spotLightNode.look(at: SCNVector3(x: 0, y: 0, z: 0)) // 모델의 중앙을 향하도록 설정
       
    
    return spotLightNode
}

func makeDirectionalLight(X: Float, Y : Float, Z : Float, intensity : CGFloat, name : String ) -> SCNNode {
    let directionalLightNode = SCNNode()
    let directionalLight = SCNLight()
    directionalLight.type = .directional
    directionalLight.intensity = intensity // 방향성 조명 강도 조절
    directionalLight.color = UIColor(red: 255/255, green: 236/255, blue: 206/255, alpha: 1.0) // 조명 색상 설정
    directionalLightNode.light = directionalLight
    directionalLightNode.name = name
    // 방향성 조명의 방향 설정
    directionalLightNode.position = SCNVector3(x: X, y: Y, z: Z)
    directionalLightNode.look(at: SCNVector3.init(x: 0, y: 0, z: 0)) // 장면의 중심을 향하도록 조명 방향 설정
    
    return directionalLightNode
}

