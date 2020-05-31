//
//  NewsFeedController.swift
//  VK Project
//
//  Created by Denis Abramov on 09/09/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

var ViewWidth: CGFloat = 0.0

class NewsFeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var news: [News] = []
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.medium
        df.dateStyle = DateFormatter.Style.medium
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadnews()
        navigationItem.title = "News Feed"
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: "NewsIdentifier")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func comeBack(segue: UIStoryboardSegue) {
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return news.count
    }
    
    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGRect {
        
        ///
        //  let sizeOfText: CGFloat = 0.0
        ///
        
        if news[indexPath.row].text != "" {
            
            ///
            //        let statusText = news[indexPath.row].text
            //        let rect = NSString(string: statusText).boundingRect(with: CGSize.init(width: view.frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
            //   sizeOfText = .height + 4 + 24
            ///
            
        }
        
        ///
        //           let knownHeight: CGFloat = 0.0  //8 + 44 + 24 + 8 + 44
        //    var needToAddHeight: CGFloat = 0.0
        ///
        
        if news[indexPath.row].src != "void" {
            let image: UIImageView = UIImageView()
            image.downloadedFrom(link: news[indexPath.row].src)
            
            ///
            //                let imageHeight: CGFloat = CGFloat((news[indexPath.row].srcHeight as NSString).floatValue)
            //               let imageWidth: CGFloat = CGFloat((news[indexPath.row].srcWidth as NSString).floatValue)
            //                let scaleX = view.frame.width / imageWidth
            //         needToAddHeight = imageHeight * scaleX + 4 + 8
            //           } else {
            //              needToAddHeight = 0.0
            ///
            
        }
        ViewWidth = view.frame.width
        return CGRect(x: 0, y: 0, width: 0, height: 0)
        
        ///
        //    return CGSize(width: view.frame.width, height: sizeOfText + knownHeight + needToAddHeight + 8.4)
        ///
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsIdentifier", for: indexPath) as! FeedCell
        cell.profileImageView.downloadedFrom(link: news[indexPath.row].source_avatar)
        let attributedText = NSMutableAttributedString(string: news[indexPath.row].author, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        dateFormatter.timeZone = TimeZone.current
        let time = dateFormatter.string(from: Date(timeIntervalSince1970: news[indexPath.row].date))
        attributedText.append(NSAttributedString(string: "\n" + time, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 155, green: 161, blue: 171)]))
        cell.nameLabel.attributedText = attributedText
        if news[indexPath.row].text == "" {
            cell.statusTextView.text = nil
        } else {
            cell.statusTextView.text = news[indexPath.row].text
        }
        if news[indexPath.row].src != "void" {
            cell.statusImageView.downloadedFrom(link: news[indexPath.row].src)
        } else {
            cell.statusImageView.image = nil
        }
        cell.likesRepostsCommentsLabel.text = "\(news[indexPath.row].likes) Likes  \(news[indexPath.row].reposts) Reposts  \(news[indexPath.row].comments) Comments"
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    func downloadnews() {
        DispatchQueue.global(qos: .userInteractive).async {
            Alamofire.request(MethodFL().getNewsForListOfNewsDataTableViewController(), method: .get).responseJSON(queue: concurrentQueue) { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["response"]["items"] {
                        let tmp = News()
                        tmp.text = subJSON["text"].stringValue
                        if subJSON["source_id"].intValue > 0 {
                            self.alamofireGetUserName(url: self.getUserName(userid: subJSON["source_id"].stringValue), tmp: tmp)
                        } else if subJSON["source_id"].intValue < 0 {
                            let someint = subJSON["source_id"].intValue
                            let someString = String(someint * (-1))
                            self.alamofireGetGroupName(url: self.getGroupName(groupid: someString), tmp: tmp)
                        } else {
                            tmp.author = "author"
                        }
                        tmp.date = subJSON["date"].doubleValue
                        tmp.comments = subJSON["comments"]["count"].stringValue
                        tmp.likes = subJSON["likes"]["count"].stringValue
                        tmp.reposts = subJSON["reposts"]["count"].stringValue
                        if subJSON["attachments"][0]["photo"]["photo_604"].stringValue != "" {
                            tmp.src = subJSON["attacments"][0]["photo"]["photo_604"].stringValue
                            tmp.srcHeight = subJSON["attacments"][0]["photo"]["height"].stringValue
                            tmp.srcWidth = subJSON["attacments"][0]["photo"]["width"].stringValue
                        } else {
                            tmp.src = "void"
                        }
                        self.news.append(tmp)
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func getUserName(userid: String) -> URL {
        return URL(string: "https://api.vk.com/method/users.get?user_id=\(userid)&fields=photo_100&v=5.71&access_token=\(ClientData.client.access_token)")!
    }
    
    func getGroupName(groupid: String) -> URL {
        return URL(string: "https://api.vk.com/method/groups.getById?group_id=\(groupid)&v=5.71&access_token=\(ClientData.client.access_token)")!
    }
    
    func alamofireGetUserName(url: URL, tmp: News) {
        DispatchQueue.global(qos: .userInteractive).async {
            Alamofire.request(url, method: .get).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["response"] {
                        tmp.author = subJSON["first_name"].stringValue + subJSON["last_name"].stringValue
                        tmp.source_avatar = subJSON["photo_100"].stringValue
                    }
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func alamofireGetGroupName(url: URL, tmp: News) {
        DispatchQueue.global(qos: .userInteractive).async {
            Alamofire.request(url, method: .get).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["response"] {
                        print(subJSON)
                        tmp.author = subJSON["name"].stringValue
                        tmp.source_avatar = subJSON["photo_200"].stringValue
                    }
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

class FeedCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var statusTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        return textView
    }()
    var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = false
        return imageView
    }()
    let likesRepostsCommentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.rgb(red: 155, green: 161, blue: 171)
        return label
    }()
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 226, green: 228, blue: 232)
        return view
    }()
    let likeButton = FeedCell.buttonForTitle(title: "Like", imageName: "like-1")
    let repostButton: UIButton = FeedCell.buttonForTitle(title: "Repost", imageName: "share")
    let commentButton = FeedCell.buttonForTitle(title: "Comment", imageName: "comment")
    
    static func buttonForTitle(title: String, imageName: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.rgb(red: 143, green: 150, blue: 163), for: .normal)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(nameLabel)
        addSubview(profileImageView)
        addSubview(statusTextView)
        addSubview(statusImageView)
        addSubview(likesRepostsCommentsLabel)
        addSubview(dividerLineView)
        addSubview(likeButton)
        addSubview(repostButton)
        addSubview(commentButton)
        
        
        addConstraintsWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
        addConstraintsWithFormat(format: "H:|-4-[v0]-4-|", views: statusTextView)
        addConstraintsWithFormat(format: "H:|-2-[v0]-2-|", views: statusImageView)
        addConstraintsWithFormat(format: "H:|-12-[v0]|", views: likesRepostsCommentsLabel)
        addConstraintsWithFormat(format: "H:|-12-[v0]-12-|", views: dividerLineView)
        addConstraintsWithFormat(format: "H:|[v0(v1)][v1(v2)][v2]|", views: likeButton, repostButton, commentButton)
        addConstraintsWithFormat(format: "V:|-12-[v0]", views: nameLabel)
        addConstraintsWithFormat(format: "V:|-8-[v0(44)]-4-[v1]-4-[v2]-8-[v3(24)]-8-[v4(0.4)][v5(44)]|", views: profileImageView, statusTextView, statusImageView, likesRepostsCommentsLabel, dividerLineView, likeButton)
        addConstraintsWithFormat(format: "V:[v0(44)]|", views: repostButton)
        addConstraintsWithFormat(format: "V:[v0(44)]|", views: commentButton)
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage {
        guard self.size != newSize else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

// Счетчик лайков
//
//    @IBOutlet weak var likeControl: LikeControl!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.likeControl.addTarget(self, action: #selector(sendLikeToServer), for: .valueChanged)
//    }
//
//    @objc func sendLikeToServer() {
//        print("User liked photo")
//    }
