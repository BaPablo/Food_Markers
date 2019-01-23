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
    @IBOutlet var sizeOptionsBtn: UIButton!
    @IBOutlet var sizeOptionsSegments: UISegmentedControl!
    var nodesOriginalScales = []
    
    //En base a la selección del usuario se cambia el tamaño
    @IBAction func sizeSelection(_ sender: UISegmentedControl) {
        var actualNode = SCNNode()
        actualNode = buscarNodoActual()
        switch sizeOptionsSegments.selectedSegmentIndex{
            case 0:
                actualNode.scale = SCNVector3(nodesOriginalScales[actualNode.name!]!.x * 0.5,
                                    nodesOriginalScales[actualNode.name!]!.y * 0.5,
                                    nodesOriginalScales[actualNode.name!]!.z * 0.5)
                sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                    sceneView.scene.rootNode.childNodes.last!, with: actualNode)
            case 1:
                actualNode.scale = nodesOriginalScales[actualNode.name!]!
                sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                    sceneView.scene.rootNode.childNodes.last!, with: actualNode)
            case 2:
                actualNode.scale = SCNVector3(actualNode.scale.x * 1.4, actualNode.scale.y * 1.4, actualNode.scale.z * 1.4)
                sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                    sceneView.scene.rootNode.childNodes.last!, with: actualNode)
            default:
                print("mMM")
        }
    }
    //Busca el nodo actual en base a si es visible y su nombre
    func buscarNodoActual() -> SCNNode {
        var actualNode = SCNNode()
        for node in sceneView.scene.rootNode.childNodes {
            if node.name == "fromAnchor" && !node.isHidden{
                actualNode = (node.childNodes.first)!
            }
        }
        return actualNode
    }
    
    override func viewDidLoad() {
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [.showBoundingBoxes]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //Busqueda del directorio con los marcadores a detectar
        guard let markers = ARReferenceImage.referenceImages(inGroupNamed: "Markers", bundle: nil)
            else {
                fatalError("No se encuentra un directorio de marcadores asociado")
        }
        
        // Create a session configuration
        if #available(iOS 12.0, *) {
            let configuration = ARImageTrackingConfiguration()
            configuration.trackingImages = markers
            // Run the view's session
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
        } else {
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionImages = markers
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
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
                let nombreMarker = imageAnchor.referenceImage.name
                //En base al nombre del marcador se muestra la escena y se agrega al nodo correspondiente
                switch (nombreMarker) {
                    case "apple":
                        print ("Apple marker detected")
                        let markerScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                        if let markerNode  = markerScene?.rootNode.childNodes.first{
                            markerNode.eulerAngles.x = .pi / 2
                            //Se le asigna un nombre al nodo con la escena
                            markerNode.name = nombreMarker
                            //Se guardan las escalas de tamaño originales del nodo
                            //nodesOriginalScales[nombreMarker!] = markerNode .scale
                            nodesOriginalScales[nombreMarker!] = nombreMarker.scale
                            //Se posiciona por sobre el ancla para evitar bug
                            markerNode.position = SCNVector3(0, 0.1, 0)
                            //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                            node.addChildNode(nodeSce)
                        }
                    case "stark":
                        let markerScene = SCNScene(named: "art.scnassets/meat/meat.scn")
                        if let markerNode = markerScene?.rootNode.childNodes.first{
                            markerNode.eulerAngles.x = -.pi
                            markerNode.opacity = 0
                            markerNode.runAction(.fadeIn(duration: 1.3))
                            node.addChildNode(markerNode)
                        }
                        
                    case "rice":
                        print ("rice marker detected")
                        let markerScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                        if let markerNode  = markerScene?.rootNode.childNodes.first{
                            markerNode.eulerAngles.x = .pi / 2   
                            markerNode.position = SCNVector3(x:0, y:0.1, z:0)
                            node.addChildNode(nodeSce)
                        }
                        
                    case "mewtwo":
                        let markerScene = SCNScene(named: "art.scnassets/" + (nombreMarker)! + "/" + nombreMarker! + ".scn")
                        print("Mewtwo marker detected")
                        if let markerNode = markerScene?.rootNode.childNode(withName: nombreMarker!, recursively: true){
                            markerNode.position = SCNVector3(x: 0, y: 0.01, z: 0)
                            markerNode.name = nombreMarker
                            nodesOriginalScales[nombreMarker!] = markerNode.scale
                            node.addChildNode(markerNode)
                        }
                    default:
                        print("No existe referencia")
                    }
                }
        }
    // Se le añade un nombre al nodo para identificar su origen posteriormente   
    node.name = "fromAnchor"
    return node
    }
    
}
