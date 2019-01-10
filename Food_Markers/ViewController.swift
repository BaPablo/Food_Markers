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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

   //     sceneView.debugOptions = [.showBoundingBoxes, .showWorldOrigin]

       sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Busqueda del directorio con los marcadores a detectar
        guard let markers = ARReferenceImage.referenceImages(inGroupNamed: "Markers", bundle: nil)
            else {
                fatalError("No se encuentra un directorio de marcadores asociado")
        }
        // Se define donde estan guardados los marcadores
        configuration.detectionImages = markers

        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARImageAnchor {
            if let imageAnchor = anchor as? ARImageAnchor{
                //Crear un plano en base al ImageAnchor
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
                //Se le asigna un color para la visualización del plano
                plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.5)
                //Se le asigna la geometria de plano
                let planeNode = SCNNode(geometry: plane)
                
                //posición del plano
                planeNode.position = SCNVector3(x:0, y: 0, z: 0)
                
                planeNode.transform = SCNMatrix4MakeRotation(-.pi/2, 1, 0, 0)
                print("----Plane Node ----")
                print(planeNode.debugDescription)
                
                node.addChildNode(planeNode)
                
                let nombreMarker = imageAnchor.referenceImage.name
                
                switch (nombreMarker) {
                    
                case "stark":
                    let markerScene = SCNScene(named: "art.scnassets/apple.scn")
                    if let markerNode = markerScene?.rootNode.childNodes.first{
                        
                        markerNode.position = SCNVector3(x: planeNode.position.x, y: planeNode.position.y + 0.3, z: planeNode.position.z)
                        
                        markerNode.transform = SCNMatrix4MakeTranslation(markerNode.boundingBox.max.x, markerNode.boundingBox.max.y, markerNode.boundingBox.max.z)
                        markerNode.eulerAngles.x = -.pi
                        //let box = SCNBox(width: CGFloat(markerNode.boundingBox.max.x), height: CGFloat(markerNode.boundingBox.max.y), length: CGFloat(markerNode.boundingBox.max.z), chamferRadius: 0)
//
//                        let nodebox = SCNNode(geometry: box)
//                         planeNode.addChildNode(nodebox)
                        
                        print("-----MarkerNode----")
                        print(markerNode.debugDescription)
                        
                      
                        planeNode.addChildNode(markerNode)
                    }
                case "rice":
                    let markerScene = SCNScene(named: "art.scnassets/Raw_meat.scn")
                    if let markerNode = markerScene?.rootNode.childNode(withName: "Raw_meat", recursively: true){
                        sceneView.scene.rootNode.addChildNode(markerNode)
                    }
                default:
                    print("No existe referencia")
                }
            }
        }
    }
}

