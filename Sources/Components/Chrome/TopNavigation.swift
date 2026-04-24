import Foundation
import Raptor

struct TopNavigation: HTML {
    var body: some HTML {
        Link("Home", destination: SiteRoutes.home)
        Link("Archive", destination: SiteRoutes.archive)
        Link("About", destination: SiteRoutes.about)
    }
}
