//
//  NewsOverviewTableViewController.swift
//  vincent
//
//  Created by Vincent on 10/24/18.
//  Copyright © 2018 drok. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import SwiftKeychainWrapper
import DropDown

public class NewsOverviewTableViewController : UIViewController {
    
    

    @IBOutlet weak var tableView: UITableView!
    
    private var newsFeed : Newsfeed?
    private var currentlyOnLikedMode : Bool = false
    private var likedRightBarButtonItem : UIBarButtonItem?
    private var dataChanged : Bool = false
    private let refreshControl = UIRefreshControl()
    private var isFetching = false
    private var feedDropDownFilter : DropDown?
    private var feedsForDropDownFilter : [Feed]?
    private var currentFilteredFeed : Int?
    
    public override func viewDidLoad() {
        title = NSLocalizedString("title_newsoverview", comment: "")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NewsOverviewTableCell", bundle: nil), forCellReuseIdentifier: "NewsOverviewTableCell")
        
        setupDropdown()
        setupAppBar()
        setupRefreshControl()
        getNewsAsync(nextId: nil, deleteExisting: true, feed: nil)
        getFeed()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if dataChanged {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            dataChanged = false
        }
    }
    
    private func setupDropdown() {
        self.feedDropDownFilter = DropDown()
        self.feedDropDownFilter?.selectionAction = {
            (index: Int, item: String) in
            if let feed = self.feedsForDropDownFilter {
                
                var selectedFeedId : Int? = nil
                if item == NSLocalizedString("filter_all", comment: "") {
                    selectedFeedId = nil
                }
                else {
                    selectedFeedId = feed[index - 1].id
                }
                self.currentFilteredFeed = selectedFeedId
                self.getNewsAsync(nextId: nil, deleteExisting: true, feed: selectedFeedId)
            }
        }
    }
    
    private func setupAppBar(){
        navigationItem.hidesBackButton = true
        var menuItems : [UIBarButtonItem] = []
        
        menuItems.append(UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(logout)))
        
        let filterButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(filterClicked))
        menuItems.append(filterButtonItem)
        //self.feedDropDownFilter?.anchorView = filterButtonItem
        
        if AppDelegate.authToken != nil {
            likedRightBarButtonItem = UIBarButtonItem(image: UIImage(named: "like"), style: .plain, target: self, action: #selector(liked))
            menuItems.append(likedRightBarButtonItem!)
        }
        navigationItem.rightBarButtonItems = menuItems
    }
    
    func setupRefreshControl() {
        tableView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc
    private func refresh() {
        getNewsAsync(nextId: nil, deleteExisting: true, feed: self.currentFilteredFeed)
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    @objc
    private func logout() {
        AppDelegate.authToken = nil
        KeychainWrapper.standard.removeObject(forKey: ViewController.authtokenKey)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func filterClicked() {
        if let dropdown = self.feedDropDownFilter {
            if dropdown.isHidden {
                dropdown.show()
            }
            else {
                dropdown.hide()
            }
        }
    }
    
    @objc
    private func liked() {
        if let token = AppDelegate.authToken {
            if(currentlyOnLikedMode) {
                likedRightBarButtonItem?.image = UIImage(named: "like")
                getNewsAsync(nextId: nil, deleteExisting: true, feed: nil)
            }
            else {
                likedRightBarButtonItem?.image = UIImage(named: "dislike")
                getLikedNewsAsync(token: token)
            }
            self.currentlyOnLikedMode = !currentlyOnLikedMode
        }
    }
    
    private func getLikedNewsAsync(token: String) {
        self.isFetching = true
        NewsreaderApiManager.getLikedNews(token: token).responseData(completionHandler: {
            (response) in
            self.isFetching = false
            guard response.error == nil else { self.view.makeToast(NSLocalizedString("error_unknown", comment: "")); return }
            guard let jsonData = response.data else { self.view.makeToast(NSLocalizedString("error_unknown", comment: "")); return }
            let decoder = JSONDecoder()
            
            let newsfeed = try? decoder.decode(Newsfeed.self, from: jsonData)
            self.newsFeed = newsfeed
            self.tableView.reloadData()
        })
    }
    
    private func getNewsAsync(nextId: Int?, deleteExisting: Bool, feed: Int?){
        self.isFetching = true
        NewsreaderApiManager.getNews(token: AppDelegate.authToken, count: nil, nextId: nextId, feed: feed).responseData(completionHandler: { (response) in
            self.isFetching = false
            guard response.error == nil else { self.view.makeToast(NSLocalizedString("error_unknown", comment: "")); return }
            guard let jsonData = response.data else { self.view.makeToast(NSLocalizedString("error_unknown", comment: "")); return }
            let decoder = JSONDecoder()
            let newsfeed = try? decoder.decode(Newsfeed.self, from: jsonData)
            
            if deleteExisting {
                self.newsFeed = newsfeed
            }
            else {
                if let newsfeed = newsfeed {
                    self.newsFeed?.nextId = newsfeed.nextId
                    self.newsFeed?.results.append(contentsOf: newsfeed.results)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    private func getFeed() {
        self.isFetching = true
        NewsreaderApiManager.getFeed().responseData(completionHandler: {
            (response) in
            self.isFetching = false
            guard response.error == nil else { self.view.makeToast(NSLocalizedString("error_unknown", comment: "")); return }
            guard let jsonData = response.data else { self.view.makeToast(NSLocalizedString("error_unknown", comment: "")); return }
            let decoder = JSONDecoder()
            let feeds = try? decoder.decode([Feed].self, from: jsonData)
            if let feed = feeds {
                var feedNames : [String] = []
                feedNames.append(NSLocalizedString("filter_all", comment: ""))
                for feedItem in feed {
                    feedNames.append(feedItem.name)
                }
                self.feedsForDropDownFilter = feed
                self.feedDropDownFilter?.dataSource = feedNames
            }
        })
    }
}

extension NewsOverviewTableViewController : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFeed?.results.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsOverviewTableCell") as! NewsOverviewTableCell
        
        if let newsfeed = newsFeed{
            let article = newsfeed.results[indexPath.row]
            //data logic
            cell.newsTitle.text = article.title
            if article.isLiked {
                cell.backgroundColor = ColorHelper.hexStringToUIColor(hex: "#DFF2FB")
            }
            
            let url = URL(string: article.image)
            cell.newsImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        }
        else {
            self.view.makeToast(NSLocalizedString("error_unknown", comment: ""))
        }
        return cell
    }
}


extension NewsOverviewTableViewController : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsDetailVc = storyboard.instantiateViewController(withIdentifier: "NewsDetailPage") as! NewsDetailPage
        newsDetailVc.newsArticle = newsFeed?.results[indexPath.row]
        newsDetailVc.delegate = self
        self.navigationController?.pushViewController(newsDetailVc, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let newsFeed = newsFeed {
            let articleCount = newsFeed.results.count
            
            guard indexPath.row >= articleCount - 1 else { return }
            guard self.isFetching == false else { return }
            //guard let nextId = newsFeed.results.last?.id else { return }
            getNewsAsync(nextId: newsFeed.nextId, deleteExisting: false, feed: currentFilteredFeed)
        }
    }
}

extension NewsOverviewTableViewController : ArticleDataSetProtocol {
    public func setLikedArticleData(data: [Int : Bool]) {
            if let newsFeed = newsFeed {
                var index = 0
                for article in newsFeed.results {
                    if article.id == data.first!.key {
                        newsFeed.results[index].isLiked = data.first!.value
                        dataChanged = true
                        return
                    }
                    index = index + 1
                }
            }
        }
}
