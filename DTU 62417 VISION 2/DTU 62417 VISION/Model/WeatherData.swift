//
//  WeatherData.swift
//  DTU 62417 VISION
//
//  Created by Arif Yildirim on 06/12/2019.
//  Copyright © 2019 Arif Yildirim. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
