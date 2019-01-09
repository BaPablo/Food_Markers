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
    private var planeNode: SCNNode?
    private var imageNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

//        sceneView.debugOptions = [.showFeaturePoints]
        
//        let scene = SCNScene(named: "art.scnassets/apple.scn")!
//
       sceneView.automaticallyUpdatesLighting = true
//
//        sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
//        configuration.planeDetection = .horizontal
        
        //Busqueda del directorio con los marcadores a detectar
        guard let markers = ARReferenceImage.referenceImages(inGroupNamed: "Markers", bundle: nil)
            else {
                fatalError("No se encuentra un directorio de marcadores asociado")
        }

        
        // Se define donde estan guardados los marcadores
        configuration.detectionImages = markers
        
                
        // Run the view's session
        sceneView.session.run(configuration)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Si el ancla que se crea es una imagen, significa que se reconocio uno de los marcadores
//       guard let imageAnchor = anchor as? ARImageAnchor else {return}
//        let planeScene = SCNScene(named: "art.scnassets/apple.scn")
//        let planeNode = planeScene?.rootNode.childNodes.first
//
//        let (min,max) = (planeNode?.boundingBox)!
//        let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
//
//        let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width)/size.x
//        let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height)/size.z
//
//        let finalRatio = [widthRatio,heightRatio].min()!
//
//        planeNode?.transform = SCNMatrix4(imageAnchor.transform)
//
//        let appeareanceAction = SCNAction.scale(to: CGFloat(finalRatio), duration: 0.4)
//        appeareanceAction.timingMode = .easeOut
//
//        planeNode?.scale = SCNVector3Make(0, 0, 0)
//
//        sceneView.scene.rootNode.addChildNode(planeNode!)
//
//        planeNode?.runAction(appeareanceAction)
//
//        self.planeNode = planeNode
//        self.imageNode = node

        if anchor is ARImageAnchor {
            let imageAnchor = anchor as! ARImageAnchor
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x:0, y: 0, z: -10)
            
            planeNode.transform = SCNMatrix4MakeRotation(-.pi/2, 1, 0, 0)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            plane.materials = [material]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
            let appleScene = SCNScene(named: "art.scnassets/apple.scn")
            
            if let appleNode = appleScene?.rootNode.childNode(withName: "apple", recursively: true){
                print("applenode")
                // appleNode.position = SCNVector3(x:planeNode.position.x, y: planeNode.position.y+0.1, z:planeNode.position.z+0.1)
                
                //appleNode.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
                sceneView.scene.rootNode.addChildNode(appleNode)
            }
            
        }
        
    }
}
