//
//  ArticlesViewController.swift
//  News
//
//  Created by HuangShih-Hsuan on 22/03/2017.
//  Copyright © 2017 HuangShih-Hsuan. All rights reserved.
//

import UIKit

class ArticlesViewController: UITableViewController {
    
    @IBOutlet weak var titleItem: UINavigationItem!
    let dateFormatter = DateFormatter()
    
    var articles = [Article]()
        {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        downloadArticles()
    }

    @IBAction func reload(_ sender: Any) {
        downloadArticles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            print("showDetail")
            
            let cell = sender as! UITableViewCell
            let contentVC = segue.destination as! ArticleViewController
            let indexPath = tableView.indexPath(for: cell)
            let article = articles[(indexPath?.row)!]
            
            contentVC.article = article
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        
        
        let article = self.articles[indexPath.row]
        cell.textLabel?.text = article.heading
        
        let publishedDate = article.publishedDate
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.detailTextLabel?.text = dateFormatter.string(from: publishedDate)
        
        return cell
    }
    
    func downloadArticles() {
        Article.downloadNews { articles, error in
            if let error = error {
                print("download faile: \(error) ")
            }
            
            DispatchQueue.main.async {
                if let articles = articles {
                    self.articles = articles
                    
                    let publishedDate = self.articles[0].publishedDate
                    self.dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    self.titleItem.title = self.dateFormatter.string(from: publishedDate)
                    self.refreshControl?.endRefreshing()
                }
            }
            
        }
    }
    
}
