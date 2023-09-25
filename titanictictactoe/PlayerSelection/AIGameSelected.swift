//
//  LocalGameSelected.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2018-06-09.
//  Copyright © 2018 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip

protocol AIGameSelectedDelegate: AnyObject {
    func beginGame(player1: Player, player2: Player, isMultiplayer: Bool, isAI: Bool)
}

class AIGameSelected: UIViewController, IndicatorInfoProvider {
    weak var delegate: AIGameSelectedDelegate?
    
    @IBOutlet var symbolSelector: UISegmentedControl!
    @IBOutlet var playButton: UIButton!
    
    
    var player1 : Player = Player()
    var player2 : Player = Player()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        symbolSelector.selectedSegmentIndex = 0
        
        playButton.addTarget(self, action: #selector(beginGame(sender:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Play with AI", image: UIImage(named: "Single Player-logo"))
    }

    @objc func beginGame(sender: UIButton) {
        if symbolSelector.selectedSegmentIndex == 0 {
            player1.initPlayer(playerName: "Your", turn: "X")
            player2.initAI(turn: "O")
        } else {
            player1.initAI(turn: "X")
            player2.initPlayer(playerName: "Your", turn: "O")
        }
        
        self.delegate!.beginGame(player1: player1, player2: player2, isMultiplayer: false, isAI: true)
    }
}
