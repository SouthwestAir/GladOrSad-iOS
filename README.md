# 😊/😢 GladOrSad-iOS

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) 

[![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)](https://developer.apple.com)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com)
[![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)](https://developer.apple.com)

#### Public feedback collection tool for iOS

## 💡 Concept

An intuitive iPad app developed to gather feedback from Customers and provide admin/configuration features.

## 📜 Background

At Southwest's Innovation lab, we often invite our customers and team members to evaluate our user experience concepts - by physically walking through and interacting with a protoype experience. We built a "Glad or Sad" tool to capture real-time feedback during these walkthroughs.

Users are presented with a question and can instantly provide feedback by selecting one of the available buttons.

![Main Screen](screenshots/01.png)

This first screen is an example of what someone experiencing the walkthrough would see. They are asked a question and then asked to tap one of a series of buttons to submit their feedback. 

![Main Screen](screenshots/02.png)

Submitting an answer goes to a thank you screen, which will reset to the question again after a few seconds.

![Main Screen](screenshots/03.png)

The admin screen appears if you tap a number of times on the Southwest Innovation logo. This allows configuring of the question and answer buttons.

![Main Screen](screenshots/04.png)

The buttons can be changed/removed, new buttons can be added, and the data can be exported.

![Main Screen](screenshots/05.png)

This is an example screen showing the configuration of an individual button.

## ⚙️ Installation Instructions

If you want to set up an AWS lambda (or other microservice, or REST API) to accept the uploaded results from an iPad, you will need to modify the `EnvironmentService.swift` file.

```
var presignedUrl: String {
        switch environment {
        case .dev, .qa:
            return "REPLACE-WITH-URL/putFile"
        case .prod:
            return "REPLACE-WITH-URL/putFile"
        }
    }
    var apiKey: String {
        switch environment {
        case .dev, .qa:
            return "REPLACE-WITH-API-KEY-TO-AWS"
        case .prod:
            return "REPLACE-WITH-API-KEY-TO-AWS"
        }
    }
```

Do not send this file in a pull request as it will be rejected.

## 🚀 Future ideas

We're always innovating! On our "to do" list are a number of enhancements, such as using drag-and-drop to reorder the buttons, visual representation of aggregated feedback for a more in-depth analysis, QR code scanning for hands-free answering, and a verbal (speech recognition and text to speech) question/response option.

## 💻 Contributors

The following members of Technology Innovation contributed to this project:

| ![Matthew Barkley](screenshots/avatar_matthew_barkley.jpg) |
| :---: | 
| Matthew Barkley |
| [![matthewbarkley](https://raster.shields.io/badge/linkedin-%40matthewbarkley-lightblue?logo=linkedin&style=for-the-badge)](https://www.linkedin.com/in/matthewbarkley/) |

| ![Sierra Dugan](screenshots/avatar_sierra_dugan.jpg) |
| :---: | 
| Sierra Dugan |
| [![sierradugandesign](https://raster.shields.io/badge/linkedin-%40sierradugandesign-lightblue?logo=linkedin&style=for-the-badge)](https://www.linkedin.com/in/sierradugandesign/) |

| ![Michael Roth](screenshots/avatar_michael_roth.png) |
| :---: | 
| Michael Roth |
| [![michael-roth](https://raster.shields.io/badge/linkedin-%40michaelroth-lightblue?logo=linkedin&style=for-the-badge)](https://www.linkedin.com/in/michael-roth-7106b91/) |

| ![Jeffrey Berthiaume](screenshots/avatar_jeffrey_berthiaume.png) |
| :---: | 
| Jeffrey Berthiaume |
| [![@jeffreality](https://raster.shields.io/badge/twitter-%40jeffreality-blue?logo=twitter&style=for-the-badge)](https://twitter.com/jeffreality) |
| [![jeffreality](https://raster.shields.io/badge/linkedin-%40jeffreality-lightblue?logo=linkedin&style=for-the-badge)](https://linkedin.com/in/jeffreality) |
| [![jeffrey-berthiaume](https://img.shields.io/badge/Stack_Overflow-FE7A16?style=for-the-badge&logo=stack-overflow&logoColor=white)](https://stackoverflow.com/users/71607/jeffrey-berthiaume) |

| ![Ben Smith](screenshots/avatar_ben_smith.png) |
| :---: | 
| Ben Smith |
| [![benjamin-x-smith-software-eng](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/benjamin-x-smith-software-eng) |

## 📖 Citations

Reference to cite if needed:

```
@software {
	title = {Glad or Sad},
	author = {Technology Innovation},
	affiliation = {Southwest Airlines},
	url = {https://github.com/SouthwestAir/GladOrSad-iOS},
	month = {10},
	year = {2023},
	license: {BSD-3-Clause}
	version: {1.0}
}

```
