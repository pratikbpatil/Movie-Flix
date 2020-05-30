//
//  NowPlayingAPIManager.swift
//  Movie Flix
//
//  Created by Apple on 26/05/20.
//  Copyright © 2020 Pratik Patil. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class NowPlayingAPIManager {
    
    weak var vc : NowPlayingViewController?
    var nowPlayingArray = [NowPlayingResults]()
    let context = AppDelegate().persistentContainer.viewContext
    
    func nowPlayingListAPI(completion: @escaping (Bool, String?,[NowPlayingResults]?) -> ()){
        
        AF.request(nowPlayingURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).response { (response) in
            if let data = response.data{
                do {
                    let model = try JSONDecoder().decode(NowPlayingBase.self, from: data)
                    if let data = model.results{
                        CoreDataManager.sharedInstance.deleteAllRecords(entityName: "MovieDetails")
                        self.nowPlayingArray.removeAll()
                        self.nowPlayingArray.append(contentsOf: data)
                        for user in self.nowPlayingArray{
                            CoreDataManager.sharedInstance.saveNowPlayingRecords(user: user)
                        }
                        print(self.nowPlayingArray)
                    }
                    DispatchQueue.main.async {
                        self.vc?.collectionViewOutlet.reloadData()
                    }
                    completion(true,"",self.nowPlayingArray)
                }catch let err{
                    print("error is :\(err.localizedDescription)")
                    completion(false,"",nil)
                }
            }
        }
    }
}
