//
//  FacebookGame.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2020-Mar-27.
//  Copyright © 2020 Varun Batta. All rights reserved.
//

import UIKit

class FacebookGame: UITableViewCell {

    @IBOutlet var player1ProfilePictureView: UIImageView!
    @IBOutlet var player1NameLabel: UILabel!
    @IBOutlet var player2ProfilePictureView: UIImageView!
    @IBOutlet var player2NameLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    
    class func instanceFromNib() -> FacebookGame {
        return UINib(nibName: "FacebookGame", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FacebookGame
    }
    
    func setFacebookGame(facebookGame: Game) {
        // Set player 1 picture and name
        let player1ProfilePictureUrl = NSURL(string: "https://graph.facebook.com/\(facebookGame.player1.playerFBID)/picture?width=48&height=48")
        let player1ProfilePictureData = NSData(contentsOf: player1ProfilePictureUrl! as URL) // make sure your image in this url does exist, otherwise unwrap in a if let check
        player1ProfilePictureView.image = UIImage(data: player1ProfilePictureData! as Data)
        player1NameLabel.text = "\(facebookGame.player1.playerName) (\(facebookGame.player1.turn))"
        
        // Set player 2 picture and name
        let player2ProfilePictureUrl = NSURL(string: "https://graph.facebook.com/\(facebookGame.player2.playerFBID)/picture?width=48&height=48")
        let player2ProfilePictureData = NSData(contentsOf: player2ProfilePictureUrl! as URL) // make sure your image in this url does exist, otherwise unwrap in a if let check
        player2ProfilePictureView.image = UIImage(data: player2ProfilePictureData! as Data)
        player2NameLabel.text = "\(facebookGame.player2.playerName) (\(facebookGame.player2.turn))"
        
        // Set level label
        levelLabel.text = "Level \(facebookGame.level)"
    }
    
}
