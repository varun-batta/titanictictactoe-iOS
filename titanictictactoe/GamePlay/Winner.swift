//
//  Winner.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-20.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import FBSDKShareKit

class Winner: UIViewController {

    var winnerName : String!
    var mainMenu : MainMenu! // TODO: Does this really need to be passed around?
    var board : Board! // TODO: Does this really need to be passed around?
    
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
                    if ((Board.player1.playerName == winnerName && AccessToken.current?.userID == String(Board.player1.playerFBID)) || (Board.player2.playerName == winnerName && AccessToken.current?.userID == String(Board.player2.playerFBID))) {
                        playerWinsLabel.text = "You WIN!!!"
                    } else {
                        playerWinsLabel.text = winnerName + "has won"
                    }
                } else {
                    playerWinsLabel.text = winnerName + " WINS!!!"
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
            self.deleteGameRequest(request_id: String(Board.gameID))
        }
        
        // Switch players since we are player 2 and we will become player 1
        if (Board.isMultiplayer && AccessToken.current?.userID == String(Board.player2.playerFBID)) {
            let temp : Player = Board.player1
            Board.player1 = Board.player2
            Board.player2 = temp
        }
        
        // TODO: Player 1 shouldn't have to be X
        BasicBoard.currentTurn = "X"
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        self.performSegue(withIdentifier: "rematch", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rematch" {
            let board = segue.destination as! Board
            board.level = self.board.level
            board.mainMenu = self.mainMenu
        }
    }
    
    // TODO: Do we need both main menu and new game if main menu is where you create a new game from? Clean up!
    @objc func mainMenuButtonTapped(sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        if (Board.isMultiplayer) {
            self.deleteGameRequest(request_id: String(Board.gameID))
        }
        
        // TODO: Handle the view dismissing process better
        if (self.mainMenu == nil) {
            let mainMenu = main.instantiateViewController(withIdentifier: "MainMenu")
            self.present(mainMenu, animated: true, completion: nil)
        } else {
            self.mainMenu.dismiss(animated: true, completion: nil)
        }
    }
    
    // TODO: Make sure when viewing the game it is not clickable
    @objc func viewGameButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func newGameButtonTapped(sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        if (Board.isMultiplayer) {
            self.deleteGameRequest(request_id: String(Board.gameID))
        }
        
        // TODO: Handle the view dismissing process better
        if (self.mainMenu == nil) {
            let mainMenu = main.instantiateViewController(withIdentifier: "MainMenu")
            self.present(mainMenu, animated: true, completion: nil)
        } else {
            self.mainMenu.dismiss(animated: true, completion: nil)
        }
    }
    
    // TODO: Is this necessary? If yes, perhaps group all deleteGameRequest functions together? And all game request functions altogether, if possible
    func deleteGameRequest(request_id: String) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/\(request_id)", httpMethod: .delete)) {connection, result, error  in
            if ((result) != nil) {
                print("\(String(describing: result))")
            } else {
                print("\(String(describing: error))")
            }
        }
        connection.start()
    }
}
