//
//  NewButtonDialog.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 7/24/23.
//

import SwiftUI

struct NewButtonDialogView: View {
    @Environment(\.managedObjectContext) private var dataContext

    @Binding var isShowing: Bool
    @Binding var buttonToEdit: SettingsButton?
    var nextIndex: Int?

    @ObservedObject private var newSettingsButton: SettingsButtonViewModel = SettingsButtonViewModel()
    
    @State private var imagePickerShowing = false
    @State private var buttonImage = UIImage()
    @State private var imageSelected = false
    
    var body: some View {
        ZStack{
            Color("SWA-BoldBlue").ignoresSafeArea().opacity(0.4)
            ScrollView{
                HStack{
                    HStack{
                        Text("Name").frame(width: 150.0, alignment: .trailing).padding(.trailing, 10.0)
                        TextField(text: $newSettingsButton.name, prompt: Text("The name for this button")) {
                        }.frame(width: 390.0)
                    }
                }.textFieldStyle(.roundedBorder).frame(width: 550.0)
                HStack{
                    HStack{
                        Text("Title").frame(width: 150.0, alignment: .trailing).padding(.trailing, 10.0)
                        TextField(text: $newSettingsButton.title, prompt: Text("The title for this button")) {
                        }.frame(width: 390.0)
                    }
                }.textFieldStyle(.roundedBorder).frame(width: 550.0)
                HStack{
                    Text("Title Color").frame(width: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                    VStack{
                        ColorPicker(selection: $newSettingsButton.titleColor) {
                        }
                    }.frame(maxWidth: 25.0)
                }.frame(width: 550.0, alignment: .leading)
                HStack{
                    Text("Background Color").frame(width: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                    VStack{
                        ColorPicker(selection: $newSettingsButton.background) {
                        }
                    }.frame(maxWidth: 25.0)
                }.frame(width: 550.0, alignment: .leading)
                HStack{
                    Text("Image").frame(width: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                    HStack{
                        Image(uiImage: self.buttonImage)
                            .resizable()
                            .padding(.all, 4)
                            .frame(width: 100, height: 100)
                            .background(Color.black.opacity(0.2))
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Rectangle())
                        Button(action: {
                            imagePickerShowing.toggle()
                            imageSelected.toggle()
                        }){
                            Text("Select Image").fontWeight(.bold)
                        }.foregroundColor(Color("SWA-MidnightBlue"))
                            .buttonStyle(.borderedProminent).tint(Color("SWA-SunriseYellow"))
                            .sheet(isPresented: $imagePickerShowing) {
                                ImagePicker(selectedImage: $buttonImage)
                            }
                    }.frame(width: 250.0, alignment: .leading)
                }.frame(width: 550.0, alignment: .leading)
                HStack{
                    Text("Index").frame(width: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                    Picker("", selection: $newSettingsButton.index) {
                        ForEach(1...6, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.inline)
                    .background(Color("SWA-White"))
                    .cornerRadius(5.0)
                    .frame(width: 100.0, height:100.0)
                }.textFieldStyle(.roundedBorder).frame(width: 550.0, alignment: .leading)
                HStack{
                    HStack{
                        Text("Width").frame(width: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                        TextField(value: $newSettingsButton.width, format: .number) {
                        }.frame(width: 50.0)
                    }
                }.textFieldStyle(.roundedBorder).frame(width: 550.0, alignment: .leading)
                HStack{
                    HStack{
                        Text("Height").frame(width: 150.0, alignment: .trailing).padding(.trailing, 5.0)
                        TextField(value: $newSettingsButton.height, format: .number) {
                        }.frame(width: 50.0)
                    }
                }.textFieldStyle(.roundedBorder).frame(width: 550.0, alignment: .leading)
                HStack {
                    Button(action: {
                        //Save Button to core data
                        saveNewButton()
                        isShowing = false
                    }){
                        Text("Save Button").fontWeight(.bold)
                    }.foregroundColor(Color("SWA-MidnightBlue"))
                        .buttonStyle(.borderedProminent).tint(Color("SWA-SunriseYellow"))
                    Button(action: {
                        isShowing = false
                    }){
                        Text("Cancel").fontWeight(.bold)
                    }.foregroundColor(Color("SWA-MidnightBlue"))
                        .buttonStyle(.borderedProminent).tint(Color("SWA-SunriseYellow"))
                }.padding(.top, 50.0)
            }
            .padding([.top], 30.0)
            .foregroundColor(Color("SWA-MidnightBlue"))
            .ignoresSafeArea(.keyboard)
        }
        .onAppear{
            initFromButton()
        }
    }
    
    func initFromButton() {
        newSettingsButton.reset()
        if let buttonToEdit = buttonToEdit  {
            newSettingsButton.updateFromSettingsButton(settingsButton: buttonToEdit)
            if let imageData = buttonToEdit.image, let image = UIImage(data: imageData) {
                self.buttonImage = image
            }
        } else if let nextIndex = nextIndex {
            newSettingsButton.index = nextIndex + 1
        }
    }
    
    func saveNewButton() {
        if let buttonToEdit = buttonToEdit {
            newSettingsButton.updateExistingButton(buttonToEdit)
            if imageSelected {
                buttonToEdit.image = buttonImage.pngData()
            }
        } else {
            let newButton = newSettingsButton.newSettingsButton(viewContext: dataContext)
            if imageSelected {
                newButton.image = buttonImage.pngData()
            }
        }

        do {
            try dataContext.save()
            print("Saved button")
        } catch {
            print("Failed to save new button \(error)")
        }
    }


}

//struct NewButtonDialog_Previews: PreviewProvider {
//    static var previews: some View {
//        NewButtonDialogView(isShowing: .constant(true)).environment(\.managedObjectContext, DataManager.preview.container.viewContext)
//    }
//}
