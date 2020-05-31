//
//  GetDataOperation.swift
//  VK Project
//
//  Created by Denis Abramov on 17/11/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetDataOperation: AsyncOperation {
    override func cancel() {
        request.cancel()
        super.cancel()
    }
    private var request: DataRequest
    var json: JSON?
    override func main() {
        request.responseJSON(queue: DispatchQueue.global()) { [weak self] response in
            switch response.result {
            case .success(let value):
                self?.json = JSON(value)
            case .failure(let error):
                print(error)
            }
            self?.state = .finished
        }
    }
    init(request: DataRequest) {
        self.request = request
    }
}
