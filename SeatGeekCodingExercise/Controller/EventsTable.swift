//
//  EventsTable.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 7/4/21.
//

import UIKit

class EventsTable: UITableViewController {

    var eventsTotal = 0
    var eventsNEW = [Int: EventsResponse.Event]()
    var cache = Cache()
    
    var searchController : UISearchController!
    var searchQuery = ""
    var searchPriority = 0
    
    var isLoading = false
    
    var reachability: Reachability?
    var reachabilityPrevious: Reachability.Connection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabilityStart()
        title = "Events"
        tableView.prefetchDataSource = self
        configureSearchBar()
        getEventsTotal(for: "", with: searchPriority)
    }
    
    deinit {
        reachabilityStop()
    }
}

// MARK: - Search
extension EventsTable: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    private func configureSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.leftView?.tintColor = .white
            searchController.searchBar.searchTextField.textColor = .white
        }
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text
        else { return }
        if text != searchQuery, reachability?.connection != .unavailable {
            searchQuery = text
            searchPriority += 1
//            tableView.isScrollEnabled = false
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//            tableView.setContentOffset(tableView.contentOffset, animated: false)
//            tableView.isScrollEnabled = true
            getEventsTotal(for: searchQuery, with: searchPriority)
        }
    }
}

// MARK: - Prefetch
extension EventsTable: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard !isCellLoaded(for: indexPath)
            else { return }
            getEvent(for: searchQuery, with: searchPriority, at: indexPath)
        }
    }
}

// MARK: - Fetch and Display
extension EventsTable {
    
    private func getEventsTotal(for query: String, with priority: Int) {
        eventsTotal = 0
        eventsNEW = [:]
        isLoading = true
        tableView.isScrollEnabled = false
        reloadEntireTable()
        tableView.isScrollEnabled = true
        
        SGRequest().totalEvents(for: query) { [weak self] totalEvents, _ in
            DispatchQueue.main.async {
                guard let self = self,
                      query == self.searchQuery,
                      priority == self.searchPriority
                else { return }
                
                self.eventsTotal = totalEvents ?? 0
                self.isLoading = false
                self.reloadEntireTable()
                self.getEventsInitial(for: query, with: priority)
            }
        }
    }
    
    private func getEventsInitial(for query: String, with priority: Int) {
        DispatchQueue.main.async {
            var rowCount = 10
            if let visibleRows = self.tableView.indexPathsForVisibleRows, visibleRows.count > rowCount {
                rowCount = visibleRows.count
            }
            let initialRows = (0..<rowCount).map { IndexPath(row: $0, section: 0) }
            for indexPath in initialRows {
                self.getEvent(for: query, with: priority, at: indexPath)
            }
        }
    }
    
    private func getEvent(for query: String, with priority: Int, at indexPath: IndexPath) {
        SGRequest().event(for: query, at: indexPath) { [weak self] event, _ in
            DispatchQueue.main.async {
                guard let self = self,
                      query == self.searchQuery,
                      priority == self.searchPriority,
                      let event = event
                else { return }
                
                self.reloadRowIfVisible(at: indexPath, for: event)
                self.getThumbnail(for: query, with: priority, at: indexPath, for: event)
            }
        }
    }
    
    private func getThumbnail(for query: String, with priority: Int, at indexPath: IndexPath, for event: EventsResponse.Event) {
        cache.thumbnail(for: event) { [weak self] mergedNewImage, _ in
            DispatchQueue.main.async {
                guard let self = self,
                      query == self.searchQuery,
                      priority == self.searchPriority, mergedNewImage
                else { return }
                
                self.reloadRowIfVisible(at: indexPath)
            }
        }
    }
    
    private func isCellLoaded(for indexPath: IndexPath) -> Bool {
        return eventsNEW.keys.contains(indexPath.row)
    }
    
    private func reloadEntireTable() {
        self.tableView.reloadData()
    }
    
    private func reloadRowIfVisible(at indexPath: IndexPath) {
        if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func reloadRowIfVisible(at indexPath: IndexPath, for event: EventsResponse.Event) {
        DispatchQueue.main.async {
            if !self.isCellLoaded(for: indexPath) {
                self.eventsNEW.merge([indexPath.row : event]) { _, new in new }
                if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    //Thread 1: "attempt to insert row 0 into section 0, but there are only 0 rows in section 0 after the update"
                    //searching Vegas, then Water. Ends at W-a
                }
            }
        }
    }
}

// MARK: - Table view & data source
extension EventsTable {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        if let event = eventsNEW[indexPath.row] {
            let thumbnail = cache.thumbnails[event.id]
            cell.displayLoaded(event, image: thumbnail)
        } else {
            cell.displayLoading()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsTotal
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if reachability?.connection == .unavailable {
            return "Check internet connection 🔌"
        } else if isLoading {
            return "loading"
        } else {
            return "\(eventsTotal.toDecimalString()) events"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            if !UIAccessibility.isReduceTransparencyEnabled {
                header.tintColor = .clear
                
                let blurEffectViewTag = 8105
                if !header.subviews.contains(where: { $0.tag == blurEffectViewTag }) {
                    let blurEffect = UIBlurEffect(style: .regular)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.tag = blurEffectViewTag
                    blurEffectView.frame = header.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    header.insertSubview(blurEffectView, at: 0)
                }
            } else {
                header.tintColor = .none
            }
            header.contentView.backgroundColor = .clear
            header.textLabel?.textColor = .grayBlue
            header.textLabel?.textAlignment = NSTextAlignment.center
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard isCellLoaded(for: indexPath)
        else { return nil }
        return indexPath
    }
}

// MARK: - Navigation
extension EventsTable {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventDetails,
           let indexPath = tableView.indexPathForSelectedRow,
           let event = eventsNEW[indexPath.row]
        {
            destination.searchController = searchController
            destination.event = event
            destination.tableView = tableView
            destination.index = indexPath
            destination.image = cache.thumbnails[event.id, default: cache.placeholder]
        }
    }
}

// MARK: - Reachability
extension EventsTable {
    
    @objc private func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.connection != reachabilityPrevious {
            switch reachability.connection {
            case .unavailable:
                if reachabilityPrevious != .unavailable {
                    reachabilityPrevious = reachability.connection
                    eventsNEW = [:]
                    isLoading = false
                    reloadEntireTable()
                }
            case .cellular, .wifi:
                if reachabilityPrevious == .unavailable {
                    reachabilityPrevious = reachability.connection
                    eventsNEW = [:]
                    getEventsTotal(for: searchQuery, with: searchPriority)
                    reloadEntireTable() // using this to display "loading" on slow connections while events are being fetched
                }
            }
        }
    }
    
    private func reachabilityStart() {
        reachability = try? Reachability(hostname: SGRequest().host)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start reachability notifier: \(error)")
        }
    }
    
    private func reachabilityStop() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
}
