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

    // DetailRow struct contains key-value items for the table view
    struct DetailRow {
        var key: String
        var value: String
    }

    var country: Country?
    var details = [DetailRow]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the table view for the controller
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareCountryFact)
        )

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

    @objc func shareCountryFact() {
        let randomCountryFact: String
        let randomArrayRange = 1...5
        guard let randomInteger = randomArrayRange.randomElement() else { return }

        // Selects a random fact about the country for the activity controller using
        // an integer from a range between 1 to 5
        switch randomInteger {
        case 1:
            randomCountryFact = "Did you know that the capital of \(country!.name) is \(country!.capital)?"
        case 2:
            randomCountryFact = "Did you know that the region for \(country!.name) is \(country!.region)?"
        case 3:
            randomCountryFact = "Did you know that the subregion for \(country!.name) is \(country!.subregion)?"
        case 4:
            randomCountryFact = "Did you know that the population of \(country!.name) is roughly \(details[randomInteger].value)?"
        default:
            randomCountryFact = "Did you know that the currency of \(country!.name) is \(country!.currency)?"
        }

        let vc = UIActivityViewController(activityItems: [randomCountryFact], applicationActivities: [])
        present(vc, animated: true)
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
