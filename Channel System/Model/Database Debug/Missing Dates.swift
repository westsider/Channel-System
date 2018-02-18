//
//  Missing Dates.swift
//  Channel System
//
//  Created by Warren Hansen on 2/16/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

class MissingDates {
    
    class func findAndGetMissingDatesFor(ticker:String, completion: @escaping (Bool) -> Void) {
        let missingDates = MissingDates.inThis(ticker: ticker)
        print("\(ticker) is missing \(missingDates.count) days")
        let missingPages = MissingDates.whatPagesFor(dates: missingDates)
        print("Here are the missing pages \(missingPages)")
        MissingDates.getMissingPagesFor(ticker: ticker, pages: missingPages) { (finished) in
            if finished {
                print("\n-------------------------------------------------\nfinished with getting missingg dates and recalc for \(ticker)\n-------------------------------------------------\n")
                completion(true)
            }
        }
        print("")
    }
    
    class func inThis(ticker:String)-> Set<Date> {
        // get all dates in SPY
        let spyTicker = Prices().sortOneTicker(ticker: "SPY", debug: false)
        var spyDateArray:[Date] = []
        for each in spyTicker {
            spyDateArray.append(each.date!)
        }
        // get all dates in ticker
        let oneTicker = Prices().sortOneTicker(ticker: ticker, debug: false)
        var tickerDateArray:[Date] = []
        for each in oneTicker {
            tickerDateArray.append(each.date!)
        }
        // make an array of dates ticker is missing
        //var difference = spyDateArray
        
        let filtered = Set(spyDateArray).subtracting(tickerDateArray)
        // IJH is missing 298 dates
        return filtered
    }
    
    class func whatPagesFor(dates:Set<Date> )-> [Int] {
        
        let pagesFromSPY = PageInfo.pagesForSpy() // [(Int, Date, Date)]
        // loop through dates
        var pagesMissing:[Int] = []
        for dateToCheck in dates {
            // if date is bettween a tuble of dates then add the tuple page num
            for tupleToCheck in pagesFromSPY {
                if (tupleToCheck.1 ... tupleToCheck.2 ).contains(dateToCheck) {
                    pagesMissing.append(tupleToCheck.0)
                }
            }
        }
        
        // remove page zero because its duplicated in 1
        let removePageZero = pagesMissing.filter { $0 != 0 }
        // remove duplicate page nums
        let duplicatesRemoved = Array(Set(removePageZero))
        return duplicatesRemoved.sorted()
    }
    
    class func getMissingPagesFor(ticker:String, pages:[Int], completion: @escaping (Bool) -> Void) {
        PriorData().addMissingDatesAndRecalc(ticker: ticker, array: pages, saveToRealm: true, debug: true) { (finished) in
            if finished {
                print("Finished adding missing pages for \(ticker)")
                completion(true)
            }
        }
    }
}

/*
 Warning test # 1 ITB is missisng 284 days of data
 Warning test # 1 IWS is missisng 190 days of data
 Warning test # 1 IYK is missisng 298 days of data
 Warning test # 1 IYR is missisng 298 days of data
 Warning test # 1 IYT is missisng 284 days of data
 Warning test # 1 IYZ is missisng 284 days of data
 Warning test # 1 JJC is missisng 298 days of data
 Warning test # 1 JKL is missisng 298 days of data
 Warning test # 1 JNK is missisng 298 days of data
 Warning test # 1 KIE is missisng 298 days of data
 Warning test # 1 PID is missisng 298 days of data
 Warning test # 1 PPH is missisng 299 days of data
 Warning test # 1 PSP is missisng 298 days of data
 Warning test # 1 PZA is missisng 298 days of data
 Warning test # 1 PXJ is missisng 298 days of data
 REM high on 2018-01-02 is 0.0
 REM low on 2018-01-02 is 0.0
 Warning test #2 on REM we found 2 with a value of zero
 Warning test # 1 XLF is missisng 294 days of data
 Warning test # 1 XOP is missisng 294 days of data
 Warning test # 1 XPH is missisng 294 days of data
 Warning test # 1 XRT is missisng 294 days of data
 Warning test # 1 XSD is missisng 294 days of data
 Warning test # 1 ABT is missisng 294 days of data
 Warning test # 1 ABBV is missisng 287 days of data
 Warning test # 1 ACN is missisng 287 days of data
 Warning test # 1 ACE is missisng 302 days of data
 Warning test # 1 ADBE is missisng 287 days of data
 Warning test # 1 ADT is missisng 302 days of data
 Warning test # 1 ARG is missisng 302 days of data
 Warning test # 1 AKAM is missisng 294 days of data
 Warning test # 1 AA is missisng 287 days of data
 Warning test # 1 AGN is missisng 294 days of data
 Warning test # 1 ALXN is missisng 294 days of data
 Warning test # 1 ALLE is missisng 294 days of data
 Warning test # 1 ADS is missisng 287 days of data
 Warning test # 1 ALL is missisng 287 days of data
 Warning test # 1 ALTR is missisng 294 days of data
 Warning test # 1 MO is missisng 294 days of data
 Warning test # 1 ADSK is missisng 288 days of data
 Warning test # 1 ADP is missisng 288 days of data
 Warning test # 1 AN is missisng 294 days of data
 Warning test # 1 AZO is missisng 294 days of data
 Warning test # 1 AVGO is missisng 288 days of data
 Warning test # 1 AVB is missisng 294 days of data
 Warning test # 1 AVY is missisng 288 days of data
 Warning test # 1 BHI is missisng 302 days of data
 Warning test # 1 BLL is missisng 288 days of data
 Warning test # 1 BAC is missisng 288 days of data
 Warning test # 1 BK is missisng 294 days of data
 Warning test # 1 BCR is missisng 302 days of data
 Warning test # 1 BAX is missisng 288 days of data
 Warning test # 1 BBT is missisng 288 days of data
 Warning test # 1 BDX is missisng 288 days of data
 Warning test # 1 BWA is missisng 288 days of data
 Warning test # 1 CA is missisng 288 days of data
 Warning test # 1 CVC is missisng 302 days of data
 Warning test # 1 GLW is missisng 294 days of data
 Warning test # 1 DO is missisng 288 days of data
 Warning test # 1 DTV is missisng 288 days of data
 Warning test # 1 DFS is missisng 294 days of data
 Warning test # 1 DOW is missisng 302 days of data
 Warning test # 1 DUK is missisng 288 days of data
 Warning test # 1 DNB is missisng 294 days of data
 Warning test # 1 ESV is missisng 294 days of data
 Warning test # 1 ETR is missisng 294 days of data
 Warning test # 1 EOG is missisng 288 days of data
 Warning test # 1 EQT is missisng 294 days of data
 Warning test # 1 EFX is missisng 288 days of data
 Warning test # 1 EQIX is missisng 288 days of data
 Warning test # 1 EQR is missisng 294 days of data
 Warning test # 1 EL is missisng 288 days of data
 Warning test # 1 ESS is missisng 294 days of data
 Warning test # 1 ES is missisng 294 days of data
 Warning test # 1 EXC is missisng 288 days of data
 Warning test # 1 EXPE is missisng 294 days of data
 Warning test # 1 EXPD is missisng 288 days of data
 Warning test # 1 ESRX is missisng 294 days of data
 Warning test # 1 FFIV is missisng 288 days of data
 Warning test # 1 FB is missisng 288 days of data
 Warning test # 1 FAST is missisng 294 days of data
 Warning test # 1 FDX is missisng 288 days of data
 Warning test # 1 FIS is missisng 288 days of data
 Warning test # 1 FITB is missisng 288 days of data
 Warning test # 1 FSLR is missisng 294 days of data
 Warning test # 1 FE is missisng 294 days of data
 Warning test # 1 FLIR is missisng 288 days of data
 Warning test # 1 FLS is missisng 288 days of data
 Warning test # 1 FLR is missisng 294 days of data
 Warning test # 1 FMC is missisng 288 days of data
 Warning test # 1 FTI is missisng 294 days of data
 Warning test # 1 F is missisng 294 days of data
 Warning test # 1 FOSL is missisng 294 days of data
 Warning test # 1 BEN is missisng 294 days of data
 Warning test # 1 FCX is missisng 294 days of data
 Warning test # 1 FTR is missisng 294 days of data
 Warning test # 1 GME is missisng 294 days of data
 Warning test # 1 GRMN is missisng 294 days of data
 Warning test # 1 GPS is missisng 294 days of data
 Warning test # 1 GD is missisng 294 days of data
 Warning test # 1 GGP is missisng 294 days of data
 Warning test # 1 GIS is missisng 294 days of data
 Warning test # 1 GM is missisng 294 days of data
 Warning test # 1 GPC is missisng 288 days of data
 Warning test # 1 GNW is missisng 294 days of data
 Warning test # 1 GILD is missisng 294 days of data
 Warning test # 1 GT is missisng 294 days of data
 Warning test # 1 GOOGL is missisng 294 days of data
 Warning test # 1 GOOG is missisng 288 days of data
 Warning test # 1 GWW is missisng 288 days of data
 Warning test # 1 HAL is missisng 288 days of data
 Warning test # 1 HBI is missisng 294 days of data
 Warning test # 1 HOG is missisng 294 days of data
 Warning test # 1 HAR is missisng 302 days of data
 Warning test # 1 HRS is missisng 288 days of data
 Warning test # 1 HIG is missisng 288 days of data
 Warning test # 1 HAS is missisng 294 days of data
 Warning test # 1 HCA is missisng 294 days of data
 Warning test # 1 HCP is missisng 288 days of data
 Warning test # 1 HCN is missisng 294 days of data
 Warning test # 1 HP is missisng 294 days of data
 Warning test # 1 HES is missisng 294 days of data
 Warning test # 1 HPQ is missisng 294 days of data
 Warning test # 1 HON is missisng 288 days of data
 Warning test # 1 HRL is missisng 294 days of data
 Warning test # 1 HSP is missisng 302 days of data
 Warning test # 1 HST is missisng 294 days of data
 Warning test # 1 HCBK is missisng 302 days of data
 Warning test # 1 HUM is missisng 288 days of data
 Warning test # 1 HBAN is missisng 288 days of data
 Warning test # 1 ITW is missisng 288 days of data
 Warning test # 1 IR is missisng 288 days of data
 Warning test # 1 ICE is missisng 294 days of data
 Warning test # 1 IP is missisng 288 days of data
 Warning test # 1 IPG is missisng 288 days of data
 Warning test # 1 IFF is missisng 294 days of data
 Warning test # 1 INTU is missisng 288 days of data
 Warning test # 1 ISRG is missisng 288 days of data
 Warning test # 1 IVZ is missisng 294 days of data
 Warning test # 1 IRM is missisng 294 days of data
 Warning test # 1 JEC is missisng 288 days of data
 Warning test # 1 JBHT is missisng 294 days of data
 Warning test # 1 JCI is missisng 294 days of data
 Warning test # 1 JOY is missisng 302 days of data
 Warning test # 1 JNPR is missisng 288 days of data
 Warning test # 1 KSU is missisng 294 days of data
 Warning test # 1 K is missisng 288 days of data
 Warning test # 1 KEY is missisng 288 days of data
 Warning test # 1 GMCR is missisng 302 days of data
 Warning test # 1 KMB is missisng 294 days of data
 Warning test # 1 KIM is missisng 288 days of data
 Warning test # 1 KMI is missisng 288 days of data
 Warning test # 1 KLAC is missisng 288 days of data
 Warning test # 1 KSS is missisng 294 days of data
 Warning test # 1 KR is missisng 294 days of data
 Warning test # 1 LB is missisng 294 days of data
 Warning test # 1 LLL is missisng 294 days of data
 Warning test # 1 LH is missisng 288 days of data
 Warning test # 1 LRCX is missisng 288 days of data
 Warning test # 1 LM is missisng 288 days of data
 Warning test # 1 LEG is missisng 294 days of data
 Warning test # 1 LEN is missisng 294 days of data
 Warning test # 1 LVLT is missisng 302 days of data
 Warning test # 1 LUK is missisng 288 days of data
 Warning test # 1 LLY is missisng 294 days of data
 Warning test # 1 LNC is missisng 288 days of data
 Warning test # 1 LLTC is missisng 302 days of data
 Warning test # 1 LMT is missisng 288 days of data
 Warning test # 1 L is missisng 288 days of data
 Warning test # 1 LOW is missisng 294 days of data
 Warning test # 1 LYB is missisng 288 days of data
 Warning test # 1 MTB is missisng 294 days of data
 Warning test # 1 MAC is missisng 294 days of data
 Warning test # 1 M is missisng 294 days of data
 Warning test # 1 MNK is missisng 294 days of data
 Warning test # 1 MRO is missisng 294 days of data
 Warning test # 1 MPC is missisng 294 days of data
 Warning test # 1 MAR is missisng 294 days of data
 Warning test # 1 MMC is missisng 288 days of data
 Warning test # 1 MLM is missisng 294 days of data
 Warning test # 1 MAS is missisng 294 days of data
 Warning test # 1 MA is missisng 288 days of data
 Warning test # 1 MAT is missisng 288 days of data
 Warning test # 1 MKC is missisng 288 days of data
 Warning test # 1 MHFI is missisng 302 days of data
 Warning test # 1 MCK is missisng 294 days of data
 Warning test # 1 MJN is missisng 302 days of data
 Warning test # 1 MDT is missisng 294 days of data
 Warning test # 1 MMV is missisng 294 days of data
 Warning test # 1 MET is missisng 294 days of data
 Warning test # 1 KORS is missisng 294 days of data
 Warning test # 1 MCHP is missisng 294 days of data
 Warning test # 1 MU is missisng 288 days of data
 Warning test # 1 MHK is missisng 288 days of data
 Warning test # 1 TAP is missisng 294 days of data
 Warning test # 1 MDLZ is missisng 294 days of data
 Warning test # 1 MON is missisng 294 days of data
 Warning test # 1 MNST is missisng 288 days of data
 Warning test # 1 MCO is missisng 288 days of data
 Warning test # 1 MS is missisng 288 days of data
 Warning test # 1 MOS is missisng 288 days of data
 Warning test # 1 MSI is missisng 294 days of data
 Warning test # 1 MUR is missisng 294 days of data
 Warning test # 1 MYL is missisng 294 days of data
 Warning test # 1 NDAQ is missisng 294 days of data
 Warning test # 1 NAVI is missisng 294 days of data
 Warning test # 1 NOV is missisng 288 days of data
 Warning test # 1 NTAP is missisng 288 days of data
 Warning test # 1 NFLX is missisng 288 days of data
 Warning test # 1 NWL is missisng 294 days of data
 Warning test # 1 NFX is missisng 294 days of data
 Warning test # 1 NEM is missisng 288 days of data
 Warning test # 1 NWSA is missisng 294 days of data
 Warning test # 1 NEE is missisng 288 days of data
 Warning test # 1 NLSN is missisng 294 days of data
 Warning test # 1 NI is missisng 294 days of data
 Warning test # 1 NE is missisng 294 days of data
 Warning test # 1 NBL is missisng 294 days of data
 Warning test # 1 JWN is missisng 294 days of data
 Warning test # 1 NSC is missisng 288 days of data
 Warning test # 1 NTRS is missisng 288 days of data
 Warning test # 1 NOC is missisng 288 days of data
 Warning test # 1 NRG is missisng 288 days of data
 Warning test # 1 NUE is missisng 288 days of data
 Warning test # 1 NVDA is missisng 288 days of data
 Warning test # 1 ORLY is missisng 288 days of data
 Warning test # 1 OXY is missisng 288 days of data
 Warning test # 1 OMC is missisng 294 days of data
 Warning test # 1 OKE is missisng 294 days of data
 Warning test # 1 ORCL is missisng 288 days of data
 Warning test # 1 OI is missisng 294 days of data
 Warning test # 1 PCAR is missisng 294 days of data
 Warning test # 1 PLL is missisng 302 days of data
 Warning test # 1 PH is missisng 294 days of data
 Warning test # 1 PDCO is missisng 294 days of data
 Warning test # 1 PAYX is missisng 294 days of data
 Warning test # 1 PNR is missisng 288 days of data
 Warning test # 1 PBCT is missisng 294 days of data
 Warning test # 1 POM is missisng 302 days of data
 Warning test # 1 PEP is missisng 288 days of data
 Warning test # 1 PKI is missisng 288 days of data
 Warning test # 1 PRGO is missisng 288 days of data
 Warning test # 1 PCG is missisng 288 days of data
 Warning test # 1 PM is missisng 288 days of data
 Warning test # 1 PSX is missisng 294 days of data
 Warning test # 1 PNW is missisng 288 days of data
 Warning test # 1 PXD is missisng 288 days of data
 Warning test # 1 PBI is missisng 294 days of data
 Warning test # 1 PCL is missisng 302 days of data
 Warning test # 1 PNC is missisng 288 days of data
 Warning test # 1 RL is missisng 294 days of data
 Warning test # 1 PPG is missisng 294 days of data
 Warning test # 1 PPL is missisng 288 days of data
 Warning test # 1 PX is missisng 288 days of data
 Warning test # 1 PCP is missisng 302 days of data
 Warning test # 1 PCLN is missisng 294 days of data
 Warning test # 1 PFG is missisng 288 days of data
 Warning test # 1 PGR is missisng 294 days of data
 Warning test # 1 PLD is missisng 294 days of data
 Warning test # 1 PRU is missisng 294 days of data
 Warning test # 1 PEG is missisng 294 days of data
 Warning test # 1 PSA is missisng 294 days of data
 Warning test # 1 PHM is missisng 294 days of data
 Warning test # 1 PVH is missisng 294 days of data
 Warning test # 1 PWR is missisng 288 days of data
 Warning test # 1 QCOM is missisng 294 days of data
 Warning test # 1 DGX is missisng 288 days of data
 Warning test # 1 RRC is missisng 288 days of data
 Warning test # 1 RTN is missisng 288 days of data
 Warning test # 1 O is missisng 294 days of data
 Warning test # 1 RHT is missisng 288 days of data
 Warning test # 1 REGN is missisng 294 days of data
 Warning test # 1 RF is missisng 288 days of data
 Warning test # 1 RSG is missisng 288 days of data
 Warning test # 1 RAI is missisng 302 days of data
 Warning test # 1 RHI is missisng 288 days of data
 Warning test # 1 ROK is missisng 288 days of data
 Warning test # 1 COL is missisng 288 days of data
 SWN
 */
