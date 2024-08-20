# Secure Video Player App with Face Recognition

This repository contains the code for a **Flutter**-based video player application that integrates a **face recognition machine learning model** to enhance security. The app uses facial recognition to automatically access a user's profile, ensuring that no one else can access their content. Additionally, the app's database and login credentials are securely managed using **AWS services**.

## Overview

The Secure Video Player App is designed to offer personalized video playback while safeguarding user profiles through advanced facial recognition technology. By leveraging the **mobile FaceNet TensorFlow Lite** model, the app provides a seamless and secure experience, where only the authorized user can access their profile and video content.

### Key Features
- **Facial Recognition Security:** Uses a FaceNet-based TensorFlow Lite model to identify and authenticate users based on their facial features.
- **Automatic Profile Access:** Automatically logs users into their profile upon successful facial recognition, providing a personalized video experience.
- **AWS Integration:** Manages user data, login credentials, and media storage securely using AWS cloud services.
- **High-Quality Video Playback:** Supports various video formats with smooth playback and user-friendly controls.

## Project Structure

- `lib/` - Contains the main Flutter application code, including the UI, facial recognition integration, and video player functionality.
- `assets/` - Stores the TensorFlow Lite model for facial recognition.
- `amplify/` - Configuration and scripts related to AWS services for user management and database integration.

## Installation

To set up the app, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/secure-video-player-app.git
   ```
2. **Navigate to the project directory:**
   ```bash
   cd secure-video-player-app
   ```
3. **Install the necessary dependencies:**
   ```bash
   flutter pub get
   ```

4. **Set up AWS credentials:**
   - Configure your AWS credentials and update the necessary configurations in the `amplify/` directory.

5. **Run the application:**
   ```bash
   flutter run
   ```

## Usage

- Upon launching the app, the user will be prompted to allow access to the device's camera for facial recognition.
- The FaceNet model will process the facial features and match them with the stored profiles.
- If a match is found, the user is automatically logged into their profile, and the video player screen is displayed.

## Face Recognition Model

The app uses a **TensorFlow Lite** implementation of the FaceNet model for efficient and accurate facial recognition on mobile devices. This model ensures that the facial recognition process is quick, reliable, and secure, providing a robust security layer to the application.

## AWS Integration

The application is integrated with **AWS** services to manage user profiles, store login credentials, and securely handle video data. AWS provides the necessary cloud infrastructure to ensure data privacy and security.

## Acknowledgements

We would like to thank the open-source community and contributors to TensorFlow and AWS for their incredible tools and libraries that made this project possible.

---

Feel free to adjust any specific details or add additional sections as needed!
