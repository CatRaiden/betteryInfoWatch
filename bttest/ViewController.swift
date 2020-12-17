//
//  ViewController.swift
//  bttest
//
//  Created by user on 2020/12/16.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    var centralManager = CBCentralManager()
    var peripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        setUp()
    }


    func setUp() {
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func startScan() {
        centralManager.scanForPeripherals(withServices: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            startScan()
        @unknown default:
            print("central.state is .unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else { return }
        if peripheral.name == "MX Master 2S" {
            self.peripheral = peripheral
            centralManager.connect(self.peripheral!)
        }
        print(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices([CBUUID(string: "0x180F")])//Battery 0x180F
    }
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            self.peripheral?.discoverCharacteristics([CBUUID(string: "0x2A19")], for: service)//Battery Level 0x2A19
            print(service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            self.peripheral?.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case CBUUID(string: "0x2A19"):
            //Battery Level 特性的UUID 是0x2A19，類型是uint8，單位是百分比，最小值0，最大值是100，值101~255 為保留。
            //first get value method
            print("Battery level: \(characteristic.value![0])")

            //second method
            let data = characteristic.value!
            var byte:UInt8 = 0
            data.copyBytes(to: &byte, count: 1)
            let valueInInt = Int(byte)
            print(valueInInt)
            
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}

