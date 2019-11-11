//
//  FirstCollectionViewController.swift
//  VK Project
//
//  Created by Denis Abramov on 30.08.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import UserNotifications

private let friendsIdentifier = "cellPicIdentifier"

class FirstCollectionViewController: UICollectionViewController {
    var avatarImage: String = "Avatar"
    var userName: String = ""
    var bdate: String = ""
    var month: String = ""
    
    @IBAction func localNotification(_ sender: Any) {
        let s = bdate.split(separator: ".")
        switch s[1] {
        case "1":
            month = "January"
        case "2":
            month = "February"
        case "3":
            month = "March"
        case "4":
            month = "April"
        case "5":
            month = "May"
        case "6":
            month = "June"
        case "7":
            month = "July"
        case "8":
            month = "August"
        case "9":
            month = "September"
        case "10":
            month = "October"
        case "11":
            month = "November"
        case "12":
            month = "December"
        default:
            month = "Numbers"
        }
        let message = UNMutableNotificationContent()
        message.title = "Remember:"
        message.subtitle = ""
        message.body = "\(userName) birthday is \(month) \(s[0])! Congratulate!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "timeDone", content: message, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPicIdentifier", for: indexPath) as! CustomCollectionViewCell
        let queue: OperationQueue = {
            let queue = OperationQueue()
            queue.qualityOfService = .userInteractive
            return queue
        }()
        let getCacheImage = GetCacheImage(url: avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                cell.Avatar.image = getCacheImage.outputImage
            }
        }
        queue.addOperation(getCacheImage)
        return cell
    }
}

