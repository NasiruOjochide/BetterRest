//
//  ContentView.swift
//  BetterRest
//
//  Created by Danjuma Nasiru on 04/01/2023.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var recommendedBedtime: Date {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            //when using picker that uses int range to loop, the value returned to the binding is the index of the loop not the value selected itself
            //            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmount + 4), coffee: Double(coffeeAmount))
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount + 1))
            //with swiftui, you can subtract any value in seconds from a date and get back a new date
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            return sleepTime
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            return Date.now
        }
    }
    var body: some View {
        NavigationView{
            Form{
                Section{
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                }
                
                Section{
                    Text("Desired amount of sleep").font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    //                    Picker("Desired amount of sleep", selection: $sleepAmount, content: {ForEach(4..<13, content: {Text("\($0) hours")})}).pickerStyle(.automatic)
                }
                
                Section{
                    
//                    Text("Daily coffee intake").font(.headline)
                    //                        Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    //                        Picker("Daily coffee intake", selection: $coffeeAmount) {ForEach(1..<21) {$0 == 1 ? Text("1 Cup") : Text("\($0) Cups")}}
                    Picker(selection: $coffeeAmount, content: {ForEach(1..<21) {$0 == 1 ? Text("1 Cup") : Text("\($0) Cups")}}, label: {Text("Daily coffee intake").font(.headline)}).labelsHidden()
                    
                }
                
                Text("Recommended Bedtime is: \(recommendedBedtime.formatted(date: .omitted, time: .shortened))").fontWeight(.bold)
            }.navigationTitle("BetterRest")
//                .toolbar(content: {Button("Calculate", action: calculateBedtime)})
        }
        //        }.alert(alertTitle, isPresented: $showingAlert){
        //            Button("OK") {}
        //        } message: {
        //            Text(alertMessage)
        //        }
    }
    func calculateBedtime() {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            //when using picker that uses int range to loop, the value returned to the binding is the index of the loop not the value selected itself
            //            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmount + 4), coffee: Double(coffeeAmount))
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount + 1))
            
            //with swiftui, you can subtract any value in seconds from a date and get back a new date
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
