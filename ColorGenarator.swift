//
//  ColorGenarator.swift
//  colorGenTor
//
//  Created by Hoanh An on 7/12/16.
//  Copyright © 2016 Hoanh An. All rights reserved.
//

import Foundation
import UIKit
class ColorGenarator {
    /////////
    static let stepDistance:Float = 3.0
    static let colorOffset:Float = 0.0
    
    static let seedColors = [
        
        ColorGenarator.hexStringToUIColor("009688"),
        ColorGenarator.hexStringToUIColor("039be5"),
//        ColorGenarator.hexStringToUIColor("2196f3"),
        ColorGenarator.hexStringToUIColor("3f51b5"),
        ColorGenarator.hexStringToUIColor("673ab7"),
        ColorGenarator.hexStringToUIColor("e91e63"),
        ColorGenarator.hexStringToUIColor("f44336"),
//        ColorGenarator.hexStringToUIColor("8d6e63"),
        ColorGenarator.hexStringToUIColor("ef6c00"),
        ColorGenarator.hexStringToUIColor("f9a825"),
//        ColorGenarator.hexStringToUIColor("827717"),
        ColorGenarator.hexStringToUIColor("689f38"),
        ColorGenarator.hexStringToUIColor("388e3c"),
        ColorGenarator.hexStringToUIColor("009688")
        ]
    
    static func getColor(index: Int) -> UIColor{
        return mixByStep(index);
    }
    
    static func mixByStep(index:Int) -> UIColor{
        let grandPercentage = (colorOffset + Float(index)*stepDistance*1.618033988749895)%100;
        let rangeStep = 100/Float(seedColors.count-1);
        var colors = getColorsFromSeed(Int(floor(grandPercentage/rangeStep)));
        let percentage = CGFloat(grandPercentage%rangeStep)*CGFloat(seedColors.count-1)/100.0;
    
        var rgb1 : (red:CGFloat, green: CGFloat, blue: CGFloat) = (0,0,0);
        var rgb2 : (red:CGFloat, green: CGFloat, blue: CGFloat) = (0,0,0);
        
        colors[0].getRed(&rgb1.red, green: &rgb1.green, blue: &rgb1.blue, alpha: nil);
        colors[1].getRed(&rgb2.red, green: &rgb2.green, blue: &rgb2.blue, alpha: nil);
        
        let newRed = rgb1.red*(1-percentage) + rgb2.red*percentage;
        let newGreen = rgb1.green*(1-percentage) + rgb2.green*percentage;
        let newBlue = rgb1.blue*(1-percentage) + rgb2.blue*percentage;
        
        return UIColor.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1);
    }
    
    static func getColorsFromSeed(point: Int) -> [UIColor]{
        return [
            seedColors[point],
            seedColors[point+1]
        ]
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}