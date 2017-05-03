//
//  CalendarVC.swift
//  Fitkeeper
//
//  Created by Erik Myhrberg on 2017-05-02.
//  Copyright © 2017 Erik. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarVC: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthYear: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()

    }
    
    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
    }
}

extension UIViewController: JTAppleCalendarViewDataSource {
    
    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDateStr = formatter.string(from: date)
        
        let startDate = formatter.date(from: startDateStr)
        let endDate = formatter.date(from: "2020 01 01")
        
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
}

extension UIViewController: JTAppleCalendarViewDelegate {
    public func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
        
        return cell
        
    }
    
    public func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        validCell.selectedView.isHidden = false
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateFormattedStr = formatter.string(from: date)
        print("Calendar selected date: \(dateFormattedStr)")
    }
    
    public func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CustomCell else { return }
        validCell.selectedView.isHidden = true
    }
    
    public func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let monthDate = visibleDates.monthDates.first?.date else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        let monthDateStr = formatter.string(from: monthDate)
        
        print("Calendar scrolled to: \(monthDateStr)")
        
    }
    
}
