//
//  HomeTable.swift
//  FetchRewardsCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

import UIKit

class HomeTable: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    var events: [Event] = []
    var eventsOriginal: [Event] = []
    var searchQuery = ""
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generatePlaceholders()
        configureNavBar()
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
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setNeedsStatusBarAppearanceUpdate()
//    }
    
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
        cell.location.text = event.venue.city + ", " + event.venue.state
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
    
    func configureNavBar() {
        let navStandardAppearance = UINavigationBarAppearance()
        navStandardAppearance.configureWithOpaqueBackground()
        navStandardAppearance.backgroundColor = .grayBlue
        navigationController?.navigationBar.standardAppearance = navStandardAppearance
        
        let navScrollAppearance = UINavigationBarAppearance()
        navScrollAppearance.configureWithOpaqueBackground()
        navScrollAppearance.backgroundColor = .white
        navigationController?.navigationBar.scrollEdgeAppearance = navScrollAppearance
    }
    
    func configureSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.textColor = .white
//        searchController.searchBar.barStyle = .black
        searchController.searchBar.searchTextField.leftView?.tintColor = .white
//        searchController.searchBar.showsCancelButton = true
        searchController.hidesNavigationBarDuringPresentation = false
//        definesPresentationContext = true
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
