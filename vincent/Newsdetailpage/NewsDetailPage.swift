//
//  NewsDetailPage.swift
//  vincent
//
//  Created by Vincent on 10/25/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Toast_Swift

public class NewsDetailPage : UIViewController {
    
    @IBOutlet weak var newsImage: UIImageView!
    
    @IBOutlet weak var newsTitle: UILabel!
    
    @IBOutlet weak var newsSummary: UILabel!
    
    @IBOutlet weak var newCategories: UILabel!
    
    
    @IBOutlet weak var newsSource: UITextView!
    
    public var newsArticle : Article?
    
    var delegate:ArticleDataSetProtocol?
    
    public override func viewDidLoad() {
        setupData()
        setupActionbar()
    
    }
    
    func setupData() {
        if let article = newsArticle {
            newsImage.kf.setImage(with: URL(string: article.image), placeholder: UIImage(named: "placeholder"))
            newsTitle.text = article.title
            newsSummary.text = article.summary
            var cats = ""
            var first = true
            for cat in article.categories {
                cats.append((first ? "" : ", ") + cat.name)
                first = false
            }
            newCategories.text = cats
            
            let linkedText = NSMutableAttributedString(attributedString: NSAttributedString(string: article.url))
            let hyperLinked = linkedText.setAsLink(textToFind: article.url, linkUrl: article.url)
            
            if hyperLinked {
                newsSource.attributedText = NSAttributedString(attributedString: linkedText)
            }
            //newsSource.text = article.url
        }
        else {
            self.view.makeToast(NSLocalizedString("error_unknown", comment: ""))
        }
    }
    
    func setupActionbar() {
        var items : [UIBarButtonItem] = []
        
        if let article = newsArticle {
            let shareimage = UIImage(named: "share")
            items.append(UIBarButtonItem(image: shareimage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickedShare)))
            
            if AppDelegate.authToken != nil {
                if article.isLiked {
                    let unlikeimage = UIImage(named: "dislike")
                    items.append(UIBarButtonItem(image: unlikeimage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickedUnlike)))
                }
                else {
                    let likeimage = UIImage(named: "like")
                    items.append(UIBarButtonItem(image: likeimage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickedLike)))
                }
            }
        }
        navigationItem.rightBarButtonItems = items
    }
    
    @objc
    func clickedShare() {
        if let article = newsArticle {
            let text = article.title + " - " + article.url
            let shareText = [text]
            let activityViewController = UIActivityViewController(activityItems: shareText, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    @objc
    func clickedLike() {
        likeAsync()
    }
    
    @objc
    func clickedUnlike() {
        unlikeAsync()
    }
    
    func likeAsync() {
        if let token = AppDelegate.authToken {
            if let articleId = self.newsArticle?.id {
                NewsreaderApiManager.like(token: token, articleId: articleId).response(completionHandler: {
                    (response) in
                    if response.response?.statusCode == 200 {
                        self.newsArticle?.isLiked = true
                        self.setupActionbar()
                        self.delegate?.setLikedArticleData(data: [articleId:true])
                    }
                })
            }
        }
    }
    
    func unlikeAsync() {
        if let token = AppDelegate.authToken {
            if let articleId = self.newsArticle?.id {
                NewsreaderApiManager.unlike(token: token, articleId: articleId).response(completionHandler: {
                    (response) in
                    if response.response?.statusCode == 200 {
                        self.newsArticle?.isLiked = false
                        self.setupActionbar()
                        self.delegate?.setLikedArticleData(data: [articleId:false])
                    }
                })
            }
        }
    }
}
