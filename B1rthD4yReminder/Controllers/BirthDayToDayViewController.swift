//
//  BirthDayToDayViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/12/20.
//

import UIKit
import CoreData
class BirthDayToDayViewController: UIViewController {
    
    private var textQuery = ""
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Person>!
    
    @IBOutlet weak var birthDayTodayTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        birthDayTodayTableView.delegate = self
        birthDayTodayTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
        private func refresh() {
        let request = Person.fetchRequest() as NSFetchRequest<Person>
        
        let currentMotn = Int32(Calendar.current.dateComponents([.month], from: Date()).month!)
        let currentDay = Int32(Calendar.current.dateComponents([.day], from: Date()).day!)
        
        let monthPredicate = NSPredicate(format: "mob == %d", currentMotn)
        let dayPredicate = NSPredicate(format: "dob == %d", currentDay)
        
        if !textQuery.isEmpty {
            let textQueryPredicate = NSPredicate(format: "name CONTAINS[cd] %@", textQuery)
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [monthPredicate,dayPredicate,textQueryPredicate])
            request.predicate = compoundPredicate
            }
        else {
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [monthPredicate, dayPredicate])
            request.predicate = compoundPredicate
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
        birthDayTodayTableView.reloadData()
    }
}



extension BirthDayToDayViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BirthDayToDayTableViewCell
        cell.config(person: fetchedRC.object(at: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionTitle = UILabel()
        headerView.addSubview(sectionTitle)
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sectionTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            sectionTitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
        ])
        if let people = fetchedRC.sections?[section].objects as? [Person], let person = people.first {
            sectionTitle.text = person.monthName
        }
        return headerView
    }
}

extension BirthDayToDayViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        textQuery = searchText
        refresh()
        birthDayTodayTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        textQuery = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
        refresh()
        birthDayTodayTableView.reloadData()
    }
}
