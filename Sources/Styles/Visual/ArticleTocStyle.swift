import Foundation
import Raptor

struct ArticleTocStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .style(.borderRadius(.px(18)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .padding(.vertical, 20)
                .padding(.horizontal, 22)
                .style(.borderRadius(.px(22)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 18, x: 0, y: 10)
        }
    }
}

struct ArticleTocTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.margin(.px(0)))
            .style(.marginBottom(.px(14)))
            .style(.fontSize(.px(13)))
            .fontWeight(.heavy)
            .style(.custom("letter-spacing", value: "0.12em"))
            .style(.textTransform(.uppercase))
            .foregroundStyle(palette.accent)
    }
}

struct ArticleTocListStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.grid))
            .style(.gap(.px(9)))
            .style(.custom("list-style", value: "none"))
            .style(.margin(.px(0)))
            .style(.padding(.px(0)))
    }
}

struct ArticleTocItemStyle: Style {
    let level: ArticleHeadingLevel

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        switch level {
        case .h2:
            content
                .border(palette.accent, width: 3, style: .solid, edges: .leading)
                .style(.paddingLeft(.px(12)))
                .fontWeight(.bold)
                .foregroundStyle(palette.text)
        case .h3:
            content
                .border(.clear, width: 3, style: .solid, edges: .leading)
                .style(.paddingLeft(.px(28)))
                .fontWeight(.medium)
                .foregroundStyle(palette.mutedText)
        }
    }
}

struct ArticleTocLinkStyle: Style {
    let level: ArticleHeadingLevel

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.block))
            .style(.custom("line-height", value: "1.45"))
            .foregroundStyle(level == .h2 ? palette.text : palette.mutedText)
            .textDecoration(.none)
    }
}
