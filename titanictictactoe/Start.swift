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
import FacebookCore

class Start: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: Properties
    @IBOutlet var background: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var playButton: UIButton!
    
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
        
        background.backgroundColor = Style.mainColorBlue;
        collectionView.backgroundColor = Style.mainColorBlue;
        playButton.backgroundColor = Style.mainColorWhite;
        playButton.setTitleColor(Style.mainColorBlack, for: .normal);
        
        NotificationCenter.default.addObserver(self, selector: #selector(promptGameToOpen(notification:)), name: NSNotification.Name(rawValue: "gamesReady"), object: nil)
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
            titleCellTextView.backgroundColor = Style.mainColorGreen;
            titleCellTextView.textColor = Style.mainColorBlack;
            titleCell.backgroundColor = Style.mainColorGreen;
            return titleCell;
        } else {
            let titleCell : UICollectionViewCell = collectionView .dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath);
            let titleCellLabel : UILabel = titleCell .viewWithTag(101) as! UILabel;
            titleCellLabel.text = titleLabels[indexPath.item];
            titleCellLabel.textColor = Style.mainColorBlack;
            titleCell.backgroundColor = Style.mainColorGreen;
            return titleCell;
        }
    }
    
    // MARK : Facebook Tools
    func promptGameToOpen(notification: Notification) {
//        let opponentNames = notification.object as! [String]
        let games = notification.object as! [Game]
        let gameCount = countGames(games: games)
        if (gameCount > 1) {
            let prompt = UIAlertController(title: "Choose Game to Play", message: "Please choose an opponent whose game you wish to return to", preferredStyle: .alert)
            //        prompt.modalPresentationStyle = .popover
            //        for i in 0...opponentNames.count - 1 {
            for i in 0..<games.count {
                //            let action = UIAlertAction(title: opponentNames[i], style: .default) { (action) in
                //                self.beginGame(index: i)
                //            }
                var opponent : Player = Player()
                if (games[i].lastMove == "X") {
                    opponent = games[i].player1
                } else if (games[i].lastMove == "O") {
                    opponent = games[i].player2
                }
                if (opponent.playerName != "") {
                    let action = UIAlertAction(title: opponent.playerName, style: .default) { (action) in
                        self.beginGame(game: games[i])
                    }
                    prompt.addAction(action)
                }
            }
            //        prompt.popoverPresentationController?.sourceRect = self.view.bounds
            //        prompt.popoverPresentationController?.sourceView = self.view
            self.present(prompt, animated: true, completion: nil)
        } else if (gameCount == 1){
            beginGame(game: games[0]);
        }
    }
    
    func countGames(games: [Game]) -> Int {
        var count : Int = -1
        for i in 0..<games.count {
            if (games[i].lastMove != "") {
                count += 1
            }
        }
        return count+1;
    }
    
    func beginGame(game: Game) {
        BasicBoard.wincheck = game.data
        if (game.lastMove == "X") {
            BasicBoard.currentTurn = "O"
        } else {
            BasicBoard.currentTurn = "X"
        }
        BasicBoard.firstTurn = false
//        Board.player1 = game.player1.playerName
//        Board.player2 = game.player2.playerName
//        Board.player1ID = game.player1.playerFBID
//        Board.player2ID = game.player2.playerFBID
        Board.player1 = game.player1
        Board.player2 = game.player2
        Board.gameID  = game.requestID
        LevelMenu.multiplayer = true
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let board : Board = mainStoryboard.instantiateViewController(withIdentifier: "Board") as! Board
        board.level = game.level
        self.present(board, animated: true, completion: nil)
    }
}
