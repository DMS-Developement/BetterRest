//
//  ContentView.swift
//  BetterRest
//
//  Created by David Shimenko on 12/8/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    //    func calculateBedtime() {
    //        do {
    //            let config = MLModelConfiguration()
    //            let model = try SleepCalculator(configuration: config)
    //            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
    //            let hour = (components.hour ?? 0) * 60 * 60
    //            let minute = (components.minute ?? 0) * 60
    //            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeAmount))
    //            let sleepTime = wakeUp - prediction.actualSleep
    //
    //            alertTitle = "Your bedtime is..."
    //            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
    //
    //        } catch {
    //            alertTitle = "Error"
    //            alertMessage = "Sorry, there was a problem calculating your bedtime."
    //        }
    //
    //        showingAlert = true
    //    }
    
    var calculatedBedtime: Date? {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
            return nil
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    HStack {
                        Text("Wakeup time: ").font(.body)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                    }
                }
                
                Section("Desired amount of sleep:") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake: ") {
                    //                    Stepper("^[\(coffeAmount) cup](inflect: true)", value: $coffeAmount, in: 1...20)
                    Picker("Cups of coffee: ", selection: $coffeAmount) {
                        ForEach(1..<21) { number in
                            Text(number == 1 ? "1 cup" : "\(number) cups")
                        }
                    }
                }
                
                Section("Here's when you should go to bed:") {
                    if let bedTime = calculatedBedtime {
                        Text(bedTime.formatted(date: .omitted, time: .shortened))
                    } else {
                        Text("There was a problem calculating your bedtime")
                    }
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .navigationTitle("Better Rest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
        }
    }
}

#Preview {
    ContentView()
}
