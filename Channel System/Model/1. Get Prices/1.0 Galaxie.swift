//
//  1.0 Galaxie.swift
//  Channel System
//
//  Created by Warren Hansen on 12/30/17.
//  Copyright © 2017 Warren Hansen. All rights reserved.
//

import Foundation

class Symbols {
    
    let international = ["QQQ", "EFA", "ILF", "EEM", "EPP","IEV"] // 5% stop
    
    let indexes = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV"]
    
    let DOW30 = ["AAPL","AXP","BA","CAT","CSCO","CVX","DIS","GE","GS","HD","IBM","INTC","JNJ","JPM","KO","MCD","MMM","MRK","MSFT","NKE","PFE","PG","TRV","UNH","UTX","V","VZ","WMT","XOM"] // DD removed, became DWDP ut only has data from 9/1/2017
    
    let ETF32 = ["DBA","DBC","DIA","EEB","EEM","EFA","EMB","EPP","EWA","EWJ","EWZ","FXI","GLD","GUR","IEV","ILF","IWM","IYR","MDY","QQQ","SHY","SPY","TLT","XLB","XLE","XLF","XLI","XLK","XLP","XLU","XLV","XLY"]
    
    let ETF200 = ["AGG","BIK","BIL","BIV","BND","BSV","BWX","CIU","CSJ","CVY","DBA","DBB","DBC","DBE","DBO","DBV","DEM","DGL","DGS","DIA","DJP","DLN","DTN","DVY","ECH","EEM","EFA","EFV","EMB","EPP","EWA","EWC","EWD","EWG","EWH","EWI","EWJ","EWL","EWM","EWO","EWP","EWQ","EWS","EWT","EWU","EWW","EWY","EWZ","EZA","EZU","FBT","FDL","FDN","FEZ","FXD","FXE","FXG","FXH","FXI","FXL","FXO","FXR","FXU","FXY","FXZ","GAZ","GDX","GLD","GSG","HYG","IAU","IBB","ICF","IDV","IEF","IEI","IEO","IEV","IEZ","IFN","IGE","IJH","IJJ","IJK","IJR","IJS","IJT","ILF","ITB","IVE","IVV","IVW","IWB","IWC","IWD","IWF","IWM","IWN","IWO","IWP","IWR","IWS","IWV","IXC","IXN","IXP","IYC","IYE","IYF","IYG","IYH","IYJ","IYK","IYM","IYR","IYT","IYT","IYW","IYY","IYZ","JJC","JKD","JKE","JKF","JKH","JKJ","JKK","JKL","JNK","KBE","KCE","KIE","KOL","KRE","LQD","MBB","MDY","MOO","OEF","OIH","OIL","ONEQ","PBE","PBW","PCY","PDP","PEJ","PEY","PFF","PFM","PGJ","PHB","PHO","PHO","PID","PIE","PPH","PRF","PSP","PWV","PXH","PXJ","PZA","QQQ","REM","RFG","RFV","RJA","RPG","RPV","RSP","RSX","RTH","RWX","RZV","SCZ","SDY","SHM","SHV","SHY","SLV","SMH","SOXX","SPY","TFI","TIP","TLT","UNG","USO","UUP","VAW","VB","VBK","VBR","VCR","VDC","VDE","VEA","VEU","VFH","VGK","VGT","VHT","VIG","VIS","VNQ","VO","VOT","VOX","VPL","VPL","VPU","VTI","VTV","VUG","VV","VWO","VXF","VYM","XBI","XES","XHB","XLB","XLE","XLF","XLG","XLI","XLK","XLP","XLU","XLV","XLY","XME","XOP","XPH","XRT","XSD"] // removed becuase intrio access denied ,"PVI" removed because it trades like an algo, MTK "You do not have sufficient access to view this data"
    let FAVORITES = ["XIV","CLF", "TSLA"]
    
    let SP500 = ["ABT", "ABBV", "ACN", "ADBE", "AAP", "AES", "AET", "AFL", "AMG", "A", "GAS", "APD", "AKAM", "AA", "AGN", "ALXN", "ADS", "ALL", "MO", "AMZN", "AEE", "AAL", "AEP", "AXP", "AIG", "AMT", "AMP", "ABC", "AME", "AMGN", "APH", "APC", "ADI", "AON", "APA", "AIV", "AMAT", "ADM", "AIZ", "T", "ADSK", "ADP", "AN", "AZO", "AVGO", "AVB", "AVY", "BHI", "BLL", "BAC", "BK", "BCR",  "BAX", "BBT", "BDX", "BBBY", "BBY", "BLX","HRB","BA", "BWA", "BXP", "BMY", "BRCM", "CHRW", "CA", "COG" , "CAM", "CPB", "COF", "CAH","HSIC", "KMX", "CCL", "CAT", "CBG", "CBS", "CELG", "CNP", "CTL", "CERN", "CF", "SCHW", "CHK", "CVX", "CMG", "CB", "CI", "XEC", "CINF", "CTAS", "CSCO", "C", "CTXS", "CLX", "CME", "CMS", "COH", "KO", "CCE", "CTSH", "CL", "CMCSA", "CMA", "CSC", "CAG", "COP", "CNX", "ED", "STZ", "CNX", "ED", "STZ", "GLW", "COST", "CCI", "CSX", "CMI", "CVS", "DHI", "DHR", "DRI", "DVA", "DE", "DLPH", "DAL", "XRAY", "DVN", "DO", "DFS", "DISCA", "DISCK", "DG", "DLTR", "D", "DOV", "DOW", "DPS", "DTE", "DD", "DUK", "DNB", "ETFC", "EMN", "ETN", "EBAY", "ECL", "EIX", "EW", "EA", "EMC", "EMR", "ENDP", "ESV", "ETR", "EOG", "EQT", "EFX", "EQIX", "EQR", "ESS", "EL", "ES", "EXC", "EXPE", "EXPD", "ESRX", "XOM", "FFIV", "FB", "FAST", "FDX", "FIS", "FITB", "FSLR", "FE", "FLIR", "FLS", "FLR", "FMC", "FTI", "F", "FOSL", "BEN", "FCX", "FTR", "GME", "GPS", "GRMN", "GD", "GE", "GGP", "GIS", "GM", "GPC", "GNW", "GILD", "GS", "GT", "GOOGL", "GOOG", "GWW", "HAL", "HBI", "HOG","HRS", "HIG", "HAS", "HCA", "HCP", "HCN", "HP", "HES", "HPQ", "HD", "HON", "HRL",  "HST", "HUM", "HBAN", "ITW", "IR", "INTC", "ICE", "IBM", "IP", "IPG", "IFF", "INTU", "ISRG", "IVZ", "IRM", "JEC", "JBHT", "JNJ", "JPM", "JNPR", "KSU", "K", "KEY", "KMB", "KIM","KMI", "KLAC", "KSS", "KR", "LB", "LLL", "LH", "LRCX", "LM", "LEG", "LEN", "LVLT", "LUK", "LLY", "LNC", "LMT", "L", "LOW", "LYB", "MTB", "MAC", "M", "MNK", "MRO", "MPC", "MAR", "MMC","MLM", "MAS", "MA", "MAT", "MKC", "MCD", "MCK", "MJN", "MMV", "MDT", "MRK", "MET", "KORS", "MCHP", "MU", "MSFT", "MHK", "TAP", "MDLZ", "MON", "MNST", "MCO", "MS", "MOS", "MSI", "MUR", "MYL", "NDAQ", "NOV", "NTAP", "NFLX", "NWL", "NFX", "NEM", "NWSA", "NEE", "NLSN", "NKE", "NI", "NE", "NBL", "JWN", "NSC", "NTRS", "NOC", "NRG", "NUE", "NVDA", "ORLY", "OXY", "OMC", "OKE", "ORCL", "OI", "PCAR", "PH", "PDCO", "PAYX", "PNR", "PBCT", "PEP", "PKI", "PRGO", "PFE", "PCG", "PM", "PSX", "PNW", "PXD", "PBI", "PNC", "RL", "PPG", "PPL", "PX",  "PCLN", "PFG", "PG", "PGR", "PLD", "PRU", "PEG", "PSA", "PHM", "PVH", "PWR", "QCOM", "DGX", "RRC", "RTN", "O", "RHT", "REGN", "RF", "RSG", "RAI", "RHI", "ROK", "COL", "ROP", "ROST", "R", "CRM", "SCG", "SLB", "SNI", "STX", "SEE", "SRE", "SHW", "SPG", "SWKS", "SLG", "SJM", "SNA", "SO", "LUV", "SWN", "SE",  "SWK", "SPLS", "SBUX", "STT", "SRCL", "SYK", "STI", "SYMC", "SYY", "TROW", "TGT", "TEL", "TGNA", "THC", "TDC", "TSO", "TXN", "TXT", "HSY", "TRV", "TMO", "TIF", "TWX", "TMK", "TSS", "TSCO", "RIG", "TRIP", "FOXA", "TSN", "UA", "UNP", "UNH", "UPS", "URI", "UTX", "UHS", "UNM", "URBN", "VFC", "VLO", "VAR", "VTR", "VRSN", "VZ", "VRTX", "VIAB", "V", "VNO", "VMC", "WMT", "WBA", "DIS", "WM", "WAT", "ANTM", "WFC", "WDC", "WU", "WY", "WHR", "WFM", "WMB", "WEC", "WYN", "WYNN", "XEL", "XRX", "XLNX", "XL", "XYL", "YHOO", "YUM", "ZBH", "ZION", "ZTS"] // "BRK-B" was nil, "BXLT" not enough data,  "BSK" no data, no data "BF-B", "FSIV" , "KRFT" RLC TJK no data, QRVO missing data
    
    //let Winners = []
    
    //let Loosers = []
    
    let AllNonDuplicated = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV", "AAPL", "AXP", "BA", "CAT", "CSCO", "CVX", "DIS", "GE", "GS", "HD", "IBM", "INTC", "JNJ", "JPM", "KO", "MCD", "MMM", "MRK", "MSFT", "NKE", "PFE", "PG", "TRV", "UNH", "UTX", "V", "VZ", "WMT", "XOM", "AGG", "BIK", "BIL", "BIV", "BND", "BSV", "BWX", "CIU", "CSJ", "CVY", "DBA", "DBB", "DBC", "DBE", "DBO", "DBV", "DEM", "DGL", "DGS", "DJP", "DLN", "DTN", "DVY", "ECH", "EFV", "EMB", "EWA", "EWC", "EWD", "EWG", "EWH", "EWI", "EWJ", "EWL", "EWM", "EWO", "EWP", "EWQ", "EWS", "EWT", "EWU", "EWW", "EWY", "EWZ", "EZA", "EZU", "FBT", "FDL", "FDN", "FEZ", "FXD", "FXE", "FXG", "FXH", "FXI", "FXL", "FXO", "FXR", "FXU", "FXY", "FXZ", "GAZ", "GDX", "GLD", "GSG", "HYG", "IAU", "IBB", "ICF", "IDV", "IEF", "IEI", "IEO", "IEZ", "IFN", "IGE", "IJH", "IJJ", "IJK", "IJR", "IJS", "IJT", "ITB", "IVE", "IVV", "IVW", "IWB", "IWC", "IWD", "IWF", "IWN", "IWO", "IWP", "IWR", "IWS", "IWV", "IXC", "IXN", "IXP", "IYC", "IYE", "IYF", "IYG", "IYH", "IYJ", "IYK", "IYM", "IYR", "IYT", "IYW", "IYY", "IYZ", "JJC", "JKD", "JKE", "JKF", "JKH", "JKJ", "JKK", "JKL", "JNK", "KBE", "KCE", "KIE", "KOL", "KRE", "LQD", "MBB", "MOO", "OEF", "OIH", "OIL", "ONEQ", "PBE", "PBW", "PCY", "PDP", "PEJ", "PEY", "PFF", "PFM", "PGJ", "PHB", "PHO", "PID", "PIE", "PPH", "PRF", "PSP", "PWV", "PXH", "PXJ", "PZA", "REM", "RFG", "RFV", "RJA", "RPG", "RPV", "RSP", "RSX", "RTH", "RWX", "RZV", "SCZ", "SDY", "SHM", "SHV", "SHY", "SLV", "SMH", "SOXX", "TFI", "TIP", "TLT", "UNG", "USO", "UUP", "VAW", "VB", "VBK", "VBR", "VCR", "VDC", "VDE", "VEA", "VEU", "VFH", "VGK", "VGT", "VHT", "VIG", "VIS", "VNQ", "VO", "VOT", "VOX", "VPL", "VPU", "VTI", "VTV", "VUG", "VV", "VWO", "VXF", "VYM", "XBI", "XES", "XHB", "XLB", "XLE", "XLF", "XLG", "XLI", "XLK", "XLP", "XLU", "XLV", "XLY", "XME", "XOP", "XPH", "XRT", "XSD", "ABT", "ABBV", "ACN", "ADBE", "AAP", "AES", "AET", "AFL", "AMG", "A", "GAS", "APD", "AKAM", "AA", "AGN", "ALXN", "ADS", "ALL", "MO", "AMZN", "AEE", "AAL", "AEP", "AIG", "AMT", "AMP", "ABC", "AME", "AMGN", "APH", "APC", "ADI", "AON", "APA", "AIV", "AMAT", "ADM", "AIZ", "T", "ADSK", "ADP", "AN", "AZO", "AVGO", "AVB", "AVY", "BHI", "BLL", "BAC", "BK", "BCR", "BAX", "BBT", "BDX", "BBBY", "BBY", "BLX", "HRB", "BWA", "BXP", "BMY", "BRCM", "CHRW", "CA",  "COG", "CAM", "CPB", "COF", "CAH", "HSIC", "KMX", "CCL", "CBG", "CBS", "CELG", "CNP", "CTL", "CERN", "CF", "SCHW", "CHK", "CMG", "CB", "CI", "XEC", "CINF", "CTAS", "C", "CTXS", "CLX", "CME", "CMS", "COH", "CCE", "CTSH", "CL", "CMCSA", "CMA", "CSC", "CAG", "COP", "CNX", "ED", "STZ", "GLW", "COST", "CCI", "CSX", "CMI", "CVS", "DHI", "DHR", "DRI", "DVA", "DE", "DLPH", "DAL", "XRAY", "DVN", "DO", "DFS", "DISCA", "DISCK", "DG", "DLTR", "D", "DOV", "DOW", "DPS", "DTE", "DD", "DUK", "DNB", "ETFC", "EMN", "ETN", "EBAY", "ECL", "EIX", "EW", "EA", "EMC", "EMR", "ENDP", "ESV", "ETR", "EOG", "EQT", "EFX", "EQIX", "EQR", "ESS", "EL", "ES", "EXC", "EXPE", "EXPD", "ESRX", "FFIV", "FB", "FAST", "FDX", "FIS", "FITB", "FSLR", "FE", "FLIR", "FLS", "FLR", "FMC", "FTI", "F", "FOSL", "BEN", "FCX", "FTR", "GME", "GPS", "GRMN", "GD", "GGP", "GIS", "GM", "GPC", "GNW", "GILD", "GT", "GOOGL", "GOOG", "GWW", "HAL", "HBI", "HOG", "HRS", "HIG", "HAS", "HCA", "HCP", "HCN", "HP", "HES", "HPQ", "HON", "HRL", "HST", "HUM", "HBAN", "ITW", "IR", "ICE", "IP", "IPG", "IFF", "INTU", "ISRG", "IVZ", "IRM", "JEC", "JBHT", "JNPR", "KSU", "K", "KEY", "KMB", "KIM", "KMI", "KLAC", "KSS", "KR", "LB", "LLL", "LH", "LRCX", "LM", "LEG", "LEN", "LVLT", "LUK", "LLY", "LNC", "LMT", "L", "LOW", "LYB", "MTB", "MAC", "M", "MNK", "MRO", "MPC", "MAR", "MMC", "MLM", "MAS", "MA", "MAT", "MKC", "MCK", "MJN", "MMV", "MDT", "MET", "KORS", "MCHP", "MU", "MHK", "TAP", "MDLZ", "MON", "MNST", "MCO", "MS", "MOS", "MSI", "MUR", "MYL", "NDAQ", "NOV", "NTAP", "NFLX", "NWL", "NFX", "NEM", "NWSA", "NEE", "NLSN", "NI", "NE", "NBL", "JWN", "NSC", "NTRS", "NOC", "NRG", "NUE", "NVDA", "ORLY", "OXY", "OMC", "OKE", "ORCL", "OI", "PCAR", "PH", "PDCO", "PAYX", "PNR", "PBCT", "PEP", "PKI", "PRGO", "PCG", "PM", "PSX", "PNW", "PXD", "PBI", "PNC", "RL", "PPG", "PPL", "PX", "PCLN", "PFG", "PGR", "PLD", "PRU", "PEG", "PSA", "PHM", "PVH", "PWR", "QCOM", "DGX", "RRC", "RTN", "O", "RHT", "REGN", "RF", "RSG", "RAI", "RHI", "ROK", "COL", "ROP", "ROST", "R", "CRM", "SCG", "SLB", "SNI", "STX", "SEE", "SRE", "SHW", "SPG", "SWKS", "SLG", "SJM", "SNA", "SO", "LUV", "SWN", "SE",  "SWK", "SPLS", "SBUX", "STT", "SRCL", "SYK", "STI", "SYMC", "SYY", "TROW", "TGT", "TEL", "TGNA", "THC", "TDC", "TSO", "TXN", "TXT", "HSY", "TMO", "TIF", "TWX", "TMK", "TSS", "TSCO", "RIG", "TRIP", "FOXA", "TSN", "UA", "UNP", "UPS", "URI", "UHS", "UNM", "URBN", "VFC", "VLO", "VAR", "VTR", "VRSN", "VRTX", "VIAB", "VNO", "VMC", "WBA", "WM", "WAT", "ANTM", "WFC", "WDC", "WU", "WY", "WHR", "WFM", "WMB", "WEC", "WYN", "WYNN", "XEL", "XRX", "XLNX", "XL", "XYL", "YHOO", "YUM", "ZBH", "ZION", "ZTS", "XIV", "CLF", "TSLA"]
}

class SymbolLists {
    
    let allSymbols = Symbols().AllNonDuplicated
    //Symbols().indexes + Symbols().DOW30 + Symbols().ETF200 + Symbols().SP500 + Symbols().FAVORITES  //Symbols().Winners //
    
   
    //MARK: - Remove any duplicated tickers
    func uniqueElementsFrom(testSet: Bool, of:Int) -> [String] {
        var set = Set<String>()
        let result = allSymbols.filter {
            guard !set.contains($0) else {
                return false
            }
            set.insert($0)
            return true
        }
        if ( testSet ) {
            return Array(result.prefix(of))
        } else {
            return result
        }
    }
    
    func segmented(by:Int, of727loadOnly:Int)-> [[String]] {
        print("\nEntire group of non duplicated symbols is \(allSymbols.count)\n")
        let smallerGroup = Array(allSymbols.prefix(of727loadOnly))
        return smallerGroup.chunked(by: by)
    }
    
}













