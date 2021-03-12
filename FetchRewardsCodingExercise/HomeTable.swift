//
//  HomeTable.swift
//  FetchRewardsCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

import UIKit

class HomeTable: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    let defaults = UserDefaults.standard
    var events: [Event] = []
    var eventsOriginal: [Event] = []
    var searchQuery = ""
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generatePlaceholders()
        configureSearchBar()
        DispatchQueue.global().async {
            if let results = SeatGeek.parse()?.events {
                self.eventsOriginal = results
                self.events = results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                }
            } else { print("json error") }            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! HomeCell
        let event = events[indexPath.row]
        cell.title.text = event.title
        if ((defaults.object(forKey: "favs") as? [Int])!.contains(event.id)) {
            cell.favorite.image = UIImage(named: "heartFill")
        } else {
            cell.favorite.image = nil
        }
        cell.location.text = event.venue?.city ?? "" + ", " + (event.venue?.state ?? "")
        cell.time.text = SeatGeek.stringDayFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local)) + "\n" + SeatGeek.stringTimeFrom(date: SeatGeek.dateFrom(rfc: event.datetime_local))
        cell.thumbnail.image = nil
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: (event.performers.first?.image ?? "_"))!) {
                DispatchQueue.main.async {
                    cell.thumbnail.image = UIImage(data: data)
                }
            }
        }
        return cell
    }

    func generatePlaceholders() {
        let venueHolder = Venue(state: "__", city: "_______")
        let perforHolder = Performers(image: "__")
        let eventHolder = Event(id: 1, datetime_utc: "", datetime_local: "", venue: venueHolder, performers: [perforHolder], title: "_____ ___ __________ _______ _____ ___________")
        events.append(eventHolder)
        events.append(eventHolder)
        events.append(eventHolder)
        events.append(eventHolder)
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }
    
    func configureSearchBar() {
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
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
        if text != searchQuery {
            searchQuery = text
            let length = text.count
            if length < 1 {
                events = eventsOriginal
                tableView.reloadData()
            } else {
                DispatchQueue.global().async {
                    if let results = SeatGeek.parse(query: text)?.events {
                        if text == self.searchQuery {
                            self.events = results
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    } else { print("json error") }
                }
            }
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
    
}
