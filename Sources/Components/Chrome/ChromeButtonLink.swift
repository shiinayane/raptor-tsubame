import Foundation
import Raptor

struct ChromeButtonLink: HTML {
    let label: String
    let destination: String
    let markerName: String?
    let markerValue: String?
    let isActive: Bool

    init(_ label: String, destination: String, markerName: String? = nil, markerValue: String? = nil, isActive: Bool = false) {
        self.label = label
        self.destination = destination
        self.markerName = markerName
        self.markerValue = markerValue
        self.isActive = isActive
    }

    var body: some HTML {
        if let markerName, let markerValue {
            if isActive {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: true))
                    .attribute("aria-label", label)
                    .attribute("aria-current", "page")
                    .data("nav-current", "true")
                    .data(markerName, markerValue)
            } else {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: false))
                    .attribute("aria-label", label)
                    .data(markerName, markerValue)
            }
        } else {
            if isActive {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: true))
                    .attribute("aria-label", label)
                    .attribute("aria-current", "page")
                    .data("nav-current", "true")
            } else {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: false))
                    .attribute("aria-label", label)
            }
        }
    }
}
