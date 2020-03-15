//
//  Board.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-15.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import FBSDKShareKit
import GameKit

class Board: UIViewController {

    var boardAdapter : BoardAdapter? = nil
    
    var gaps : CGFloat = 20
    var level : Int = 1
    var dimension : CGFloat!
    var currentPlayer : String!
    static var player1 : Player = Player()
    static var player2 : Player = Player()
    static var currentPlayer : Player = Player()
    var playerTurn : String!
    static var keys : NSMapTable<NSNumber, UIButton> = NSMapTable<NSNumber, UIButton>()
    static var playerTurnLabel: UILabel!
    var doneOnce : Bool = false
    var willLayoutSubviewsCount : Int = 0
    static var reload = false
    static var titleLabel : UILabel!
    static var background : UIView!
    var levelMenu : LevelMenu!
    var mainMenu : MainMenu!
    static var gameID : Int64 = 0
    
    @IBOutlet var background: UIView!
    @IBOutlet var board: UIView!
    @IBOutlet var playersTurnLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !self.doneOnce {
            Board.titleLabel = self.view.viewWithTag(402) as? UILabel
            Board.background = self.view.viewWithTag(401)
            Board.playerTurnLabel = self.view.viewWithTag(407) as? UILabel
            self.doneOnce = true
        }
        
        if level == 1 {
            titleLabel.text = "Tic"
        } else {
            titleLabel.text = "Tic Tac"
        }
        
        Board.playerTurnLabel.text = Board.player1.playerName + "'s Turn"
        Board.playerTurnLabel.textColor = Style.mainColorBlack
        
        // UI Setup
        background.backgroundColor = Style.mainColorGreen;
        playersTurnLabel.textColor = Style.mainColorBlack;
        
        if (LevelMenu.multiplayer) {
            saveButton.isEnabled = false
            saveButton.isHidden = true
        }
        saveButton.backgroundColor = Style.mainColorBlack;
        saveButton.setTitleColor(Style.mainColorWhite, for: .normal);
        
        menuButton.backgroundColor = Style.mainColorBlack;
        menuButton.setTitleColor(Style.mainColorWhite, for: .normal);
        titleLabel.textColor = Style.mainColorBlack;
    }
    
    override func viewWillLayoutSubviews() {
        configureBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPlayers(player1 : Player, player2: Player) {
        Board.player1 = player1
        Board.player2 = player2
    }
    
    func configureBoard() {
        self.willLayoutSubviewsCount += 1
        if (self.willLayoutSubviewsCount == 2) {
            if boardAdapter == nil {
                boardAdapter = BoardAdapter.init(collectionViewLayout: UICollectionViewFlowLayout.init())
            }
            
            let metaBoard : BasicBoard = BasicBoard();
            metaBoard.frame = CGRect(x: 0, y: 0, width: self.board.frame.size.width, height: self.board.frame.size.height)
            metaBoard.metaRow = 0
            metaBoard.metaColumn = 0
            
            metaBoard.configureBoard(width: self.board.frame.size.width, level: level, metaLevel: level, board: self)
            
            board.addSubview(metaBoard)
            
            if (BasicBoard.wincheck[9][2] != "" && level >= 2) {
                let row : Int = Int(BasicBoard.wincheck[9][0])!
                let column : Int = Int(BasicBoard.wincheck[9][1])!
                metaBoard.boardChanger(row: row, column: column, level: level, clickable: true)
            }
        }
    }
    
    func sizeForItemAt(index : Int, width: CGFloat) {
        dimension = (width - gaps)/3.0
    }
    
    @IBAction func bottomPanelListener(_ sender: UIButton) {
        switch sender.tag {
        case 408:
            let localPlayer = GKLocalPlayer.local
            let gameData = createGameString().data(using: .utf8)
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
    
    func createGameString() -> String {
        var game = ""
        for i in 0..<10 {
            for j in 0..<9 {
                game += BasicBoard.wincheck[i][j] + ","
            }
            game += ";"
        }
        return game
    }
    
    func winningBoardChanger(boardAdapter : BasicBoard, row : Int, column : Int, level : Int, clickable : Bool, x : String) -> Bool {
        let metaRow = row/3
        let metaColumn = column/3
        let label = BasicBoard.metaBoard[metaRow][metaColumn].overlayingWinnerLabel
        label?.text = BasicBoard.metawincheck[metaRow][metaColumn]
        label?.textColor = Style.mainColorBlack
        label?.textAlignment = .center
        label?.font = Style.globalFont?.withSize(100)
        
        BasicBoard.metaBoard[metaRow][metaColumn].boardBackground.alpha = 0
        BasicBoard.metaBoard[metaRow][metaColumn].boardBackgroundRed.alpha = 0
        BasicBoard.metaBoard[metaRow][metaColumn].horizontalStackView.alpha = 0
        
        boardAdapter.boardChanger(row: row, column: column, level: level, clickable: clickable)
        return boardAdapter.winChecker(row: row, column: column, level: 1, actual: level, winchecker: BasicBoard.metawincheck, turnValue: x, recreatingGame: false)
    }
    
    func finish(won : Bool, winnerName : String) {
        if won {
            let extras = [winnerName]
            self.performSegue(withIdentifier: "ToWinner", sender: extras)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToWinner" {
            let winner = segue.destination as! Winner
            let extras = sender as! [Any]
            winner.board = self
            winner.levelMenu = self.levelMenu
            winner.winnerName = extras[0] as? String
            winner.mainMenu = self.mainMenu
        }
    }
    
    func deleteGameRequest(request_id: String) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/\(request_id)", httpMethod: .delete)) {connection, result, error in
            if (result != nil) {
                print("\(String(describing: result))")
            } else {
                print("\(String(describing: error))")
            }
        }
        connection.start()
    }
}
