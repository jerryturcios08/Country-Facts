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

        fetchCountryData()
    }

    func fetchCountryData() {
        let countryEndpoint = "https://restcountries.eu/rest/v2/all"
        let endpointUrl = URL(string: countryEndpoint)

        DispatchQueue.global(qos: .userInitiated).async {
            if let url = endpointUrl {
                let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let data = data else { return }
                    if error != nil { return }

                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data)

                        // Iterates through each JSON block and instantiates a new Country instance
                        for country in jsonObject as! [Dictionary<String, Any>] {
                            let name = country["name"] as! String
                            let capital = country["capital"] as! String
                            let region = country["region"] as! String
                            let subregion = country["subregion"] as! String
                            let population = country["population"] as! Int
                            let flagUrl = country["flag"] as! String

                            // Obtains the correct currency name inside a nested array
                            let currency: String
                            let currencyBlock = country["currencies"] as! [Dictionary<String, Any>]
                            let currencyName = currencyBlock[0]["name"] as! String

                            // If there is a symbol for the currency, it is included in the string
                            if let currencySymbol = currencyBlock[0]["symbol"] as? String {
                                currency = "\(currencySymbol)  -  \(currencyName)"
                            } else {
                                currency = "\(currencyName)"
                            }

                            // Creates a new instance of country with the fetched data
                            let newCountry = Country(
                                name: name,
                                capital: capital,
                                region: region,
                                subregion: subregion,
                                population: population,
                                currency: currency,
                                flagUrl: flagUrl
                            )

                            self?.countries.append(newCountry)
                        }

                        // Calls the completion handler after the array has been populated
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    } catch {
                        print("Error occurred while deserializing JSON data: \(error)")
                    }
                }

                task.resume()
            }
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
        if searchBar.text == nil || searchBar.text == "" {
            searching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            filteredCountries = countries.filter({ country -> Bool in
                country.name.lowercased().prefix(searchText.count) == searchText.lowercased()
            })
            searching = true
            tableView.reloadData()
        }
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
