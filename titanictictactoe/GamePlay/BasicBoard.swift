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

class BasicBoard: UIView, GameRequestDialogDelegate {

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
    
    // TODO: Might need to clarify what of all this is necessary and what is not
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
        // Reset the 3 stack views
        verticalLeftStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        verticalMiddleStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        verticalRightStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        // TODO: Clean up this logic!!
        self.level = level
        self.metaLevel = metaLevel
        let gaps : CGFloat = 20.0
        self.board = board
        self.boardBackgroundRed.alpha = 0;
        
        let dimension = dimensionForButton(width: width, gaps: gaps)
        
        if (level == 1) {
            for index in 0...8 {
                let row : Int = index/3
                let column : Int = index%3
                let button = UIButton()
                button.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
                button.setTitle(BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column], for: .normal)
                
                // TODO: Clean up this logic
                if (BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column] != "") {
                    button.isEnabled = false
                }
                
                if ((BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column] == "X" || BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column] == "O") && metaLevel >= 2 && self.winChecker(row: metaRow*3 + row, column: metaColumn*3 + column, level: metaLevel, actual: metaLevel, winchecker: BasicBoard.wincheck, turnValue: BasicBoard.wincheck[metaRow*3 + row][metaColumn*3 + column], recreatingGame: true)) {
                    let label = BasicBoard.metaBoard[metaRow][metaColumn].overlayingWinnerLabel
                    label?.text = BasicBoard.metawincheck[metaRow][metaColumn]
                    label?.textColor = UIColor(named: "mainColorBlack")
                    label?.textAlignment = .center
                    label?.font = Style.globalFont?.withSize(100)
                    
                    BasicBoard.metaBoard[metaRow][metaColumn].boardBackground.alpha = 0
                    BasicBoard.metaBoard[metaRow][metaColumn].horizontalStackView.alpha = 0
                }
                
                // TODO: See if there's anyway to avoid all this UI logic
                button.setTitleColor(UIColor(named: "mainColorBlack"), for: .disabled)
                button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
                button.backgroundColor = .clear
                if metaLevel == 1 {
                    button.titleLabel!.font = Style.globalFont?.withSize(100)
                } else {
                    button.titleLabel!.font = Style.globalFont?.withSize(15)
                }
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                if metaLevel == 2 {
                    button.tag = metaRow*27 + row*9 + metaColumn*3 + column
                } else {
                    button.tag = row*3 + column
                }
                
                button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
                
                Board.keys.setObject(button, forKey: NSNumber.init(value: button.tag))
                
                // TODO: Find a way to arrange the views better!
                if column == 0 {
                    verticalLeftStackView.addArrangedSubview(button)
                } else if column == 1 {
                    verticalMiddleStackView.addArrangedSubview(button)
                } else {
                    verticalRightStackView.addArrangedSubview(button)
                }
            }
        } else if (level == 2) {
            for index in 0...8 {
                let miniBoard : BasicBoard = BasicBoard();
                miniBoard.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
                miniBoard.metaRow = index/3
                miniBoard.metaColumn = index%3
                
                BasicBoard.metaBoard[miniBoard.metaRow][miniBoard.metaColumn] = miniBoard
                
                miniBoard.configureBoard(width: dimension, level: 1, metaLevel: 2, board: board)
                
                // TODO: Clean up all this UI logic, it shouldn't be necessary
                miniBoard.horizontalStackViewTopConstraint.constant = miniBoard.horizontalStackViewTopConstraint.constant/3;
                miniBoard.horizontalStackViewBottomConstraint.constant = miniBoard.horizontalStackViewBottomConstraint.constant/3;
                miniBoard.horizontalStackViewLeadingConstraint.constant = miniBoard.horizontalStackViewLeadingConstraint.constant/3;
                miniBoard.horizontalStackViewTrailingConstraint.constant = miniBoard.horizontalStackViewTrailingConstraint.constant/3;
                
                // TODO: Clean up this logic!!
                if ((BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "X" || BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "O") && self.winChecker(row: miniBoard.metaRow, column: miniBoard.metaColumn, level: 1, actual: level, winchecker: BasicBoard.metawincheck, turnValue: BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn], recreatingGame: true)) {
                        if (BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "X") {
                            board.finish(won: true, winnerName: Board.player1.playerName)
                        } else if (BasicBoard.metawincheck[miniBoard.metaRow][miniBoard.metaColumn] == "O") {
                            board.finish(won: true, winnerName: Board.player2.playerName)
                        }
                    }

                // TODO: Find a way to arrange these views better (this really shouldn't be necessary)
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
    
    @objc func buttonClicked(sender: UIButton) {
        
        let turn : String! = BasicBoard.currentTurn
        
        board.setCurrentPlayerLabel()
        
        sender.setTitle(turn, for: .disabled)
        sender.isEnabled = false
        sender.backgroundColor = .clear
        
        let size : Int = Int(truncating: NSDecimalNumber(decimal: pow(3, metaLevel)))
        
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

        if Board.isMultiplayer {
            var toPlayer : Player = Player()
            var fromPlayer : Player = Player()
            if turn == "X" {
                toPlayer = Board.player2
                fromPlayer = Board.player1
            } else {
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
            let game = Game.createGameString()
            let params : [String : Any] = ["data" : game, "message" : messageText, "title" : titleText]
            makeTurn(to: toPlayer.playerFBID, params: params)
        }
    }
    
    func boardChanger( row : Int, column : Int, level : Int, clickable : Bool) {
        // TODO: Clean up this logic as much as possible
        if level == 2 {
            for i in 0..<9 {
                for j in 0..<9 {
                    let key : Int = i*9 + j
                    let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                    
                    button.isEnabled = false
                    button.backgroundColor = .clear
                    if BasicBoard.metawincheck[i%3][j%3] == "" {
                        BasicBoard.metaBoard[i%3][j%3].boardBackgroundRed.alpha = 0.5
                    }
                }
            }
            let metaRow = row%3
            let metaColumn = column%3
            if BasicBoard.metawincheck[metaRow][metaColumn] == "" {
                for k in 0..<3 {
                    for l in 0..<3 {
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
                for i in 0..<9 {
                    for j in 0..<9 {
                        let key : Int = i*9 + j
                        let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                        
                        if button.title(for: .disabled) == "" {
                            button.isEnabled = true
                            button.backgroundColor = .clear
                        }
                        
                        if BasicBoard.metawincheck[i%3][j%3] == "" {
                            BasicBoard.metaBoard[i%3][j%3].boardBackgroundRed.alpha = 0
                        }
                    }
                }
            }
        }
    }
    
    // TODO: See if there is a way to integrate this into boardChanger above
    func disableBoard(level: Int) {
        let boardSize = 3^level
        for rowIndex in 0..<boardSize {
            for columnIndex in 0..<boardSize {
                let key : Int = rowIndex*boardSize + columnIndex
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                button.isEnabled = false
            }
        }
    }
    
    func winChecker(row: Int, column: Int, level: Int, actual: Int, winchecker: [[String]], turnValue: String, recreatingGame: Bool) -> Bool {
        // TODO: Refactor this function
        var winOrTie : Bool = false
        var value : String = ""
        var value1 : String = ""
        var value2 : String = ""
        var x : String = ""
        var rowIndex : Int = row
        var columnIndex : Int = column
        
        
        if level == 1 && actual >= 2 {
            rowIndex /= 3
            columnIndex /= 3
        }
        
        // Check the column
        // TODO: Clean up this approach
        if rowIndex%3 == 0 {
            value = winchecker[rowIndex][columnIndex]
            value1 = winchecker[rowIndex+1][columnIndex]
            value2 = winchecker[rowIndex+2][columnIndex]
        } else if rowIndex%3 == 1 {
            value = winchecker[rowIndex-1][columnIndex]
            value1 = winchecker[rowIndex][columnIndex]
            value2 = winchecker[rowIndex+1][columnIndex]
        } else if rowIndex%3 == 2 {
            value = winchecker[rowIndex-2][columnIndex]
            value1 = winchecker[rowIndex-1][columnIndex]
            value2 = winchecker[rowIndex][columnIndex]
        }
        
        // Seeing if all the cells in the column have the same value
        if value != "" && value1 != "" && value2 != "" && value == value1 && value1 == value2 {
            x = turnValue
        }
        
        // Check the row
        // TODO: Clean up this approach
        if columnIndex%3 == 0 {
            value = winchecker[rowIndex][columnIndex]
            value1 = winchecker[rowIndex][columnIndex+1]
            value2 = winchecker[rowIndex][columnIndex+2]
        } else if columnIndex%3 == 1 {
            value = winchecker[rowIndex][columnIndex-1]
            value1 = winchecker[rowIndex][columnIndex]
            value2 = winchecker[rowIndex][columnIndex+1]
        } else if columnIndex%3 == 2 {
            value = winchecker[rowIndex][columnIndex-2]
            value1 = winchecker[rowIndex][columnIndex-1]
            value2 = winchecker[rowIndex][columnIndex]
        }
        
        // Seeing if all the cells in the row have the same value
        if value != "" && value1 != "" && value2 != "" && value == value1 && value1 == value2 {
            x = turnValue
        }
        
        // Check the top left to bottom right diagonal
        // TODO: Clean up this approach
        if rowIndex%3 == 0 && columnIndex%3 == 0 {
            value = winchecker[rowIndex][columnIndex]
            value1 = winchecker[rowIndex+1][columnIndex+1]
            value2 = winchecker[rowIndex+2][columnIndex+2]
        } else if rowIndex%3 == 1 && columnIndex%3 == 1 {
            value = winchecker[rowIndex-1][columnIndex-1]
            value1 = winchecker[rowIndex][columnIndex]
            value2 = winchecker[rowIndex+1][columnIndex+1]
        } else if rowIndex%3 == 2 && columnIndex%3 == 2 {
            value = winchecker[rowIndex-2][columnIndex-2]
            value1 = winchecker[rowIndex-1][columnIndex-1]
            value2 = winchecker[rowIndex][columnIndex]
        }
        
        // Seeing if all the cells in the diagonal have the same value
        if value != "" && value1 != "" && value2 != "" && value == value1 && value1 == value2 {
            x = turnValue
        }
        
        // Check the top right to bottom-left diagonal
        // TODO: Clean up this approach
        if rowIndex%3 == 2 && columnIndex%3 == 0 {
            value = winchecker[rowIndex][columnIndex]
            value1 = winchecker[rowIndex-1][columnIndex+1]
            value2 = winchecker[rowIndex-2][columnIndex+2]
        } else if rowIndex%3 == 1 && columnIndex%3 == 1 {
            value = winchecker[rowIndex+1][columnIndex-1]
            value1 = winchecker[rowIndex][columnIndex]
            value2 = winchecker[rowIndex-1][columnIndex+1]
        } else if rowIndex%3 == 0 && columnIndex%3 == 2 {
            value = winchecker[rowIndex+2][columnIndex-2]
            value1 = winchecker[rowIndex+1][columnIndex-1]
            value2 = winchecker[rowIndex][columnIndex]
        }
        
        // Seeing if all the cells in the diagonal have the same value
        if value != "" && value1 != "" && value2 != "" && value == value1 && value1 == value2 {
            x = turnValue
        }
        
        // Setting the winning player name and winning letter
        // TODO: Make this not based on the letter being played (if possible)
        var winningPlayer : String = ""
        let winningLetter : UILabel = UILabel()
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
                    BasicBoard.metawincheck[rowIndex/3][columnIndex/3] = x
                    return true;
                default:
                    return false;
                }
                
            }
            switch(level) {
            case 1:
                if (!Board.isMultiplayer) {
                    board.finish(won: true, winnerName: winningPlayer)
                }
                winOrTie = true
                break
            case 2:
                BasicBoard.metawincheck[rowIndex/3][columnIndex/3] = x
                winOrTie = board.winningBoardChanger(basicBoard: self, row: rowIndex, column: columnIndex, level: level, clickable: true, x: x)
                break
            default:
                return false
            }
        }
        
        // TODO: Check for ties as well
        
        return winOrTie
    }
    
    // TODO : What is this for?
    func winningBoardChanger(row: Int, column: Int, level: Int, clickable: Bool, x : String)
    {
        
    }
    
    // MARK: Multiplayer Functions
    
    func makeTurn(to : Int64, params : [String : Any]) {
        let gameRequestContent = GameRequestContent()
        gameRequestContent.recipients = [String(to)]
        gameRequestContent.message = params["message"] as! String
        gameRequestContent.data = params["data"] as? String
        gameRequestContent.title = params["title"] as! String
        gameRequestContent.actionType = .turn
        
        GameRequestDialog.init(content: gameRequestContent, delegate: self).show()
    }
    
    func gameRequestDialogDidCancel(_ gameRequestDialog: GameRequestDialog) {
        // TODO: Fall back as if no move was made
    }
    
    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didFailWithError error: Error) {
        print("Error!")
        // TODO: Fall back as if no move was made
    }
    
    // TODO: Document this function
    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didCompleteWithResults results: [String : Any]) {
        let size : Int = Int(truncating: NSDecimalNumber(decimal: pow(3, metaLevel)))
        for i in 0..<size {
            for j in 0..<size {
                let key = i*size + j
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.isEnabled = false
            }
        }
        AppDelegate.deleteGameRequest(request_id: String(Board.gameID))
        
        var winningPlayerName : String = ""
        if turn == "X" {
            winningPlayerName = Board.player1.playerName
        } else {
            winningPlayerName = Board.player2.playerName
        }
        board.finish(won: winOrTie, winnerName: winningPlayerName)
        
        print("Success! \(String(describing: results))")
    }
}
