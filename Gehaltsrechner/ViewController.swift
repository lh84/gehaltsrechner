//
//  ViewController.swift
//  Gehaltsrechner
//
//  Created by Lars Häuser on 15.10.15.
//  Copyright © 2015 Lars Häuser. All rights reserved.
//

import Cocoa
import SWXMLHash

class LohnsteuerViewController: NSViewController {
    
    /*Subview Lohnstsuer*/
    @IBOutlet weak var steuerklasseSelectbox: NSPopUpButton!
    @IBOutlet weak var birthdaySelectbox: NSPopUpButton!
    @IBOutlet weak var kinderfreibetragSelectbox: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.steuerklasseSelectbox.addItemsWithTitles(
            ["I","II","III","IV","V","VI",])
        self.birthdaySelectbox.addItemsWithTitles(
            ["I","II","III","IV","V","VI",])
        
        self.kinderfreibetragSelectbox.addItemsWithTitles(["0"])
        for var i=0; i<10; ++i {
            self.kinderfreibetragSelectbox.addItemsWithTitles(["\(Double(i) + 0.5)"])
        }
    }

}

class ViewController: NSViewController {
    
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
        
        print(url)
        
        
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
                
                // Berechnung KV 2015 (8,2%)
                print(self.sv_beitraege["ab 12/2015"]!["kv"])
                let kv = bruttoeinkommen * 0.082
                self.kvField.floatValue = kv
                // Berechnung PV 2015 (1,425%)
                let pv = bruttoeinkommen * 0.01725
                self.pvField.floatValue = pv
                // Berechnung RV 2015 (9,35%)
                let rv = bruttoeinkommen * 0.0935
                self.rvField.floatValue = rv
                // Berechnung AV 2015 (1,5%)
                let av =  bruttoeinkommen * 0.015
                self.avField.floatValue = av
                
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
    
    override func awakeFromNib() {
        print("awake")
        if self.view.layer != nil {
            let color : CGColorRef = CGColorCreateGenericRGB(0, 0, 0, 0.5)
            self.view.layer?.backgroundColor = color
        }
        
    }


}

