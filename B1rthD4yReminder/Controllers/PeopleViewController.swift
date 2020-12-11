//
//  PeopleViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/10/20.
//

import UIKit
import CoreData
class PeopleViewController: UIViewController {
    
    let searchController = UISearchController()
    private var textQuery = ""
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      private var fetchedRC: NSFetchedResultsController<Person>!
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        configureSearchController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    @IBOutlet weak var peopleTableView: UITableView!
    
    
    func configureSearchController() {
        searchController.searchResultsUpdater                   = self
        searchController.searchBar.placeholder                  = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation   = false
        navigationItem.searchController                         = searchController
    }
    
    private func refresh() {
        let request = Person.fetchRequest() as NSFetchRequest<Person>
        if !textQuery.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", textQuery)
        }
        let monthOfBirth = NSSortDescriptor(key: #keyPath(Person.mob), ascending: true)
        let sort = NSSortDescriptor(key: #keyPath(Person.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [monthOfBirth, sort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(Person.mob), cacheName: nil)
        do {
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error),\(error.userInfo)")
        }
    }
}

// MARK: - Extension

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedRC.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedRC.sections, let objs = sections[section].objects else {
            return 0
        }
        return objs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonTableViewCell
        cell.config(person: fetchedRC.object(at: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let people = fetchedRC.sections?[section].objects as? [Person], let person = people.first {
            return "\(person.mob)"
        }
        return "hhhhhh"
    }
}


extension PeopleViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        textQuery = searchText
        refresh()
        peopleTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        textQuery = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
        refresh()
        peopleTableView.reloadData()
    }
}
