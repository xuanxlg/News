//
//  Article.swift
//  News
//
//  Created by HuangShih-Hsuan on 22/03/2017.
//  Copyright © 2017 HuangShih-Hsuan. All rights reserved.
//

import UIKit

let ArticlesURL = "https://hpd-iosdev.firebaseio.com/news/latest.json"

class Article: NSObject {
    let heading: String?
    let content: String?
    
    let category: String?
    let imageURL: URL?
    let publishedDate: Date
    let url: URL!
    
    init(data: [String: Any]){
        heading = data["heading"] as? String
        content = data["content"] as? String
        category = data["category"] as? String
        
        if let imageURLString = data["imageUrl"] as? String {
            imageURL = URL(string: imageURLString)
        } else {
            imageURL = nil
        }
        
        
        let date = data["publishedDate"] as! Double
        publishedDate = Date(timeIntervalSince1970: date/1000)
        
        url = URL(string: data["url"] as! String)
    }
    
    class func downloadNews(completionHandler: @escaping ([Article]?, Error?) -> Void) {
        let session = URLSession.shared
        let url = URL(string: ArticlesURL)
        let task = session.dataTask(with: url!) { data, response, error in
            
            if let error = error {
                print("download API error \(error)")
                return
            }
            let data = data!
            if let jsonObject = try?JSONSerialization.jsonObject(with: data, options: .mutableContainers), let articlesArray = jsonObject as? [[String: Any]] {
                
//                var articles = [Article]()
//                
//                for article in articlesArray {
//                    let data = Article.init(data: article)
//                    articles.append(data)
//                }
                let articles = articlesArray.map { Article(data: $0) }
                
                completionHandler(articles, nil)
            }
            
            print("Download Finish!!")
        }
        
        task.resume()
    }

    
}
