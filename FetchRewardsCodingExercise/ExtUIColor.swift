//
//  ExtUIColor.swift
//  FetchRewardsCodingExercise
//
//  Created by endOfLine on 3/10/21.
//

import UIKit

extension UIColor {
    static let boardRed     = #colorLiteral(red: 0.2, green: 0.03921568627, blue: 0.0431372549, alpha: 1) //UIColor(hexString: "#330A0B")
    static let boardGreen   = #colorLiteral(red: 0.1882352941, green: 0.2, blue: 0.03921568627, alpha: 1) //UIColor(hexString: "#30330A")
    static let boardBlue    = #colorLiteral(red: 0.03921568627, green: 0.09803921569, blue: 0.2, alpha: 1) //UIColor(hexString: "#0A1933")
    static let boardOrange  = #colorLiteral(red: 0.2, green: 0.1254901961, blue: 0.03921568627, alpha: 1) //UIColor(hexString: "#33200A")
    
    static let grayBlue     = #colorLiteral(red: 0.2666666667, green: 0.3098039216, blue: 0.3882352941, alpha: 1) //UIColor(hexString: "#444F63")
    
    static let light        = #colorLiteral(red: 0.8509803922, green: 0.8509803922, blue: 0.8509803922, alpha: 1) //UIColor(hexString: "#D9D9D9")
    static let midlight     = #colorLiteral(red: 0.5490196078, green: 0.5490196078, blue: 0.5490196078, alpha: 1) //UIColor(hexString: "#8C8C8C")
    static let middark      = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1) //UIColor(hexString: "#404040")
    static let dark         = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1) //UIColor(hexString: "#1A1A1A")
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
