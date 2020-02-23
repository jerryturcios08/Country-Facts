//
//  NetworkManager.swift
//  Country Facts
//
//  Created by Jerry Turcios on 2/22/20.
//  Copyright © 2020 Jerry Turcios. All rights reserved.
//

import Foundation

struct NetworkManager {
    static func fetchCountryData(completionHandler: @escaping ([Country]) -> Void) {
        let countryEndpoint = "https://restcountries.eu/rest/v2/all"
        let endpointUrl = URL(string: countryEndpoint)!
        let session = URLSession.shared

        var countriesArray = [Country]()

        DispatchQueue.global(qos: .userInitiated).async {
            let task = session.dataTask(with: endpointUrl) {
                (data, response, error) in

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
                            currency = "\(currencySymbol) (\(currencyName))"
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

                        countriesArray.append(newCountry)
                    }

                    // Calls the completion handler after the array has been populated
                    DispatchQueue.main.async {
                        completionHandler(countriesArray)
                    }
                } catch {
                    print("Error occurred while deserializing JSON data: \(error)")
                }
            }

            task.resume()
        }
    }
}
