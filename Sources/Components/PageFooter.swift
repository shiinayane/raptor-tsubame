import Foundation
import Raptor

struct PageFooter: HTML {
    var body: some HTML {
        Tag("footer") {
            Text {
                "Built with "
                Link("Raptor", destination: "https://raptor.build")
            }
            .multilineTextAlignment(.center)
        }
    }
}

