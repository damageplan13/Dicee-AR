//
//  ViewController.swift
//  Dicee AR
//
//  Created by Shwait Kumar on 12/06/18.
//  Copyright © 2018 Shwait Kumar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    
        sceneView.autoenablesDefaultLighting = true
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)

        node.addChildNode(planeNode)
        
    }
    
    
    func createPlane(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
                
               addDice(atLocation: hitResult)
                
            }
            
        }
        
    }
    
    
    func addDice(atLocation location : ARHitTestResult){
        
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z
            )
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            rollDice(dice: diceNode)
            
            
        }
        
    }
    
    
    func rollAllDices(){
        
        if !diceArray.isEmpty{
            
            for dice in diceArray{
                
                rollDice(dice : dice)
                
            }
            
        }
        
    }
    
    func rollDice(dice : SCNNode){
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5), //multiplied by 5 to add more rotations to make it more realistic
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5
            )
    )
        
        
    }
    
    @IBAction func rollAgainButtonPressed(_ sender: UIBarButtonItem) {
        
        rollAllDices()
        
    }
    
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        rollAllDices()
        
    }
    
    @IBAction func clearAllDices(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty{
            
            for dice in diceArray{
                dice.removeFromParentNode()
            }
            
        }
        
    }
    
    

}
