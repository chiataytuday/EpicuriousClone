//
//  NewestRecipiesViewController.swift
//  EpicuriousClone
//
//  Created by Tringapps on 03/09/19.
//  Copyright © 2019 Tringapps. All rights reserved.
//

import UIKit

class NewestVideosPageViewController: UIViewController, scrollablePageView {
    var allVideos:[NewestVideosDecodableDataModel] = []

    @IBOutlet weak var tableView: UITableView!
    let dispatchGroup = DispatchGroup()
    var selectedIndex:Int!
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Newest Videos View Loaded")
        tableView.dataSource = self
        tableView.delegate = self
        refreshData()
        setupRefreshControl()
    }

    fileprivate func setupRefreshControl() {
        tableView.refreshControl = refresher
    }

    @objc fileprivate func refreshData() {
        initalizeData()
        dispatchGroup.notify(queue: .main, execute: { [weak self] in
            self?.refreshViewController()
            self?.refresher.endRefreshing()
        })
    }

    fileprivate func initalizeData() {
        let fileName:String = "HomeTabNewestVideosPageJSON"
        let fileExtension:String = "json"
        let urlObject = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        GetDataFromApi.getJsonArrayFromFile(fromFile: urlObject!, dispatchGroup: dispatchGroup) { [weak self] (entries: [NewestVideosDecodableDataModel]) in
            self?.allVideos = entries
        }
    }

    fileprivate func refreshViewController() {
        tableView.reloadData()
    }

    deinit {
        print("Newest Videos View Safe From Memory Leaks")
    }
}

extension NewestVideosPageViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return allVideos.count
        default:
            print("Internal Error")
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewestVideosHeaderTableViewCell.reusableIdentity) as! NewestVideosHeaderTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: VideosTableViewCell.reusableIdentity) as! VideosTableViewCell
            cell.setValues(ofVideo: self.allVideos[indexPath.row])
            return cell;
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewestVideosHeaderTableViewCell.reusableIdentity) as! NewestVideosHeaderTableViewCell
            print("Internal Error")
            return cell
        }
    }
}

extension NewestVideosPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "VideoPlayerSegueIdentifier", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let videoPlayerViewController = segue.destination as? VideoPlayerViewController else {return}
        videoPlayerViewController.urlString = allVideos[selectedIndex].videoUrl
        videoPlayerViewController.descriptionString = allVideos[selectedIndex].description
    }
}
