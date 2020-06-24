//
//  Winner.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-20.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class Winner: UIViewController {

    var winnerName : String!
    var level : Int!
    
    @IBOutlet var playerWinsLabel: UILabel!
    @IBOutlet var mainMenuButton: UIButton!
    @IBOutlet var viewGameButton: UIButton!
    @IBOutlet var newGameButton: UIButton!
    @IBOutlet var rematchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the winning player label
        if winnerName != nil {
            if winnerName == "Tie" {
                playerWinsLabel.text = "It's a Tie!"
            } else {
                if (Board.isMultiplayer && AccessToken.current != nil) {
                    // For facebook, we need to verify that you are the winning player
                    // TODO: Once game is available, just use game.opponentWon
                    if ((Board.player1.playerName == winnerName && AccessToken.current?.userID == String(Board.player1.playerFBID)) || (Board.player2.playerName == winnerName && AccessToken.current?.userID == String(Board.player2.playerFBID))) {
                        playerWinsLabel.text = "You WIN!!!"
                    } else {
                        playerWinsLabel.text = winnerName + " has won"
                    }
                } else {
                    playerWinsLabel.text = winnerName == "Your" ? "YOU WIN!!!" : winnerName + " WINS!!!"
                }
            }
        }
        
        // UI Setup
        rematchButton.addTarget(self, action: #selector(rematchButtonTapped), for: .touchUpInside)
        mainMenuButton.addTarget(self, action: #selector(mainMenuButtonTapped), for: .touchUpInside)
        viewGameButton.addTarget(self, action: #selector(viewGameButtonTapped), for: .touchUpInside)
        newGameButton.addTarget(self, action: #selector(newGameButtonTapped), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TODO: Handle button clicks better if possible
    @objc func rematchButtonTapped(sender: UIButton) {
        // TODO: What is this for?
        if (Board.isMultiplayer) {
            AppDelegate.deleteGameRequest(request_id: String(Board.gameID))
        }
        
        // Switch players since we are player 2 and we will become player 1
        if (Board.isMultiplayer && AccessToken.current?.userID == String(Board.player2.playerFBID)) {
            let temp : Player = Board.player1
            Board.player1 = Board.player2
            Board.player2 = temp
        }
        
        // Resetting board
        // TODO: Player 1 shouldn't have to be X
        BasicBoard.currentTurn = "X"
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        
        // Initiating Rematch
        self.performSegue(withIdentifier: "rematch", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rematch" {
            let board = segue.destination as! Board
            board.level = self.level
        }
    }
    
    @objc func mainMenuButtonTapped(sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        if (Board.isMultiplayer) {
            AppDelegate.deleteGameRequest(request_id: String(Board.gameID))
        }
        
        // Resetting board
        BasicBoard.currentTurn = "X"
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        
        // Moving to Main Menu
        let mainMenu = main.instantiateViewController(withIdentifier: "MainMenu")
        mainMenu.modalPresentationStyle = .fullScreen // Necessary for iOS 13 onwards to make sure you can't come back
        self.present(mainMenu, animated: true, completion: nil)
    }
    
    @objc func viewGameButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func newGameButtonTapped(sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        if (Board.isMultiplayer) {
            AppDelegate.deleteGameRequest(request_id: String(Board.gameID))
        }
        
        // Resetting board
        BasicBoard.currentTurn = "X"
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        
        // Moving to Player Selector to start new game
        let playerSelector = main.instantiateViewController(withIdentifier: "PlayerSelector")
        playerSelector.modalPresentationStyle = .fullScreen // Necessary for iOS 13 onwards to make sure you can't come back
        self.present(playerSelector, animated: true, completion: nil)
    }
}
