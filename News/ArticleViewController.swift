//
//  ArticleViewController.swift
//  News
//
//  Created by HuangShih-Hsuan on 22/03/2017.
//  Copyright © 2017 HuangShih-Hsuan. All rights reserved.
//

import UIKit
import Social

class ArticleViewController: UIViewController {
    
    @IBOutlet weak var subtitleItem: UINavigationItem!
    
    var article: Article!
    var ratio: CGFloat = 1.0
    
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        DispatchQueue.main.async {
            self.titleLabel.text = self.article.heading
            self.dateLabel.text = self.dateFormatter.string(from: self.article.publishedDate)
            self.contentLabel.text = self.article.content
            self.showPhoto(url: (self.article.imageURL!))
            self.subtitleItem.title = self.article.category
        }
    }

    private func showPhoto(url: URL) {
        print("url: \(url)")
        if url != nil {
            // Creating a session object with the default configuration.
            // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
            let session = URLSession(configuration: .default)
            
            // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
            let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    print("Error downloading cat picture: \(e)")
                } else {
                    // No errors found.
                    // It would be weird if we didn't have a response, so check for that too.
                    if let res = response as? HTTPURLResponse {
                        print("Downloaded cat picture with response code \(res.statusCode)")
                        if let imageData = data {
                            // Finally convert that Data into an image and do what you wish with it.
                            //                            self.imageView.image = UIImage(data: imageData)
                            DispatchQueue.main.async {
                                let urlImage = UIImage(data: imageData)
                                
                                self.ratio = (urlImage?.size.width)! / self.imageView.frame.width
                                self.imageView.frame.size = CGSize(width: (urlImage?.size.width)! / self.ratio, height: (urlImage?.size.height)! / self.ratio)
                                
                                self.imageView.image = self.resizeImage(image: urlImage!)
                            }
                            
                            // Do something with your image.
                        } else {
                            print("Couldn't get image: Image is nil")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            
            downloadPicTask.resume()
        }
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let newWidth = image.size.width / self.ratio
        let newHeight = image.size.height / self.ratio
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func openUrlAlert(_ sender: Any) {
        if self.article.url != nil {
            showAlert(title: "URL", message: "\(self.article.url!)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let runAction: UIAlertAction = UIAlertAction(title: "Open with Safari", style: .default) { action -> Void in
            
            UIApplication.shared.open(self.article.url, options: [:])
        }
        let shareToLineAction: UIAlertAction = UIAlertAction(title: "Share to Line", style: .default) { action -> Void in
            
            let url = URL(string: "line://msg/text/%0D%0A\(self.article.url!)")
            UIApplication.shared.open(url!, options: [:])
            if (UIApplication.shared.canOpenURL(url!)) {
                UIApplication.shared.open(url!, options: [:])
            }
            else {
                let itunesURL = URL(string: "itms-apps://itunes.apple.com/app/id443904275")
                UIApplication.shared.open(itunesURL!, options: [:])
            }
        }
        let copyUrlAction: UIAlertAction = UIAlertAction(title: "Copy URL", style: .default) { action -> Void in
            
            UIPasteboard.general.string = "\(self.article.url!)"
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(runAction)
        actionSheetController.addAction(shareToLineAction)
        actionSheetController.addAction(copyUrlAction)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
}
