//
//  ViewController.swift
//  Country Facts
//
//  Created by Jerry Turcios on 1/21/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit

class HomeScreen: UIViewController {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!

    var countries = [Country]()
    var filteredCountries = [Country]()
    var searching = false

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.returnKeyType = .done
        tableView.dataSource = self
        tableView.delegate = self

        NetworkManager.fetchCountryData { [weak self] (countries) in
            self?.countries = countries
            self?.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let vc = segue.destination as? DetailScreen {
                    if searching {
                        vc.country = filteredCountries[indexPath.row]
                    } else {
                        vc.country = countries[indexPath.row]
                    }
                }
            }
        }
    }
}

extension HomeScreen: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCountries = countries.filter({ country -> Bool in
            country.name.lowercased().prefix(searchText.count) == searchText.lowercased()
        })
        searching = true
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension HomeScreen: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredCountries.count
        } else {
            return countries.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        // Returns all filtered countries if the user is searching for a specific one
        if searching {
            cell.textLabel?.text = filteredCountries[indexPath.row].name
        } else {
            cell.textLabel?.text = countries[indexPath.row].name
        }

        return cell
    }
}
