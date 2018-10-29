//
//  FacebookGameSelected.swift
//  titanictictactoe
//
//  Created by Varun Batta on 2018-06-09.
//  Copyright © 2018 Varun Batta. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FacebookGameSelected: UIViewController, IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Play over Facebook", image: UIImage(named: "Facebook F-logo"))
    }

}
