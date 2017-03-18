//
//  GlobalSplitViewController.swift
//  Github Client
//
//  Created by Artem Misesin on 3/18/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    var collapseDVC = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let dvc = storyboard.instantiateViewController(withIdentifier: "detailNVC")
//        self.addChildViewController(dvc)
    }
    
    // MARK: - UISplitViewControllerDelegate
    
//    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
//        return true
//    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDVC
    }
    
}
