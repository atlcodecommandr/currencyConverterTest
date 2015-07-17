//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by gabriel arronte on 7/16/15.
//  Copyright (c) 2015 Make and Build. All rights reserved.
//

import UIKit
import Foundation

public class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet var valuetoConvert: UITextField!
    @IBOutlet var fromTextField: UITextField!
    @IBOutlet var toTextField: UITextField!
    @IBOutlet var convertButton: UIButton!
    @IBOutlet var convertedValue: UILabel!
    @IBOutlet var countryLabel: UILabel!

    var currencyNames:NSMutableArray = []


    override public func viewDidLoad() {
        super.viewDidLoad()
        var currencyPicker = UIPickerView()
        var newcurrencyPicker = UIPickerView()

        currencyPicker.delegate = self
        currencyPicker.tag = 1
        newcurrencyPicker.delegate = self
        newcurrencyPicker.tag = 2
        self.valuetoConvert.delegate = self

        fromTextField.inputView = currencyPicker
        toTextField.inputView = newcurrencyPicker


        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        var items = [AnyObject]()
        //making done button
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "donePressed")
        items.append(doneButton)
        toolbar.barStyle = UIBarStyle.Black
        toolbar.setItems(items, animated: true)

        fromTextField.inputAccessoryView = toolbar
        toTextField.inputAccessoryView = toolbar
    }

    func donePressed() {
        fromTextField.resignFirstResponder()
        toTextField.resignFirstResponder()
    }

    override public func viewWillAppear(animated: Bool) {
        makeHTTPGetRequest(""){
            (data, error) -> Void in

            let that = self
            if (error == nil){
                let obj =  data!.valueForKey("rates") as! NSDictionary
                for (key, value) in obj{
                    self.currencyNames.addObject(key as! String)
                }

            } else {
                println(error)
            }
        }
    }

   override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




    func makeHTTPGetRequest(countryCode: String, callback: ((NSDictionary?, NSString?) -> ())){
        var url = "http://api.fixer.io/latest"
        if countryCode != "" {
            url = url + "?base=" + countryCode
        }

        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()

        var task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in

            if error != nil {
                callback(nil, "Error Getting Currency Info")
            } else {
                if let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:nil) as? NSDictionary {
                    callback(dict, nil)
                } else {
                     callback(nil, "Error Getting Currency Info")
                }
            }
        }
        task.resume()
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.currencyNames.count
    }
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.currencyNames[row] as! String
    }
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            fromTextField.text = self.currencyNames[row] as! String
        } else{
            toTextField.text = self.currencyNames[row] as! String
        }

    }


    @IBAction func convertClicked(sender: AnyObject) {
        if (self.valuetoConvert.text != ""){
        println(self.toTextField.text)
         self.valuetoConvert.resignFirstResponder()

        makeHTTPGetRequest(self.fromTextField.text){
            (data, error) -> Void in

            let that = self
            if (error == nil){
                let obj =  data!.valueForKey("rates") as! NSDictionary
                let currencyIndex = obj.valueForKey(self.toTextField.text) as? Double
                 println("Currency Index: %.2f", currencyIndex)
                let newValue = (self.valuetoConvert.text as NSString).doubleValue

                dispatch_async(dispatch_get_main_queue()) {
                   self.convertedValue.text = String(format:"%.2f", (newValue * currencyIndex!))
                    self.countryLabel.text = self.toTextField.text
                    NSNotificationCenter.defaultCenter().postNotificationName("currencyCalculated", object:nil)

                }

            } else {
                println(error)
            }
        }
    } else {
            let alert = UIAlertController(title: "Error", message:
                "Please enter value to convert", preferredStyle: UIAlertControllerStyle.Alert)

            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))

            self.presentViewController(alert, animated: true, completion: nil)
    }
    }

}



