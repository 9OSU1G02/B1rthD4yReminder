//
//  BirthDayToDayViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/12/20.
//

import UIKit
import CoreData
class BirthDayToDayViewController: UIViewController {
    
    private var textQuery       = ""
    
    @IBOutlet weak var birthDayTodayTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        birthDayTodayTableView.delegate = self
        birthDayTodayTableView.dataSource = self
        birthDayTodayTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    @IBSegueAction func showActionView(_ coder: NSCoder) -> ActionViewController? {
        guard let indexPath = birthDayTodayTableView.indexPathForSelectedRow else {
            fatalError()
        }
        return ActionViewController(coder: coder, person: fetchedRC.object(at: indexPath))
    }
    
    private func refresh() {
        let request                 = Person.fetchRequest() as NSFetchRequest<Person>
        
        let monthPredicate          = NSPredicate(format: "mob == %d", Date().currentMonthIntValue())
        let dayPredicate            = NSPredicate(format: "dob == %d", Date().currentDayIntValue())
        let compoundPredicate       = NSCompoundPredicate(type: .and, subpredicates: [monthPredicate, dayPredicate])
        request.predicate           = compoundPredicate
        
        let sortByMonthOfBirth      = NSSortDescriptor(key: #keyPath(Person.mob), ascending: true)
        let sortbyname                           = NSSortDescriptor(key: #keyPath(Person.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors     = [sortByMonthOfBirth, sortbyname]
        
        do {
            fetchedRC               = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(Person.mob), cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error),\(error.userInfo)")
        }
        birthDayTodayTableView.reloadData()
    }
    deinit {
        print("BirthDayToDay Deinit")
    }
}



extension BirthDayToDayViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if fetchedRC.sections!.count == 0{
            tableView.setEmptyView(title: "No one is birthday today.", message: "Your friend birthday will be in here.", messageImage: #imageLiteral(resourceName: "9"))
        }
        return fetchedRC.sections!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedRC.sections, let objs = sections[section].objects else {
            tableView.setEmptyView(title: "No one is birthday today.", message: "Your friend birthday will be in here.", messageImage: #imageLiteral(resourceName: "swipe-right (1)"))
            return 0
        }
        return objs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BirthDayToDayTableViewCell
        cell.config(person: fetchedRC.object(at: indexPath))
        return cell
    }
}

extension BirthDayToDayViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        textQuery            = searchText
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
