//
//  AdjustmentLayerKey.swift
//  
//
//  Created by Hugh Bellamy on 20/01/2021.
//

/// The following sections describe the different types of data available, their keys and their format.
/// Adjustment layer (Photoshop 4.0)
/// Adjustment layers can have one of the following keys:
/// The data for the adjustment layer is the same as the load file formats for each format. See See Additional File
/// Formats for information.
public enum AdjustmentLayerKey: String {
    /// 'SoCo' = Solid Color
    case solidColor = "SoCo"
    
    /// 'GdFl' = Gradient
    case gradient = "GdFl"
    
    /// 'PtFl' = Pattern
    case pattern = "PtFl"
    
    /// 'brit' = Brightness/Contrast
    case brightnessContrast = "brit"

    /// 'levl' = Levels
    case levels = "levl"

    /// 'curv' = Curves
    case curves = "curv"
    
    /// 'expA' = Exposure
    case exposure = "expA"

    /// 'vibA' = Vibrance
    case vibrance = "vibA"

    /// 'hue ' = Old Hue/saturation, Photoshop 4.0
    case hueSaturationOld = "hue "

    /// 'hue2' = New Hue/saturation, Photoshop 5.0
    case hueSaturation = "hue2"

    /// 'blnc' = Color Balance
    case colorBalance = "blnc"

    /// 'blwh' = Black and White
    case blackAndWhite = "blwh"

    /// 'phfl' = Photo Filter
    case photoFilter = "phfl"

    /// 'mixr' = Channel Mixer
    case channelMixer = "mixr"

    /// 'clrL' = Color Lookup
    case colorLookup = "clrL"

    /// 'nvrt' = Invert
    case invert = "nvrt"

    /// 'post' = Posterize
    case posterize = "post"

    /// 'thrs' = Threshold
    case threshold = "thrs"

    /// 'grdm' = Gradient Map
    case gradientMap = "grdm"

    /// 'selc' = Selective color
    case selectiveColor = "selc"
}
