//
//  MethodFL.swift
//  VK Project
//
//  Created by Denis Abramov on 09/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation

struct MethodFL {
    private let apiUrl = "https://api.vk.com/method/"
    
    func auth(client_id: String, scope: String) -> URL {
        return URL(string: "https://oauth.vk.com/authorize?client_id=\(client_id)&redirect_uri=https://oauth.vk.com/blank.html&display=mobile&scope=\(scope)&response_type=token&v=5.71&state=123456")!
    }
    
    func getFriendsForListOfFriendsTableViewController() -> URL {
        return URL(string: "\(apiUrl)friends.get?user_id=\(ClientData.client.user_id)&order=hints&fields=photo_100,bdate,online,can_write_private_message&access_token=\(ClientData.client.access_token)&v=5.71")!
    }
    
    func getGroupsForGroupsTableViewController() -> URL {
        return URL(string: "\(apiUrl)groups.get?user_id=\(ClientData.client.user_id)&extended=1&access_token=\(ClientData.client.access_token)&v=5.71")!
    }
    
    func getNewsForListOfNewsDataTableViewController() -> URL {
        return URL(string: "\(apiUrl)newsfeed.get?filters=post&access_token=\(ClientData.client.access_token)&v=5.71")!
    }
    
    func searchGroups(q: String) -> URL {
        return URL(string: "\(apiUrl)groups.search?access_token=\(ClientData.client.access_token)&v=5.71")!
    }
    
    func postSomething(text: String) -> URL {
        return URL(string: "\(apiUrl)wall.post?access_token=\(ClientData.client.access_token)&message=\(text)&v=5.71")!
    }
    
    func getDialogsForListOfMessengerTableViewController() -> URL {
        return URL(string: "\(apiUrl)messages.getDialogs?access_token=\(ClientData.client.access_token)&preview_length=50&v=5.71")!
    }
}
