//
//  HomeTable.swift
//  FetchRewardsCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

//TODO: UILock when scrolling far down on poor connection then tapping top bar to skip to top
    //lots of NSURLConnection finished with error - code -1001
//TODO: prevent scrolling past 1 unloaded row
//TODO: check for internet connection
//TODO: placeholder image when none was provided
//TODO: end of results row - if row == eventsTotal, show EndOfResultsRow

import UIKit

class HomeTable: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSourcePrefetching {
    
    let defaults = UserDefaults.standard
    var events: [Event] = []
    var thumbnails: [UIImage?] = []
    var eventsTotal = 0
    var searchQuery = ""
    var searchController : UISearchController!
    var shouldCancelLoading = false
    var isLoading = false
    var loadingPriority = 0
    var nextPageCursor = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        configureSearchBar()
        loadEventsInitial()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }
    
    // MARK: - Table view & data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventsTotal > 1 {
            return eventsTotal
        } else {
            return 1
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! HomeCell
        if isLoadingCell(for: indexPath) {
            cell.title.text = "_____ ___ __________ _______ _____ ___________"
            cell.favorite.image = nil
            cell.location.text = "__ _______"
            cell.time.text = "______ _____ _ ____\n____ __"
            cell.thumbnail.image = nil
            cell.activityIndicator.stopAnimating()
        } else {
            let event = events[indexPath.row]
            cell.title.text = event.title
            if ((defaults.object(forKey: "favs") as? [Int])!.contains(event.id)) {
                cell.favorite.image = UIImage(named: "heartFill")
            } else {
                cell.favorite.image = nil
            }
            cell.location.text = (event.venue?.city ?? "") + ", " + (event.venue?.state ?? "")
            cell.time.text = SeatGeek.stringDayFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local)) + "\n" + SeatGeek.stringTimeFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local))
            if let thumbnail = thumbnails[indexPath.row] {
                cell.thumbnail.image = thumbnail
            } else {
                cell.thumbnail.image = nil
                cell.activityIndicator.startAnimating()
                let thumbnailPriority = loadingPriority
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: URL(string: (event.performers.first?.image ?? "_"))!) {
                        if thumbnailPriority == self.loadingPriority {
                            DispatchQueue.main.async {
                                self.thumbnails.remove(at: indexPath.row)
                                self.thumbnails.insert(UIImage(data: data), at: indexPath.row)
                                //cell.activityIndicator.stopAnimating()
                                if (self.tableView.indexPathsForVisibleRows ?? []).contains(indexPath) { cell.thumbnail.image = UIImage(data: data) }
                            }
                        }
                    } else {
                        // TODO: placeholder image when none was provided
                    }
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            loadEvents()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print("updateSearchResults: " + text)
        if text != searchQuery {
            searchQuery = text
            nextPageCursor = 1
            events = []
            eventsTotal = 0
            shouldCancelLoading = true
            loadingPriority += 1
            isLoading = false
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            tableView.reloadData()
            loadEvents(priority: loadingPriority)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? EventDetails, let index = tableView.indexPathForSelectedRow {
            destination.event = events[index.row]
            destination.tableView = tableView
            destination.index = index
            destination.thumbnailImage = (tableView.cellForRow(at: index) as! HomeCell).thumbnail.image
        }
    }
    
    // MARK: - Utilities
    
    private func calculateIndexPathsToReload(from newEvents: [Event]) -> [IndexPath] {
        let startIndex = events.count - newEvents.count
        let endIndex = startIndex + newEvents.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    private func configureSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.tintColor = .white
//        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.barTintColor = .white
//        searchController.searchBar.barStyle = .black
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.leftView?.tintColor = .white
            searchController.searchBar.searchTextField.textColor = .white
        } else {
            // Fallback on earlier versions
        }
//        searchController.searchBar.showsCancelButton = true
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.titleView = searchController.searchBar
    }
    
    private func loadEvents(priority: Int = 0) {
        if self.isLoading {
            print("still loading")
        } else {
            DispatchQueue.global().async {
                self.isLoading = true
                if let results = SeatGeek.parse(query: self.searchQuery, pageCursor: self.nextPageCursor) {
                    if self.shouldCancelLoading && priority < self.loadingPriority {
                        print("cancelled loading")
                        return
                    } else {
                        DispatchQueue.main.async {
                            self.nextPageCursor = results.meta.page + 1

                            if results.meta.page > 1 {
                                self.events.append(contentsOf: results.events)
                                let newIndexPaths = self.calculateIndexPathsToReload(from: results.events)
                                let reloadTheseIndexPaths = self.visibleIndexPathsToReload(intersecting: newIndexPaths)
                                if reloadTheseIndexPaths.count > 0 {
                                    print("Reloading: \(reloadTheseIndexPaths)")
                                    self.tableView.reloadRows(at: reloadTheseIndexPaths, with: .automatic)
                                }
                            } else {
                                self.events = results.events
                                self.eventsTotal = results.meta.total
                                self.thumbnails = [UIImage?](repeating: nil, count: self.eventsTotal)
                                print("loadEvents.tableView.reloadData")
                                self.tableView.reloadData()
                            }
                            self.shouldCancelLoading = false
                        }
                    }
                } else { print("json error") }
                self.isLoading = false
            }
        }
    }
    
    private func loadEventsInitial() {
        print("loadEventsInitial start")
        if let results = SeatGeek.parse(query: self.searchQuery, pageCursor: self.nextPageCursor) {
            eventsTotal = results.meta.total
            nextPageCursor = results.meta.page + 1
            events = results.events
            thumbnails = [UIImage?](repeating: nil, count: eventsTotal)
        } else { print("json error") }
        print("loadEventsInitial finished")
    }
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= events.count
    }
    
    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
