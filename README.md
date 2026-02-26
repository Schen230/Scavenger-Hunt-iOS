# Project 1 - Scavenger Hunt 

Submitted by: Sunny Chen

**Scavenger Hunt** is an application that requires the user to attach photos based on the task. 
After attaching the photo to a task, the app shows the user where that photo was taken in a map.

## Required Features

The following **required** functionality is completed:

- [X] App displays list of hard-coded tasks
- [X] When a task is tapped it navigates the user to a task detail view
- [X] When user adds photo to complete the tasks, it marks the task as complete
- [X] When adding photo of task, the location is added
- [X] User returns to home page (list of tasks) and the status of your task is updated to complete
 
The following **optional** features are implemented:

- [X] User can launch camera to snap a picture	

The following **additional** features are implemented:

- [X] After launching the camera, the app saves the photo to the photo library.

## Video Walkthrough
![RPReplay_Final1725313955](https://github.com/user-attachments/assets/03bfdffa-3d83-4429-8c81-bc1108fb3f0e)

## Notes

Implementing the camera feature was a challenging part of this project. 
There was difficulty in retrieving the location of the photo after the user snaps a picture using the "Open Camera" feature.
The application is able to request access to location services but it is unable to store the location metadata with the photo.
The photo is stored in the user's photo library after they take a picture but the lack of location metadata prevents the user from uploading the photo taken using the application's camera feature.

## License

    Copyright [2024] [Sunny Chen]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
