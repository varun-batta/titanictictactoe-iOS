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
    var mainMenu : MainMenu!
    var levelMenu : LevelMenu!
    var board : Board!
    
    @IBOutlet var background: UIView!
    @IBOutlet var playerWinsLabel: UILabel!
    @IBOutlet var mainMenuButton: UIButton!
    @IBOutlet var viewGameButton: UIButton!
    @IBOutlet var newGameButton: UIButton!
    @IBOutlet var rematchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if winnerName != nil {
            if winnerName == "Tie" {
                playerWinsLabel.text = "It's a Tie!"
            } else {
                if (LevelMenu.multiplayer && (AccessToken.current) != nil) {
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
        background.backgroundColor = Style.mainColorGreen;
        playerWinsLabel.textColor = Style.mainColorBlack;
        
        rematchButton.backgroundColor = Style.mainColorBlack;
        rematchButton.setTitleColor(Style.mainColorWhite, for: .normal);
        rematchButton.addTarget(self, action: #selector(rematchButtonTapped), for: .touchUpInside)
        
        mainMenuButton.backgroundColor = Style.mainColorBlack;
        mainMenuButton.setTitleColor(Style.mainColorWhite, for: .normal);
        mainMenuButton.addTarget(self, action: #selector(mainMenuButtonTapped), for: .touchUpInside)
        
        viewGameButton.backgroundColor = Style.mainColorBlack;
        viewGameButton.setTitleColor(Style.mainColorWhite, for: .normal);
        viewGameButton.addTarget(self, action: #selector(viewGameButtonTapped), for: .touchUpInside)
        
        newGameButton.backgroundColor = Style.mainColorBlack;
        newGameButton.setTitleColor(Style.mainColorWhite, for: .normal);
        newGameButton.addTarget(self, action: #selector(newGameButtonTapped), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func rematchButtonTapped(sender: UIButton) {
        if (LevelMenu.multiplayer) {
            self.deleteGameRequest(request_id: String(Board.gameID))
        }
        
        if (LevelMenu.multiplayer && (AccessToken.current?.userID == String(Board.player2.playerFBID))) {
            let temp : Player = Board.player1
            Board.player1 = Board.player2
            Board.player2 = temp
        }
        
        BasicBoard.currentTurn = "X"
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        self.performSegue(withIdentifier: "rematch", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rematch" {
            let board = segue.destination as! Board
            board.level = self.board.level
            board.levelMenu = self.levelMenu
            board.mainMenu = self.mainMenu
        }
    }
    
    @objc func mainMenuButtonTapped(sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        if (LevelMenu.multiplayer) {
            self.deleteGameRequest(request_id: String(Board.gameID))
        }
        if (self.mainMenu == nil) {
            let mainMenu = main.instantiateViewController(withIdentifier: "MainMenu")
            self.present(mainMenu, animated: true, completion: nil)
        } else {
            self.mainMenu.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func viewGameButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func newGameButtonTapped(sender: UIButton) {
        let main = UIStoryboard(name: "Main", bundle: nil)
        if (LevelMenu.multiplayer) {
            self.deleteGameRequest(request_id: String(Board.gameID))
        }
        if (self.levelMenu == nil) {
            let levelMenu = main.instantiateViewController(withIdentifier: "MainMenu")
            self.present(levelMenu, animated: true, completion: nil)
        } else {
            self.levelMenu.dismiss(animated: true, completion: nil)
        }
    }
    
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
