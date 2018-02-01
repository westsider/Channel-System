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
    
    let SP500 = ["ABT", "ABBV", "ACN", "ACE", "ADBE", "ADT", "AAP", "AES", "AET", "AFL", "AMG", "A", "GAS", "APD", "ARG", "AKAM", "AA", "AGN", "ALXN", "ALLE", "ADS", "ALL", "ALTR", "MO", "AMZN", "AEE", "AAL", "AEP", "AXP", "AIG", "AMT", "AMP", "ABC", "AME", "AMGN", "APH", "APC", "ADI", "AON", "APA", "AIV", "AMAT", "ADM", "AIZ", "T", "ADSK", "ADP", "AN", "AZO", "AVGO", "AVB", "AVY", "BHI", "BLL", "BAC", "BK", "BCR",  "BAX", "BBT", "BDX", "BBBY", "BBY", "BLX","HRB","BA", "BWA", "BXP", "BMY", "BRCM", "CHRW", "CA", "CVC", "COG" , "CAM", "CPB", "COF", "CAH","HSIC", "KMX", "CCL", "CAT", "CBG", "CBS", "CELG", "CNP", "CTL", "CERN", "CF", "SCHW", "CHK", "CVX", "CMG", "CB", "CI", "XEC", "CINF", "CTAS", "CSCO", "C", "CTXS", "CLX", "CME", "CMS", "COH", "KO", "CCE", "CTSH", "CL", "CMCSA", "CMA", "CSC", "CAG", "COP", "CNX", "ED", "STZ", "CNX", "ED", "STZ", "GLW", "COST", "CCI", "CSX", "CMI", "CVS", "DHI", "DHR", "DRI", "DVA", "DE", "DLPH", "DAL", "XRAY", "DVN", "DO", "DTV", "DFS", "DISCA", "DISCK", "DG", "DLTR", "D", "DOV", "DOW", "DPS", "DTE", "DD", "DUK", "DNB", "ETFC", "EMN", "ETN", "EBAY", "ECL", "EIX", "EW", "EA", "EMC", "EMR", "ENDP", "ESV", "ETR", "EOG", "EQT", "EFX", "EQIX", "EQR", "ESS", "EL", "ES", "EXC", "EXPE", "EXPD", "ESRX", "XOM", "FFIV", "FB", "FAST", "FDX", "FIS", "FITB", "FSLR", "FE", "FLIR", "FLS", "FLR", "FMC", "FTI", "F", "FOSL", "BEN", "FCX", "FTR", "GME", "GPS", "GRMN", "GD", "GE", "GGP", "GIS", "GM", "GPC", "GNW", "GILD", "GS", "GT", "GOOGL", "GOOG", "GWW", "HAL", "HBI", "HOG", "HAR", "HRS", "HIG", "HAS", "HCA", "HCP", "HCN", "HP", "HES", "HPQ", "HD", "HON", "HRL", "HSP", "HST", "HCBK", "HUM", "HBAN", "ITW", "IR", "INTC", "ICE", "IBM", "IP", "IPG", "IFF", "INTU", "ISRG", "IVZ", "IRM", "JEC", "JBHT", "JNJ", "JCI", "JOY", "JPM", "JNPR", "KSU", "K", "KEY", "GMCR", "KMB", "KIM","KMI", "KLAC", "KSS", "KR", "LB", "LLL", "LH", "LRCX", "LM", "LEG", "LEN", "LVLT", "LUK", "LLY", "LNC", "LLTC", "LMT", "L", "LOW", "LYB", "MTB", "MAC", "M", "MNK", "MRO", "MPC", "MAR", "MMC","MLM", "MAS", "MA", "MAT", "MKC", "MCD", "MHFI", "MCK", "MJN", "MMV", "MDT", "MRK", "MET", "KORS", "MCHP", "MU", "MSFT", "MHK", "TAP", "MDLZ", "MON", "MNST", "MCO", "MS", "MOS", "MSI", "MUR", "MYL", "NDAQ", "NOV", "NAVI", "NTAP", "NFLX", "NWL", "NFX", "NEM", "NWSA", "NEE", "NLSN", "NKE", "NI", "NE", "NBL", "JWN", "NSC", "NTRS", "NOC", "NRG", "NUE", "NVDA", "ORLY", "OXY", "OMC", "OKE", "ORCL", "OI", "PCAR", "PLL", "PH", "PDCO", "PAYX", "PNR", "PBCT", "POM", "PEP", "PKI", "PRGO", "PFE", "PCG", "PM", "PSX", "PNW", "PXD", "PBI", "PCL", "PNC", "RL", "PPG", "PPL", "PX", "PCP", "PCLN", "PFG", "PG", "PGR", "PLD", "PRU", "PEG", "PSA", "PHM", "PVH", "PWR", "QCOM", "DGX", "RRC", "RTN", "O", "RHT", "REGN", "RF", "RSG", "RAI", "RHI", "ROK", "COL", "ROP", "ROST", "R", "CRM", "SNDK", "SCG", "SLB", "SNI", "STX", "SEE", "SRE", "SHW", "SIAL", "SPG", "SWKS", "SLG", "SJM", "SNA", "SO", "LUV", "SWN", "SE", "STJ", "SWK", "SPLS", "SBUX", "HOT", "STT", "SRCL", "SYK", "STI", "SYMC", "SYY", "TROW", "TGT", "TEL", "TE", "TGNA", "THC", "TDC", "TSO", "TXN", "TXT", "HSY", "TRV", "TMO", "TIF", "TWX", "TWC", "TMK", "TSS", "TSCO", "RIG", "TRIP", "FOXA", "TSN", "TYC", "UA", "UNP", "UNH", "UPS", "URI", "UTX", "UHS", "UNM", "URBN", "VFC", "VLO", "VAR", "VTR", "VRSN", "VZ", "VRTX", "VIAB", "V", "VNO", "VMC", "WMT", "WBA", "DIS", "WM", "WAT", "ANTM", "WFC", "WDC", "WU", "WY", "WHR", "WFM", "WMB", "WEC", "WYN", "WYNN", "XEL", "XRX", "XLNX", "XL", "XYL", "YHOO", "YUM", "ZBH", "ZION", "ZTS"] // "BRK-B" was nil, "BXLT" not enough data,  "BSK" no data, no data "BF-B", "FSIV" , "KRFT" RLC TJK no data, QRVO missing data
    
    let Winners = ["SPY", "QQQ", "DIA", "MDY", "IWM", "EFA", "ILF", "EEM", "EPP", "IEV", "AAPL", "BA", "CAT", "IBM", "JPM", "MCD", "MMM", "MRK", "MSFT", "PG", "UNH", "V", "WMT", "CVY", "DBB", "DBC", "DEM", "DGS", "DLN", "DTN", "DVY", "ECH", "EFV", "EWA", "EWC", "EWG", "EWI", "EWJ", "EWL", "EWO", "EWP", "EWQ", "EWS", "EWT", "EWY", "EZU", "FBT", "FDL", "FDN", "FEZ", "FXD", "FXG", "FXI", "FXL", "FXO", "FXR", "FXU", "FXZ", "IDV", "IFN", "IJJ", "IJR", "IJS", "IVE", "IVV", "IVW", "IWB", "IWC", "IWD", "IWF", "IWN", "IWO", "IWP", "IWR", "IWV", "IXC", "IXN", "IXP", "IYC", "IYE", "IYF", "IYG", "IYH", "IYJ", "IYM", "IYW", "IYY", "JKD", "JKE", "JKF", "JKH", "JKJ", "JKK", "KBE", "KCE", "KOL", "KRE", "MOO", "OEF", "ONEQ", "PBW", "PDP", "PEJ", "PEY", "PFM", "PHO", "PIE", "PRF", "PWV", "PXH", "REM", "RFG", "RFV", "RPG", "RSX", "SCZ", "SDY", "SMH", "SOXX", "TLT", "VAW", "VB", "VBK", "VBR", "VCR", "VDE", "VEA", "VEU", "VFH", "VGK", "VGT", "VHT", "VIG", "VIS", "VO", "VPL", "VTI", "VTV", "VV", "VWO", "VXF", "VYM", "XLB", "XLG", "XLI", "XLK", "XLY", "ABBV", "ACN", "ACE", "ADBE", "AFL", "A", "ARG", "AA", "ADS", "ALL", "AMZN", "AEE", "AMT", "AMP", "AME", "APH", "APC", "AON", "APA", "AMAT", "ADM", "ADSK", "ADP", "AVGO", "AVY", "BLL", "BAC", "BCR", "BAX", "BBT", "BDX", "BBY", "BLX", "BWA", "BMY", "BRCM", "CA", "COG", "CPB", "COF", "CAH", "HSIC", "CCL", "CNP", "SCHW", "CB", "CI", "C", "CTXS", "CMS", "CTSH", "CMA", "CSC", "CAG", "STZ", "CSX", "CMI", "DHI", "DHR", "DE", "DLPH", "XRAY", "DO", "DTV", "DISCA", "DOV", "DOW", "DTE", "DUK", "ETFC", "EMN", "EBAY", "ECL", "EIX", "EA", "EOG", "EFX", "EQIX", "EL", "EXC", "EXPD", "FFIV", "FB", "FDX", "FIS", "FITB", "FLIR", "FLS", "FMC", "GPC", "GOOG", "GWW", "HAL", "HRS", "HIG", "HCP", "HON", "HSP", "HCBK", "HUM", "HBAN", "ITW", "IR", "IP", "IPG", "INTU", "ISRG", "JEC", "JNPR", "K", "KEY", "KIM", "KMI", "KLAC", "LH", "LRCX", "LM", "LUK", "LNC", "LLTC", "LMT", "L", "LYB", "MMC", "MA", "MAT", "MKC", "MHFI", "MU", "MHK", "MNST", "MCO", "MS", "MOS", "NOV", "NTAP", "NFLX", "NEM", "NEE", "NSC", "NTRS", "NOC", "NRG", "NUE", "NVDA", "ORLY", "OXY", "ORCL", "PLL", "PNR", "PEP", "PKI", "PRGO", "PCG", "PM", "PNW", "PXD", "PNC", "PPL", "PX", "PCP", "PFG", "PWR", "DGX", "RRC", "RTN", "RHT", "RF", "RSG", "RAI", "RHI", "ROK", "COL", "ROP", "ROST", "CRM", "SCG", "STX", "SHW", "SIAL", "SWKS", "SNA", "SWN", "SE", "SWK", "STT", "STI", "TROW", "TEL", "TDC", "TXN", "TXT", "TIF", "TWC", "TMK", "TSN", "TYC", "VLO", "VAR", "VRTX", "WM", "WAT", "ANTM", "WDC", "XL", "XYL", "YHOO", "ZION", "ZTS", "XIV"] // 357
    
    let Loosers = ["AXP", "CSCO", "CVX", "DIS", "GE", "GS", "HD", "INTC", "JNJ", "KO", "NKE", "PFE", "TRV", "UTX", "VZ", "XOM", "AGG", "BIK", "BIL", "BIV", "BND", "BSV", "BWX", "CIU", "CSJ", "DBA", "DBE", "DBO", "DBV", "DGL", "DJP", "EMB", "EWD", "EWH", "EWM", "EWU", "EWW", "EWZ", "EZA", "FXE", "FXH", "FXY", "GAZ", "GDX", "GLD", "GSG", "HYG", "IAU", "IBB", "ICF", "IEF", "IEI", "IEO", "IEZ", "IGE", "IJH", "IJK", "IJT", "ITB", "IWS", "IYK", "IYR", "IYT", "IYZ", "JJC", "JKL", "JNK", "KIE", "LQD", "MBB", "OIH", "OIL", "PBE", "PCY", "PFF", "PGJ", "PHB", "PID", "PPH", "PSP", "PXJ", "PZA", "RJA", "RPV", "RSP", "RTH", "RWX", "RZV", "SHM", "SHV", "SHY", "SLV", "TFI", "TIP", "UNG", "USO", "UUP", "VDC", "VNQ", "VOT", "VOX", "VPU", "VUG", "XBI", "XES", "XHB", "XLE", "XLF", "XLP", "XLU", "XLV", "XME", "XOP", "XPH", "XRT", "XSD", "ABT", "ADT", "AAP", "AES", "AET", "AMG", "GAS", "APD", "AKAM", "AGN", "ALXN", "ALLE", "ALTR", "MO", "AAL", "AEP", "AIG", "ABC", "AMGN", "ADI", "AIV", "AIZ", "T", "AN", "AZO", "AVB", "BHI", "BK", "BBBY", "HRB", "BXP", "CHRW", "CVC", "CAM", "KMX", "CBG", "CBS", "CELG", "CTL", "CERN", "CF", "CHK", "CMG", "XEC", "CINF", "CTAS", "CLX", "CME", "COH", "CCE", "CL", "CMCSA", "COP", "CNX", "ED", "GLW", "COST", "CCI", "CVS", "DRI", "DVA", "DAL", "DVN", "DFS", "DISCK", "DG", "DLTR", "D", "DPS", "DD", "DNB", "ETN", "EW", "EMC", "EMR", "ENDP", "ESV", "ETR", "EQT", "EQR", "ESS", "ES", "EXPE", "ESRX", "FAST", "FSLR", "FE", "FLR", "FTI", "F", "FOSL", "BEN", "FCX", "FTR", "GME", "GPS", "GRMN", "GD", "GGP", "GIS", "GM", "GNW", "GILD", "GT", "GOOGL", "HBI", "HOG", "HAR", "HAS", "HCA", "HCN", "HP", "HES", "HPQ", "HRL", "HST", "ICE", "IFF", "IVZ", "IRM", "JBHT", "JCI", "JOY", "KSU", "GMCR", "KMB", "KSS", "KR", "LB", "LLL", "LEG", "LEN", "LVLT", "LLY", "LOW", "MTB", "MAC", "M", "MNK", "MRO", "MPC", "MAR", "MLM", "MAS", "MCK", "MJN", "MMV", "MDT", "MET", "KORS", "MCHP", "TAP", "MDLZ", "MON", "MSI", "MUR", "MYL", "NDAQ", "NAVI", "NWL", "NFX", "NWSA", "NLSN", "NI", "NE", "NBL", "JWN", "OMC", "OKE", "OI", "PCAR", "PH", "PDCO", "PAYX", "PBCT", "POM", "PSX", "PBI", "PCL", "RL", "PPG", "PCLN", "PGR", "PLD", "PRU", "PEG", "PSA", "PHM", "PVH", "QCOM", "O", "REGN", "R", "SNDK", "SLB", "SNI", "SEE", "SRE", "SPG", "SLG", "SJM", "SO", "LUV", "STJ", "SPLS", "SBUX", "HOT", "SRCL", "SYK", "SYMC", "SYY", "TGT", "TE", "TGNA", "THC", "TSO", "HSY", "TMO", "TWX", "TSS", "TSCO", "RIG", "TRIP", "FOXA", "UA", "UNP", "UPS", "URI", "UHS", "UNM", "URBN", "VFC", "VTR", "VRSN", "VIAB", "VNO", "VMC", "WBA", "WFC", "WU", "WY", "WHR", "WFM", "WMB", "WEC", "WYN", "WYNN", "XEL", "XRX", "XLNX", "YUM", "ZBH", "CLF", "TSLA"] // 370
}

class SymbolLists {
    
    let allSymbols = Symbols().Winners //Symbols().indexes + Symbols().DOW30 + Symbols().ETF200 + Symbols().SP500 + Symbols().FAVORITES
    
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
}













