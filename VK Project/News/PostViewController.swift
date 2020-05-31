//
//  PostViewController.swift
//  VK Project
//
//  Created by Denis Abramov on 06/11/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class PostViewController: UIViewController {
    var someLocation = ""
    
    @IBOutlet weak var textOfPost: UITextField!
    @IBAction func postMyText(_ sender: Any) {
        
        Alamofire.request("https://api.vk.com/method/wall.post", method: .get, parameters: ["message": self.textOfPost.text! + self.someLocation, "access_token": ClientData.client.access_token, "v": "5.71"]).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.someLocation = ""
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addLocation(segue: UIStoryboardSegue){
        let mapController = segue.source as! MapViewController
        someLocation = " (\(mapController.locationTouch.coordinate.latitude) / \(mapController.locationTouch.coordinate.longitude))"
        print(someLocation)
    }
    
    func replace(str: String, replace: Character, replaced: Character) -> String {
        let str = str
        var str1 = ""
        for char in str {
            var i = char
            if i == replace {
                i = replaced
            }
            str1.append(i)
        }
        return str1
    }
}
