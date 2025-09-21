# Architecture

The application follows a **SwiftUI + MVVM** approach.

## Components

- **Model**
  - `UserTask`: Represents a task with ID, title, times, and location.
  - `TaskStore`: ObservableObject that manages tasks in a dictionary grouped by Date.

- **Views**
  - `Home`: Main view showing the weekly calendar and tasks.
  - `TaskRow`: Displays a task entry with edit/remove options.
  - `TaskEditView`: Modal sheet for editing tasks.

## Data Flow

1. User interacts with **Home** view (add/modify/remove).
2. `TaskStore` updates the tasks dictionary.
3. SwiftUI automatically refreshes views bound to `TaskStore`.
