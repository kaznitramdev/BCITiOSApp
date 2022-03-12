//
//  ViewController.swift
//  BitcoinTrackerTutorial
//
//  Created by Zak Martin on 3/11/22.
//
/*
    Prototype: Demonstrating API Functionality
                - this demo uses the api with hardcoded data
                - The api for individual prices is more complicated
                - will have to create dynamic objects for multiple assets too
                - will be the focus of next week
 */
import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var btcPrice: UILabel!
    @IBOutlet weak var ethPrice: UILabel!
    @IBOutlet weak var usdPrice: UILabel!
    @IBOutlet weak var lastUpdatedPrice: UILabel!
    
    let urlString = "https://api.coingecko.com/api/v3/exchange_rates"
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        fetchData()
        
        let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
    }
    
    @objc func refreshData() -> Void
    {
        fetchData()
    }

    
    func fetchData()
    {
        let url = URL(string: urlString)
        let defaultSession = URLSession(configuration: .default)
        let dataTask = defaultSession.dataTask(with: url!) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if(error != nil)
            {
                print("An error happened: first if") // debugging
                print(error!)
                return
            }
            
            do
            {
                print("Price Updated") // this isn't running
                let json = try JSONDecoder().decode(Rates.self, from: data!)
                self.setPrices(currency: json.rates)
            }
            catch
            {
                print("An error happened: catch") // debugging
                print(error)
                return
            }
        }
        dataTask.resume()
    }
    
    
    func setPrices(currency: Currency)
    {
        // when trying to change the view from not the main thread
        //uilabel text must be used from main thread only
        DispatchQueue.main.async
        {
            self.btcPrice.text = self.formatPrice(currency.btc)
            self.ethPrice.text = self.formatPrice(currency.eth)
            self.usdPrice.text = self.formatPrice(currency.usd)
            self.lastUpdatedPrice.text = self.formatDate(date: Date())
        }
        
    }
    
    // Recieve a price and return a string
    func formatPrice(_ price: Price) -> String
    {
        return String(format: "%@ %.4f", price.unit, price.value)
    }
    
    func formatDate(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM y HH:mm:ss"
        return formatter.string(from: date)
    }
    
    struct Rates: Codable
    {
        let rates: Currency
    }
    
    struct Currency: Codable
    {
        let btc: Price
        let eth: Price
        let usd: Price
    }
    
    struct Price: Codable
    {
        let name:  String
        let unit:  String
        let value: Float
        let type:  String
    }
    

}

