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
    static var isMultiplayerMode : Bool! = false // Will come from game
    static var isAIMode: Bool! = false // Will come from game
    static var isInstructionalMode: Bool! = false // Will come from game
    static var gameID : Int64 = 0 // Will come from game
    static var keys : NSMapTable<NSNumber, UIButton> = NSMapTable<NSNumber, UIButton>() // TODO: Required for the buttons - does it need to be here or could it move to the BasicBoard?
    static var enabledKeys : [NSNumber] = []
    
    @IBOutlet var board: BasicBoard!
    @IBOutlet var currentPlayerLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        // TODO: Is a title even necessary?
        if level == 1 {
            titleLabel.text = "Tic"
        } else {
            titleLabel.text = "Tic Tac"
        }
        
        currentPlayerLabel.text = Board.player1.playerName == "Your" ? "Your Turn" :  Board.player1.playerName + "'s Turn"
        
        // TODO: Does "isMultiplayer" need to be static?
        if Board.isMultiplayerMode || Board.isInstructionalMode {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Handle AI Player
        if currentPlayerLabel.text == "AI's Turn" {
            // Determine which of the enabledKeys will be chosen
            populateEnabledKeys(metaRow: -1, metaColumn: -1)
            let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
            Board.keys.object(forKey: chosenKey)?.sendActions(for: .touchUpInside)
        }
        
        // Handle Instructional Mode
        if Board.isInstructionalMode {
            if level == 1 {
                // Instruction Set
                _ = [
                    [
                        "message": "No worries! Since you don't know how Tic Tac Toe works, let's give you a quick intro. Start by tapping on any one of the available squares.",
                        "action": "Dismiss to allow user to tap on one of the squares"
                    ],
                    [
                        "message": "Since you started off the game, you are X this time around. Your opponent can now make a move in any one of the remaining squares and they are O.",
                        "action": "Have the AI make a turn in the background"
                    ],
                    [
                        "message": "Now, before we continue, let's clarify what your goal is.",
                        "action": "Click next"
                    ],
                    [
                        "message": "You are trying to get your symbol, X in this case, to be either 3 in a row",
                        "action": "Highlight the 3 squares in the same row as selected"
                    ],
                    [
                        "message": "You are trying to get your symbol, X in this case, to be either 3 in a row, 3 in a column",
                        "action": "Highlight the 3 squares in the same column as selected"
                    ],
                    [
                        "message": "You are trying to get your symbol, X in this case, to be either 3 in a row, 3 in a column, or 3 in a diagonal",
                        "action": "Highlight the 3 squares in the same diagonal as selected if possible, else either of the 2 choices"
                    ],
                    [
                        "message": "Now let's play a bit",
                        "action": "Dismiss and allow a couple moves until 2 in a row column or diagonal for either of the two players"
                    ],
                    [
                        "message": "Well done! Remember to make sure your opponent doesn't get 3 in a row and they will be doing the same",
                        "action": "Dismiss and, if AI turn, make sure to choose the option to block the opponent. Let game continue to end"
                    ],
                    [
                        "message": "Hope you enjoyed! If you'd like to try to learn how we make Tic Tac Toe a little more complicated, please click Next. If you'd like to continue practicing for now and perhaps try later, feel free to look at the instructions again (just click Yes when asking whether you know Tic Tac Toe already since now you do!)",
                        "action": "If they click Next, show level 2 instructions. If not, just dismiss to the main menu"
                    ]
                ]
                let alert = UIAlertController(title: nil, message: "No worries! Since you don't know how Tic Tac Toe works, let's give you a quick intro. Start by tapping on any one of the available squares.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if level == 2 {
                // Instruction Set
                _ = [
                    [
                        "message": "Great! Let's show you the next level of Tic Tac Toe. Start by tapping on any one of the available squares.",
                        "action": "Dismiss to allow user to tap on one of the squares"
                    ],
                    [
                        "message": "Oh, look at that! Since you picked the <<their selection>> square, your opponent is only allowed to play in the <<their selection>> section of the board (everything that is red cannot be clicked on). Let's let them make a move.",
                        "action": "Have the AI make a turn in the background"
                    ],
                    [
                        "message": "As you can see, this is more complicated since we are moving around the entire board. But the goal is the same as regular tic tac toe. You keep moving around and try to win the different sections by getting 3 in a row, column or diagonal.",
                        "action": "Let the user continue playing until the next move will win one of the sections (maybe guide the user to that state by highlighting the best option and making it the only clickable option)"
                    ],
                    [
                        "message": "Now you'll want to click here",
                        "action": "Highlight the ideal choice and make it the only clickable option. Allow user to click there. If it ends up being the opponent, show the alert and say 'It looks like your opponent will win this section of the board.' then highlight the button and say 'They'll want to click here', and then click it."
                    ],
                    [
                        // TODO: Edit this text a bit based on whether the opponent or you clicked there
                        "message": "Brilliant! You just won the <<their selection>> section! As you can see, it became a giant X! To win the game, you have to continue playing and try to win 3 sections in a row, column or diagonal. So you can think of this as Tic Tac Toe in Tic Tac Toe :)",
                        "action": "Show the next instruction"
                    ],
                    [
                        "message": "Oh, and one more thing you should be aware of. If you or your opponent click here (highlight all the squares that would lead them back to the won square) at any point, since that particular section is not available, the entire game board would be available. So it would look like this",
                        "action": "Force the user to select that square (make everything unselectable) or make the AI select that square"
                    ],
                    [
                        "message": "Now let's play!",
                        "action": "Dismiss and allow user to play until there's a victor"
                    ],
                    [
                        "message": "Well done! Hope you enjoyed the game and keep practicing, perhaps try playing with a friend via Faceboook or in person. If your friend doesn't have the app yet, just share it with them!",
                        "action": "Click done"
                    ]
                ]
                let alert = UIAlertController(title: nil, message: "Great! Let's show you the next level of Tic Tac Toe. Start by tapping on any one of the available squares.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func populateEnabledKeys(metaRow: Int, metaColumn: Int) {
        Board.enabledKeys = []
        for key in Board.keys.keyEnumerator() {
            let button : UIButton = Board.keys.object(forKey: (key.self as! NSNumber))!
            // Check for whether key should no tbe put into enabledKeys (it's the same as the section, so users won't see any movement)
            let keyInt = key.self as! Int
            let keyMetaColumn = keyInt % 3
            let keyMetaRow = (keyInt / 9) % 3
            if button.isEnabled && keyMetaRow != metaRow && keyMetaColumn != metaColumn {
                Board.enabledKeys.append(key.self as! NSNumber)
            }
        }
    }
    
    func setCurrentPlayerLabel() {
        // TODO: Fix all this unnecessary static logic
        if BasicBoard.currentTurn == "X" {
            currentPlayerLabel.text = Board.player2.playerName == "Your" ? "Your Turn" : Board.player2.playerName + "'s Turn"
            BasicBoard.currentTurn = "O"
        } else {
            currentPlayerLabel.text = Board.player1.playerName == "Your" ? "Your Turn" :  Board.player1.playerName + "'s Turn"
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
            BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
            BasicBoard.firstTurn = true
            BasicBoard.metaBoard = [[BasicBoard]](repeating: [BasicBoard](repeating: BasicBoard(), count: 3), count: 3)
            BasicBoard.lastMoveRow = -1
            BasicBoard.lastMoveColumn = -1
            BasicBoard.currentTurn = "X"
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
    
    func dismiss(action: UIAlertAction) {
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        BasicBoard.firstTurn = true
        BasicBoard.metaBoard = [[BasicBoard]](repeating: [BasicBoard](repeating: BasicBoard(), count: 3), count: 3)
        BasicBoard.lastMoveRow = -1
        BasicBoard.lastMoveColumn = -1
        BasicBoard.currentTurn = "X"
        self.dismiss(animated: true, completion: nil)
    }
    
    func showNextLevelInstructions(action: UIAlertAction) {
        self.dismiss(animated: true, completion: nil)
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
