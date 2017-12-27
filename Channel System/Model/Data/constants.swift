//
//  constants.swift
//  Channel System
//
//  Created by Warren Hansen on 11/24/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation
import UIKit

class Symbols {
    
    let international = ["QQQ", "EFA", "ILF", "EEM", "EPP","IEV"] // 5% stop
    
    let indexes = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV"]
    
    let DOW30 = ["AAPL","AXP","BA","CAT","CSCO","CVX","DD","DIS","GE","GS","HD","IBM","INTC","JNJ","JPM","KO","MCD","MMM","MRK","MSFT","NKE","PFE","PG","TRV","UNH","UTX","V","VZ","WMT","XOM"]
    
    let ETF32 = ["DBA","DBC","DIA","EEB","EEM","EFA","EMB","EPP","EWA","EWJ","EWZ","FXI","GLD","GUR","IEV","ILF","IWM","IYR","MDY","QQQ","SHY","SPY","TLT","XLB","XLE","XLF","XLI","XLK","XLP","XLU","XLV","XLY"]
    
    let ETF200 = ["AGG","BIK","BIL","BIV","BND","BSV","BWX","CIU","CSJ","CVY","DBA","DBB","DBC","DBE","DBO","DBV","DEM","DGL","DGS","DIA","DJP","DLN","DTN","DVY","ECH","EEM","EFA","EFV","EMB","EPP","EWA","EWC","EWD","EWG","EWH","EWI","EWJ","EWL","EWM","EWO","EWP","EWQ","EWS","EWT","EWU","EWW","EWY","EWZ","EZA","EZU","FBT","FDL","FDN","FEZ","FXD","FXE","FXG","FXH","FXI","FXL","FXO","FXR","FXU","FXY","FXZ","GAZ","GDX","GLD","GSG","HYG","IAU","IBB","ICF","IDV","IEF","IEI","IEO","IEV","IEZ","IFN","IGE","IJH","IJJ","IJK","IJR","IJS","IJT","ILF","ITB","IVE","IVV","IVW","IWB","IWC","IWD","IWF","IWM","IWN","IWO","IWP","IWR","IWS","IWV","IXC","IXN","IXP","IYC","IYE","IYF","IYG","IYH","IYJ","IYK","IYM","IYR","IYT","IYT","IYW","IYY","IYZ","JJC","JKD","JKE","JKF","JKH","JKJ","JKK","JKL","JNK","KBE","KCE","KIE","KOL","KRE","LQD","MBB","MDY","MOO","MTK","OEF","OIH","OIL","ONEQ","PBE","PBW","PCY","PDP","PEJ","PEY","PFF","PFM","PGJ","PHB","PHO","PHO","PID","PIE","PPH","PRF","PSP","PVI","PWV","PXH","PXJ","PZA","QQQ","REM","RFG","RFV","RJA","RPG","RPV","RSP","RSX","RTH","RWX","RZV","SCZ","SDY","SHM","SHV","SHY","SLV","SMH","SOXX","SPY","TFI","TIP","TLT","UNG","USO","UUP","VAW","VB","VBK","VBR","VCR","VDC","VDE","VEA","VEU","VFH","VGK","VGT","VHT","VIG","VIS","VNQ","VO","VOT","VOX","VPL","VPL","VPU","VTI","VTV","VUG","VV","VWO"] //,"VXF","VXF","VYM","XBI","XES","XHB","XLB","XLE","XLF","XLG","XLI","XLK","XLP","XLU","XLV","XLY","XME","XOP","XOP","XPH","XRT","XSD"]
}

class SymbolLists {
    
    let allSymbols = Symbols().indexes + Symbols().DOW30 + Symbols().ETF200
    
    func uniqueElementsFrom(testTenOnly: Bool) -> [String] {
        var set = Set<String>()
        let result = allSymbols.filter {
            guard !set.contains($0) else {
                return false
            }
            set.insert($0)
            return true
        }
        if ( testTenOnly ) {
            return Array(result.prefix(10))
        } else {
            return result
        }
        
    }
}

class UIColorScheme {
    let darkTitle = #colorLiteral(red: 0.1239131168, green: 0.1334807277, blue: 0.1463290155, alpha: 1)
    let activeCell = #colorLiteral(red: 0.3233767748, green: 0.3370164633, blue: 0.388761431, alpha: 1)
    let inactiveCell = #colorLiteral(red: 0.189868629, green: 0.2039808333, blue: 0.2340657711, alpha: 1)
    let alertCell = #colorLiteral(red: 0.2384223342, green: 0.6748339534, blue: 0.9696156383, alpha: 1)
}
