//
//  ClientData.swift
//  VK Project
//
//  Created by Denis Abramov on 09/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation

struct ClientData {
    struct app {
        static let client_id = "6609999"
        static let service_key = "67192a95e890802089f5671369d6e52ff60e8ba9e6c58da47995369bb98b2082f6bcfbd841206f7100046"
    }
    struct client {
        static var access_token = ""
        static var user_id = ""
    }
    struct scope {
        static let friendsPhotoGroups = "262150,friends,wall,messages"
        static let friendsPhotoAudioVideo = "30"
    }
}
