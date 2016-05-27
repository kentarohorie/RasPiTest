//
//  ViewController.swift
//  RasPiTest
//
//  Created by 堀江健太朗 on 2016/05/24.
//  Copyright © 2016年 kentaro. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var lightCharacteristic: CBCharacteristic?
    
    var connectButton = UIButton()
    let btn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        setSearchBtn()
        setConnectBtn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("state: \(central.state)")
    }
    
    private func setSearchBtn() {
        btn.setTitle("search", forState: .Normal)
        btn.sizeToFit()
        btn.center = view.center
        btn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        btn.addTarget(self, action: #selector(ViewController.didTapSearchButton), forControlEvents: .TouchUpInside)
        view.addSubview(btn)
    }
    
    private func setConnectBtn() {
        connectButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        connectButton.setTitle("no devise", forState: .Normal)
        connectButton.sizeToFit()
        connectButton.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        connectButton.addTarget(self, action: #selector(ViewController.didTapConnectButton), forControlEvents: .TouchUpInside)
        view.addSubview(connectButton)
    }
    
    private func setOnOffButton() {
        let onButton = UIButton()
        onButton.setTitle("On", forState: .Normal)
        onButton.setTitle("Off", forState: .Selected)
        onButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        onButton.setTitleColor(UIColor.redColor(), forState: .Selected)
        onButton.sizeToFit()
        onButton.center = CGPoint(x: view.center.x, y: view.center.y + 100)
        onButton.addTarget(self, action: #selector(ViewController.didSelectOnOffButton(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(onButton)
    }
    
    func didTapSearchButton() {
        btn.setTitle("searching...", forState: .Normal)
        btn.sizeToFit()
        btn.center = view.center
        
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func didTapConnectButton() {
        centralManager.connectPeripheral(self.peripheral, options: nil)
    }
    
    func didSelectOnOffButton(sender: UIButton) {
        if sender.selected == false {
            print("write characteristic and on")
            var value: CUnsignedInt = 1
            let data: NSData = NSData(bytes: &value, length: 1)
            peripheral.writeValue(data, forCharacteristic: lightCharacteristic!, type: .WithResponse)
            sender.selected = true
        } else {
            print("write characteristic and off")
            var value: CUnsignedInt = 0
            let data: NSData = NSData(bytes: &value, length: 1)
            peripheral.writeValue(data, forCharacteristic: lightCharacteristic!, type: .WithResponse)
            sender.selected = false
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("peripheral: \(peripheral.name)")
        guard let pName = peripheral.name else {
            return
        }
        if pName == "led service" {
            btn.setTitle("complete search", forState: .Normal)
            btn.setTitleColor(UIColor.greenColor(), forState: .Normal)
            btn.sizeToFit()
            btn.center = view.center
            centralManager.stopScan()
            
            print("connecting...")
            self.peripheral = peripheral
            
            connectButton.setTitle("connect to \(peripheral.name!)", forState: .Normal)
            connectButton.sizeToFit()
            connectButton.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connected")
        connectButton.setTitle("complete connect", forState: .Normal)
        connectButton.setTitleColor(UIColor.greenColor(), forState: .Normal)
        connectButton.sizeToFit()
        connectButton.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("fail connect")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let services = peripheral.services
        print("Found \(services?.count) services: \(services)")
        
        for service in services! {
            print(service.UUID)
            if String(service.UUID) == "FF10" {
                print("discovering characteristics")
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let error = error {
            print("error in dicovercharc: \(error)")
        }
        
        let characteristics = service.characteristics
        print("Found \(characteristics!.count) characteristics! : \(characteristics)")
        for characteristic in characteristics! {
            if String(characteristic.UUID) == "FF11" {
                setOnOffButton()
                self.lightCharacteristic = characteristic
            }
        }
    }


}

