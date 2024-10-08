
import SwiftUI
import Charts
import SwiftData
import Foundation

struct StressDatePickerView: View {
    @ObservedObject var viewModel: JournalViewModel
    
    @State var selectedDay = Date()
    @State var page = "day"
    
    var body: some View {
        
        let endDate = Calendar.current.startOfDay(for: selectedDay.addingTimeInterval(86400))
        let dayStartDate = Calendar.current.startOfDay(for: selectedDay)
        let weekStartDate = Calendar.current.startOfDay(for: selectedDay.addingTimeInterval(-86400*6))
        let monthStartDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
        
        ZStack {
            Color("Prim")
                .ignoresSafeArea()// Background
            
            
            VStack {
                HStack {
                    Text("Day")
                        .padding(7)
                        .frame(maxWidth: .infinity)
                        .background(page == "day" ? Color("Tint") : Color("Prim"))
                        .foregroundColor(page == "day" ? Color("Sec") : Color("Sec"))
                        .clipShape(.rect(cornerRadius:5))
                        .onTapGesture {
                            page = "day"
                        }
                    
                    Text("Week")
                        .padding(7)
                        .frame(maxWidth: .infinity)
                        .background(page == "week" ? Color("Tint") : Color("Prim"))
                        .foregroundColor(page == "week" ? Color("Sec") : Color("Sec"))
                        .clipShape(.rect(cornerRadius:5))
                        .onTapGesture {
                            page = "week"
                        }
                    
                    Text("Month")
                        .padding(7)
                        .frame(maxWidth: .infinity)
                        .background(page == "month" ? Color("Tint") : Color("Prim"))
                        .foregroundColor(page == "month" ? Color("Sec") : Color("Sec"))
                        .clipShape(.rect(cornerRadius:5))
                        .onTapGesture {
                            page = "month"
                        }
                    
                }
                .font(.system(15))
                
                HStack {
                    
                    if page == "week" {
                        
                        Text(weekStartDate, format: .dateTime.day().month().year())
                        Text(" to")
                        
                    } else if page == "month" {
                        
                        Text(monthStartDate, format: .dateTime.day().month().year())
                        Text(" to")
                        
                    }
                    
                    DatePicker("", selection: $selectedDay, displayedComponents: [.date])
                        .labelsHidden()
                    
                } //Hstack
                .foregroundStyle(Color("Sec"))
                .font(.system(18))
                
                
                TabView(selection: $page) { // Using TabView as a work around for Dynamic Query
                    DayStressView(startsOn: dayStartDate, endsOn: endDate, viewModel: viewModel)
                        .tag("day")
                    
                    WeekStressView(startsOn: weekStartDate, endsOn: endDate, viewModel: viewModel)
                        .tag("week")
                    
                    MonthStressView(startsOn: monthStartDate, endsOn: endDate)
                        .tag("month")
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                              
            } // VStack
        } //ZStack
    }
}



struct DayStressView: View {
    
    @ObservedObject var viewModel: JournalViewModel
    
    @Query var allLogs: [stressLog]
    
    @Query var dailyStressLog: [stressLog]
    @Query var dayBeforeStressLog: [stressLog]
    
    
    init(startsOn startDate: Date, endsOn endDate: Date, viewModel: JournalViewModel) {
        
        let dayBefore = startDate.addingTimeInterval(-86400)
        
        let todayPredicate = #Predicate<stressLog> {
            startDate <= $0.logDate &&
            $0.logDate < endDate
        }
        
        let dayBeforePredicate = #Predicate<stressLog> {
            dayBefore <= $0.logDate &&
            $0.logDate < startDate
            
        }
        
        self.viewModel = viewModel
        _dailyStressLog = Query(filter: todayPredicate, sort: \.logDate)
        _dayBeforeStressLog = Query(filter: dayBeforePredicate, sort: \.logDate)
    }
    
    
    var body: some View {
                
        ZStack {
            
            Color("Prim")
                .ignoresSafeArea()// Background
            
            ScrollView {
                                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))]) {
                    if dailyStressLog.count > 0 {
                        
                        Chart {
                            
                            ForEach(dailyStressLog) { log in
                                LineMark(
                                    x: .value("Date", log.logDate),
                                    y: .value("Stress", log.stressLevel)
                                )
                                .interpolationMethod(.linear)
                                .symbol(.square)
                                .foregroundStyle(Color("Sec"))
                                
                            } // ForEach
                            
                            
                        } // Chart
                        .chartYAxis {
                            
                            AxisMarks(
                                values: [0, 5, 10]
                            ) {
                                AxisValueLabel()
                                    .foregroundStyle(Color("Sec")) // change the color for  readability
                                    .font(.system(10))
                            }
                            
                            AxisMarks(
                                values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                            ) {
                                AxisGridLine()
                                    .foregroundStyle(Color("Sec"))
                            }
                            
                        }
                        .chartXVisibleDomain(length: 86400) // https://stackoverflow.com/questions/77236097/swift-charts-chartxvisibledomain-hangs-or-crashes (measured in seconds)
                        .chartXAxis {
                            AxisMarks(values: .stride(by:.hour, count:3)) { // https://zenn.dev/matsuei/articles/812d0476aa573f
                                
                                AxisValueLabel(format:.dateTime.hour())
                                    .foregroundStyle(Color("Sec"))
                                    .font(.system(10))
                                
                                AxisGridLine()
                                    .foregroundStyle(Color("Sec"))
                            }
                            AxisMarks(values:.stride(by:.day, count:1)) {
                                
                                AxisValueLabel()
                                    .foregroundStyle(Color("Sec"))
                                    .font(.system(10))
                                    .offset(x:-10, y:15)
                            }
                        }
                        .padding(30)
                        .background(Color("Tint"))
                        .clipShape(.rect(cornerRadius: 20))
                        .frame(width:350, height: 350)
                        .chartXScale(range: .plotDimension(padding: 10))
                        .chartYScale(domain: 0 ... 10, range: .plotDimension(padding: 10))
                        
                    } else {
                        
                        Text("No Data")
                            .frame(width: 350)
                    }
                    
                    // Data Analysis
                    
                    LazyVGrid(columns: [GridItem(alignment: .topLeading), GridItem(alignment: .topLeading)]) {
                        
                        AnalysisView(data: dailyStressLog, beforeData: dayBeforeStressLog, duration: "day")
                        
                    }// LazyVGrid
                    .padding(10)
                    .background(Color("Tint"))
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(width:350)
                    
                    // Average stress level by time of day
                    TimeOfDayBarChartView(data: allLogs)
                    
                } //LazyVGrid
                
                
            } // scrollview
            .foregroundStyle(Color("Sec"))
            .font(.system(18))
            
        }//ZStack
        
        
    } // Body
} // StressView

struct WeekStressView: View {
    @ObservedObject var viewModel: JournalViewModel

    
    @Query var allLogs: [stressLog]
    
    
    @Query var weeklyStressLog: [stressLog]
    @Query var weekBeforeStressLog: [stressLog]
    
    init(startsOn startDate: Date, endsOn endDate: Date, viewModel: JournalViewModel) {
        
        let dayBefore = startDate.addingTimeInterval(-86400*7)
        let predicateDailyLog = #Predicate<stressLog> {
            startDate <= $0.logDate &&
            $0.logDate < endDate
        }
        
        let predicateDayBefore = #Predicate<stressLog> {
            dayBefore <= $0.logDate &&
            $0.logDate < startDate
            
        }
        
        self.viewModel = viewModel
        _weeklyStressLog = Query(filter: predicateDailyLog, sort: \.logDate)
        _weekBeforeStressLog = Query(filter: predicateDayBefore, sort: \.logDate)
    }
    
    var body: some View {
        
        ZStack {
            
            Color("Prim")
                .ignoresSafeArea()// Background
            
            ScrollView {
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum:350))]) {
                    
                    if weeklyStressLog.count > 0 {
                        
                        Chart {
                            ForEach(weeklyStressLog) { log in
                                
                                LineMark(
                                    x: .value("Date", log.logDate),
                                    y: .value("Stress", log.stressLevel)
                                )
                                .interpolationMethod(.linear)
                                .symbol(.square)
                                .foregroundStyle(Color("Sec"))
                                
                            } // ForEach
                        } // Chart
                        .chartYAxis {
                            AxisMarks(
                                values: [0, 5, 10]
                            ) {
                                AxisValueLabel()
                                    .foregroundStyle(Color("Sec")) // change the color for  readability
                                    .font(.system(10))

                            }
                            
                            AxisMarks(
                                values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                            ) {
                                AxisGridLine()
                                    .foregroundStyle(Color("Sec"))
                            }

                        }
                        .chartXVisibleDomain(length: 86400*7) // https://stackoverflow.com/questions/77236097/swift-charts-chartxvisibledomain-hangs-or-crashes (measured in seconds)
                        .chartXAxis {
                            
                            AxisMarks(
                                preset: .aligned, position: .bottom,
                                values: .stride(by:.day, count:1), content:
                                    {
                                        AxisValueLabel(format: .dateTime.weekday().day()) // TODO: it somehow doesn't show the last date, looks like I need to crate chartXAxis values manually
                                            .foregroundStyle(Color("Sec"))
                                            .font(.system(10))

                                        
                                        AxisGridLine()
                                            .foregroundStyle(Color("Sec"))
                                    })
                            
                        }
                        .padding(30)
                        .background(Color("Tint"))
                        .clipShape(.rect(cornerRadius: 20))
                        .frame(width: 350, height:350)
                        .chartXScale(range: .plotDimension(padding: 10))
                        .chartYScale(domain: 0 ... 10, range: .plotDimension(padding: 10))
                        
                    } else {
                        
                        Text("No Data")
                        
                    }
                    
                    LazyVGrid(columns:  [GridItem(alignment: .topLeading), GridItem(alignment: .topLeading)]) {
                        
                        AnalysisView(data: weeklyStressLog, beforeData: weekBeforeStressLog, duration: "week")
                        
                    }// LazyVGrid
                    .padding(10)
                    .background(Color("Tint"))
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(width: 350)
                    
                    
                    // Average stress by day of the week
                    WeekdayBarChart(data: allLogs)
                    
                }
                
                
            } // ScrollView
            .font(.system(18))
            .foregroundStyle(Color("Sec"))
            
        }
        
    }
}

struct MonthStressView: View {
    
    @Query var thisMonthStressLog: [stressLog]
    @Query var lastMonthStressLog: [stressLog]
    var numOfDaysInMonth: Int
    
    
    init(startsOn startDate: Date, endsOn endDate: Date) {
        let monthBefore = Calendar.current.date(byAdding: .month, value: -1, to: startDate)!
        
        let thisMonthPredicate = #Predicate<stressLog> {
            startDate < $0.logDate &&
            $0.logDate <= endDate
        }
        
        let lastMonthPredicate = #Predicate<stressLog> {
            monthBefore < $0.logDate &&
            $0.logDate <= startDate
            
        }
        
        _thisMonthStressLog = Query(filter: thisMonthPredicate, sort: \.logDate)
        _lastMonthStressLog = Query(filter: lastMonthPredicate, sort: \.logDate)
        numOfDaysInMonth = Calendar.current.numOfDaysInBetween(from: startDate, to: endDate)
    }
    
    var body: some View {
        
        ZStack {
            
            Color("Prim")
                .ignoresSafeArea()// Background
            
            ScrollView {
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))]) {
                    
                    if thisMonthStressLog.count > 0 {
                        
                        Chart {
                            ForEach(thisMonthStressLog) { log in
                                
                                LineMark(
                                    x: .value("Date", log.logDate),
                                    y: .value("Stress", log.stressLevel)
                                )
                                .interpolationMethod(.linear)
                                .symbol(.square)
                                .foregroundStyle(Color("Sec"))
                                
                            } // ForEach
                        } // Chart
                        .chartYAxis {
                            AxisMarks(
                                values: [0, 5, 10]
                            ) {
                                AxisValueLabel()
                                    .foregroundStyle(Color("Sec")) // change the color for  readability
                                    .font(.system(10))
                            }
                            
                            AxisMarks(
                                values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                            ) {
                                AxisGridLine()
                                    .foregroundStyle(Color("Sec"))
                            }
                        }
                        .chartXVisibleDomain(length: 86400*numOfDaysInMonth) // https://stackoverflow.com/questions/77236097/swift-charts-chartxvisibledomain-hangs-or-crashes (measured in seconds)
                        .chartXAxis {AxisMarks(
                            preset: .aligned, position: .bottom,
                            values: .stride(by:.day, count:3), content:
                                {
                                    AxisValueLabel(format: .dateTime.day().month())
                                        .foregroundStyle(Color("Sec"))
                                        .font(.system(10))
                                    
                                    AxisGridLine()
                                        .foregroundStyle(Color("Sec"))
                                })
                        }
                        .padding(30)
                        .background(Color("Tint"))
                        .clipShape(.rect(cornerRadius: 20))
                        .frame(width:350, height:350)
                        .chartXScale(range: .plotDimension(padding: 10))
                        .chartYScale(domain: 0 ... 10, range: .plotDimension(padding: 10))
                        
                    } else {
                        
                        Text("No Data")
                        
                    }
                    
                    LazyVGrid(columns:  [GridItem(alignment: .topLeading), GridItem(alignment: .topLeading)]) {
                        
                        AnalysisView(data: thisMonthStressLog, beforeData: lastMonthStressLog, duration: "month")
                        
                    }// LazyVGrid
                    .padding(10)
                    .background(Color("Tint"))
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(width:350)
                    
                }
                
            } // ScrollView
            .font(.system(18))
            .foregroundStyle(Color("Sec"))
            
        }
        
    }
}



struct AnalysisView : View {
    let data:[stressLog]
    let beforeData:[stressLog]
    var dataSortedFromLargest: [stressLog] {
        return data.sorted { $0.stressLevel > $1.stressLevel }
    }
    
    let periodInPast = ["day": "yesterday", "week": "last week", "month": "last month"]
    let duration: String // I am not sure if this is correct.
    
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            Text("Average: ")
                .font(.system(18))
            
            if data.count > 0 { // If data available for selected day
                
                let avgStressString = String(format: "%.2f", stressLog.getStressAvg(dayStressLogs: data)) // round to 2dp
                
                Text("\(avgStressString)")
                    .foregroundStyle(Color("Sec"))
            } else {
                Text("No Data")
                
            }
        }
        .padding(10)
        .foregroundStyle(Color("Sec"))
        .font(.systemSemiBold(20))
        
        
        VStack (alignment: .leading) {
            
            Text("Trend:")
                .font(.system(18))
            
            if data.count > 0
                && beforeData.count > 0 {  // If data available for both selected day and day before.
                
                Text("\(stressLog.calculatePercentage(previous: stressLog.getStressAvg(dayStressLogs: data), current: stressLog.getStressAvg(dayStressLogs: beforeData))) from \(periodInPast[duration] ?? "yesterday")")
                
            } else {
                Text("No Data")
            }
            
        }
        .padding(10)
        .foregroundStyle(Color("Sec"))
        .font(.systemSemiBold(20))
        
        
        
        VStack(alignment: .leading) {
            
            Text("Maximum:")
                .font(.system(18))
            
            if dataSortedFromLargest.count > 0 {
                
                Text("\(String(format: "%.2f", dataSortedFromLargest[0].stressLevel))")
                
                if duration == "day" {
                    
                    Text(" at ")
                    Text(dataSortedFromLargest[0].logDate, format: .dateTime.hour().minute()) // show date and weekday
                    
                } else {
                    
                    Text(" on ")

                    Text(dataSortedFromLargest[0].logDate, format: .dateTime.day().month().weekday()) // show date and weekday
                }
                
            } else {
                Text("No Data")
            }
            
        }
        .foregroundStyle(Color("Sec"))
        .font(.systemSemiBold(20))
        .padding(10)
        
        VStack(alignment: .leading) {
            
            Text("Minimum:")
                .font(.system(18))
            
            if dataSortedFromLargest.count > 0 {
                
                Text("\(String(format: "%.2f", dataSortedFromLargest[dataSortedFromLargest.count - 1].stressLevel)) on")
                
                if duration == "day" {
                    Text( dataSortedFromLargest[dataSortedFromLargest.count - 1].logDate, format: .dateTime.hour().minute()) // show hour and minute
                    
                } else {
                    Text( dataSortedFromLargest[dataSortedFromLargest.count - 1].logDate, format: .dateTime.day().month().weekday()) // show date and weekday
                }
                
            } else {
                Text("No Data")
            }
            
        }
        .foregroundStyle(Color("Sec"))
        .font(.systemSemiBold(20))
        .padding(10)
        
    }
}


struct WeekdayBarChart: View {
    var data:[stressLog]
    
    var body: some View {
        
        let weekdayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let weekdayAvgs = stressLog.calcWeekdayAvgs(dayStressLogs: data)
        
        var weekdayData:[(String, Double)] { // Create an array
            Array(zip(weekdayNames, weekdayAvgs))
        }
        
        Text("Average Stress Level by Day of the Week")
        
        Chart (weekdayData, id:\.0) { tuple in
            BarMark(
                x: .value("Weekday", tuple.0),
                y: .value("Stress", tuple.1)
            )
            .foregroundStyle(Color("Sec"))
            
        } // Chart
        .chartXAxis {
            AxisMarks(values: .automatic) { // https://zenn.dev/matsuei/articles/812d0476aa573f
                
                AxisValueLabel()
                    .foregroundStyle(Color("Sec"))
                    .font(.system(10))
            }
        }
        .chartYAxis {
            
            AxisMarks(
                values: [0, 5, 10]
            ) {
                AxisValueLabel()
                    .foregroundStyle(Color("Sec"))
                    .font(.system(10))
            }
            
            AxisMarks(
                values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            ) {
                AxisGridLine()
                    .foregroundStyle(Color("Sec"))
            }
            
        }
        .padding(30)
        .background(Color("Tint"))
        .clipShape(.rect(cornerRadius: 20))
        .frame(width:350, height:350)
        .foregroundStyle(Color("Sec"))
        .chartXScale(range: .plotDimension(padding: 10))
        .chartYScale(domain: 0 ... 10, range: .plotDimension(padding: 10))
        
    }
}

struct TimeOfDayBarChartView: View {
    
    var data:[stressLog]
    
    var body: some View {
        
        let timeSpans = ["0-3", "3-6", "6-9", "9-12", "12-15", "15-18", "18-21", "21-24"]
        let timeOfDayAvgs = stressLog.calcTimeOfDayAvgs(dayStressLogs: data)
        
        var timeOfDayData:[(String, Double)] {
            Array(zip(timeSpans, timeOfDayAvgs))
        }
        
        
        Text("Average Stress Level by Time of the Day")
        
        Chart (timeOfDayData, id:\.0) { tuple in
            BarMark(
                x: .value("Weekday", tuple.0),
                y: .value("Stress", tuple.1)
            )
            .foregroundStyle(Color("Sec"))
            
        } // Chart
        .chartXAxis {
            AxisMarks(values: .automatic) { // https://zenn.dev/matsuei/articles/812d0476aa573f
                
                AxisValueLabel()
                    .foregroundStyle(Color("Sec"))
                    .font(.system(10))
            }
        }
        .chartYAxis {
            
            AxisMarks(
                values: [0, 5, 10]
            ) {
                AxisValueLabel()
                    .foregroundStyle(Color("Sec"))
                    .font(.system(10))
            }
            
            AxisMarks(
                values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            ) {
                AxisGridLine()
                    .foregroundStyle(Color("Sec"))
            }
            
        }
        .padding(30)
        .background(Color("Tint"))
        .clipShape(.rect(cornerRadius: 20))
        .frame(width:350, height:350)
        .foregroundStyle(Color("Sec"))
        .chartXScale(range: .plotDimension(padding: 10))
        .chartYScale(domain: 0 ... 10, range: .plotDimension(padding: 10))
        
    }
}




