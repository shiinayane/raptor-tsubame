import Foundation
import Raptor

struct MainLayout: Layout {
    var body: some Document {
        Navigation { TopNavigation() }
        Main {
            content
        }
        Footer { PageFooter() }
    }
}
