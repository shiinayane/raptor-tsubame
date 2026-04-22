import Foundation
import Raptor

struct MainLayout: Layout {
    var body: some Document {
        Main {
            content
            RaptorFooter()
        }
    }
}
