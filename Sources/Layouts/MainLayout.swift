import Foundation
import Raptor

struct MainLayout: Layout {
    var body: some Document {
        TopNavigation()
        Main {
            content
            PageFooter()
        }
    }
}
