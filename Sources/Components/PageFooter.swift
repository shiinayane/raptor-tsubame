import Foundation
import Raptor

struct PageFooter: HTML {
    var body: some HTML {
        Text {
            "Built with "
            Link("Raptor", destination: "https://raptor.build")
        }
        .multilineTextAlignment(.center)
    }
}
