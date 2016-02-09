//
//  ParseViewController.swift
//  Pods
//
//  Created by Daniel Arkun on 4/02/2016.
//
//

import UIKit

class ParseViewController: UIViewController {
    @IBOutlet weak var parseText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Start viewDidLoad")
    }
    
    func returnParse() -> (lat: String, long: String)    {
        let url = NSURL(string: "https://dl.dropboxusercontent.com/u/50133881/CSV/coords.csv")
        let error = NSErrorPointer()
        let firstRow = parseCSV(url!, encoding: NSUTF8StringEncoding, error: error)
        let firstCoord = firstRow.first
        //  let lastCoord = firstRow.last
        return firstCoord!
    }
    
    // Parsing
    func parseCSV (contentsOfURL: NSURL, encoding: NSStringEncoding, error: NSErrorPointer) -> [(lat:String, long:String)] {
        // Load the CSV file and parse it
        let delimiter = ","
        var coords:[(lat: String, long: String)]?
        if let data = NSData(contentsOfURL: contentsOfURL){
            if let content = NSString(data: data, encoding: NSUTF8StringEncoding) {
                coords = []
                let lines:[String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]
                
                for line in lines {
                    var values:[String] = []
                    if line != "" {
                        // For a line with double quotes
                        // we use NSScanner to perform the parsing
                        if line.rangeOfString("\"") != nil {
                            var textToScan:String = line
                            var value:NSString?
                            var textScanner:NSScanner = NSScanner(string: textToScan)
                            while textScanner.string != "" {
                                
                                if (textScanner.string as NSString).substringToIndex(1) == "\"" {
                                    textScanner.scanLocation += 1
                                    textScanner.scanUpToString("\"", intoString: &value)
                                    textScanner.scanLocation += 1
                                } else {
                                    textScanner.scanUpToString(delimiter, intoString: &value)
                                }
                                
                                // Store the value into the values array
                                values.append(value as! String)
                                
                                // Retrieve the unscanned remainder of the string
                                if textScanner.scanLocation < textScanner.string.characters.count {
                                    textToScan = (textScanner.string as NSString).substringFromIndex(textScanner.scanLocation + 1)
                                } else {
                                    textToScan = ""
                                }
                                textScanner = NSScanner(string: textToScan)
                            }
                            
                            // For a line without double quotes, we can simply separate the string
                            // by using the delimiter (e.g. comma)
                        } else  {
                            values = line.componentsSeparatedByString(delimiter)
                        }
                        
                        // Put the values into the tuple and add it to the peoples array
                        let coord = (lat: values[0], long: values[1])
                        coords?.append(coord)
                    }
                    
                }
            }
        }

        return coords!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
