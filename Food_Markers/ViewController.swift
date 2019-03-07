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
    @IBOutlet var sizeOptionsSegments: UISegmentedControl!
    @IBOutlet var markerNotVisible: UILabel!
    var visibleMarkerNode = SCNNode()
    var nodesScales = ["apple": (small: SCNVector3(0.001, 0.001, 0.001),
                                 medium: SCNVector3(0.005, 0.005, 0.005),
                                 large: SCNVector3(0.01, 0.01, 0.01)
                                ),
                       "meat": (small: SCNVector3(0.001, 0.001, 0.001),
                                medium: SCNVector3(0.005, 0.005, 0.005),
                                large: SCNVector3(0.01, 0.01, 0.01)
                                )]
    //Selección de tamaño
    @IBAction func sizeSelection(_ sender: UISegmentedControl) {
        var actualNode = SCNNode()
        actualNode = findActualNode()
        //Chequeo si nodo actual es uno de los marcadores
        guard actualNode.name != nil else {
            markerNotVisible.layer.masksToBounds = true
            markerNotVisible.layer.cornerRadius = 4
            markerNotVisible.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.markerNotVisible.isHidden = true
            }
            return
        }
            switch sizeOptionsSegments.selectedSegmentIndex{
                //Pequeño
                case 0:
                    actualNode.scale = nodesScales[actualNode.name!]!.small
                    sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                        sceneView.scene.rootNode.childNodes.last!,
                        with: actualNode)
                //Mediano
                case 1:
                    actualNode.scale = nodesScales[actualNode.name!]!.medium
                    sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                        sceneView.scene.rootNode.childNodes.last!,
                        with: actualNode)
                //Grande
                case 2:
                    actualNode.scale = nodesScales[actualNode.name!]!.large
                    sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                        sceneView.scene.rootNode.childNodes.last!,
                        with: actualNode)
                //Caso -1
                default:
                    print("No segment found")
            }
    }
    
    //Busca el nodo que se encuentra visible
    func findActualNode() -> SCNNode {
        var actualNode = SCNNode()
        for node in sceneView.scene.rootNode.childNodes {
            //Nodo visible
            if !node.isHidden {
                actualNode = node
                //Nodo visible y que tiene un modelo 3D
                if node.name == "fromImageAnchor" {
                    actualNode = node.childNodes.first!
                    visibleMarkerNode = actualNode
                }
            }
        }
        return actualNode
    }
    
    override func viewDidLoad() {
        // Set the view's delegate
        sceneView.delegate = self
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
                            //Se asignan las escalas de tamaño originales del nodo
                            markerNode.scale = nodesScales[nombreMarker!]!.medium
                            //Se posiciona por sobre el ancla para evitar bug
                            markerNode.position = SCNVector3(0, 0.1, 0)
                            //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                            node.addChildNode(markerNode)
                        }
                    case "meat":
                        print ("Meat  marker detected")
                        let markerScene = SCNScene(named: "art.scnassets/meat/meat.scn")
                        if let markerNode  = markerScene?.rootNode.childNodes.first{
                            //markerNode.eulerAngles.z = .pi / 2
                            //Se guardan las escalas de tamaño originales del nodo
                            markerNode.scale = nodesScales[nombreMarker!]!.medium
                            //Se posiciona por sobre el ancla para evitar bug
                            markerNode.position = SCNVector3(0, 0.1, 0)
                            //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                            node.addChildNode(markerNode)
                        }
                    default:
                        print("No existe referencia")
                    }
            }
            // Se le añade un nombre al nodo para identificar su origen
            node.name = "fromImageAnchor"
        }
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var actualNode = SCNNode()
        actualNode = findActualNode()
        if actualNode == visibleMarkerNode {
            DispatchQueue.main.async {
                self.sizeSelection(self.sizeOptionsSegments!)
            }
        }
    }
}
