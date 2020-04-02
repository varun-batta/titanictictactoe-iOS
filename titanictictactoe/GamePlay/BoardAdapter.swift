//
//  BoardAdapter.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-15.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookShare
import FBSDKCoreKit
import FBSDKShareKit

private let reuseIdentifier = "Cell"

class BoardAdapter: UICollectionViewController, UICollectionViewDelegateFlowLayout, GameRequestDialogDelegate {

    // TODO: Figure out what in this entire file is even necessary, clean up!
    var level : Int!
    var dimension : CGFloat!
    static var metaRow : Int = -1
    static var metaColumn : Int = -1
    var zeroCount : Int = -1
    var currentTurn : String = "X"
    var turn : String!
    var board : Board!
    static var wincheck = Array(repeating: Array(repeating: "", count: 9), count: 10)
    static var metawincheck = Array(repeating: Array(repeating: "", count: 3), count: 3)
    static var firstTurn : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if level == 1 {
            return 1
        } else {
            return 9
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var dimension : CGFloat = self.dimension
        if level == 2 {
            dimension = CGFloat(self.dimension - 10)/3.0
        }
        return CGSize(width: dimension, height: dimension);
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "miniBoardCell", for: indexPath)

        if indexPath.item == 0 {
            BoardAdapter.metaColumn = (BoardAdapter.metaColumn + 1) % 3
            zeroCount = zeroCount + 1
            if zeroCount % 3 == 0 {
                BoardAdapter.metaRow = BoardAdapter.metaRow + 1
            }
        }

        var dimension : CGFloat = self.dimension
        if level == 2 {
            dimension = CGFloat(self.dimension - 10)/3.0
        }

        let row : Int = indexPath.item/3
        let column : Int = indexPath.item%3

        var tag : Int = -1
        if level == 1 {
            tag = BoardAdapter.metaRow*3 + BoardAdapter.metaColumn
        } else {
            tag = BoardAdapter.metaRow*27 + row*9 + BoardAdapter.metaColumn*3 + column
        }

        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        button.setTitle("", for: .normal)
        button.setTitleColor(Style.mainColorBlack, for: .disabled)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        button.backgroundColor = Style.mainColorGreen
        if level == 1 {
            button.titleLabel!.font = Style.globalFont?.withSize(100)
        } else {
            button.titleLabel!.font = Style.globalFont?.withSize(15)
        }
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.tag = tag
        button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)

        Board.keys.setObject(button, forKey: NSNumber.init(value: button.tag))

        cell.addSubview(button)
        cell.alpha = 1;

        return cell

    }

    // MARK: ButtonPressedActions

    @objc func buttonClicked(sender: UIButton) {

        if self.currentTurn == "X" {
            turn = "X"

            Board.playerTurnLabel.text = Board.player2.playerName + "'s Turn"

            currentTurn = "O"
        } else {
            turn = "O"

            Board.playerTurnLabel.text = Board.player1.playerName + "'s Turn"

            currentTurn = "X"
        }

        sender.setTitle(turn, for: .disabled)
        sender.isEnabled = false
        sender.backgroundColor = .clear

        let size : Int = Int(truncating: NSDecimalNumber(decimal: pow(3, level)))

        var found : Bool = false
        var row : Int = -1
        var column : Int = -1

        for i in 0...(size - 1) {
            for j in 0...(size - 1) {
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

        BoardAdapter.wincheck[row][column] = turn

        if level >= 2 {
            boardChanger(row: row, column: column, level: level, clickable: true)
        }

        let winOrTie : Bool = winChecker(row: row, column: column, level: level, actual: level, winchecker: BoardAdapter.wincheck, turnValue: turn)

//        if LevelMenu.multiplayer {
//            var toID : Int64 = 0
//            var fromID : Int64 = 0
//            if turn == "X" {
//                toID = Board.player2ID
//                fromID = Board.player1ID
//            } else {
//                toID = Board.player1ID
//                fromID = Board.player2ID
//            }
//            var messageText = ""
//            if BoardAdapter.firstTurn {
//                messageText = "@[\(fromID)] has challenged you to a game, play now!"
//            } else {
//                messageText = "@[\(fromID)] has played and now it is your turn!"
//            }
//            let game = createGameString()
//            let params : [String : Any] = ["data" : game, "message" : messageText]
//            makeTurn(to: toID, params: params)
//        }
    }

    func createGameString() -> String {
        var game = ""
        let size : Int = Int(truncating: NSDecimalNumber(decimal: pow(3, level)))
        for i in 0...(size - 1) {
            for j in 0...(size - 1) {
                game += BoardAdapter.wincheck[i][j] + ","
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
                    button.backgroundColor = .white
                }
            }
            let metaRow = abs(row - 8)%3;
            let metaColumn = abs(column - 8)%3;
            if BoardAdapter.metawincheck[metaRow][metaColumn] == "" {
                for k in 0...2 {
                    for l in 0...2 {
                        let key : Int = abs(((row % 3)*27 + k*9 + (column % 3)*3 + l) - 80)
                        let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!

                        if button.title(for: .disabled) == "" {
                            button.isEnabled = true
                            button.backgroundColor = .orange
                        }
                    }
                }
            } else {
                for i in 0...8 {
                    for j in 0...8 {
                        let key : Int = i*9 + j
                        let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!

                        if button.title(for: .disabled) == "" {
                            button.isEnabled = true
                            button.backgroundColor = .orange
                        }
                    }
                }
            }
        }
    }

    func winChecker(row: Int, column: Int, level: Int, actual: Int, winchecker: [[String]], turnValue : String) -> Bool {
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
//        if x == "X" {
//            winningPlayer = Board.player1
//            winningLetter.text = "X"
//        }
//        if x == "O" {
//            winningPlayer = Board.player2
//            winningLetter.text = "O"
//        }

        if x == "X" || x == "O" {
            switch(level) {
            case 1:
                board.finish(won: true, winnerName: winningPlayer)
                winOrTie = true
                break
            case 2:
                BoardAdapter.metawincheck[f/3][g/3] = x
//                board.winningBoardChanger(boardAdapter: self, row: f, column: g, level: level, clickable: true, x: x)
                break
            default:
                return false
            }
        }


        return winOrTie
    }

    //MARK: Multiplayer Functions

    func makeTurn(to : Int64, params : [String : Any]) {
        let gameRequestContent = GameRequestContent()
        gameRequestContent.recipients = [String(to)]
        gameRequestContent.message = params["message"] as! String
        gameRequestContent.data = params["data"] as? String
        gameRequestContent.actionType = GameRequestActionType.turn

        GameRequestDialog.init(content: gameRequestContent, delegate: self).show()
    }

    func gameRequestDialogDidCancel(_ gameRequestDialog: GameRequestDialog) {
        //Fall back as if no move was made
    }

    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didFailWithError error: Error) {
        print("Error!")
        //Fall back as if no move was made
    }

    func gameRequestDialog(_ gameRequestDialog: GameRequestDialog, didCompleteWithResults results: [String : Any]) {
        for i in 0...2 {
            for j in 0...2 {
                let key : Int = i*3 + j
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!

                button.isEnabled = false
            }
        }
        print("Success! \(String(describing: results))")
    }
}
