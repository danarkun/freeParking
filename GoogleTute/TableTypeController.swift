//
//  TableTypeController.swift
//  GoogleTute
//
//  Created by Daniel Arkun on 4/03/2016.
//  Copyright © 2016 Daniel Arkun. All rights reserved.
//

import UIKit

class TableTypeController: UITableViewController {
    
    var timeValues = [TimeValue]()
    
    override func viewDidLoad() {
        self.timeValues = [TimeValue(name: "15 Minute Parking"), TimeValue(name: "30 Minute Parking"), TimeValue(name: "1 Hour Parking"), TimeValue(name: "2 Hour Parking"), TimeValue(name: "3 Hour Parking"), TimeValue(name: "5 Hour Parking"), TimeValue(name: "10 Hour Parking:"), TimeValue(name: "Other")]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeValues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        var time : TimeValue
        
        time = timeValues[indexPath.row]
        
        cell.textLabel?.text = time.name
        
        return cell
        
    }
}