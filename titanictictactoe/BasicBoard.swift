//
//  BasicBoard.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-10-26.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import FBSDKCoreKit
import FBSDKShareKit

class BasicBoard: UIView, FBSDKGameRequestDialogDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet var boardBackground: UIImageView!
    @IBOutlet var boardBackgroundRed: UIImageView!
    @IBOutlet var horizontalStackView: UIStackView!
    @IBOutlet var horizontalStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var horizontalStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var horizontalStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var horizontalStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var verticalLeftStackView: UIStackView!
    @IBOutlet var verticalMiddleStackView: UIStackView!
    @IBOutlet var verticalRightStackView: UIStackView!
    @IBOutlet var overlayingWinnerLabel: UILabel!
    
    var level : Int!
    var metaLevel : Int!
    var dimension : CGFloat!
    var metaRow : Int = -1
    var metaColumn : Int = -1
    static var currentTurn : String = "X"
    var turn : String!
    var board : Board!
    static var wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
    static var metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
    static var firstTurn : Bool = true
    static var metaBoard : [[BasicBoard]] = [[BasicBoard]](repeating: [BasicBoard](repeating: BasicBoard(), count: 3), count: 3)
    var winOrTie : Bool = false
    static var lastMoveRow : Int = -1
    static var lastMoveColumn : Int = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("BasicBoard", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func configureBoard(width: CGFloat, level: Int, metaLevel: Int, board: Board) {
        self.level = level
        self.metaLevel = metaLevel
        let gaps : CGFloat = 20.0
        self.board = board
        self.boardBackgroundRed.alpha = 0;
        
        let dimension = dimensionForButton(width: width, gaps: gaps)
        
        if (level == 1) {
            for index in 0...8 {
                var row : Int = -1
                var column : Int = -1
                switch(index) {
                case 0:
                    row = 0
                    column = 0
                    break
                case 1:
                    row = 0
                    column = 1
                    break
                case 2:
                    row = 0
                    column = 2
                    break
                case 3:
                    row = 1
                    column = 0
                    break
                case 4:
                    row = 1
                    column = 1
                    break
                case 5:
                    row = 1
                    column = 2
                    break
                case 6:
                    row = 2
                    column = 0
                    break
                case 7:
                    row = 2
                    column = 1
                    break
                case 8:
                    row = 2
                    column = 2
                    break
                default:
                    row = -1
                    column = -1
                    break
                }
                let button = UIButton()
                button.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
//                button.setTitle("", for: .normal)
                button.setTitle(BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column], for: .normal)
                if (BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column] != "") {
                    button.isEnabled = false
                }
                if (BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column] == "X" || BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column] == "O") {
                    if (metaLevel >= 2 && self.winChecker(row: metaRow*3 + row, column: metaColumn*3 + column, level: metaLevel, actual: metaLevel, winchecker: BasicBoard.wincheck, turnValue: BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column], recreatingGame: true)) {
                        let label = BasicBoard.metaBoard[metaRow][metaColumn].overlayingWinnerLabel
                        label?.text = BasicBoard.metawincheck[metaRow][metaColumn]
                        label?.textColor = Style.mainColorBlack
                        label?.textAlignment = .center
                        label?.font = Style.globalFont?.withSize(100)
                        
                        BasicBoard.metaBoard[metaRow][metaColumn].boardBackground.alpha = 0
                        BasicBoard.metaBoard[metaRow][metaColumn].horizontalStackView.alpha = 0
                    }
                }
                button.setTitleColor(Style.mainColorBlack, for: .disabled)
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
                button.contentVerticalAlignment = UIControlContentVerticalAlignment.center
                button.backgroundColor = .clear
                if metaLevel == 1 {
                    button.titleLabel!.font = Style.globalFont?.withSize(100)
                } else {
                    button.titleLabel!.font = Style.globalFont?.withSize(15)
                }
                button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
                if metaLevel == 2 {
                    button.tag = metaRow*27 + row*9 + metaColumn*3 + column
                } else if metaLevel == 1 {
                    button.tag = row*3 + column
                }
                
                button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
                
                Board.keys.setObject(button, forKey: NSNumber.init(value: button.tag))
                
                if index%3 == 0 {
                    verticalLeftStackView.addArrangedSubview(button)
                } else if index%3 == 1 {
                    verticalMiddleStackView.addArrangedSubview(button)
                } else {
                    verticalRightStackView.addArrangedSubview(button)
                }
            }
        } else if (level == 2) {
            for index in 0...8 {
                let miniBoard : BasicBoard = BasicBoard();
                miniBoard.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
                switch(index) {
                case 0:
                    miniBoard.metaRow = 0
                    miniBoard.metaColumn = 0
                    break
                case 1:
                    miniBoard.metaRow = 0
                    miniBoard.metaColumn = 1
                    break
                case 2:
                    miniBoard.metaRow = 0
                    miniBoard.metaColumn = 2
                    break
                case 3:
                    miniBoard.metaRow = 1
                    miniBoard.metaColumn = 0
                    break
                case 4:
                    miniBoard.metaRow = 1
                    miniBoard.metaColumn = 1
                    break
                case 5:
                    miniBoard.metaRow = 1
                    miniBoard.metaColumn = 2
                    break
                case 6:
                    miniBoard.metaRow = 2
                    miniBoard.metaColumn = 0
                    break
                case 7:
                    miniBoard.metaRow = 2
                    miniBoard.metaColumn = 1
                    break
                case 8:
                    miniBoard.metaRow = 2
                    miniBoard.metaColumn = 2
                    break
                default:
                    miniBoard.metaRow = -1
                    miniBoard.metaColumn = -1
                    break
                }
                
                BasicBoard.metaBoard[miniBoard.metaRow][miniBoard.metaColumn] = miniBoard
                
                miniBoard.configureBoard(width: dimension, level: 1, metaLevel: 2, board: board)
                
                miniBoard.horizontalStackViewTopConstraint.constant = miniBoard.horizontalStackViewTopConstraint.constant/3;
                miniBoard.horizontalStackViewBottomConstraint.constant = miniBoard.horizontalStackViewBottomConstraint.constant/3;
                miniBoard.horizontalStackViewLeadingConstraint.constant = miniBoard.horizontalStackViewLeadingConstraint.constant/3;
                miniBoard.horizontalStackViewTrailingConstraint.constant = miniBoard.horizontalStackViewTrailingConstraint.constant/3;
                
                if (BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "X" || BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "O") {
                    if (self.winChecker(row: miniBoard.metaRow, column: miniBoard.metaColumn, level: 1, actual: level, winchecker: BasicBoard.metawincheck, turnValue: BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn], recreatingGame: true)) {
                        if (BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "X") {
                            board.finish(won: true, winnerName: Board.player1.playerName)
                        } else if (BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "O") {
                            board.finish(won: true, winnerName: Board.player2.playerName)
                        }
                    }

                }
                
                if index%3 == 0 {
                    verticalLeftStackView.addArrangedSubview(miniBoard)
                } else if index%3 == 1 {
                    verticalMiddleStackView.addArrangedSubview(miniBoard)
                } else {
                    verticalRightStackView.addArrangedSubview(miniBoard)
                }
            }
        }
    }
    
    func dimensionForButton(width: CGFloat, gaps: CGFloat) -> CGFloat {
        let dimension = (width - gaps)/3.0
        return dimension
    }
    
    func buttonClicked(sender: UIButton) {
        
        var turn : String!
        
        if BasicBoard.currentTurn == "X" {
            turn = "X"
            
            Board.playerTurnLabel.text = Board.player2.playerName + "'s Turn"
            
            BasicBoard.currentTurn = "O"
        } else {
            turn = "O"
            
            Board.playerTurnLabel.text = Board.player1.playerName + "'s Turn"
            
            BasicBoard.currentTurn = "X"
        }
        
        sender.setTitle(turn, for: .disabled)
        sender.isEnabled = false
        sender.backgroundColor = .clear
        
        let size : Int = Int(NSDecimalNumber(decimal: pow(3, metaLevel)))
        
        var found : Bool = false
        var row : Int = -1
        var column : Int = -1
        
        for i in 0..<size {
            for j in 0..<size {
                if i*size + j == sender.tag {
                    found = true
                    row = i
                    column = j
                    break
                }
            }
            if found {
                break
            }
        }
        
        BasicBoard.wincheck[row][column] = turn
        
        BasicBoard.wincheck[9][0] = String(row)
        BasicBoard.wincheck[9][1] = String(column)
        BasicBoard.wincheck[9][2] = turn
        BasicBoard.wincheck[9][3] = String(metaLevel)
        
        if metaLevel >= 2 {
            boardChanger(row: row, column: column, level: metaLevel, clickable: true)
        }

        self.winOrTie = winChecker(row: row, column: column, level: metaLevel, actual: level, winchecker: BasicBoard.wincheck, turnValue: turn, recreatingGame: false)

        if LevelMenu.multiplayer {
//            var toID : Int64 = 0
//            var fromID : Int64 = 0
            var toPlayer : Player = Player()
            var fromPlayer : Player = Player()
            if turn == "X" {
//                toID = Board.player2ID
//                fromID = Board.player1ID
                toPlayer = Board.player2
                fromPlayer = Board.player1
            } else {
//                toID = Board.player1ID
//                fromID = Board.player2ID
                toPlayer = Board.player1
                fromPlayer = Board.player2
            }
            var messageText = ""
            var titleText = ""
            if BasicBoard.firstTurn {
                messageText = "\(fromPlayer.playerName) has challenged you to a game, play now!"
                titleText = "New Game!"
            } else {
                if self.winOrTie {
                    messageText = "\(fromPlayer.playerName) has won the game!"
                    titleText = "Game Over"
                } else {
                    messageText = "\(fromPlayer.playerName) has played and now it is your turn!"
                    titleText = "Your turn"
                }
            }
            let game = createGameString()
            let params : [String : Any] = ["data" : game, "message" : messageText, "title" : titleText]
            makeTurn(to: toPlayer.playerFBID, params: params)
        }
    }
    
    func createGameString() -> String {
        var game = ""
//        let size : Int = Int(NSDecimalNumber(decimal: pow(3, level)))
//        for i in 0...(size - 1) {
//            for j in 0...(size - 1) {
        for i in 0..<10 {
            for j in 0..<9 {
                game += BasicBoard.wincheck[i][j] + ","
            }
            game += ";"
        }
        return game
    }
    
    func boardChanger( row : Int, column : Int, level : Int, clickable : Bool) {
        if level == 2 {
            for i in 0...8 {
                for j in 0...8 {
                    let key : Int = i*9 + j
                    let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                    
                    button.isEnabled = false
                    button.backgroundColor = .clear
                    if BasicBoard.metawincheck[i%3][j%3] == "" {
                        BasicBoard.metaBoard[i%3][j%3].boardBackgroundRed.alpha = 0.5
                    }
                }
            }
            let metaRow = row%3 //abs(row - 8)%3;
            let metaColumn = column%3 //abs(column - 8)%3;
            if BasicBoard.metawincheck[metaRow][metaColumn] == "" {
                for k in 0...2 {
                    for l in 0...2 {
                        let key : Int = ((row % 3)*27 + k*9 + (column % 3)*3 + l)
                        let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                        
                        if button.title(for: .disabled) == "" {
                            button.isEnabled = true
                            button.backgroundColor = .clear
                        }
                    }
                }
                BasicBoard.metaBoard[metaRow][metaColumn].boardBackgroundRed.alpha = 0
            } else {
                for i in 0...8 {
                    for j in 0...8 {
                        let key : Int = i*9 + j
                        let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                        
                        if button.title(for: .disabled) == "" {
                            button.isEnabled = true
                            button.backgroundColor = .clear
                        }
                        
                        if BasicBoard.metawincheck[i%3][j%3] == "" {
                            BasicBoard.metaBoard[i%3][j%3].boardBackgroundRed.alpha = 0;
                        }
                    }
                }
            }
        }
    }
    
    func winChecker(row: Int, column: Int, level: Int, actual: Int, winchecker: [[String]], turnValue: String, recreatingGame: Bool) -> Bool {
        var winOrTie : Bool = false
        var value : String = ""
        var value1 : String = ""
        var value2 : String = ""
        var x : String = ""
        var q : Int = -1
        var r : Int = -1
        var f : Int = row
        var g : Int = column
        var length : Int = winchecker.count
        var width : Int = winchecker[0].count
        
        
        if level == 1 && actual >= 2 {
            q = row
            r = column
            f = row/3
            g = column/3
        }
        
        if f%3 == 0 {
            value = winchecker[f][g]
            value1 = winchecker[f+1][g]
            value2 = winchecker[f+2][g]
        } else if f%3 == 1 {
            value = winchecker[f-1][g]
            value1 = winchecker[f][g]
            value2 = winchecker[f+1][g]
        } else if f%3 == 2 {
            value = winchecker[f-2][g]
            value1 = winchecker[f-1][g]
            value2 = winchecker[f][g]
        }
        
        if value != "" && value1 != "" && value2 != "" {
            if value == value1 && value1 == value2 {
                x = turnValue
            }
        }
        
        if g%3 == 0 {
            value = winchecker[f][g]
            value1 = winchecker[f][g+1]
            value2 = winchecker[f][g+2]
        } else if g%3 == 1 {
            value = winchecker[f][g-1]
            value1 = winchecker[f][g]
            value2 = winchecker[f][g+1]
        } else if g%3 == 2 {
            value = winchecker[f][g-2]
            value1 = winchecker[f][g-1]
            value2 = winchecker[f][g]
        }
        
        if value != "" && value1 != "" && value2 != "" {
            if value == value1 && value1 == value2 {
                x = turnValue
            }
        }
        
        if f%3 == 0 && g%3 == 0 {
            value = winchecker[f][g]
            value1 = winchecker[f+1][g+1]
            value2 = winchecker[f+2][g+2]
        } else if f%3 == 1 && g%3 == 1 {
            value = winchecker[f-1][g-1]
            value1 = winchecker[f][g]
            value2 = winchecker[f+1][g+1]
        } else if f%3 == 2 && g%3 == 2 {
            value = winchecker[f-2][g-2]
            value1 = winchecker[f-1][g-1]
            value2 = winchecker[f][g]
        }
        
        if value != "" && value1 != "" && value2 != "" {
            if value == value1 && value1 == value2 {
                x = turnValue
            }
        }
        
        if f%3 == 2 && g%3 == 0 {
            value = winchecker[f][g]
            value1 = winchecker[f-1][g+1]
            value2 = winchecker[f-2][g+2]
        } else if f%3 == 1 && g%3 == 1 {
            value = winchecker[f+1][g-1]
            value1 = winchecker[f][g]
            value2 = winchecker[f-1][g+1]
        } else if f%3 == 0 && g%3 == 2 {
            value = winchecker[f+2][g-2]
            value1 = winchecker[f+1][g-1]
            value2 = winchecker[f][g]
        }
        
        if value != "" && value1 != "" && value2 != "" {
            if value == value1 && value1 == value2 {
                x = turnValue
            }
        }
        
        var winningPlayer : String = ""
        var winningLetter : UILabel = UILabel()
        if x == "X" {
            winningPlayer = Board.player1.playerName
            winningLetter.text = "X"
        }
        if x == "O" {
            winningPlayer = Board.player2.playerName
            winningLetter.text = "O"
        }
        
        if x == "X" || x == "O" {
            if (recreatingGame) {
                switch(level) {
                case 1:
                    return true;
                case 2:
                    BasicBoard.metawincheck[f/3][g/3] = x
                    return true;
                default:
                    return false;
                }
                
            }
            switch(level) {
            case 1:
                if (!LevelMenu.multiplayer) {
                    board.finish(won: true, winnerName: winningPlayer)
                }
                winOrTie = true
                break
            case 2:
                BasicBoard.metawincheck[f/3][g/3] = x
                winOrTie = board.winningBoardChanger(boardAdapter: self, row: f, column: g, level: level, clickable: true, x: x)
                break
            default:
                return false
            }
        }
        
        
        return winOrTie
    }
    
    func winningBoardChanger(row: Int, column: Int, level: Int, clickable: Bool, x : String)
    {
        
    }
    
    //MARK: Multiplayer Functions
    
    func makeTurn(to : Int64, params : [String : Any]) {
        let gameRequestContent = FBSDKGameRequestContent()
        gameRequestContent.recipients = [String(to)]
        gameRequestContent.message = params["message"] as! String
        gameRequestContent.data = params["data"] as! String
        gameRequestContent.title = params["title"] as! String
        gameRequestContent.actionType = .turn
//        if self.winOrTie {
//            gameRequestContent.actionType = FBSDKGameRequestActionType.none
//        } else {
//            gameRequestContent.actionType = FBSDKGameRequestActionType.turn
//        }
        
        FBSDKGameRequestDialog.show(with: gameRequestContent, delegate: self)
    }
    
    func gameRequestDialogDidCancel(_ gameRequestDialog: FBSDKGameRequestDialog!) {
        //Fall back as if no move was made
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didFailWithError error: Error!) {
        print("Error!")
        //Fall back as if no move was made
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        let size : Int = Int(NSDecimalNumber(decimal: pow(3, metaLevel)))
        for i in 0..<size {
            for j in 0..<size {
                let key = i*size + j
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.isEnabled = false
            }
        }
        self.deleteGameRequest()
        
        var winningPlayerName : String = ""
        if turn == "X" {
            winningPlayerName = Board.player1.playerName
        } else {
            winningPlayerName = Board.player2.playerName
        }
        board.finish(won: winOrTie, winnerName: winningPlayerName)
        
        print("Success! \(results)")
    }
    
    func deleteGameRequest() {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/\(Board.gameID)", httpMethod: .DELETE)) {httpResponse, result in
            switch(result) {
            case .success(let response):
                print("\(response)")
            case .failed(let error):
                print("\(error)")
            }
        }
        connection.start()
    }
}
