//
//  CommitsTableViewController.swift
//  Github Client
//
//  Created by Artem Misesin on 3/18/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftyJSON

class CommitsTableViewController: UITableViewController {

    var repoTitle: String = ""
    
    var commits: [(message: String, author: String, date: String)] = []
    
    var spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        test(SingleOAuth.shared.oAuthSwift as! OAuth2Swift)
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        self.spinner.frame = CGRect(x: self.tableView.bounds.midX - 10, y: self.tableView.bounds.midY - 10, width: 20.0, height: 20.0) // (or wherever you want it in the button)
        
        self.tableView.addSubview(self.spinner)
        self.spinner.startAnimating()
        self.spinner.alpha = 1.0
        //self.parent.
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func test(_ oauthswift: OAuth2Swift) {
        let url :String = "https://api.github.com/repos/" + SingleOAuth.shared.owner! + "/\(repoTitle)/commits"
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? JSON(response.jsonObject())
                if let arrayMessages = jsonDict?.arrayValue.map({$0["commit"].dictionaryValue}).map({$0["message"]?.stringValue}){
                    
                    if let arrayAuthors = jsonDict?.arrayValue.map({$0["commit"].dictionaryValue}).map({$0["committer"]?.dictionaryValue}).map({$0?["name"]?.stringValue}){
                        
                        if let arrayDates = jsonDict?.arrayValue.map({$0["commit"].dictionaryValue}).map({$0["committer"]?.dictionaryValue}).map({$0?["date"]?.stringValue}){
                            
                            for i in 0..<arrayMessages.count{
                                let range = arrayDates[i]?.range(of: "T")
                                let date = arrayDates[i]?.substring(to: (range?.lowerBound)!)
                                self.commits.append((arrayMessages[i]!, arrayAuthors[i]!, date!))
                            }
                        }
                    }
                }
                //print(jsonDict)
                self.spinner.stopAnimating()
                self.spinner.alpha = 0.0
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
        },
            failure: { error in
                print(error.localizedDescription)
                var message = ""
                if error.localizedDescription == "The operation couldn’t be completed. (OAuthSwiftError error -11.)"{
                    message = "No internet connection"
                } else {
                    message = "No commits found"
                }
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)})
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = commits[indexPath.row].message
        cell.detailTextLabel?.text = commits[indexPath.row].author + ", " + commits[indexPath.row].date
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
