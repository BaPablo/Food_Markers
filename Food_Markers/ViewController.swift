//
//  ViewController.swift
//  Food_Markers
//
//  Created by Pablo Barría on 03-01-19.
//  Copyright © 2019 Universidad de La Frontera. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var imgAnchors: [ARImageAnchor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

      sceneView.debugOptions = [.showWorldOrigin]

       sceneView.automaticallyUpdatesLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //Busqueda del directorio con los marcadores a detectar
        guard let markers = ARReferenceImage.referenceImages(inGroupNamed: "Markers", bundle: nil)
            else {
                fatalError("No se encuentra un directorio de marcadores asociado")
        }
        // Create a session configuration
        
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionImages = markers
            // Run the view's session
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: -ARSCNViewDelegate
    

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?{

        let node = SCNNode()
        if anchor is ARImageAnchor {

            if let imageAnchor = anchor as? ARImageAnchor{

                    //Crear un plano en base al ImageAnchor
                    let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                         height: imageAnchor.referenceImage.physicalSize.height)
                    
                    //Se le asigna un color para la visualización del plano
                    plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha:  0.5)
                    
                    //Se le asigna la geometria de plano
                    let planeNode = SCNNode(geometry: plane)

                    planeNode.eulerAngles.x = -.pi/2
                
                   // node.addChildNode(planeNode)
                    let nombreMarker = imageAnchor.referenceImage.name
                    
                    //Casos para cada marcador, dado que cada modelo tiene distintas orientaciones y posiciones
                    switch (nombreMarker) {
                
                    case "apple":
                        print ("Apple marker detected")
                        let appleScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                        if let appleNode = appleScene?.rootNode.childNodes.first{
                            appleNode.eulerAngles.x = .pi / 2
                            // appleNode.position = SCNVector3(x:0, y:0.1, z:-0.3)
//                            appleNode.position = SCNVector3(x:Float(imageAnchor.referenceImage.physicalSize.width),
//                                                            y:0,
//                                                            z:Float(imageAnchor.referenceImage.physicalSize.height))
                            //node.addChildNode(appleNode)
                            print(appleNode.debugDescription)
                            node.addChildNode(appleNode)
                            print(appleNode.debugDescription)
                            sceneView.session.setWorldOrigin(relativeTransform: imageAnchor.transform )
                            sceneView.scene.rootNode.addChildNode(appleNode)
                        
                        }
                    
                    case "meat":
                        let markerScene = SCNScene(named: "art.scnassets/meat/meat.scn")
                        if let markerNode = markerScene?.rootNode.childNodes.first{
                                markerNode.eulerAngles.x = -.pi
                                markerNode.opacity = 0
                                markerNode.runAction(.fadeIn(duration: 1.3))
                        }
                        
                   case "stark":
                        print ("Rice marker detected")
                        let appleScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                        if let appleNode = appleScene?.rootNode.childNodes.first{
                            appleNode.eulerAngles.x = .pi / 2
                            
                            appleNode.position = SCNVector3(x:0, y:0.1, z:0)
                            //planeNode.addChildNode(appleNode)
                            node.addChildNode(appleNode)
                        }
                        
                    case "mewtwo":
                        let markerScene = SCNScene(named: "art.scnassets/" + (nombreMarker)! + "/" + nombreMarker! + ".scn")
                        print("Mewtwo marker detected")
                        if let markerNode = markerScene?.rootNode.childNode(withName: nombreMarker!, recursively: true){
                            //Animacion para la aparicion

                            let (min,max) = planeNode.boundingBox
                            let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
                            
                            let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width)/size.x
                            let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height)/size.z
                            
                            let finalRatio = [widthRatio,heightRatio].min()!
                            
                            planeNode.transform = SCNMatrix4(imageAnchor.transform)
                            
                            
                            planeNode.rotation = SCNVector4Make(0, 0, 0, 0)
                            
                            let aparicion = SCNAction.scale(to: CGFloat(finalRatio), duration: 0.8)
                            aparicion.timingMode = .easeOut
                            
                            planeNode.scale = SCNVector3Make(0, 0, 0)

                            planeNode.runAction(aparicion)
                            planeNode.addChildNode(markerNode)
                            sceneView.scene.rootNode.addChildNode(markerNode)
                            //sceneView.scene.rootNode.addChildNode(planeNode)
                        }
                    default:
                        print("No existe referencia")
                    }
                }
        }
        return node
    }
}
