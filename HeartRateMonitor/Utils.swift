//
//  Utils.swift
//  HeartRateMonitor
//
//  Created by UGO MARINELLI on 05/02/2017.
//  Copyright © 2017 UGO MARINELLI. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    //Convert BPM Data into readable value
    class func calculateNewBPM(heartRateData:Data) -> UInt16{
        
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm{
            return actualBpm
            
        }else {
            return bpm!
        }
    }
}
