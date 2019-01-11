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

       sceneView.debugOptions = [.showBoundingBoxes]

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
                
                //posición del plano respecto a la imagen de referencia (marcador)
                planeNode.position = SCNVector3(x:0, y: 0, z: 0)
                
                planeNode.transform = SCNMatrix4MakeRotation(.pi/2, 1, 0, 0)
                
                node.addChildNode(planeNode)
                
                
                let nombreMarker = imageAnchor.referenceImage.name
                
                //Casos para cada marcador, dado que cada modelo tiene distintas orientaciones y posiciones
                switch (nombreMarker) {
            
                case "apple":
                    let markerScene = SCNScene(named: "art.scnassets/apple/apple.scn")
//                    if let markerNode = markerScene?.rootNode.childNodes.first{
                    
                    if let markerNode = markerScene?.rootNode.childNode(withName: "apple", recursively: true){
                           
                        markerNode.opacity = 0
                        markerNode.runAction(.fadeIn(duration: 1.3))
                      
                        planeNode.addChildNode(markerNode)
                        
                       // sceneView.scene.rootNode.addChildNode(markerNode)
                    }
                    
                case "cofee":
                    let markerScene = SCNScene(named: "art.scnassets/coffee/coffee.scn")
                    if let markerNode = markerScene?.rootNode.childNodes.first{
                        markerNode.position = SCNVector3(x: planeNode.position.x, y: planeNode.position.y + 0.3, z: planeNode.position.z)
                        
                        markerNode.transform = SCNMatrix4MakeTranslation(markerNode.boundingBox.max.x, markerNode.boundingBox.max.y, markerNode.boundingBox.max.z)
                        markerNode.eulerAngles.x = -.pi
                        
                        markerNode.runAction(.fadeOut(duration: 1))
                        
                        planeNode.addChildNode(markerNode)
                    }
                    
                case "meat":
                        let markerScene = SCNScene(named: "art.scnassets/meat/meat.scn")
                        if let markerNode = markerScene?.rootNode.childNodes.first{
                           // markerNode.position = SCNVector3(x: planeNode.position.x, y: planeNode.position.y + 0.3, z: planeNode.position.z)
                            
                          //  markerNode.transform = SCNMatrix4MakeTranslation(markerNode.boundingBox.max.x, markerNode.boundingBox.max.y, markerNode.boundingBox.max.z)
                            markerNode.eulerAngles.x = -.pi
                            
                           // let action = SCNAction()
                            markerNode.opacity = 0
                            markerNode.runAction(.fadeIn(duration: 1.3))
                            planeNode.addChildNode(markerNode)
                    }
                    
//                case "rice":
//                    let markerScene = SCNScene(named: "art.scnassets/rice/rice.scn")
//                    if let markerNode = markerScene?.rootNode.childNodes.first{
//                        markerNode.position = SCNVector3(x: planeNode.position.x, y: planeNode.position.y + 0.3, z: planeNode.position.z)
//                        
//                        markerNode.transform = SCNMatrix4MakeTranslation(markerNode.boundingBox.max.x, markerNode.boundingBox.max.y, markerNode.boundingBox.max.z)
//                        markerNode.eulerAngles.x = -.pi
//                        
//                      //  let action = SCNAction()
//                        
//                        markerNode.runAction(.fadeOut(duration: 1))
//                        
//                        planeNode.addChildNode(markerNode)
//                    }
                    
                    
                case "mewtwo":
                    let markerScene = SCNScene(named: "art.scnassets/" + (nombreMarker)! + "/" + nombreMarker! + ".scn")
                    print("A wild Mewtwo has appeared")
                    if let markerNode = markerScene?.rootNode.childNode(withName: nombreMarker!, recursively: true){
//                        markerNode.opacity = 0
//                        markerNode.runAction(.fadeIn(duration: 1.3))
//                        markerNode.eulerAngles.x = -.pi/2
                        
                        let (min,max) = planeNode.boundingBox
                        let size = SCNVector3Make(max.x - min.x, max.y - min.y, max.z - min.z)
                        
                        let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width)/size.x
                        let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height)/size.z
                        
                        let finalRatio = [widthRatio,heightRatio].min()!
                        
                        planeNode.transform = SCNMatrix4(imageAnchor.transform)
                        
                        print (planeNode.debugDescription)
                        planeNode.rotation = SCNVector4Make(0, 0, 0, 0)
                        
                        print (planeNode.debugDescription)
                        
                        let aparicion = SCNAction.scale(to: CGFloat(finalRatio), duration: 4)
                        
                        aparicion.timingMode = .easeOut
                        
                        planeNode.scale = SCNVector3Make(0, 0, 0)

                        planeNode.runAction(aparicion)
                        
                      //sceneView.scene.rootNode.addChildNode(markerNode)
                      planeNode.addChildNode(markerNode)
                    }
                default:
                    print("No existe referencia")
                }
            }
        }
    }
}

