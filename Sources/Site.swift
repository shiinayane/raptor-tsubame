import Foundation
import Raptor

@main
struct RaptorWebsite {
    static func main() async {
        var site = ExampleSite()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ExampleSite: Site {    
    var name = "Hello World"
    var titleSuffix = " – My Awesome Site"
    var url = URL(static: "https://www.example.com")

    var author = "John Appleseed"

    var homePage = Home()
    var layout = MainLayout()
}
