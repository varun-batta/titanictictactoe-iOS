//
//  BoardAdapter.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-15.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit
import FacebookCore
import FBSDKCoreKit
import FBSDKShareKit

private let reuseIdentifier = "Cell"

class BoardAdapter: UICollectionViewController, UICollectionViewDelegateFlowLayout, FBSDKGameRequestDialogDelegate {

    var level : Int!
    var dimension : Int!
    static var metaRow : Int = -1
    static var metaColumn : Int = -1
    var multiplayer : Bool!
    var recipientID : String!
    var zeroCount : Int = -1
    var currentTurn : String = "X"
    var turn : String!
    var board : Board!
    static var wincheck = Array(repeating: Array(repeating: "", count: 9), count: 10)
    static var metawincheck = Array(repeating: Array(repeating: "", count: 3), count: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "miniBoardCell")
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
        var dimension : Int = self.dimension
        if level == 2 {
            dimension = (self.dimension - 10)/3
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
        
        var dimension : Int = self.dimension
        if level == 2 {
            dimension = (self.dimension - 10)/3
        }
        
        var row : Int = -1
        var column : Int = -1
        
        switch(indexPath.item) {
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
        
        var tag : Int = -1
        if level == 1 {
            tag = BoardAdapter.metaRow*3 + BoardAdapter.metaColumn
        } else {
            tag = BoardAdapter.metaRow*27 + row*9 + BoardAdapter.metaColumn*3 + column
        }
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        button.setTitle("", for: .normal)
        button.setTitleColor(.black, for: .disabled)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        button.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        button.backgroundColor = .orange
        if level == 1 {
            button.titleLabel!.font = UIFont(name: "Times New Roman", size: 100)
        } else {
            button.titleLabel!.font = UIFont(name: "Times New Roman", size: 15)
        }
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        button.tag = tag
        button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        
        Board.keys.setObject(button, forKey: NSNumber.init(value: button.tag))

        cell.addSubview(button)
        
        return cell

    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: ButtonPressedActions
    
    func buttonClicked(sender: UIButton) {
        
        if self.currentTurn == "X" {
            turn = "X"
            
            Board.playerTurnLabel.text = Board.player2 + "'s Turn"
            
            currentTurn = "O"
        } else {
            turn = "O"
            
            Board.playerTurnLabel.text = Board.player1 + "'s Turn"
            
            currentTurn = "X"
        }
        
        sender.setTitle(turn, for: .disabled)
        sender.isEnabled = false
        sender.backgroundColor = .white
        
        let size : Int = Int(NSDecimalNumber(decimal: pow(3, level)))
        
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
        
        if self.multiplayer! {
            saveGame()
        }
        
        let winOrTie : Bool = winChecker(row: row, column: column, level: level, actual: level, winchecker: BoardAdapter.wincheck, turnValue: turn)
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
            
            if BoardAdapter.metawincheck[abs(row - 8)%3][abs(column - 8)%3] == "" {
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
        if x == "X" {
            winningPlayer = Board.player1
            winningLetter.text = "X"
        }
        if x == "O" {
            winningPlayer = Board.player2
            winningLetter.text = "O"
        }
        
        if x == "X" || x == "O" {
            switch(level) {
            case 1:
                board.finish(won: true, winnerName: winningPlayer)
                winOrTie = true
                break
            case 2:
                BoardAdapter.metawincheck[f/3][g/3] = x
                board.winningBoardChanger(boardAdapter: self, row: f, column: g, level: level, clickable: true, x: x)
                break
            default:
                return false
            }
        }
        
        
        return winOrTie
    }
    
    func saveGame() {
        let gameRequestContent = FBSDKGameRequestContent()
        gameRequestContent.message = Board.player1 + " has just played their turn"
        gameRequestContent.recipients = [self.recipientID]
        gameRequestContent.actionType = FBSDKGameRequestActionType.turn
        
        FBSDKGameRequestDialog.show(with: gameRequestContent, delegate: self)
    }
    
    func gameRequestDialogDidCancel(_ gameRequestDialog: FBSDKGameRequestDialog!) {
        //Fall back as if no move was made
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didFailWithError error: Error!) {
        print("Error!")
        //Fall back as if no move was made, or ask for retry
    }
    
    func gameRequestDialog(_ gameRequestDialog: FBSDKGameRequestDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        for i in 0...2 {
            for j in 0...2 {
                let key : Int = i*3 + j
                let button : UIButton = Board.keys.object(forKey: NSNumber.init(value: key))!
                
                button.isEnabled = false
            }
        }
        print("Success! \(results)")
    }
}
