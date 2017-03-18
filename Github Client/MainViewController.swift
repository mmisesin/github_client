//
//  MainViewController.swift
//  Github Client
//
//  Created by Artem Misesin on 3/17/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var authorUserPic: UIImageView!
    
    var imageURLString = ""
    
    @IBOutlet var authorName: UILabel!
    
    var authorString = ""
    
    @IBOutlet weak var forksCount: UILabel!
    
    var forksNumber = 0
    
    @IBOutlet weak var watchesCount: UILabel!
    
    var watchersNumber = 0
    
    @IBOutlet weak var descriptionField: UILabel!
    
    var descriptionString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SingleOAuth.shared.owner = authorString
        descriptionField.sizeToFit()
        authorName.text = authorString
        forksCount.text = "\(forksNumber)"
        watchesCount.text = "\(watchersNumber)"
        if descriptionString != "" {
            descriptionField.text = descriptionString
            descriptionField.textColor = .black
        } else {
            descriptionField.text = "Nothing found"
            descriptionField.textColor = .lightGray
        }
        if let url = URL(string: imageURLString){
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.authorUserPic.image = UIImage(data: data)
                    }
                } catch {
                    self.authorUserPic.image = UIImage(contentsOfFile: "defaultPic")
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCommits" {
            let repoInfoVC = (segue.destination as! CommitsTableViewController)
            repoInfoVC.repoTitle = self.title!
        }
    }

}
