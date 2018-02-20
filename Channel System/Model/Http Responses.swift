//
//  Http Responses.swift
//  Channel System
//
//  Created by Warren Hansen on 2/19/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class Process {
    
    class func httpStatus(httpStatus: Int ) {
        print("\nstatus code: \(httpStatus)")
        // process result

        switch httpStatus {
        case 200:
            print("Server: OK – Everything worked as expected\n")
        case 401:
            print("\n------------------------------------------------------------------\n")
            print("Server: Unauthorized – Your User/Password API Keys are incorrect")
            print("\n------------------------------------------------------------------\n")
            Utilities().playErrorSound()
        case 403:
            print("\n------------------------------------------------------------------\n")
            print("Server: You are not subscribed to the data feed requested")
            print("\n------------------------------------------------------------------\n")
            Utilities().playErrorSound()
        case 404:
            print("\n------------------------------------------------------------------\n")
            print("Server: Not Found – The end point requested is not available")
            print("\n------------------------------------------------------------------\n")
            Utilities().playErrorSound()
        case 429:
            print("\n------------------------------------------------------------------\n")
            print("Server: Too Many Requests – You have hit a limit. See Limits")
            print("\n------------------------------------------------------------------\n")
            Utilities().playErrorSound()
        case 500:
            print("\n-------------------------------------------------------------------------------\n")
            print("Server: Internal Server Error – We had a problem with our server. Try again later.")
            print("\n------------------------------------------------------------------------------\n")
            Utilities().playErrorSound()
        case 503:
            print("\n----------------------------------------------------------------------------------------------------------\n")
            print("Server: Service Unavailable – You have hit your throttle limit or Intrinio may be experiencing difficulties.")
            print("\n----------------------------------------------------------------------------------------------------------\n")
            Utilities().playErrorSound()
        default:
            print("\n------------------------------------------------------------------\n")
            print("Server didn't handshake")
            print("\n------------------------------------------------------------------\n")
            Utilities().playErrorSound()
        }
    }
}
