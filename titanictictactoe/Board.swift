//
//  Board.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2017-03-15.
//  Copyright © 2017 Varun Batta. All rights reserved.
//

import UIKit

class Board: UIViewController { //}, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var boardAdapter : BoardAdapter? = nil
    
    var gaps : CGFloat = 20
    var level : Int = 1
    var dimension : CGFloat!
    var currentPlayer : String!
//    static var player1 : String = "Player 1"
//    static var player2 : String = "Player 2"
//    static var player1ID : Int64 = 0
//    static var player2ID : Int64 = 0
    static var player1 : Player = Player()
    static var player2 : Player = Player()
    var playerTurn : String!
    static var keys : NSMapTable<NSNumber, UIButton> = NSMapTable<NSNumber, UIButton>()
    static var playerTurnLabel: UILabel!
    var doneOnce : Bool = false
    var willLayoutSubviewsCount : Int = 0
//    static var boardCollectionView : UICollectionView!
    static var reload = false
    static var titleLabel : UILabel!
    static var background : UIView!
    var levelMenu : LevelMenu!
    var mainMenu : MainMenu!
    
    @IBOutlet var background: UIView!
    @IBOutlet var board: UIView!
//    @IBOutlet var boardCollectionView: UICollectionView!
    @IBOutlet var playersTurnLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !self.doneOnce {
            Board.titleLabel = self.view.viewWithTag(402) as! UILabel
            Board.background = self.view.viewWithTag(401)
            Board.playerTurnLabel = self.view.viewWithTag(407) as! UILabel
//            Board.boardCollectionView = self.view.viewWithTag(403) as! UICollectionView
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
//        boardCollectionView.backgroundColor = Style.mainColorGreen;
//        boardCollectionView.alpha = 0.3;
        playersTurnLabel.textColor = Style.mainColorBlack;
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
    
    func configureBoard() {
        self.willLayoutSubviewsCount += 1
        if (self.willLayoutSubviewsCount == 2) {
            if boardAdapter == nil {
                boardAdapter = BoardAdapter.init(collectionViewLayout: UICollectionViewFlowLayout.init())
            }
            
            let metaBoard : BasicBoard = BasicBoard();
            metaBoard.frame = CGRect(x: 0, y: 0, width: self.board.frame.size.width, height: self.board.frame.size.height)
            
            metaBoard.configureBoard(width: self.board.frame.size.width, level: level, metaLevel: level, board: self)
            
            board.addSubview(metaBoard)
        }
    }
    
    func sizeForItemAt(index : Int, width: CGFloat) {
        dimension = (width - gaps)/3.0
    }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 9
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = Double(self.view.frame.size.width);
//        dimension = CGFloat(0.9 * width - gaps)/3.0;
//        return CGSize(width: dimension, height: dimension);
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCell", for: indexPath)
//
//        if boardAdapter == nil {
//            boardAdapter = BoardAdapter.init(collectionViewLayout: UICollectionViewFlowLayout.init())
//        }
//
//        var row : Int = -1
//        var column : Int = -1
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
//            column = 0
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
//        }
//
////        let miniBoard = cell.viewWithTag(405) as! UICollectionView
////        let miniBoardBackground = UIImageView();
////        miniBoardBackground.frame = CGRect(x: 0, y: 0, width: self.dimension, height: self.dimension)
////        miniBoardBackground.image = UIImage(named: "BoardBackground")
////        miniBoardBackground.contentMode = .scaleAspectFill
////        cell.addSubview(miniBoardBackground)
//
//        if BoardAdapter.metawincheck[abs(row - 2)][abs(column - 2)] == "" {
//
//            boardAdapter?.level = self.level
//            boardAdapter?.dimension = self.dimension
//            boardAdapter?.board = self
//            //        boardAdapter?.metaRow = row
//            //        boardAdapter?.metaColumn = column
//
//            miniBoard.dataSource = boardAdapter
//            miniBoard.delegate = boardAdapter
//            miniBoard.backgroundColor = Style.mainColorGreen;
//            if (self.level > 1) {
//                miniBoard.alpha = 0.3;
//            }
//        } else {
//            let label = UILabel()
//            label.text = BoardAdapter.metawincheck[abs(row - 2)][abs(column - 2)]
//            label.textColor = .orange
//            label.frame = CGRect(x: 0, y: 0, width: self.dimension, height: self.dimension)
//            label.font = Style.globalFont?.withSize(90)
//            label.textAlignment = .center
//            label.backgroundColor = .black
//
//            miniBoard.removeFromSuperview()
//
//            cell.addSubview(label)
//        }
//
//        return cell
//    }
    
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
    
    func winningBoardChanger(boardAdapter : BasicBoard, row : Int, column : Int, level : Int, clickable : Bool, x : String) {
        let metaRow = row/3
        let metaColumn = column/3
//
//        let indexPath = abs(((row/3)*3 + (column/3)) - 8)
//        let indexPaths = [IndexPath(item: indexPath, section: 0)]
//        Board.boardCollectionView.reloadItems(at: indexPaths)
        let label = BasicBoard.metaBoard[metaRow][metaColumn].overlayingWinnerLabel
        label?.text = BasicBoard.metawincheck[metaRow][metaColumn]
        label?.textColor = Style.mainColorBlack
        label?.textAlignment = .center
        label?.font = Style.globalFont?.withSize(100)
        
        BasicBoard.metaBoard[metaRow][metaColumn].boardBackground.alpha = 0
        BasicBoard.metaBoard[metaRow][metaColumn].horizontalStackView.alpha = 0
        
        boardAdapter.boardChanger(row: row, column: column, level: level, clickable: clickable)
        boardAdapter.winChecker(row: row, column: column, level: 1, actual: level, winchecker: BasicBoard.metawincheck, turnValue: x)
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
