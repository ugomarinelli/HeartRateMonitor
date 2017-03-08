//
//  Constants.swift
//  HeartRateMonitor
//
//  Created by UGO MARINELLI on 05/02/2017.
//  Copyright © 2017 UGO MARINELLI. All rights reserved.
//

import Foundation

//Bluetooth Manager
var kHrmUUID = "180D"
var kHrmCharacteristicUUID = "2A37"
var kBatteryCharacteristicUUID = "2A19"

//Bluetooth Status
var kBLEUnsupported = "The hardware doesn't support Bluetooth Low Energy"
var kBLEUnauthorized = "The app is not authorized to use Bluetooth Low Energy"
var kBLEIsOff = "Bluetooth is Off"
var kBLEIsOn = "Bluetooth is Ready"
var kBLEDidFail = "Failed to connect to the device"
var kBLEDidDisconnect = "Disconnected from the device"
var kBLENotConnected = "Not connected"
var kBLEIsConnected = "Connected to device"


//Chart Layout
var kChartGranularity = 1.0
var kChartCircleRadius = 3.0
var kChartLegendBPM = "BPM"


