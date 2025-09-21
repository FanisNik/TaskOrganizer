# Task Organizer – Specification

## Overview
**Task Organizer** is an iOS application built with SwiftUI that allows users to manage their personal tasks in a weekly calendar view.  
The app supports basic operations: **Add Task, Modify Task, Remove Task**.

---

## Features

- **Task Management**
  - Add new tasks
  - Modify existing tasks
  - Remove tasks by date

- **Task Attributes**
  - Title (string)
  - Start Time & End Time (date)
  - Location (string)
  - Unique ID (UUID)

---

## Usage

The program is used through a graphical interface:

- **Add Task** → Tap on the `+` button of a day column.
- **Modify Task** → Tap on an existing task to open the edit sheet.
- **Remove Task** → Tap the trash button on a task.

---

## Data Model

| Entity      | Attributes                                      |
|-------------|-------------------------------------------------|
| UserTask    | id: UUID, title: String, startTime: Date, endTime: Date, location: String |
| TaskStore   | tasks: [Date: [UserTask]]                       |

---

## Limitations
- Tasks are stored in memory only (no persistence).
- No recurring tasks supported.
- No login or multi-user functionality.
