//
//  Board.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-15.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

class Board: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var boardAdapter : BoardAdapter? = nil
    
    var gaps : Double = 30
    var level : Int = 1
    var dimension : Int!
    var currentPlayer : String!
    static var player1 : String = "Player 1"
    static var player2 : String = "Player 2"
    static var player1ID : Int = 0
    static var player2ID : Int = 0
    var playerTurn : String!
    static var keys : NSMapTable<NSNumber, UIButton> = NSMapTable<NSNumber, UIButton>()
    static var playerTurnLabel: UILabel!
    var doneOnce : Bool = false
    static var boardCollectionView : UICollectionView!
    static var reload = false
    static var titleLabel : UILabel!
    static var background : UIView!
    var levelMenu : LevelMenu!
    var mainMenu : MainMenu!
    var multiplayer : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !self.doneOnce {
            Board.titleLabel = self.view.viewWithTag(402) as! UILabel
            Board.background = self.view.viewWithTag(401)
            Board.playerTurnLabel = self.view.viewWithTag(407) as! UILabel
            Board.boardCollectionView = self.view.viewWithTag(403) as! UICollectionView
            self.doneOnce = true
        }
        
        if level == 1 {
            Board.titleLabel.text = "Tic"
        } else {
            Board.titleLabel.text = "Tic Tac"
        }

        if level == 1 {
            Board.background.backgroundColor = .yellow
        } else {
            Board.background.backgroundColor = .red
        }
        
        Board.playerTurnLabel.text = Board.player1 + "'s Turn"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Double(self.view.frame.size.width);
        dimension = Int(0.9 * width - gaps)/3;
        return CGSize(width: dimension, height: dimension);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCell", for: indexPath)
        
        if boardAdapter == nil {
            boardAdapter = BoardAdapter.init(collectionViewLayout: UICollectionViewFlowLayout.init())
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
        
        let miniBoard = cell.viewWithTag(405) as! UICollectionView
        
        if BoardAdapter.metawincheck[abs(row - 2)][abs(column - 2)] == "" {
            
            boardAdapter?.level = self.level
            boardAdapter?.dimension = self.dimension
            boardAdapter?.board = self
            //        boardAdapter?.metaRow = row
            //        boardAdapter?.metaColumn = column
            boardAdapter?.multiplayer = self.multiplayer
            boardAdapter?.recipientID = self.recipientID
            
            miniBoard.dataSource = boardAdapter
            miniBoard.delegate = boardAdapter
        } else {
            let label = UILabel()
            label.text = BoardAdapter.metawincheck[abs(row - 2)][abs(column - 2)]
            label.textColor = .orange
            label.frame = CGRect(x: 0, y: 0, width: self.dimension, height: self.dimension)
            label.font = UIFont(name: "Times New Roman", size: 100)
            label.textAlignment = .center
            label.backgroundColor = .black
            
            miniBoard.removeFromSuperview()
            
            cell.addSubview(label)
        }
        
        return cell
    }
    
//    func reloadItems(at indexPaths: [IndexPath]) {
//        
//        let indexPath = indexPaths[0]
        
//        var row = -1
//        var column = -1
//        
//        switch(indexPath.item) {
//        case 0:
//            row = 0
//            column = 0
//            break
//        case 1:
//            row = 0
//            column = 1
//            break
//        case 2:
//            row = 0
//            column = 2
//            break
//        case 3:
//            row = 1
//            column = 2
//            break
//        case 4:
//            row = 1
//            column = 1
//            break
//        case 5:
//            row = 1
//            column = 2
//            break
//        case 6:
//            row = 2
//            column = 0
//            break
//        case 7:
//            row = 2
//            column = 1
//            break
//        case 8:
//            row = 2
//            column = 2
//            break
//        default:
//            row = -1
//            column = -1
//            break
//
//        }
        
//        let cell = Board.boardCollectionView.cellForItem(at: indexPath)
//        
//        let label = UILabel()
//        label.text = BoardAdapter.metawincheck[row][column]
//        label.textColor = .orange
//        label.textAlignment = .center
//        label.font = UIFont(name: "Times New Roman", size: 100)
//        
//        cell?.addSubview(label)
//    }
    
    @IBAction func bottomPanelListener(_ sender: UIButton) {
        switch sender.tag {
        case 409:
            BoardAdapter.metaRow = -1
            BoardAdapter.metaColumn = -1
            self.dismiss(animated: true, completion: nil)
            break
        default:
            return
        }
    }
    
    func winningBoardChanger(boardAdapter : BoardAdapter, row : Int, column : Int, level : Int, clickable : Bool, x : String) {
        BoardAdapter.metaRow = row/3 - 1
        BoardAdapter.metaColumn = column/3 - 1
        
        let indexPath = abs(((row/3)*3 + (column/3)) - 8)
        let indexPaths = [IndexPath(item: indexPath, section: 0)]
        Board.boardCollectionView.reloadItems(at: indexPaths)
        
        boardAdapter.boardChanger(row: row, column: column, level: level, clickable: clickable)
        boardAdapter.winChecker(row: row, column: column, level: 1, actual: level, winchecker: BoardAdapter.metawincheck, turnValue: x)
    }
    
    func finish(won : Bool, winnerName : String) {
//        self.dismiss(animated: true, completion: nil)
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
            winner.winnerName = extras[0] as! String
            winner.mainMenu = self.mainMenu
        }
    }
//    func playerTurnLabelChanger( player : Int ) {
////        let playerTurnLabel : UILabel = self.view.viewWithTag(407) as! UILabel
//        if player == 1 {
//            Board.playerTurnLabel.text = player1 + "'s Turn"
//        } else {
//            Board.playerTurnLabel.text = player2 + "'s Turn"
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
