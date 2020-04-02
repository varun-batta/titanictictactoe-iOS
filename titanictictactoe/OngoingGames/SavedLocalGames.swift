//
//  LocalSavedGames.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2020-Mar-27.
//  Copyright © 2020 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import GameKit

protocol SavedLocalGamesDelegate: AnyObject {
    func promptForSelectedGame(game: Game, isMultiplayer: Bool)
}

class SavedLocalGames: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider {

    @IBOutlet var savedLocalGamesTableView: UITableView!
    
    weak var delegate: SavedLocalGamesDelegate?
    
    var savedGames : [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let localPlayer = GKLocalPlayer.local
        localPlayer.fetchSavedGames() {(savedGames, error) -> Void in
            if (error != nil) {
                print("\(String(describing: error))")
            } else {
                self.addToSavedGamesFromData(savedGames: savedGames!)
            }
        }
        
        self.savedLocalGamesTableView.dataSource = self
        self.savedLocalGamesTableView.delegate = self
        self.savedLocalGamesTableView.reloadData()
    }

    func addToSavedGamesFromData(savedGames : [GKSavedGame]) {
        for savedGame in savedGames {
            savedGame.loadData() { (data, error) -> Void in
                if (error != nil) {
                    print("\(String(describing: error))")
                } else {
                    let gameString = String.init(data: data!, encoding: .utf8)
                    let game = Game()
                    game.initWithSavedGame(savedGameData: gameString!, savedGameName: savedGame.name!)
                    self.savedGames.append(game)
                }
            }
        }
    }
    
    // MARK: Indicator Info Provider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Local Games", image: UIImage(named: "Local Players-logo"))
    }

    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get current facebook game and create cell
        let localGame = self.savedGames[indexPath.row]
        let cell = LocalGame.instanceFromNib()
        cell.setLocalGame(localGame: localGame)
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Get selected facebook game and prompt accordingly
        let localGame = self.savedGames[indexPath.row]
        self.delegate?.promptForSelectedGame(game: localGame, isMultiplayer: false)
    }
}
