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
    
    @IBAction func sizeSelection(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        var actualNode = SCNNode()
        print("Cantidad de nodos:", sceneView.scene.rootNode.childNodes.count)
        for node in sceneView.scene.rootNode.childNodes {
            print ("Debug description: ", node.debugDescription)
            print ("Node name: ", node.name)
            print ("Node hidden: ", node.isHidden)
            
            if node.name == "fromAnchor" && !node.isHidden{
                actualNode = (node.childNodes.first)!
            }
        }
        switch sizeOptionsSegments.selectedSegmentIndex{
            case 0:
                actualNode.scale = SCNVector3(0.001, 0.001, 0.001)
                sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                sceneView.scene.rootNode.childNodes.last!, with: actualNode)
            case 1:
                print(sender.selectedSegmentIndex)
                actualNode.scale = SCNVector3(0.005, 0.005, 0.005)
                sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                    sceneView.scene.rootNode.childNodes.last!, with: actualNode)
            case 2:
                actualNode.scale = SCNVector3(0.01, 0.01, 0.01)
                sceneView.scene.rootNode.childNodes.last?.replaceChildNode(
                    sceneView.scene.rootNode.childNodes.last!, with: actualNode)
            default:
                print("mMM")
        }
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
                switch (nombreMarker) {
                    case "apple":
                        print ("Apple marker detected")
                        let appleScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                        if let appleNode = appleScene?.rootNode.childNodes.first{
                            appleNode.eulerAngles.x = .pi / 2
                            appleNode.name = nombreMarker
                            appleNode.position = SCNVector3(0, 0.1, 0)
                            node.addChildNode(appleNode)
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
                        let appleScene = SCNScene(named: "art.scnassets/apple/apple.scn")
                        if let appleNode = appleScene?.rootNode.childNodes.first{
                            appleNode.eulerAngles.x = .pi / 2   
                            appleNode.position = SCNVector3(x:0, y:0.1, z:0)
                            node.addChildNode(appleNode)
                        }
                        
                    case "mewtwo":
                        let markerScene = SCNScene(named: "art.scnassets/" + (nombreMarker)! + "/" + nombreMarker! + ".scn")
                        print("Mewtwo marker detected")
                        if let markerNode = markerScene?.rootNode.childNode(withName: nombreMarker!, recursively: true){
                            markerNode.position = SCNVector3(x: 0, y: 0.01, z: 0)
                            markerNode.name = nombreMarker
                            node.addChildNode(markerNode)
                            sceneView.scene.rootNode.addChildNode(node)
                        }
                    default:
                        print("No existe referencia")
                    }
                }
        }
        node.name = "fromAnchor"
    return node
    }
}
