//
//  RatingView.swift
//  GladOrSad-iOS
//
//  Created by Jeffrey Berthiaume on 6/29/23.
//

import SwiftUI

struct RatingView: View {
    @Environment(\.managedObjectContext) private var dataContext
    @EnvironmentObject private var dataManager: DataManager

    @FetchRequest(sortDescriptors: [], predicate: nil, animation: .default)
    private var settingsList: FetchedResults<Settings>

    @FetchRequest(sortDescriptors: [SortDescriptor(\SettingsButton.index, order: .forward)], predicate: nil, animation: .default)
    private var settingsButtonsList: FetchedResults<SettingsButton>
    
    @ObservedObject private var settingsViewModel = SettingsViewModel()

    @State private var selectedAnswer: UUID?
    @State private var showSettingsView: Bool = false
    @State private var showThankyouView: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView{
                VStack {
                    HStack {
                        HStack {
                            NavigationLink("", destination:
                                            AdminView(settingsViewModel: settingsViewModel)
                                .environmentObject(dataManager)
                                .environment(\.managedObjectContext, dataContext),
                                           isActive: $showSettingsView
                            ).hidden()
                            Text("Southwest")
                                .font(.custom("SouthwestSans-Bold", size: 20))
                                .gesture(TapGesture(count: 5).onEnded({
                                    showSettingsView = true
                                }))
                                .defersSystemGestures(on: .all)
                            Text("Innovation").font(.custom("SouthwestSans-Light", size: 20))
                            Spacer()
                        }.foregroundColor(Color("SWA-White"))
                            .padding()
                            .frame(maxWidth:.infinity, maxHeight: 50.0, alignment: .top)
                        Spacer()
                        Image("swalogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32.0)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 20))
                    }.frame(height: 75.0)
                    VStack{
                        Text(settingsViewModel.caption)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(settingsViewModel.captionColor)
                            .padding(.top, 50.0)
                            .padding(.bottom, 20)
                        
                        Text(settingsViewModel.prompt)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(settingsViewModel.promptColor)
                            .padding(.bottom, 50)
                    }.frame(height: 150.0)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: settingsButtonsList.count < settingsViewModel.maxColumns ? settingsButtonsList.count : settingsViewModel.maxColumns ), spacing: 20.0) {
                        ForEach(settingsButtonsList) { button in
                            Button(action: {
                                selectedAnswer = button.id
                            }) {
                                ZStack {
                                    Color.clear
                                        .frame(width: CGFloat(button.width), height: CGFloat(button.height))
                                    
                                    VStack(spacing: 5) { // Adjust the spacing as needed
                                        let frameWidth = button.title == nil || button.title == "" ? CGFloat(button.width) : CGFloat(button.width * 0.4)
                                        if let imageData = button.image,
                                           let image = UIImage(data: imageData)  {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: frameWidth)
                                                .opacity(selectedAnswer == button.id ? 0.5 : 1.0)
                                        }
                                        
                                        if let title = button.title {
                                            Text(title)
                                                .foregroundColor(Color(hex: button.titleColor ?? "FFFFFF"))
                                                .font(.custom("SouthwestSans-Bold", size: 32))
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: button.background ?? "000000")?.opacity(selectedAnswer == button.id ? 0.5 : 1.0))
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding(50.0)

                    
                    // Submit button
                    HStack {
                        Button(action: {
                            saveAnswer()
                        }) {
                            Text("Submit")
                                .frame(minWidth: 300.0, minHeight: 60.0)
                                .padding(10.0)
                                .foregroundColor(Color("SWA-MidnightBlue"))
                                .font(.custom("SouthwestSans-Bold", size: 32.0))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("SWA-White"))
                        .cornerRadius(45.0)
                        NavigationLink("",
                                       destination:
                                        ThankyouView(settingsViewModel: settingsViewModel)
                            .environmentObject(dataManager)
                            .environment(\.managedObjectContext, dataContext),
                                       isActive: $showThankyouView
                        ).hidden()
                    }.frame(maxWidth: .infinity, minHeight: 80.0, alignment: .bottom)
                    HStack{
                        Text("This form is used by Southwest Innovation to collect feedback. For questions, please reach out to SWA.Innovations@wnco.com")
                            .foregroundColor(Color("SWA-SummitSilver"))
                            .font(.custom("SouthwestSans-Light", size: 12.0))
                    }.frame(maxWidth: .infinity, alignment: .bottom)
                        .padding(.top, 30.0)
                }
                .frame(maxHeight: .infinity)
            }.onAppear{
                initFromCurrentSettings()
                selectedAnswer = nil
            }.background(settingsViewModel.background)
        }
    }
    
    func saveAnswer() {
        if let selectedAnswer = selectedAnswer {
            settingsButtonsList.forEach { settingsButton in
                if settingsButton.id == selectedAnswer {
                    let quizResponse = QuizResponse(context: dataContext)
                    quizResponse.id = settingsViewModel.id
                    quizResponse.deviceName = settingsViewModel.deviceName
                    quizResponse.quizName = settingsViewModel.quizName
                    quizResponse.quizCaption = settingsViewModel.caption
                    quizResponse.quizPrompt = settingsViewModel.prompt
                    quizResponse.location = settingsViewModel.location
                    quizResponse.quizTime = Int64(Date().timeIntervalSince1970)
                    quizResponse.selectedIndex = Int16(settingsButton.index)
                    quizResponse.selectedName = settingsButton.name
                    quizResponse.selectedTitle = settingsButton.title
                    
                    do{
                        try dataContext.save()
                        showThankyouView.toggle()
                    } catch {
                        print("Error saving QuizResponse!")
                    }
                }
            }
        }
    }
    
    func initFromCurrentSettings() {
        if let currentSettings = settingsList.first {
            settingsViewModel.updateFromSettings(settings: currentSettings)
        }
//        settingsList.forEach { settings in
//            settingsViewModel.updateFromSettings(settings: settings)
//        }
    }
    

}

//struct RatingView_Previews: PreviewProvider {
//    static var previews: some View {
//        RatingView().environment(\.managedObjectContext, DataManager.preview.container.viewContext)
//    }
//}
