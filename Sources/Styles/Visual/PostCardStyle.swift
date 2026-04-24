import Foundation
import Raptor

struct PostCardStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.padding(.px(18)))
                .style(.lineHeight(1.55))
                .foregroundStyle(Color(red: 56, green: 38, blue: 25))
        } else {
            content
                .style(.padding(.px(22)))
                .style(.lineHeight(1.58))
                .foregroundStyle(Color(red: 56, green: 38, blue: 25))
        }
    }
}
