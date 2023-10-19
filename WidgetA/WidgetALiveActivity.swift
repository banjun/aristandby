//
//  WidgetALiveActivity.swift
//  WidgetA
//
//  Created by BAN Jun on R 5/10/19.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WidgetAAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WidgetALiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetAAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WidgetAAttributes {
    fileprivate static var preview: WidgetAAttributes {
        WidgetAAttributes(name: "World")
    }
}

extension WidgetAAttributes.ContentState {
    fileprivate static var smiley: WidgetAAttributes.ContentState {
        WidgetAAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WidgetAAttributes.ContentState {
         WidgetAAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WidgetAAttributes.preview) {
   WidgetALiveActivity()
} contentStates: {
    WidgetAAttributes.ContentState.smiley
    WidgetAAttributes.ContentState.starEyes
}
