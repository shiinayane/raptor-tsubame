import Foundation
import Raptor

struct MainLayout: Layout {
    var body: some Document {
        Navigation { TopNavigation().body }
        Main {
            content
        }
        Footer { PageFooter() }
    }
}
