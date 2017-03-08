//
//  BluetoothManager.swift
//  HeartRateMonitor
//
//  Created by UGO MARINELLI on 04/02/2017.
//  Copyright © 2017 UGO MARINELLI. All rights reserved.
//

import Foundation
import CoreBluetooth


//Protocol declaration
protocol DeviceNotificationDelegate{
    func bleConnexionStatus(status : String)
    func batteryLevelUpdate(newBatteryLevel : UInt16)
    func heartRateUpdate(newBPM : UInt16, peripheral : CBPeripheral)
}


public class BluetoothManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //Variables instantiation
    var manager:CBCentralManager!
    var peripheralDiscovered:CBPeripheral!
    var delegate : DeviceNotificationDelegate?
    var bluetoothState = String()
    let hrmUUID = CBUUID.init( string:kHrmUUID )


    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    //MARK: CBCentralManagerDelegate metho
    //Checking Bluetooth status
    public func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        //By Default we are not connected
        bluetoothState = kBLENotConnected

        switch central.state{
        
        //If Bluetooth is not authorized
        case .unauthorized:
            print("Low energy is not authorized on this app")
            bluetoothState = kBLEUnauthorized
    
        //If Bluetooth is off
        case .poweredOff:
            print("Bluetooth Off")
            bluetoothState = kBLEIsOff

        //If Bluetooth is on
        case .poweredOn:
            print("Bluetooth is ready")
            bluetoothState = kBLEIsOn

            //Start looking for hrm
            central.scanForPeripherals(withServices: [hrmUUID] , options: nil)
            
        default:break
        }
        //Informing our VC about connexion status
        delegate?.bleConnexionStatus(status: bluetoothState)
    }
    
    
    //When we find an heart rate monitor
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        //We automatically connect to it
        central.connect(peripheral, options: nil)
        
        //We set our variable with the device we connect with (to reuse it afterward)
        self.peripheralDiscovered = peripheral
     
        // We stop the scanning to save battery
        central.stopScan()
    }
    
    
     //Once we are connected to the device
     public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
     {
        //Setting the Bluetooth state to connected
        bluetoothState = kBLEIsConnected
        
        //Informing our VC about connexion status
        delegate?.bleConnexionStatus(status: bluetoothState)
        
        // Device name
        print("PERIPHERAL NAME: \(peripheral.name)\n")
        
        //Setting delegates, to get callbacks
        peripheral.delegate = self
        
        //Start looking for the services our devices can provide us
        peripheral.discoverServices(nil)
    }
    
    //Fail to connect the device
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    {
        //Setting the Bluetooth state
        bluetoothState = kBLEDidFail
        
        //Informing our VC about connexion status
        delegate?.bleConnexionStatus(status: bluetoothState)
        
        //If we lose the connection , we want it back :)
        central.scanForPeripherals(withServices: [hrmUUID])
    }
    
    
    //Did Disconnect 
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        //Setting the Bluetooth state
        bluetoothState = kBLEDidDisconnect
        
        //Informing our VC about connexion status
        delegate?.bleConnexionStatus(status: bluetoothState)
        
        //If we lose the connection , we want it back :)
        central.scanForPeripherals(withServices: [hrmUUID])
    }
    
  
    //MARK: CBPeripheralDelegate method

    //Once we get the services provided by the device
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        //We first check if everything went well
        if error != nil {
            print(error!)
        }
        else {
            //We look deeper in the services provided by the device
            for service in peripheral.services as [CBService]!{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        //We first check if everything went well
        if error != nil{
            print(error!)
        }
        else {
            //We want to be notified when the heart rate changes
            if service.uuid == CBUUID(string: kHrmUUID){
                for characteristic in service.characteristics! as [CBCharacteristic]{
                    
                    //We check the characteristic
                    switch characteristic.uuid.uuidString{

                    //If the characteristic is heartRate
                    case kHrmCharacteristicUUID:
                        // Set notification to be alerted when there is a change on the hear rate
                        print("Found a Heart Rate Measurement Characteristic")
                        peripheral.setNotifyValue(true, for: characteristic)
                    
                    //If the characteristic is Battery
                    case kBatteryCharacteristicUUID:
                        print("Found a Battery Measurement Characteristic")
                        peripheral.readValue(for: characteristic)
                        peripheral.setNotifyValue(true, for: characteristic)
                    default:break
                    }
                }
            }
        }
    }
    
    //When the BPM changes
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        //We first check if everything went well
        if error != nil{
            print(error!)
        }else {
            //Check if the changes comes from the BPM
            switch characteristic.uuid.uuidString {
            case kHrmCharacteristicUUID:
                //We convert our new Data into readable BPM value
                let newBPM = Utils.calculateNewBPM(heartRateData:characteristic.value!)
                
                delegate?.heartRateUpdate(newBPM: newBPM, peripheral : peripheral)
                
            case kBatteryCharacteristicUUID:
                //Getting the Battery Value
                print("Battery Level : \(characteristic.value![0])")
            default:break
            }
        }
    }
    
}
