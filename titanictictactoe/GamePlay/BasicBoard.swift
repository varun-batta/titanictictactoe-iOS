//
//  BasicBoard.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-10-26.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
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
    static var curInstructionsStep : Int = 1
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

        if Board.isMultiplayerMode {
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
        } else if Board.isAIMode && board.currentPlayerLabel.text == "AI's Turn" {
            // Determine which of the enabledKeys will be chosen
            board.populateEnabledKeys(metaRow: -1, metaColumn: -1)
            let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
            buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
        } else if Board.isInstructionalMode && board.currentPlayerLabel.text != "AI's Turn" {
            // TODO: Clean up this code once it's working. Move it to a separate function maybe and clean up how the messages are populated
            if metaLevel == 1 {
                if BasicBoard.curInstructionsStep == 2 {
                    let alert = UIAlertController(title: nil, message: "Now, before we continue, let's clarify what your goal is.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: "Next"), style: .default, handler: showRows))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                } else if BasicBoard.curInstructionsStep == 3 {
                    // Check if potential win is there for the opponent
                    let (isPotentialWin, _, _) = checkForPotentialWin(playerTurn: "O", row: row, column: column)
                    if isPotentialWin {
                        let alert = UIAlertController(title: nil, message: "Well done! Remember to make sure your opponent doesn't get 3 in a row and they will be doing the same.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                        board.present(alert, animated: true, completion: nil)
                        BasicBoard.curInstructionsStep += 1
                    }
                }
            } else if metaLevel == 2 {
                if BasicBoard.curInstructionsStep == 2 {
                    let alert = UIAlertController(title: nil, message: "As you can see, this is more complicated since we are moving around the entire board. But the goal is the same as regular tic tac toe. You keep moving around and try to win the different sections by getting 3 in a row, column or diagonal.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                } else if BasicBoard.curInstructionsStep == 3 {
                    let (isPotentialWin, rowIndex, columnIndex) = checkForPotentialWin(playerTurn: "X", row: row, column: column)
                    if isPotentialWin {
                        let alert = UIAlertController(title: nil, message: "Awesome! It looks like you can win this section of the board.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(alert: UIAlertAction) in
                            self.showButtonToClick(rowIndex: rowIndex, columnIndex: columnIndex)
                        }))
                        board.present(alert, animated: true, completion: nil)
                        BasicBoard.curInstructionsStep += 1
                    }
                } else if BasicBoard.curInstructionsStep == 4 {
                    let playerTurn = "O"
                    let (selectionName, metaRow, metaColumn) = getMetaboardSelectionName(playerTurn: playerTurn)
                    let alert = UIAlertController(title: nil, message: "Oh no! Your opponent just won the \(selectionName) section! As you can see, it became a giant \(playerTurn)! To win the game, you have to continue playing and try to win 3 sections in a row, column or diagonal. So you can think of this as Tic Tac Toe in Tic Tac Toe :)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(alert: UIAlertAction!) in
                        self.showWarning(metaRow: metaRow, metaColumn: metaColumn, selectedMetaRow: row % 3, selectedMetaColumn: column % 3)
                    }))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                } else if BasicBoard.curInstructionsStep == 5 {
                    // Reset all the buttons to their original state
                    for r in 0..<9 {
                        for c in 0..<9 {
                            let key : Int = r*9 + c
                            let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                            
                            button.backgroundColor = .clear
                        }
                    }
                    
                    let alert = UIAlertController(title: nil, message: "Now let's play!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                }
            }
        } else if Board.isInstructionalMode && board.currentPlayerLabel.text == "AI's Turn" && !self.winOrTie {
            if metaLevel == 1 {
                if BasicBoard.curInstructionsStep == 1 {
                    board.populateEnabledKeys(metaRow: -1, metaColumn: -1)
                    let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
                    let alert = UIAlertController(title: nil, message: "Since you started off the game, you are X this time around. Your opponent can now make a move in any one of the remaining squares and they are O.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(alert: UIAlertAction!) in
                        self.buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
                    }))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                } else if BasicBoard.curInstructionsStep == 3 {
                    // Check if potential win is there for the opponent
                    let (isPotentialWin, rowIndex, colIndex) = checkForPotentialWin(playerTurn: "X", row: row, column: column)
                    if isPotentialWin {
                        let alert = UIAlertController(title: nil, message: "Well done! Remember to make sure your opponent doesn't get 3 in a row and they will be doing the same.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(alert: UIAlertAction!) in
                            self.buttonClicked(sender: Board.keys.object(forKey: NSNumber.init(value: rowIndex*3 + colIndex))!)
                        }))
                        board.present(alert, animated: true, completion: nil)
                        BasicBoard.curInstructionsStep += 1
                    } else {
                        board.populateEnabledKeys(metaRow: -1, metaColumn: -1)
                        let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
                        buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
                    }
                } else {
                    board.populateEnabledKeys(metaRow: -1, metaColumn: -1)
                    let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
                    buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
                }
            } else if metaLevel == 2 {
                if BasicBoard.curInstructionsStep == 1 {
                    board.populateEnabledKeys(metaRow: row % 3, metaColumn: column % 3)
                    let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
                    let selectionName = getSelectionName(row: row % 3, column: column % 3)
                    let alert = UIAlertController(title: nil, message: "Oh, look at that! Since you picked the \(selectionName) square, your opponent is only allowed to play in the \(selectionName) section of the board (everything that is red cannot be clicked on). Let's let them make a move.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(alert: UIAlertAction!) in
                        self.buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
                    }))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                } else if BasicBoard.curInstructionsStep == 3 {
                    let (isPotentialWin, rowIndex, colIndex) = checkForPotentialWin(playerTurn: "O", row: row, column: column)
                    if isPotentialWin {
                        let alert = UIAlertController(title: nil, message: "It looks like your opponent will win this section of the board.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(alert: UIAlertAction!) in
                            self.showButtonToClick(rowIndex: rowIndex, columnIndex: colIndex)
                        }))
                        board.present(alert, animated: true, completion: nil)
                        BasicBoard.curInstructionsStep += 1
                    } else {
                        board.populateEnabledKeys(metaRow: -1, metaColumn: -1)
                        let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
                        buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
                    }
                } else if BasicBoard.curInstructionsStep == 4 {
                    let playerTurn = "X"
                    let (selectionName, metaRow, metaColumn) = getMetaboardSelectionName(playerTurn: playerTurn)
                    let alert = UIAlertController(title: nil, message: "Awesome! Youjust won the \(selectionName) section! As you can see, it became a giant \(playerTurn)! To win the game, you have to continue playing and try to win 3 sections in a row, column or diagonal. So you can think of this as Tic Tac Toe in Tic Tac Toe :)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(alert: UIAlertAction!) in
                        self.showWarning(metaRow: metaRow, metaColumn: metaColumn, selectedMetaRow: row % 3, selectedMetaColumn: column % 3)
                    }))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                } else if BasicBoard.curInstructionsStep == 5 {
                    // Reset all the buttons to their original state
                    for r in 0..<9 {
                        for c in 0..<9 {
                            let key : Int = r*9 + c
                            let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                            
                            button.backgroundColor = .clear
                        }
                    }
                    board.populateEnabledKeys(metaRow: -1, metaColumn: -1)
                    let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
                    let alert = UIAlertController(title: nil, message: "Now let's play!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(action: UIAlertAction) in
                        self.buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
                    }))
                    board.present(alert, animated: true, completion: nil)
                    BasicBoard.curInstructionsStep += 1
                } else {
                    board.populateEnabledKeys(metaRow: -1, metaColumn: -1)
                    let chosenKey = Board.enabledKeys[Int.random(in: 0..<Board.enabledKeys.count)]
                    buttonClicked(sender: Board.keys.object(forKey: chosenKey)!)
                }
            }
        }
    }
    
    func checkForPotentialWin(playerTurn: String, row: Int, column: Int) -> (Bool, Int, Int) {
        // TODO: See about combining this logic if possible
        if metaLevel == 1 {
            // Check row option
            var found = -1
            var empty = -1
            for i in 0..<3 {
                if BasicBoard.wincheck[row][i] == playerTurn && i != column {
                    found = i
                }
                if BasicBoard.wincheck[row][i] == "" {
                    empty = i
                }
            }
            if found != -1 && empty != -1 {
                return (true, row, empty)
            }
            // Check column option
            found = -1
            empty = -1
            for i in 0..<3 {
                if BasicBoard.wincheck[i][column] == playerTurn && i != row {
                    found = i
                }
                if BasicBoard.wincheck[i][column] == "" {
                    empty = i
                }
            }
            if found != -1 && empty != -1 {
                return (true, empty, column)
            }
            // Check top left to bottom right diagonal
            if row == column {
                found = -1
                empty = -1
                for i in 0..<3 {
                    if BasicBoard.wincheck[i][i] == playerTurn && i != row {
                        found = i
                    }
                    if BasicBoard.wincheck[i][i] == "" {
                        empty = i
                    }
                }
                if found != -1 && empty != -1 {
                    return (true, empty, empty)
                }
            }
            // Check top right to bottom left diagonal
            if isInTopRightToBottomLeftDiagonal(row: row, column: column) {
                var foundRow = -1
                var foundCol = -1
                var emptyRow = -1
                var emptyCol = -1
                var c = 2
                for r in 0..<3 {
                    if BasicBoard.wincheck[r][c] == playerTurn && r != row && c != column {
                        foundRow = r
                        foundCol = c
                    }
                    if BasicBoard.wincheck[r][c] == "" {
                        emptyRow = r
                        emptyCol = c
                    }
                    c -= 1
                }
                if foundRow != -1 && foundCol != -1 && emptyRow != -1 && emptyCol != -1 {
                    return (true, emptyRow, emptyCol)
                }
            }
        } else if metaLevel == 2 {
            let metaRow = row % 3
            let metaColumn = column % 3
            // Check row option
            for r in metaRow*3+0..<metaRow*3+3 {
                var foundIndices = [Int]()
                var emptyIndices = [Int]()
                for c in metaColumn*3+0..<metaColumn*3+3 {
                    if BasicBoard.wincheck[r][c] == playerTurn {
                        foundIndices.append(c)
                    }
                    if BasicBoard.wincheck[r][c] == "" {
                        emptyIndices.append(c)
                    }
                }
                if foundIndices.count == 2 && emptyIndices.count == 1 {
                    return (true, r, emptyIndices[0])
                }
            }
            // Check column option
            for c in metaColumn*3+0..<metaColumn*3+3 {
                var foundIndices = [Int]()
                var emptyIndices = [Int]()
                for r in metaRow*3+0..<metaRow*3+3 {
                    if BasicBoard.wincheck[r][c] == playerTurn {
                        foundIndices.append(r)
                    }
                    if BasicBoard.wincheck[r][c] == "" {
                        emptyIndices.append(r)
                    }
                }
                if foundIndices.count == 2 && emptyIndices.count == 1 {
                    return (true, emptyIndices[0], c)
                }
            }
            // Check top left to bottom right diagonal
            var foundRows = [Int]()
            var foundColumns = [Int]()
            var emptyRows = [Int]()
            var emptyColumns = [Int]()
            var c = metaColumn*3
            for r in metaRow*3+0..<metaRow*3+3 {
                if BasicBoard.wincheck[r][c] == playerTurn {
                    foundRows.append(r)
                    foundColumns.append(c)
                }
                if BasicBoard.wincheck[r][c] == "" {
                    emptyRows.append(r)
                    emptyColumns.append(c)
                }
                c += 1
            }
            if foundRows.count == 2 && foundColumns.count == 2 && emptyRows.count == 1 && emptyColumns.count == 1 {
                return (true, emptyRows[0], emptyColumns[0])
            }
            // Check top right to bottom left diagonal
            foundRows = [Int]()
            foundColumns = [Int]()
            emptyRows = [Int]()
            emptyColumns = [Int]()
            c = metaColumn*3 + 2
            for r in 0..<3 {
                if BasicBoard.wincheck[r][c] == playerTurn {
                    foundRows.append(r)
                    foundColumns.append(c)
                }
                if BasicBoard.wincheck[r][c] == "" {
                    emptyRows.append(r)
                    emptyColumns.append(c)
                }
                c -= 1
            }
            if foundRows.count == 2 && foundColumns.count == 2 && emptyRows.count == 1 && emptyColumns.count == 1 {
                return (true, emptyRows[0], emptyColumns[0])
            }
        }
        return (false, -1, -1)
    }
    
    func getMetaboardSelectionName(playerTurn: String) -> (String, Int, Int) {
        for r in 0..<3 {
            for c in 0..<3 {
                if BasicBoard.metawincheck[r][c] == playerTurn {
                    return (getSelectionName(row: r, column: c), r, c)
                }
            }
        }
        return ("", -1, -1)
    }
    
    func getSelectionName(row: Int, column: Int) -> String {
        var selectionName = ""
        switch(row) {
        case 0:
            selectionName += "Top"
        case 1:
            selectionName += "Middle"
        case 2:
            selectionName += "Bottom"
        default:
            selectionName += ""
        }
        switch(column) {
        case 0:
            selectionName += " Left"
        case 1:
            if row == 1 {
                selectionName = "Center"
            } else {
                selectionName += " Middle"
            }
        case 2:
            selectionName += " Right"
        default:
            selectionName += ""
        }
        return selectionName
    }
    
    func isInTopRightToBottomLeftDiagonal(row: Int, column: Int) -> Bool {
        let isTopLeft = row == 0 && column == 2
        let isCenter = row == 1 && column == 1
        let isBottomLeft = row == 2 && column == 0
        return isTopLeft || isCenter || isBottomLeft
    }
    
    func showRows(action : UIAlertAction) {
        // Find the rowIndex of the last selection
        var rowIndex : Int = -1;
        for i in 0..<3 {
            for j in 0..<3 {
                if BasicBoard.wincheck[i][j] == "X" {
                    rowIndex = i
                    break
                }
            }
            if rowIndex != -1 {
                break
            }
        }
        // Highlight that row of buttons
        for i in 0..<3 {
            let key : Int = rowIndex*3 + i
            let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
            
            button.backgroundColor = .yellow
        }
        // Present the alert
        let alert = UIAlertController(title: nil, message: "You are trying to get your symbol, X in this case, to be either 3 in a row", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: "Next"), style: .default, handler: showColumns))
        board.present(alert, animated: true, completion: nil)
    }
    
    func showColumns(action: UIAlertAction) {
        // Find the colIndex of the last selection
        var colIndex : Int = -1
        for i in 0..<3 {
            for j in 0..<3 {
                if BasicBoard.wincheck[i][j] == "X" {
                    colIndex = j
                    break
                }
            }
            if colIndex != -1 {
                break
            }
        }
        // Reset all the buttons to their original state
        for i in 0..<3 {
            for j in 0..<3 {
                let key : Int = i*3 + j
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.backgroundColor = .clear
            }
        }
        // Highlight that column of buttons
        for i in 0..<3 {
            let key : Int = i*3 + colIndex
            let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
            
            button.backgroundColor = .yellow
        }
        // Present the alert
        let alert = UIAlertController(title: nil, message: "You are trying to get your symbol, X in this case, to be either 3 in a row, 3 in a column", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: "Next"), style: .default, handler: showDiagonals))
        board.present(alert, animated: true, completion: nil)
    }
    
    func showDiagonals(action : UIAlertAction) {
        // Find the rowIndex and colIndex of the last selection
        var rowIndex : Int = -1
        var colIndex : Int = -1
        for i in 0..<3 {
            for j in 0..<3 {
                if BasicBoard.wincheck[i][j] == "X" {
                    rowIndex = i
                    colIndex = j
                    break
                }
            }
            if rowIndex != -1 && colIndex != -1 {
                break
            }
        }
        // Reset all the buttons to their original state
        for i in 0..<3 {
            for j in 0..<3 {
                let key : Int = i*3 + j
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.backgroundColor = .clear
            }
        }
        // Determine if the selection is in one of the 2 diagonals and highlight accordingly
        if rowIndex == colIndex {
            // Top Left to Bottom Right Diagonal
            for i in 0..<3 {
                let key : Int = i*3 + i
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.backgroundColor = .yellow
            }
        } else if abs(rowIndex - colIndex) == 2 {
            // Top Right to Bottom Left Diagonal
            var c = 2
            for r in 0..<3 {
                let key : Int = r*3 + colIndex
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.backgroundColor = .yellow
                c -= 1
            }
        } else {
            // Not in a diagonal, so just any of the two
            for i in 0..<3 {
                let key : Int = i*3 + i
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.backgroundColor = .yellow
            }
        }
        // Present the alert
        let alert = UIAlertController(title: nil, message: "You are trying to get your symbol, X in this case, to be either 3 in a row, 3 in a column, or 3 in a diagonal.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: "Got it"), style: .default, handler: finishShowingGuide))
        board.present(alert, animated: true, completion: nil)
    }
    
    func finishShowingGuide(action: UIAlertAction) {
        // Reset all the buttons to their original state
        for i in 0..<3 {
            for j in 0..<3 {
                let key : Int = i*3 + j
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.backgroundColor = .clear
            }
        }
        
        let alert = UIAlertController(title: nil, message: "Now let's play a bit!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
        board.present(alert, animated: true, completion: nil)
    }
    
    func showWarning(metaRow: Int, metaColumn: Int, selectedMetaRow: Int, selectedMetaColumn: Int) {
        let alert = UIAlertController(title: nil, message: "Oh, and one more thing you should be aware of.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: "Next"), style: .default, handler: {(action: UIAlertAction) in 
            self.showMetaboardSelection(metaRow: metaRow, metaColumn: metaColumn, selectedMetaRow: selectedMetaRow, selectedMetaColumn: selectedMetaColumn)
        }))
        board.present(alert, animated: true, completion: nil)
    }
    
    func showMetaboardSelection(metaRow: Int, metaColumn: Int, selectedMetaRow: Int, selectedMetaColumn: Int) {
        for r in 0..<3 {
            for c in 0..<3 {
                let key: Int = (r*3 + metaRow) * 9 + c*3 + metaColumn
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                button.backgroundColor = .yellow
            }
        }
        let alert = UIAlertController(title: nil, message: "Oh, and one more thing you should be aware of. If you or your opponent click in any of the highlighted areas at any point, since that particular section is not available, the entire game board would become available.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {(action: UIAlertAction) in
            self.forceMetaboardSelection(metaRow: metaRow, metaColumn: metaColumn, selectedMetaRow: selectedMetaRow, selectedMetaColumn: selectedMetaColumn)
        }))
        board.present(alert, animated: true, completion: nil)
    }
    
    func forceMetaboardSelection(metaRow: Int, metaColumn: Int, selectedMetaRow: Int, selectedMetaColumn: Int) {
        // Disable all buttons for now and return them back to not highlighted
        for r in 0..<9 {
            for c in 0..<9 {
                let key: Int = r*9 + c
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                button.isEnabled = false
                button.backgroundColor = .clear
            }
        }
        
        // Highlight and enable only the one button to select
        let key = (selectedMetaRow * 3 + metaRow)*9 + selectedMetaColumn * 3 + metaColumn
        let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
        button.isEnabled = true
        button.backgroundColor = .yellow
        
        // Handle clicking
        let isAITurn = board.currentPlayerLabel.text == "AI's Turn"
        var endingText = "Please click here to see what that will look like."
        if isAITurn {
            endingText = "So it would look like this."
        }
        let alert = UIAlertController(title: nil, message: "Oh, and one more thing you should be aware of. If you or your opponent click in any of the highlighted areas at any point, since that particular section is not available, the entire game board would become available. \(endingText)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: isAITurn ? {(action: UIAlertAction) in
            self.buttonClicked(sender: button)} : nil))
        board.present(alert, animated: true, completion: nil)
    }
    
    func showButtonToClick(rowIndex: Int, columnIndex: Int) {
        // Highlight button to click
        let key : Int = rowIndex*9 + columnIndex
        let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
        button.backgroundColor = .yellow
        
        // Disable all other buttons that can be clicked
        let metaRow = rowIndex / 3
        let metaColumn = columnIndex / 3
        for r in metaRow*3..<metaRow*3+3 {
            for c in metaColumn*3..<metaColumn*3+3 {
                let key = r*9 + c
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                if r != rowIndex || c != columnIndex {
                    button.isEnabled = false
                }
            }
        }
        
        // TODO: Fix logic to determine AI or player turn
        let isAITurn = board.currentPlayerLabel.text == "AI's Turn"
        let alert = UIAlertController(title: nil, message: isAITurn ? "They'll want to click here" : "Now you'll want to click here.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: isAITurn ? {(action: UIAlertAction) in self.buttonClicked(sender: button)} : nil ))
        board.present(alert, animated: true, completion: nil)
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
            Board.enabledKeys = []
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
            var messagePart1 = ""
            var messagePart2 = ""
            if x == "X" {
                messagePart1 = "Congrats! You won!"
            }
            if x == "O" {
                messagePart1 = "Sorry! Your opponent won."
            }
            if actual == 1 {
                messagePart2 = "Hope you enjoyed! If you'd like to try to learn how we make Tic Tac Toe a little more complicated, please click Next. If you'd like to continue practicing for now and perhaps try later, feel free to look at the instructions again (just click Yes when asking whether you know Tic Tac Toe already since now you do!)"
            }
            if actual == 2 {
                messagePart2 = "Hope you enjoyed the game and keep practicing, perhaps try playing with a friend via Faceboook or in person. If your friend doesn't have the app yet, just share it with them!"
            }
            switch(level) {
            case 1:
                if (Board.isInstructionalMode) {
                    let alert = UIAlertController(title: nil, message: "\(messagePart1) \(messagePart2)", preferredStyle: .alert)
                    if actual == 1 {
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Not now", comment: "Not now"), style: .default, handler: board.dismiss))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Next", comment: "Next"), style: .default, handler: changeToNextLevelInstructions))
                    }
                    if actual == 2 {
                        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .default, handler: board.dismiss))
                    }
                    board.present(alert, animated: true, completion: nil)
                } else if (!Board.isMultiplayerMode) {
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
    
    func changeToNextLevelInstructions(action: UIAlertAction) {
        BasicBoard.wincheck = [[String]](repeating: [String](repeating: "", count: 9), count: 10)
        BasicBoard.metawincheck = [[String]](repeating: [String](repeating: "", count: 3), count: 3)
        BasicBoard.firstTurn = true
        BasicBoard.metaBoard = [[BasicBoard]](repeating: [BasicBoard](repeating: BasicBoard(), count: 3), count: 3)
        BasicBoard.lastMoveRow = -1
        BasicBoard.lastMoveColumn = -1
        BasicBoard.currentTurn = "X"
        BasicBoard.curInstructionsStep = 1
        self.board.level = 2
        self.board.board.metaLevel = 2
        self.configureBoard(width: self.frame.size.width, level: 2, metaLevel: 2, board: self.board)
        let alert = UIAlertController(title: nil, message: "Great! Let's show you the next level of Tic Tac Toe. Start by tapping on any one of the available squares.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
        board.present(alert, animated: true, completion: nil)
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
