//
//  LocalGameSelected.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2018-06-09.
//  Copyright © 2018 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol LocalGameSelectedDelegate: AnyObject {
    func beginGame(player1: Player, player2: Player, isMultiplayer: Bool)
}

class LocalGameSelected: UIViewController, IndicatorInfoProvider {
    weak var delegate: LocalGameSelectedDelegate?
    
    @IBOutlet weak var player1TextField: UITextField!
    @IBOutlet weak var player2TextField: UITextField!
    
    @IBOutlet weak var player1SymbolSelector: UISegmentedControl!
    @IBOutlet weak var player2SymbolSelector: UISegmentedControl!
    
    @IBOutlet weak var playButton: UIButton!
    
    var player1 : Player = Player()
    var player2 : Player = Player()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        player1SymbolSelector.selectedSegmentIndex = 0
        player2SymbolSelector.selectedSegmentIndex = 1
        
        player1SymbolSelector.addTarget(self, action: #selector(selectSymbolForPlayer(sender:)), for: .valueChanged)
        player2SymbolSelector.addTarget(self, action: #selector(selectSymbolForPlayer(sender:)), for: .valueChanged)
        
        playButton.addTarget(self, action: #selector(beginGame(sender:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Play with Friend", image: UIImage(named: "Local Players-logo"))
    }
    
    @objc func selectSymbolForPlayer(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        
        if (sender == player1SymbolSelector) {
            player2SymbolSelector.selectedSegmentIndex = selectedIndex == 0 ? 1 : 0
        } else {
            player1SymbolSelector.selectedSegmentIndex = selectedIndex == 0 ? 1 : 0
        }
    }
    
    @objc func beginGame(sender: UIButton) {
        let player1Name : String = player1TextField.text!
        let player2Name : String = player2TextField.text!
        if (player1Name == "" || player2Name == "") {
            let alert = UIAlertController(title: "Alert", message: "You must enter both player names to play the game", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            player1.initPlayer(playerName: player1Name, turn: player1SymbolSelector.selectedSegmentIndex == 0 ? "X" : "O")
            player2.initPlayer(playerName: player2Name, turn: player2SymbolSelector.selectedSegmentIndex == 0 ? "X" : "O")
            
            self.delegate!.beginGame(player1: player1, player2: player2, isMultiplayer: false)
        }
    }
}
