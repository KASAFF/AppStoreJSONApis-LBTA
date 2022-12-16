//
//  Service.swift
//  AppStoreJSONApis
//
//  Created by Aleksey Kosov on 14.12.2022.
//

import Foundation

class Service {
    
    static let shared = Service() //Singleton
    
    func fetchApps(seachTerm: String, completion: @escaping (SearchResult?, Error?)->()) {
        let urlString = "https://itunes.apple.com/search?term=\(seachTerm)&entity=software"
        
        fetchGenericJSONData(urlString: urlString, completion: completion)
    }
    
     func fetchTopFree(completion: @escaping (AppGroup?, Error?) -> ()) {
        let urlString = "https://rss.applemarketingtools.com/api/v2/tr/apps/top-free/50/apps.json"
        fetchAppGroup(urlString: urlString, completion: completion)
    }
     func fetchTopPaid(completion: @escaping (AppGroup?, Error?) -> ()) {
        fetchAppGroup(urlString: "https://rss.applemarketingtools.com/api/v2/us/apps/top-paid/25/apps.json", completion: completion)
    }
    
    func fetchAppGroup(urlString: String, completion: @escaping (AppGroup?, Error?) -> Void) {
        fetchGenericJSONData(urlString: urlString, completion: completion)
    }
    
    func fetchSocialApps(completion: @escaping ([SocialApp]?, Error?)-> Void) {
        let urlString = "https://api.letsbuildthatapp.com/appstore/social"
        fetchGenericJSONData(urlString: urlString, completion: completion)
    }
    //declare my generic json function here
    func fetchGenericJSONData<T: Decodable>(urlString: String, completion: @escaping (T?, Error?)->()) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, resp, err in
            if let err = err {
                completion(nil, err)
                return
            }
            do {
                let objects = try JSONDecoder().decode(T.self, from: data!)
                completion(objects, nil)
            } catch {
                completion(nil, error)
                print("Failed to decode:", error)
            }
        }.resume()
    }
    
}


