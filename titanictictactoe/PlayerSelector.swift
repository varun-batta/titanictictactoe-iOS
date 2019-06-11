//
//  PlayerSelector.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2018-06-09.
//  Copyright © 2018 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PlayerSelector: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = Style.mainColorGreen
        settings.style.buttonBarItemBackgroundColor = Style.mainColorGreen
        settings.style.selectedBarBackgroundColor = Style.mainColorBlack
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = Style.mainColorWhite
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = Style.mainColorWhite
            oldCell?.imageView.image = oldCell?.imageView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            oldCell?.imageView.tintColor = Style.mainColorWhite
            newCell?.label.textColor = Style.mainColorBlack
            newCell?.imageView.image = newCell?.imageView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            newCell?.imageView.tintColor = Style.mainColorBlack
        }
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let facebookGameSelected = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "facebookGameSelected")
        let localGameSelected = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "localGameSelected")
        return [localGameSelected, facebookGameSelected]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
