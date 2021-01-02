//
//  PeopleViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/10/20.
//

import UIKit
import CoreData
class PeopleViewController: UIViewController {
    
    // MARK: - Properties
    let searchController    = UISearchController()
    private var textQuery   = ""
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.tableFooterView = UIView()
        configureSearchController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    // MARK: - IBOutlets
    @IBOutlet weak var peopleTableView: UITableView!
    
    
    func configureSearchController() {
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater                   = self
        searchController.searchBar.placeholder                  = "Search for a username"
        searchController.obscuresBackgroundDuringPresentation   = false
        navigationItem.searchController                         = searchController
    }
    
    private func refresh() {
        let request             = Person.fetchRequest() as NSFetchRequest<Person>
        if !textQuery.isEmpty {
            request.predicate   = NSPredicate(format: "name CONTAINS[cd] %@", textQuery)
        }
        let monthOfBirth        = NSSortDescriptor(key: #keyPath(Person.mob), ascending: true)
        let sort                = NSSortDescriptor(key: #keyPath(Person.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [monthOfBirth, sort]
        fetchedRC                       = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(Person.mob), cacheName: nil)
        do {
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error),\(error.userInfo)")
        }
        peopleTableView.reloadData()
    }
}

// MARK: - Extension

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // if don't have section, the fetchedRC.sections will = 0
        if fetchedRC.sections!.count == 0{
            tableView.setEmptyView(title: "You don't have any friend.", message: "Your friend list will be in here.", messageImage: #imageLiteral(resourceName: "6"))
        }
        return fetchedRC.sections!.count
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
        guard let sections = fetchedRC.sections, let objs = sections[section].objects as? [Person] else {
            return ""
        }
        return objs.first?.monthName
    }
    
     func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.backgroundView?.backgroundColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1)
        headerView.textLabel?.textColor = .red
        
        headerView.textLabel?.font = UIFont(name: "Avenir", size: 25.0)
    }
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    // MARK: - TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person      = fetchedRC.object(at: indexPath)
        let personVC    = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "personVC") as! PersonViewController
        personVC.person = person
        navigationController?.pushViewController(personVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let person = fetchedRC.object(at: indexPath)
        context.delete(person)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [person.id])
        appDelegate.saveContext()
        refresh()
    }
}


extension PeopleViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        textQuery            = searchText
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

extension PeopleViewController: NSFetchedResultsControllerDelegate {
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let cellIndex = indexPath else {return}
        switch type {
        case .delete:
            peopleTableView.deleteRows(at: [cellIndex], with: .fade)
        default:
            break
        }
    }
}
