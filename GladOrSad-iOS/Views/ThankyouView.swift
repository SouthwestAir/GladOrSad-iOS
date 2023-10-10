//
//  ThankyouView.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 8/6/23.
//

import SwiftUI

struct ThankyouView: View {
    @Environment(\.managedObjectContext) private var dataContext
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var startTime = Date()

    var body: some View {
        ZStack{
            VStack{
                Spacer()
                Text("Thank you for your input!")
                    .font(.custom("SouthwestSans-Bold", size: 64))
                    .foregroundColor(Color("SWA-SunriseYellow"))
                Spacer()
                Text("This feedback will be used to improve your airport experience.")
                    .font(.custom("SouthwestSans-Regular", size: 20))
                    .foregroundColor(Color("SWA-White"))
                Text("We have recorded your response and appreciate your time.")
                    .font(.custom("SouthwestSans-Regular", size: 20))
                    .foregroundColor(Color("SWA-White"))
                HStack{
                    Text("Southwest").font(.custom("SouthwestSans-Bold", size: 20))
                    Text("Innovation").font(.custom("SouthwestSans-Light", size: 20))
                }
                .foregroundColor(Color("SWA-White"))
                .padding(.top, 30.0)
                Spacer()
            }.frame(maxWidth: .infinity)
        }.background(settingsViewModel.background)
            .onReceive(timer) { timeFired in
                print("Countdown \(Int(timeFired.timeIntervalSince(startTime)))")
                if Int(timeFired.timeIntervalSince(startTime)) >= 5 {
                    timer.upstream.connect().cancel()
                    presentationMode.wrappedValue.dismiss()
                }
            }
    }
    
}

//struct ThankyouView_Previews: PreviewProvider {
//    static var previews: some View {
//        ThankyouView().environment(\.managedObjectContext, DataManager.preview.container.viewContext)
//    }
//}
