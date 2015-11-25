//
//  ViewController.swift
//  Gehaltsrechner
//
//  Created by Lars Häuser on 15.10.15.
//  Copyright © 2015 Lars Häuser. All rights reserved.
//

import Cocoa
import SWXMLHash

class BaseController: NSViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


class LohnsteuerViewController: BaseController {
    
    /*Subview Lohnstsuer*/
    @IBOutlet weak var steuerklasseSelectbox: NSPopUpButton!
    @IBOutlet weak var birthdaySelectbox: NSPopUpButton!
    @IBOutlet weak var kinderfreibetragSelectbox: NSPopUpButton!
    
    @IBAction func steuerklasseAction(sender: NSPopUpButton) {
        defaults.setObject(sender.selectedItem!.title, forKey: "steuerklasseSelectbox")
    }
    @IBAction func birthdayAction(sender: NSPopUpButton) {
        defaults.setObject(sender.selectedItem!.title, forKey: "birthdaySelectbox")
    }
    @IBAction func kinderfreibetragAction(sender: NSPopUpButton) {
        defaults.setObject(sender.selectedItem!.title, forKey: "kinderfreibetragSelectbox")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.steuerklasseSelectbox.addItemsWithTitles(
            ["I","II","III","IV","V","VI",])
        
        if (defaults.objectForKey("steuerklasseSelectbox") != nil) {
            self.steuerklasseSelectbox.setTitle(defaults.objectForKey("steuerklasseSelectbox") as! String)
        }
        
        let calendar = NSCalendar.currentCalendar()
        let year = calendar.component(.Year,fromDate: NSDate())
        for var i=1940; i<year; ++i {
            self.birthdaySelectbox.addItemsWithTitles(
                ["\(i)"])
        }
        if (defaults.objectForKey("birthdaySelectbox") != nil) {
            self.birthdaySelectbox.setTitle(defaults.objectForKey("birthdaySelectbox") as! String)
        }
        
        self.kinderfreibetragSelectbox.addItemsWithTitles(["0"])
        for var i=0; i<20; ++i {
            let value = Double(i)/2 + 0.5
            self.kinderfreibetragSelectbox.addItemsWithTitles(["\(value)"])
        }
        if (defaults.objectForKey("kinderfreibetragSelectbox") != nil) {
            self.kinderfreibetragSelectbox.setTitle(defaults.objectForKey("kinderfreibetragSelectbox") as! String)
        }
    }

}

class ViewController: BaseController {
    
    @IBOutlet weak var lohnsteuerField: NSTextField!
    @IBOutlet weak var bruttoeinkommenField: NSTextField!
    @IBOutlet weak var soliField: NSTextField!
    @IBOutlet weak var nettoeinkommenField: NSTextField!
    

    @IBOutlet weak var selectYear: NSPopUpButton!
    @IBOutlet weak var pvField: NSTextField!
    @IBOutlet weak var rvField: NSTextField!
    @IBOutlet weak var avField: NSTextField!
    @IBOutlet weak var kvField: NSTextField!

    @IBAction func changePopup(sender:AnyObject) { calculateNetto() }
    @IBAction func enterBrutto(sender: AnyObject) { calculateNetto()}
    @IBAction func calculateButton(sender: NSButton) {calculateNetto()}
    
//    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "segueTest") {
//            var svc = segue.destinationViewController as LohnsteuerViewController;
//            svc.toPass = textField.text
//    }
    
    let sv_beitraege = [
        "ab 12/2015": ["url": "2015Dez", "kv": 0.082, "pv": 0.01725, "rv": 0.0935, "av": 0.015],
        "bis 11/2015": ["url": "2015bisNov","kv": 0.082, "pv": 0.01725, "rv": 0.0935, "av": 0.015],
        "2014": ["url": "2014","kv": 0.082, "pv": 0.01025, "rv": 0.0945, "av": 0.015]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        // Do any additional setup after loading the view.
        self.selectYear.removeAllItems()
        for (year, values) in sv_beitraege {
            print("\(year)")
            self.selectYear.addItemsWithTitles(["\(year)"])
        }
        
    }
    
    func calculateNetto()
    {
        let url_year = self.sv_beitraege[(self.selectYear.selectedItem?.title)!]!["url"]!
        let bruttoeinkommen = self.bruttoeinkommenField.floatValue
        let url = NSURL(string: "https://www.bmf-steuerrechner.de/interface/\(url_year).jsp?LZZ=2&RE4=\(Int(bruttoeinkommen*100))&STKL=1")
        //print(url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            let xml = SWXMLHash.parse(data!)
            do {
                // fill up lohnstsuer field
                let lohnsteuer = Float((try xml["lohnsteuer"]["ausgaben"]["ausgabe"].withAttr("name", "LSTLZZ").element?.attributes["value"])!)! / 100.00
                self.lohnsteuerField.floatValue = lohnsteuer
                // fill up soli field
                let soli = Float((try xml["lohnsteuer"]["ausgaben"]["ausgabe"].withAttr("name", "SOLZLZZ").element?.attributes["value"])!)! / 100.00
                self.soliField.floatValue = soli
                
                // Berechnung SV Beiträge
                let beitrag = self.sv_beitraege[(self.selectYear.selectedItem?.title)!]
                let kv = bruttoeinkommen * (beitrag!["kv"] as! Float)
                self.kvField.floatValue = kv
                let pv = bruttoeinkommen * (beitrag!["pv"] as! Float)
                self.pvField.floatValue = pv
                let rv = bruttoeinkommen * (beitrag!["rv"] as! Float)
                self.rvField.floatValue = rv
                let av =  bruttoeinkommen * (beitrag!["av"] as! Float)
                self.avField.floatValue = av
                //gesamt netto berechnen
                self.nettoeinkommenField.floatValue =
                    self.bruttoeinkommenField.floatValue - lohnsteuer - soli - kv - pv - av - rv

            } catch {
                // error is an XMLIndexer.Error instance that you can deal with
                print(error)
            }
        }
        task.resume()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
//    override func awakeFromNib() {
//        if self.view.layer != nil {
//            let color : CGColorRef = CGColorCreateGenericRGB(1, 0.5, 1, 0.5)
//            self.view.layer?.backgroundColor = color
//        }
//        
//    }


}

