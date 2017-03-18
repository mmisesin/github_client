//
//  ViewController.swift
//  Github Client
//
//  Created by Artem Misesin on 3/16/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftyJSON

class SingleOAuth{
    static let shared = SingleOAuth()
    
    var oAuthSwift: OAuthSwift?
    
    var owner: String?

}

class LoginViewController: OAuthViewController {

    var oAuthSwift: OAuthSwift?
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var repos: [(name: String, language: String)] = []
    
    var reposInfo: JSON?
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var logOutItem: UIBarButtonItem!

    @IBOutlet weak var signInItem: UIBarButtonItem!
    
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        controller.view = UIView(frame: UIScreen.main.bounds) // needed if no nib or not loaded from storyboard
        controller.delegate = self
        controller.viewDidLoad()// allow WebViewController to use this ViewController as parent to be presented
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logOutItem.isEnabled = false
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        spinner.frame = CGRect(x: self.view.bounds.midX - 10, y: self.view.bounds.midY - 10, width: 20.0, height: 20.0) // (or wherever you want it in the button)
        
        self.view.addSubview(spinner)
        doOAuthGithub()
        // Do any additional setup after loading the view, typically from a nib.
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func signIn(_ sender: UIBarButtonItem) {
        doOAuthGithub()
        //self.test(SingleOAuth.shared.oAuthSwift as! OAuth2Swift)
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        let token = self.oAuthSwift?.client.credential.oauthToken
        
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        self.oAuthSwift?.cancel()
        //doOAuthGithub()
        repos.removeAll()
        self.mainTableView.reloadData()
        signInItem.isEnabled = true
        logOutItem.isEnabled = false
    }

    func doOAuthGithub(){
        let oauthswift = OAuth2Swift(
            consumerKey:    "dc77c40af509089c9af0",
            consumerSecret: "b0d78d5401b2324db779aaf0029c793400935487",
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        self.oAuthSwift = oauthswift
        SingleOAuth.shared.oAuthSwift = oauthswift
        oauthswift.authorizeURLHandler = getURLHandler()
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "http://oauthswift.herokuapp.com/callback/github_client")!, scope: "user,repo", state: state,
            success: { credential, response, parameters in
                self.spinner.startAnimating()
                self.spinner.alpha = 1.0
                self.mainTableView.isHidden = true
                self.signInItem.isEnabled = false
                self.logOutItem.isEnabled = true
                self.test(oauthswift)
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    
    func test(_ oauthswift: OAuth2Swift) {
        let url :String = "https://api.github.com/user/repos"
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? JSON(response.jsonObject())
                if let arrayNames = jsonDict?.arrayValue.map({$0["name"].stringValue}){
                    if let arrayLanguages = jsonDict?.arrayValue.map({$0["language"].stringValue}){
                        for i in 0..<arrayNames.count{
                            self.repos.append((arrayNames[i], arrayLanguages[i]))
                        }
                    }
                }
                //print(jsonDict)
                
                self.spinner.stopAnimating()
                self.spinner.alpha = 0.0
                self.mainTableView.isHidden = false
                
                self.reposInfo = jsonDict
                self.mainTableView.reloadData()
        },
            failure: { error in
                self.showAlertView(title: "Error", message: error.localizedDescription)
        }
        )
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool{
        return true
    }
}

extension LoginViewController: OAuthWebViewControllerDelegate {
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
        oAuthSwift?.cancel()
    }
}

extension LoginViewController{
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauthToken)"
        if !credential.oauthTokenSecret.isEmpty {
            message += "\n\noauth_token_secret:\(credential.oauthTokenSecret)"
        }
        self.showAlertView(title: "Service", message: message)
    }
    
    // MARK: handler
    
    func getURLHandler() -> OAuthSwiftURLHandlerType {
        if internalWebViewController.parent == nil {
            self.addChildViewController(internalWebViewController)
        }
        return internalWebViewController
    }

//    override func prepare(for segue: OAuthStoryboardSegue, sender: Any?) {
//        if segue.identifier == Storyboards.Main.FormSegue {
//            #if os(OSX)
//                let controller = segue.destinationController as? FormViewController
//            #else
//                let controller = segue.destination as? FormViewController
//            #endif
//            // Fill the controller
//            if let controller = controller {
//                controller.delegate = self
//            }
//        }
//        
//        super.prepare(for: segue, sender: sender)
//    }
}

extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = repos[indexPath.row].name
        cell.detailTextLabel?.text = repos[indexPath.row].language
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.parent?.parent as? GlobalSplitViewController{
            vc.collapseDVC = false
            performSegue(withIdentifier: "showDetail", sender: tableView.cellForRow(at: indexPath))
            mainTableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.mainTableView.indexPathForSelectedRow {
                let repoInfoVC = (segue.destination as! UINavigationController).topViewController as! MainViewController
                repoInfoVC.title = repos[indexPath.row].name
                let arrayAuthor = reposInfo?.arrayValue.map({$0["owner"].dictionaryValue}).map({$0["login"]?.stringValue})
                repoInfoVC.authorString = arrayAuthor![indexPath.row]!
                let arrayImage = reposInfo?.arrayValue.map({$0["owner"].dictionaryValue}).map({$0["avatar_url"]?.stringValue})
                repoInfoVC.imageURLString = arrayImage![indexPath.row]!
                let arrayForks = reposInfo?.arrayValue.map({$0["forks"].stringValue})
                repoInfoVC.forksNumber = Int(arrayForks![indexPath.row])!
                let arrayWatchers = reposInfo?.arrayValue.map({$0["watchers_count"].stringValue})
                repoInfoVC.watchersNumber = Int(arrayWatchers![indexPath.row])!
                let arrayDescription = reposInfo?.arrayValue.map({$0["description"].stringValue})
                repoInfoVC.descriptionString = arrayDescription![indexPath.row]
            }
        }
    }
}
