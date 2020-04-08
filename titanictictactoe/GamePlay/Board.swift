//
//  Board.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-15.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FBSDKShareKit
import GameKit

class Board: UIViewController {

    var level : Int = 1 // Will come from game
    static var player1 : Player = Player() // Will come from game
    static var player2 : Player = Player() // Will come from game
    static var isMultiplayer : Bool! // Will come from game
    static var gameID : Int64 = 0 // Will come from game
    static var keys : NSMapTable<NSNumber, UIButton> = NSMapTable<NSNumber, UIButton>() // TODO: Required for the buttons - does it need to be here or could it move to the BasicBoard?
    
    @IBOutlet var board: BasicBoard!
    @IBOutlet var currentPlayerLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if level == 1 {
            titleLabel.text = "Tic"
        } else {
            titleLabel.text = "Tic Tac"
        }
        
        // UI Setup
        currentPlayerLabel.text = Board.player1.playerName + "'s Turn"
        
        // TODO: Does "isMultiplayer" need to be static?
        if (Board.isMultiplayer) {
            saveButton.isEnabled = false
            saveButton.isHidden = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.board.metaRow = 0
        self.board.metaColumn = 0
        self.board.configureBoard(width: self.board.frame.size.width, level: level, metaLevel: level, board: self)
        
        // The logic to recreate an existing game
        // TODO: Perhaps this logic should be moved elsewhere to clarify the code
        if (BasicBoard.wincheck[9][2] != "" && level >= 2) {
            let row : Int = Int(BasicBoard.wincheck[9][0])!
            let column : Int = Int(BasicBoard.wincheck[9][1])!
            board.boardChanger(row: row, column: column, level: level, clickable: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setCurrentPlayerLabel() {
        // TODO: Fix all this unnecessary static logic
        if BasicBoard.currentTurn == "X" {
            currentPlayerLabel.text = Board.player2.playerName + "'s Turn"
            BasicBoard.currentTurn = "O"
        } else {
            currentPlayerLabel.text = Board.player1.playerName + "'s Turn"
            BasicBoard.currentTurn = "X"
        }
    }
    
    // TODO: Clean up this data being all over the place
    func setPlayers(player1 : Player, player2: Player) {
        Board.player1 = player1
        Board.player2 = player2
    }
    
    // TODO: Get rid of this once the UI is cleaned up
    @IBAction func bottomPanelListener(_ sender: UIButton) {
        switch sender.tag {
        case 408:
            let localPlayer = GKLocalPlayer.local
            let gameData = Game.createGameString().data(using: .utf8)
            let gameName = Board.player1.playerName + " vs. " + Board.player2.playerName + " - Level \(level)"
            localPlayer.saveGameData(gameData!, withName: gameName) {(savedGame, error) -> Void in
                if (error == nil) {
                    print("Successfully saved!")
                } else {
                    print("\(String(describing: error))")
                }
            }
            break
        case 409:
            BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
            BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
            BasicBoard.firstTurn = true
            BasicBoard.metaBoard = [[BasicBoard]](repeating: [BasicBoard](repeating: BasicBoard(), count: 3), count: 3)
            BasicBoard.lastMoveRow = -1
            BasicBoard.lastMoveColumn = -1
            self.dismiss(animated: true, completion: nil)
            break
        default:
            return
        }
    }
    
    func winningBoardChanger(basicBoard : BasicBoard, row : Int, column : Int, level : Int, clickable : Bool, x : String) -> Bool {
        let metaRow = row/3
        let metaColumn = column/3
        let label = BasicBoard.metaBoard[metaRow][metaColumn].overlayingWinnerLabel
        label?.text = BasicBoard.metawincheck[metaRow][metaColumn]
        label?.textColor = UIColor(named: "mainColorBlack")
        label?.textAlignment = .center
        label?.font = Style.globalFont?.withSize(100)
        
        BasicBoard.metaBoard[metaRow][metaColumn].boardBackground.alpha = 0
        BasicBoard.metaBoard[metaRow][metaColumn].boardBackgroundRed.alpha = 0
        BasicBoard.metaBoard[metaRow][metaColumn].horizontalStackView.alpha = 0
        
        basicBoard.boardChanger(row: row, column: column, level: level, clickable: clickable)
        return basicBoard.winChecker(row: row, column: column, level: 1, actual: level, winchecker: BasicBoard.metawincheck, turnValue: x, recreatingGame: false)
    }
    
    func finish(won : Bool, winnerName : String) {
        if won {
            board.disableBoard(level: level)
            let extras = [winnerName]
            self.performSegue(withIdentifier: "ToWinner", sender: extras)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToWinner" {
            let winner = segue.destination as! Winner
            let extras = sender as! [Any]
            winner.winnerName = extras[0] as? String
            winner.level = self.level
        }
    }
}
