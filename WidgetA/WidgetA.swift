//
//  WidgetA.swift
//  WidgetA
//
//  Created by BAN Jun on R 5/10/19.
//

import WidgetKit
import SwiftUI
import SwiftSparql
import Charts

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), idol1: nil, idol2: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, idol1: nil, idol2: nil)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let endpoint = URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!
        let query1 = SelectQuery(
            where: WhereClause(patterns: subject(Var("idol"))
                .rdfTypeIsImasIdol()
                .rdfsLabel(is: "橘ありす")
                .rdfsLabel(is: Var("name"))
                .schemaHeight(is: Var("height"))
                .optional {$0.imasColor(is: Var("color"))}
                .triples),
            limit: 1)
        let query2 = SelectQuery(
            where: WhereClause(patterns: subject(Var("idol"))
                .rdfTypeIsImasIdol()
                .rdfsLabel(is: Var("name"))
                .schemaHeight(is: Var("height"))
                .optional {$0.imasColor(is: Var("color"))}
                .triples),
            order: [.by(.RAND)],
            limit: 100)

        do {
            let idol1: Idol? = try await Request(endpoint: endpoint, select: query1).fetch().first
            let idol2: [Idol] = try await Request(endpoint: endpoint, select: query2).fetch()
            guard !idol2.isEmpty else { return Timeline(entries: [], policy: .atEnd) }

            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for offset in 0 ..< 300 {
                let entryDate = Calendar.current.date(byAdding: .minute, value: offset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, configuration: configuration,
                                        idol1: idol1, idol2: idol2[offset % idol2.count])
                entries.append(entry)
            }

            return Timeline(entries: entries, policy: .atEnd)
        } catch {
            return Timeline(entries: [], policy: .atEnd)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent

    let idol1: Idol?
    let idol2: Idol?
}

struct Idol: Codable {
    var name: String
    var height: Double
    var color: String?

    var cgColor: CGColor? {
        guard let hex = (color.flatMap {Int($0, radix: 16)}) else { return nil }
        return CGColor(srgbRed: CGFloat(hex >> 16 & 0xff) / 255,
                       green: CGFloat(hex >> 8 & 0xff) / 255,
                       blue: CGFloat(hex >> 0 & 0xff) / 255,
                       alpha: 1)
    }
}

struct WidgetAEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            let idols = [entry.idol1, entry.idol2].compactMap {$0}
            Chart(idols, id: \.name) { idol in
                let color = idol.cgColor.map {Color(cgColor: $0)} ?? Color.gray.opacity(0.2)

                BarMark(
                    x: .value("name", idol.name),
                    y: .value("height", idol.height))
                .foregroundStyle(LinearGradient(colors: [color.opacity(0.75), color], startPoint: .init(x: 0, y: 1), endPoint: .init(x: 0, y: 0.25)))
                .cornerRadius(4)
                .annotation(position: .top) {
                    Text("\(Int(idol.height))").font(.system(size: 8))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    let text = idols[value.index].name
                    AxisValueLabel(text, orientation: .automatic)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                }
            }
        }
    }
}

struct WidgetA: Widget {
    let kind: String = "WidgetA"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WidgetAEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    WidgetA()
} timeline: {
    let 橘ありす = Idol(name: "橘ありす", height: 141, color: "5881C1")
    let 橘ありす2 = Idol(name: "橘ありす2", height: 151, color: "5881C1")
    let 橘ありす3 = Idol(name: "橘ありす3", height: 161, color: "5881C1")
    SimpleEntry(date: .now, configuration: .smiley, idol1: 橘ありす, idol2: 橘ありす2)
    SimpleEntry(date: .now, configuration: .starEyes, idol1: 橘ありす, idol2: 橘ありす3)
}
