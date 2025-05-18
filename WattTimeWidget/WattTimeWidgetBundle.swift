//
//  WattTimeWidgetBundle.swift
//  WattTimeWidget
//
//  Created by Andrew Palmer on 5/18/25.
//

import WidgetKit
import SwiftUI

@main
struct WattTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        WattTimeWidget()
        WattTimeWidgetControl()
    }
}
