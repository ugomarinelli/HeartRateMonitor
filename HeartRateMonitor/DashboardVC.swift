//
//  ChartVC.swift
//  HeartRateMonitor
//
//  Created by UGO MARINELLI on 05/02/2017.
//  Copyright © 2017 UGO MARINELLI. All rights reserved.
//

import UIKit
import Charts
import CoreBluetooth

class DashboardVC: UIViewController, DeviceNotificationDelegate {

    //Instantiating variables
    let bluetoothManager = BluetoothManager()
    var bpmValues = [CGFloat]()

    //Instantiating Boutlets
    @IBOutlet var lineChartView: LineChartView!
    @IBOutlet var deviceName: UILabel!
    @IBOutlet var batteryLevel: UILabel!
    @IBOutlet var currentHeartRate: UILabel!
    @IBOutlet var bluetoothStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting the delegate to be notified when the heartRate changes
        bluetoothManager.delegate = self

    }
    
    
    //Every Time we have an heart Rate update
    func heartRateUpdate(newBPM: UInt16, peripheral : CBPeripheral) {
        //We add the new value in our array
        bpmValues.append(CGFloat(newBPM))
        
        //Setting heart Rate Label
        currentHeartRate.text = String(newBPM)
        
        //Setting device Name
        deviceName.text = peripheral.name
        
        //We re-draw the chart
        setChart(dataPoints: bpmValues, values: bpmValues)
    }
    
    //When we have an update of the bluetooth status
    func bleConnexionStatus(status: String) {
        bluetoothStatus.text = status
    }
    
    //Drawing the chart
    func setChart(dataPoints: [CGFloat], values: [CGFloat]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        //Defining axis values
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x:Double(i) , y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        
        //ChartView Layout
        customizeChartView()
        
        //Defining points and Legend
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: kChartLegendBPM)
        
        //Line Color
        lineChartDataSet.setColor(.red)
        //Circle Color
        lineChartDataSet.setCircleColor(.red)
        
        //Circle Radius
        lineChartDataSet.circleRadius = CGFloat(kChartCircleRadius)
        
        //Defining our line with our layout
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        //Removing value label at each points
        lineChartData.setDrawValues(false)
        
        //Defining data with our line
        lineChartView.data = lineChartData
        
    }
    
    //Chart Layout
    func customizeChartView()
    {
        //We want only to have integer on our axis 
        
        //Left Axis
        lineChartView.leftAxis.granularityEnabled = true
        lineChartView.leftAxis.granularity = kChartGranularity
        
        //Right Axis
        lineChartView.rightAxis.granularityEnabled = true
        lineChartView.rightAxis.granularity = kChartGranularity
        
        //X Axis
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = kChartGranularity
    }
    
    //Battery Update
    func batteryLevelUpdate(newBatteryLevel: UInt16) {
        batteryLevel.text = String(newBatteryLevel)
    }
}
