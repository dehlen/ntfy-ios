//
//  Date+Ext.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

public import Foundation

public extension Date {
    func formattedRelativeDateTime(
        dateStyle: Date.FormatStyle.DateStyle = .abbreviated,
        timeStyle: Date.FormatStyle.TimeStyle = .shortened
    ) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return self.formatted(date: .omitted, time: timeStyle)
        } else if calendar.isDateInYesterday(self) {
            return "\(NSLocalizedString("Yesterday", comment: "")), " + self.formatted(date: .omitted, time: timeStyle)
        } else {
            return self.formatted(date: dateStyle, time: timeStyle)
        }
    }
}
