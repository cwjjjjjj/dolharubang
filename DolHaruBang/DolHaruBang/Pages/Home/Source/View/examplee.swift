import SwiftUI
import RealityKit

struct RealityKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        
        // Create ARView and set up the scene
        let arView = ARView(frame: containerView.bounds)
        containerView.addSubview(arView)
        
        // Create an anchor for the model
        let anchor = AnchorEntity(world: SIMD3(x: 0, y: 0, z: 0))
        
        // Load the .usdz model
        do {
            let modelEntity = try ModelEntity.load(named: "cupid.usdz")
            modelEntity.position = SIMD3(x: 0, y: 0, z: 0) // Adjust the position as needed
            anchor.addChild(modelEntity)
        } catch {
            print("Failed to load model: \(error)")
        }
        
        // Add the anchor to the scene
        arView.scene.anchors.append(anchor)
        
        // Add a light source
        let light = DirectionalLightComponent()
        let lightEntity = Entity()
        lightEntity.components[DirectionalLightComponent.self] = light
        lightEntity.position = SIMD3(x: 0, y: 1, z: 2) // Position the light
        anchor.addChild(lightEntity)
        
        // Set up the camera
        let camera = PerspectiveCamera()
        camera.position = SIMD3(x: 0, y: 0, z: 2) // Position the camera away from the model
        anchor.addChild(camera)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}

struct ContentVieww: View {
    var body: some View {
        RealityKitView()
            .edgesIgnoringSafeArea(.all) // Ensure the ARView fills the screen
    }
}
