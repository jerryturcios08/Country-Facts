//
//  DetailScreen.swift
//  Country Facts
//
//  Created by Jerry Turcios on 1/21/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import UIKit
import WebKit

class DetailScreen: UIViewController {
    @IBOutlet var flagWebView: WKWebView!
    @IBOutlet var tableView: UITableView!

    struct DetailRow {
        var key: String
        var value: String
    }

    var country: Country?
    var details = [DetailRow]()
    //    var details = Dictionary<String, Any>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the table view for the controller
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        if let country = country {
            title = country.name

            // Create a URL request for the flag URL
            let flagUrl = URL(string: country.flagUrl)!
            let request = URLRequest(url: flagUrl)

            // Configure web view content before it is created
            //flagWebView.navigationDelegate = self
            flagWebView.load(request)
            flagWebView.scrollView.isScrollEnabled = false
            flagWebView.contentMode = .scaleAspectFit
            flagWebView = WKWebView()

            // Formats the population integer in order to show commas
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedString = formatter.string(for: country.population)!
            let formattedPopulation = String(describing: formattedString)

            // Creates the details array that will be used to display the data
            // in the table view
            details = [
                DetailRow(key: "Name", value: country.name),
                DetailRow(key: "Capital", value: country.capital),
                DetailRow(key: "Region", value: country.region),
                DetailRow(key: "Subregion", value: country.subregion),
                DetailRow(key: "Population", value: formattedPopulation),
                DetailRow(key: "Currency", value: country.currency),
            ]
        }

        tableView.reloadData()
    }
}

extension DetailScreen: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Information", for: indexPath)

        cell.textLabel?.text = details[indexPath.row].key
        cell.detailTextLabel?.text = details[indexPath.row].value

        return cell
    }
}
