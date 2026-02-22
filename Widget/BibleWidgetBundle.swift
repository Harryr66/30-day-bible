import WidgetKit
import SwiftUI

@main
struct BibleWidgetBundle: WidgetBundle {
    var body: some Widget {
        BibleWidget()
        BibleLockScreenWidget()
    }
}
