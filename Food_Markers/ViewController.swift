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
    /*  
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    */
    
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
        //guard  else { return }
        
        // Si el ancla que se crea es una imagen, significa que se reconocio uno de los marcadores
        if anchor is ARImageAnchor {
            print("Marcador encontrado")
            let imageAnchor = anchor as! ARImageAnchor
            let appleScene = SCNScene(named: "art.scnassets/apple.scn")!
            //withName = Identity  --> Name of the node 
           if let appleNode = appleScene.rootNode.childNode(withName: "apple", recursively: true) {
                appleNode?.position = SCNVector3(anchor.transform.columns.3.x,anchor.transform.columns.3.y + 0.1, anchor.transform.columns.3.z)
                appleScene.scene.rootNode.addChildNode(appleNode)
           }
            
        }
    }