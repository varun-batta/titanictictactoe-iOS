//
//  PlayerSelector.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2018-06-09.
//  Copyright © 2018 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PlayerSelector: ButtonBarPagerTabStripViewController, LocalGameSelectedDelegate, FacebookGameSelectedDelegate {
    
    var level : Int = 1
    var localGameSelected : LocalGameSelected!
    var facebookGameSelected : FacebookGameSelected!
    
    override func viewDidLoad() {
        // Change selected bar color
        settings.style.buttonBarBackgroundColor = Style.mainColorDarkGreen
        settings.style.buttonBarItemBackgroundColor = Style.mainColorDarkGreen
        settings.style.selectedBarBackgroundColor = Style.mainColorWhite
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = Style.mainColorBlack
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.isHidden = false
            oldCell?.label.textColor = Style.mainColorBlack
            oldCell?.imageView.isHidden = true
            oldCell?.imageView.image = oldCell?.imageView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            oldCell?.imageView.tintColor = Style.mainColorBlack

            newCell?.label.isHidden = true
            newCell?.label.textColor = Style.mainColorWhite
            newCell?.imageView.isHidden = false
            newCell?.imageView.image = newCell?.imageView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            newCell?.imageView.tintColor = Style.mainColorWhite
        }
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Added this just to make sure the button bar cell width is correct
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/2, height: self.buttonBarView.frame.height)
    }
    
    // Added this to make sure the view looks correct
    // CANNOT call super.viewWillAppear as that ruins this for some reason
    override func viewWillAppear(_ animated: Bool) {
        self.reloadPagerTabStripView()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        facebookGameSelected = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "facebookGameSelected") as! FacebookGameSelected)
        localGameSelected = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "localGameSelected") as! LocalGameSelected)
        localGameSelected.delegate = self
        facebookGameSelected.delegate = self
        return [localGameSelected, facebookGameSelected]
    }
    
    func beginGame(player1: Player, player2: Player, isMultiplayer: Bool) {
        performSegue(withIdentifier: "BeginGame", sender: [level, player1, player2, isMultiplayer])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BeginGame" {
            let board : Board = segue.destination as! Board
            let extras = sender as! [Any]
            board.level = extras[0] as! Int
            board.setPlayers(player1: extras[1] as! Player, player2: extras[2] as! Player)
            Board.isMultiplayer = extras[3] as? Bool
        }
    }
}
