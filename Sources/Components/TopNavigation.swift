import Foundation
import Raptor

func TopNavigation() -> Navigation {
    Navigation {
        Link("Home", destination: "/")
        Link("Archive", destination: "/archive")
        Link("About", destination: "/about")
    }
}
