//
//  FriendListTableViewController.swift
//  VK Project
//
//  Created by Denis Abramov on 27.08.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import Firebase
import WatchConnectivity
import UserNotifications

var cellUsers: [UserData] = []

class FriendListTableViewController: UITableViewController, UISearchResultsUpdating {
   
    let friendsUtils = FriendsUtils()
    var session: WCSession?
    let dictMessage = ["key1": "value1"]
    var filteredFriends = [UserData]()
    let searchController = UISearchController(searchResultsController: nil)
    var notificationToken: NotificationToken? = nil
    var friends: Results<UserData>?
    let queue: OperationQueue = {
    let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInteractive).sync {
            navigationItem.title = "My Friends"
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search Friends"
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
        let dbLink = Database.database().reference()
        dbLink.child("\(ClientData.client.user_id)/Status").setValue("loggined")
        setupNavigationBar()
        if loadData != true {
            friendsUtils.downloadfriends(userController: self)
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        pairTableAndRealm()
    }
    
    func getUserData() -> [UserData] {
        let realm = try! Realm()
        var userList: [UserData] = []
        let data = realm.objects(UserData.self)
        for value in data {
            userList.append(value)
        }
        return userList
    }
    
    func getIdUserData(id: String) -> Results<UserData> {
        let realm = try! Realm()
        let data = realm.objects(UserData.self).filter("user_id == %@", id)
        return data
    }
    
    func saveUserData(_ user: UserData, id: String, url: String) {
        do {
            let realm = try! Realm()
            let oldUserData = realm.objects(UserData.self).filter("user_id == %@", id)
            print(user.full_name)
            let oldUserPhoto = realm.objects(Photo.self).filter("photo_100 == %@", url)
            realm.beginWrite()
            realm.delete(oldUserData)
            realm.delete(oldUserPhoto)
            realm.add(user, update: true)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func pairTableAndRealm() {
        guard let realm = try? Realm() else { return }
        friends = realm.objects(UserData.self)
        notificationToken = friends?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.deleteRows(at: deletions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.reloadRows(at: modifications.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! FirstCollectionViewController
                if searchBarIsEmpty() {
                    destination.avatarImage = friends![indexPath.row].userPhoto?.photo_100 != nil ? (friends![indexPath.row].userPhoto?.photo_100)! : "https://vk.com/images/camera_200.png"
                    destination.userName = friends![indexPath.row].full_name
                    destination.bdate = friends![indexPath.row].bdate
                } else {
                    destination.avatarImage = filteredFriends[indexPath.row].userPhoto?.photo_100 != nil ? (filteredFriends[indexPath.row].userPhoto?.photo_100)! : "https://vk.com/images/camera_200.png"
                    destination.userName = filteredFriends[indexPath.row].full_name
                    destination.bdate = filteredFriends[indexPath.row].bdate
                }
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredFriends.count
        } else {
            return friends?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsIdentifier", for: indexPath) as! FriendsListViewCell
        if isFiltering() {
            var getCacheImage: GetCacheImage
            if filteredFriends[indexPath.row].userPhoto?.url != nil {
                getCacheImage = GetCacheImage(url: (filteredFriends[indexPath.row].userPhoto?.url)!)
            } else {
                getCacheImage = GetCacheImage(url: "https://vk.com/images/camera_200.png")
            }
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    cell.Avatar.image = getCacheImage.outputImage
                }
            }
            queue.addOperation(getCacheImage)
            cell.UserName.text = "\(filteredFriends[indexPath.row].full_name)"
            if filteredFriends[indexPath.row].online == "1" {
                cell.Avatar.layer.borderColor = UIColor(red: 65/255, green: 195/255, blue: 50/255, alpha: 1.0).cgColor
            } else {
                cell.Avatar.layer.borderColor = UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1.0).cgColor
            }
        } else {
            var getCacheImage: GetCacheImage
            if friends![indexPath.row].userPhoto?.url != nil {
                getCacheImage = GetCacheImage(url: (friends![indexPath.row].userPhoto?.url)!)
            } else {
                getCacheImage = GetCacheImage(url: "https://vk.com/images/camera_200.png")
            }
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    cell.Avatar.image = getCacheImage.outputImage
                }
            }
            queue.addOperation(getCacheImage)
            cell.UserName.text = "\(friends![indexPath.row].full_name)"
            if friends![indexPath.row].online == "1" {
                cell.Avatar.layer.borderColor = UIColor(red: 65/255, green: 195/255, blue: 50/255, alpha: 1.0).cgColor
            } else {
                cell.Avatar.layer.borderColor = UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1.0).cgColor
            }
        }
        return cell }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredFriends = friends!.filter({( friend : UserData) -> Bool in
            return friend.description.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension UIImageView {
    func downloadedFrom(link:String) {
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            guard let data = data , error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
            }
        }).resume()
    }
}

extension FriendListTableViewController: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(error ?? "")
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactive")
    }
}
