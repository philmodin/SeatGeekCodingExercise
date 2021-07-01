//
//  EventsTable.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 6/26/21.
//

import UIKit

class EventsTable: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSourcePrefetching {

    var eventsResponse: EventsResponse?
    var events = [EventsResponse.Event]()
    var searchController : UISearchController!
    var searchQuery = ""
    var shouldCancelLoading = false
    var isLoading = false
    var loadingPriority = 0
    var reachability: Reachability?
    var reachabilityPrevious: Reachability.Connection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reachabilityStart()
        tableView.prefetchDataSource = self
        configureSearchBar()
        displayEvents()
    }
    
    // MARK: - Table view & data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        if reachability?.connection == .unavailable {
            cell.displayNoConnection()
        } else if !isLoading && eventsResponse?.meta.total ?? 0 < 1 {
            cell.displayNoEvents()
        } else if isLoadingCell(for: indexPath) {
            cell.displayLoading()
        } else {
            cell.displayLoaded(events[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let eventsTotal = eventsResponse?.meta.total {
            return eventsTotal
        } else {
            return 0
        }
        
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            displayEvents()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if reachability?.connection == .unavailable {
            return "Check internet connection 🔌"
        } else if !isLoading, let eventsTotal = eventsResponse?.meta.total {
            return "\(eventsTotal.toDecimalString()) events"
        } else {
            return "loading"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            if !UIAccessibility.isReduceTransparencyEnabled {
                header.tintColor = .clear
                let blurEffect = UIBlurEffect(style: .regular)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                //always fill the view
                blurEffectView.frame = header.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                header.insertSubview(blurEffectView, at: 0)
            } else {
                header.tintColor = .none
            }
            header.contentView.backgroundColor = .clear
            header.textLabel?.textColor = .grayBlue
            header.textLabel?.textAlignment = NSTextAlignment.center
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isLoadingCell(for: indexPath) || eventsResponse?.meta.total ?? 0 < 1 { return nil } else { return indexPath }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if events.count > 10 {
            let rectForFirstPending = self.tableView.rectForRow(at: IndexPath(row: self.events.count, section: 0))
            let contentHeight = rectForFirstPending.origin.y + rectForFirstPending.height
            self.tableView.contentSize = CGSize(width: self.tableView.contentSize.width, height: contentHeight)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text != searchQuery, reachability?.connection != .unavailable {
            searchQuery = text
            eventsResponse = nil
            events = []
            shouldCancelLoading = true
            loadingPriority += 1
            isLoading = false
            tableView.reloadData()
            displayEvents(priority: loadingPriority)
        }
        searchQuery = text
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventDetails, let index = tableView.indexPathForSelectedRow {
//            destination.event = events[index.row]
            destination.tableView = tableView
            destination.index = index
//            destination.image = thumbnails[index.row] ?? UIImage(named: "icon")
        }
    }
    
    // MARK: - Utilities
    
    private func calculateIndexPathsToReload(from newEvents: [EventsResponse.Event]) -> [IndexPath] {
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
        searchController.searchBar.barTintColor = .white
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.leftView?.tintColor = .white
            searchController.searchBar.searchTextField.textColor = .white
        }
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.titleView = searchController.searchBar
    }
    
    private func displayEvents(priority: Int = 0) {
        print("loadEvents with priority: \(priority) START")
        if !isLoading {
            
            isLoading = true
            SGRequest().event(searching: self.searchQuery, at: (eventsResponse?.meta.page ?? 0) + 1) { [weak self] eventsResponse, error in
                
                guard let self = self else { return }
                self.isLoading = false
                
                guard let eventsResponse = eventsResponse, !(self.shouldCancelLoading && priority < self.loadingPriority)
                else {
                    print("cancelled loading with priority: \(priority)/\(self.loadingPriority), should cancel: \(self.shouldCancelLoading)")
                    return
                }
                
                print("loadEvents with priority: \(priority) LOADED with \(eventsResponse.meta.total) events")
                self.eventsResponse = eventsResponse
                DispatchQueue.main.async {
                    
                    if eventsResponse.meta.page > 1 {
                        self.events.append(contentsOf: eventsResponse.events)
                        let newIndexPaths = self.calculateIndexPathsToReload(from: eventsResponse.events)
                        let reloadTheseIndexPaths = self.visibleIndexPathsToReload(intersecting: newIndexPaths)
                        if reloadTheseIndexPaths.count > 0 {
                            self.tableView.reloadRows(at: reloadTheseIndexPaths, with: .automatic)
                        }
                    } else {
                        self.events = eventsResponse.events
                        self.tableView.reloadData()
                    }
                    self.shouldCancelLoading = false
                }
            }
        }
    }
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= events.count
    }
    
    @objc private func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.connection != reachabilityPrevious {
            switch reachability.connection {
            case .unavailable:
                print("Network.reachability.status: UNREACHABLE")
                reachabilityPrevious = reachability.connection
                loadingPriority += 1
                eventsResponse = nil
                events = []
                isLoading = false
                tableView.reloadData()
            case .cellular, .wifi:
                print("Network.reachability.status: CONNECTED")
                if reachabilityPrevious == .unavailable {
                    reachabilityPrevious = reachability.connection
                    displayEvents()
                    tableView.reloadData() // using this to display "loading" on slow connections while events are being fetched
                }
            }
        }
    }
    
    private func reachabilityStart() {
        reachability = try? Reachability(hostname: SeatGeek.host)
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
    
    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    deinit {
        reachabilityStop()
    }
}