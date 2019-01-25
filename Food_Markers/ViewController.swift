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
    var nodesOriginalScales = [String:SCNVector3]()
    var visibleNodes = [SCNNode()]
    
    //En base a la selección del usuario se cambia el tamaño
    @IBAction func sizeSelection(_ sender: UISegmentedControl) {
        var actualNode = SCNNode()
        actualNode = buscarNodoActual()
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
                case 0:
                    actualNode.scale = SCNVector3(nodesOriginalScales[actualNode.name!]!.x * 0.5,
                                        nodesOriginalScales[actualNode.name!]!.y * 0.5,
                                        nodesOriginalScales[actualNode.name!]!.z * 0.5)
                    sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                        sceneView.scene.rootNode.childNodes.last!,
                        with: actualNode)
                case 1:
                    actualNode.scale = nodesOriginalScales[actualNode.name!]!
                    sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                        sceneView.scene.rootNode.childNodes.last!,
                        with: actualNode)
                case 2:
                    actualNode.scale = SCNVector3(nodesOriginalScales[actualNode.name!]!.x * 1.5,
                                                  nodesOriginalScales[actualNode.name!]!.y * 1.5,
                                                  nodesOriginalScales[actualNode.name!]!.z * 1.5)
                    sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                        sceneView.scene.rootNode.childNodes.last!,
                        with: actualNode)
                default:
                    // Caso -1
                    print("No segment found")
            }
    }
    //Busca el nodo actual en base a si es visible y al nombre que se le asignó previamente
    func buscarNodoActual() -> SCNNode {
        var actualNode = SCNNode()
        for node in sceneView.scene.rootNode.childNodes {
            if node.name == "fromAnchor" && !node.isHidden{
                actualNode = (node.childNodes.first)!
                if actualNode == visibleNodes.last {
                        visibleNodes.append(actualNode)
                }
            }
        }
        return actualNode
    }
    
    override func viewDidLoad() {
        // Set the view's delegate
        sceneView.delegate = self
        //sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [.showFeaturePoints]
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
                    case "cuadrados":
                        print ("Apple marker detected")
                        let markerScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                        if let markerNode  = markerScene?.rootNode.childNodes.first{
                            markerNode.eulerAngles.x = .pi / 2
                            //Se le asigna un nombre al nodo con la escena
                            markerNode.name = nombreMarker
                            //Se guardan las escalas de tamaño originales del nodo
                            nodesOriginalScales[nombreMarker!] = markerNode.scale
                            //Se posiciona por sobre el ancla para evitar bug
                            markerNode.position = SCNVector3(0, 0.1, 0)
                            //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                            node.addChildNode(markerNode)
                        }
                case "apple":
                    print ("Apple2 marker detected")
                    let markerScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                    if let markerNode  = markerScene?.rootNode.childNodes.first{
                        markerNode.eulerAngles.x = .pi / 2
                        //Se le asigna un nombre al nodo con la escena
                        markerNode.name = nombreMarker
                        //Se guardan las escalas de tamaño originales del nodo
                        nodesOriginalScales[nombreMarker!] = markerNode.scale
                        //Se posiciona por sobre el ancla para evitar bug
                        markerNode.position = SCNVector3(0, 0.1, 0)
                        //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                        node.addChildNode(markerNode)
                    }
                case "triangulos":
                        print ("Meat  marker detected")
                        let markerScene = SCNScene(named: "art.scnassets/meat/meat.scn")
                        if let markerNode  = markerScene?.rootNode.childNodes.first{
                            //markerNode.eulerAngles.z = .pi / 2
                            //Se le asigna un nombre al nodo con la escena
                            markerNode.name = nombreMarker
                            //Se guardan las escalas de tamaño originales del nodo
                            nodesOriginalScales[nombreMarker!] = markerNode.scale
                            //Se posiciona por sobre el ancla para evitar bug
                            markerNode.position = SCNVector3(0, 0.1, 0)
                            //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                            node.addChildNode(markerNode)
                        }
                case "meat":
                    print ("Meat2  marker detected")
                    let markerScene = SCNScene(named: "art.scnassets/meat/meat.scn")
                    if let markerNode  = markerScene?.rootNode.childNodes.first{
                        //markerNode.eulerAngles.z = .pi / 2
                        //Se le asigna un nombre al nodo con la escena
                        markerNode.name = nombreMarker
                        //Se guardan las escalas de tamaño originales del nodo
                        nodesOriginalScales[nombreMarker!] = markerNode.scale
                        //Se posiciona por sobre el ancla para evitar bug
                        markerNode.position = SCNVector3(0, 0.1, 0)
                        //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                        node.addChildNode(markerNode)
                    }
                case "meat3":
                    print ("Meat3  marker detected")
                    let markerScene = SCNScene(named: "art.scnassets/meat/meat.scn")
                    if let markerNode  = markerScene?.rootNode.childNodes.first{
                        //markerNode.eulerAngles.z = .pi / 2
                        //Se le asigna un nombre al nodo con la escena
                        markerNode.name = nombreMarker
                        //Se guardan las escalas de tamaño originales del nodo
                        nodesOriginalScales[nombreMarker!] = markerNode.scale
                        //Se posiciona por sobre el ancla para evitar bug
                        markerNode.position = SCNVector3(0, 0.1, 0)
                        //Se agrega el nodo de la manzana al nodo creado sobre el ancla
                        node.addChildNode(markerNode)
                    }
                    case "circulo":
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
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var currentNode = SCNNode()
        currentNode = buscarNodoActual()
        //Que el currentNode sea un nodo cualquiera sin escena o que sea el visible
        if currentNode.name != visibleNodes.last?.name{
            DispatchQueue.main.async {
                self.sizeSelection(self.sizeOptionsSegments!)
            }
        }
    }
}
