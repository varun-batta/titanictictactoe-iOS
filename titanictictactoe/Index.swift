//
//  Index.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-09.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Index: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if #available(iOS 10.0, *) {
            if let scene = GKScene(fileNamed: "GameScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
                    
                    // Copy gameplay related content over to the scene
                    sceneNode.entities = scene.entities
                    sceneNode.graphs = scene.graphs
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    if let view = self.view as! SKView? {
                        view.presentScene(sceneNode)
                        
                        view.ignoresSiblingOrder = true
                        
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UICollectionViewDataSource
    
    var titleLabels = ["Tic", "Tac", "Toe", "", "This is the\nenhanced version\nof Tic-Tac-Toe\nEnjoy!", "", "", "", ""];
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : Double = Double(self.view.frame.size.width);
        let dimension : Int = Int(0.9 * width - 20)/3;
        return CGSize(width: dimension, height: dimension);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.item == 4) {
            let titleCell : UICollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: "titleCellDescription", for: indexPath)
            let titleCellTextView : UITextView = titleCell .viewWithTag(102) as! UITextView;
            titleCellTextView.text = titleLabels[indexPath.item];
            return titleCell;
        } else {
            let titleCell : UICollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath);
            let titleCellLabel : UILabel = titleCell .viewWithTag(101) as! UILabel;
            titleCellLabel.text = titleLabels[indexPath.item];
            return titleCell;
        }
    }
}
