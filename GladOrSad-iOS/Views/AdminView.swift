//
//  AdminView.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 7/3/23.
//

import SwiftUI
import CoreData

struct AdminView: View {
    @Environment(\.managedObjectContext) private var dataContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\SettingsButton.index, order: .forward)], predicate: nil, animation: .default)
    private var settingsButtonsList: FetchedResults<SettingsButton>
    
    @State private var buttonDialogShowing = false
    @State private var selectedButton: SettingsButton? = nil
    
    @State private var deleteButtonAlertShowing = false
    @State private var settingsSavedAlertShowing = false
    @State private var dataExportedAlertShowing = false
    @State private var deleteButtonTitle = ""
    @State private var deleteButtonId:UUID?
    
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        ZStack{
            Color("SWA-BoldBlue").ignoresSafeArea()
            ScrollView{
                VStack {
                    Section(header: Text("Quiz Definition").font(.title).fontWeight(.bold)){
                        VStack{
                            
                            SettingsTextField(
                                text: $settingsViewModel.deviceName,
                                label: "Device Name",
                                prompt: "The name for the device in the quiz"
                            )
                            SettingsTextField(
                                text: $settingsViewModel.quizName,
                                label: "Quiz Name",
                                prompt: "The name of the quiz"
                            )
                            SettingsTextField(
                                text: $settingsViewModel.location,
                                label: "Location",
                                prompt: "Where the quiz is located"
                            )
                            SettingsTextField(
                                text: $settingsViewModel.caption,
                                label: "Quiz Caption",
                                prompt: "The caption to display to the viewer"
                            )
                            SettingsTextField(
                                text: $settingsViewModel.prompt,
                                label: "Quiz Prompt",
                                prompt: "The prompt to display to the viewer"
                            )
                            
                            HStack{
                                Text("Max Columns").frame(width: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                                Picker("", selection: $settingsViewModel.maxColumns) {
                                    ForEach(1...6, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                                .pickerStyle(.inline)
                                .background(Color("SWA-White"))
                                .cornerRadius(5.0)
                                .frame(width: 100.0, height:100.0)
                                Spacer()
                            }.textFieldStyle(.roundedBorder).frame(minWidth: 700.0, alignment: .leading)
                            HStack{
                                Text("Background Color").frame(minWidth: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                                VStack{
                                    ColorPicker(selection: $settingsViewModel.background) {
                                    }
                                }.frame(maxWidth: 25.0)
                                Spacer()
                            }.frame(minWidth: 700.0, alignment: .leading)
                            HStack{
                                Text("Caption Color").frame(minWidth: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                                VStack{
                                    ColorPicker(selection: $settingsViewModel.captionColor) {
                                    }
                                }.frame(maxWidth: 25.0)
                                Spacer()
                            }.frame(minWidth: 700.0, alignment: .leading)
                            HStack{
                                Text("Prompt Color").frame(minWidth: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                                VStack{
                                    ColorPicker(selection: $settingsViewModel.promptColor) {
                                    }
                                }.frame(maxWidth: 25.0)
                                Spacer()
                            }.frame(minWidth: 700.0, alignment: .leading)
                        }.textFieldStyle(.roundedBorder)
                    }.ignoresSafeArea(.keyboard)
                    Section(header: Text("Buttons").font(.title).fontWeight(.bold)) {
                        VStack{
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: settingsButtonsList.count < settingsViewModel.maxColumns ? settingsButtonsList.count : settingsViewModel.maxColumns), spacing: 20.0) {
                                ForEach(settingsButtonsList) { button in
                                    Button(action: {
                                        selectedButton = button
                                        buttonDialogShowing = true
                                    }) {
                                        ZStack {
                                            Color.clear
                                                .frame(width: CGFloat(button.width), height: CGFloat(button.height))
                                            
                                            VStack(spacing: 5) { // Adjust the spacing as needed
                                                let frameWidth = button.title == nil || button.title == "" ? CGFloat(button.width) : CGFloat(button.width * 0.4)
                                                if let imageData = button.image, let image = UIImage(data: imageData) {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: frameWidth)
                                                }
                                                
                                                if let title = button.title {
                                                    Text(title)
                                                        .foregroundColor(Color(hex: button.titleColor ?? "FFFFFF"))
                                                        .font(.custom("SouthwestSans-Bold", size: 32))
                                                }
                                            }
                                            
                                            Button(action: {
                                                verifyDelete(button: button)
                                            }){
                                                Image(systemName: "minus.circle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30.0)
                                                    .foregroundColor(Color("SWA-SunriseYellow"))
                                                    .overlay(
                                                        Circle()
                                                            .inset(by: 1) // inset value should be same as lineWidth in .stroke
                                                            .stroke(Color("SWA-MidnightBlue"), lineWidth: 1)
                                                    )
                                            }.frame(width: CGFloat(button.width), height: CGFloat(button.height), alignment: .topTrailing)
                                            
                                        }
                                        
                                    }
                                    .tint(Color(hex: button.background ?? "000000"))
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxHeight: .infinity)
                            .padding([.leading, .trailing], 20.0)
                            
                            .alert(deleteButtonTitle, isPresented: $deleteButtonAlertShowing, actions: {
                                Button("Yes", role: .none, action: {
                                    removeButton(id: deleteButtonId)
                                    deleteButtonAlertShowing.toggle()
                                })
                                Button("Cancel", role: .cancel, action: {
                                    deleteButtonAlertShowing.toggle()
                                })
                            }, message: {
                                Text("Are you sure?")
                            })
                        }
                    }
                    .foregroundColor(Color("SWA-White")).padding(.top, 10.0)
                    
                    Section(content: {
                        HStack{
                            Spacer()
                            Button(action: {
                                selectedButton = nil
                                print ("selectButton is NIL")
                                buttonDialogShowing = true
                            }){
                                Text("Add Button").fontWeight(.bold)
                            }
                            .foregroundColor(Color("SWA-MidnightBlue"))
                            .buttonStyle(.borderedProminent).tint(Color("SWA-SunriseYellow"))
                            Spacer()
                        }
                        HStack {
                            Button(action: {
                                saveSettings()
                            }){
                                Text("Save Settings").fontWeight(.bold)
                            }.foregroundColor(Color("SWA-MidnightBlue"))
                                .buttonStyle(.borderedProminent).tint(Color("SWA-SunriseYellow"))
                            Button(action: {
                                dataExportedAlertShowing.toggle()
                            }){
                                Text("Export Test Data").fontWeight(.bold)
                            }.foregroundColor(Color("SWA-MidnightBlue"))
                                .buttonStyle(.borderedProminent).tint(Color("SWA-SunriseYellow"))
                        }
                        .alert("Settings", isPresented: $settingsSavedAlertShowing, actions: {
                            Button("Okay", role: .none, action: {
                                settingsSavedAlertShowing = false
                                presentationMode.wrappedValue.dismiss()
                            })
                        }, message: {
                            Text("The settings have been updated.")
                        })
                        .alert("Data Export", isPresented: $dataExportedAlertShowing, actions: {
                            Button("Okay", role: .none, action: {
                                exportData()
                                dataExportedAlertShowing.toggle()
                            })
                            Button("Cancel", role: .cancel, action: {
                                dataExportedAlertShowing.toggle()
                            })
                        }, message: {
                            Text("Export Quiz data and clear local Quiz data storage?")
                        })
                    }).padding([.top, .leading, .trailing], 50.0)
                }.padding([.leading, .trailing], 20.0)
            }.frame(maxHeight: 1080.0)
        }
        .foregroundColor(Color("SWA-White"))
        .sheet(isPresented: $buttonDialogShowing) {
            NewButtonDialogView(isShowing: $buttonDialogShowing, buttonToEdit: $selectedButton, nextIndex: settingsButtonsList.count)
        }
    }
    
    func verifyDelete(button: SettingsButton) {
        deleteButtonId = button.id
        deleteButtonTitle = "Delete Button \(button.title ?? "")"
        deleteButtonAlertShowing.toggle()
    }
    
    func removeButton(id: UUID?) {
        print("Deleting button id \(String(describing: id))")
        settingsButtonsList.forEach { settingsButton in
            if settingsButton.id == id {
                dataContext.delete(settingsButton)
                do {
                    try dataContext.save()
                    print("Button deleted")
                } catch {
                    print("Failed to delete button")
                }
            }
        }
    }
    
    func saveSettings() {
        settingsViewModel.updateSettings()
        do {
            try dataContext.save()
            settingsSavedAlertShowing = true
            print("Settings saved")
        } catch {
            print("Failed to save settings \(error)")
        }
    }
    
    func exportData() {
        UploadDataManager.shared.createAndUploadCsv(dataContext: dataContext) {
            print("******* We exported!!")
        }
    }
}

//struct AdminView_Previews: PreviewProvider {
//    static var previews: some View {
//        AdminView().environment(\.managedObjectContext, DataManager.preview.container.viewContext)
//    }
//}
