# CorpConnect Architecture

## Project Description

CorpConnect is a platform that facilitates connections and support between employees within the same company. The application enables employees to find colleagues in specific cities and request help from them, fostering collaboration and support networks across different locations.

## Roles

- **Company Admin**: Administrators who can register companies and manage company settings
- **Employee**: Users who can be onboarded to companies, update their location information, find colleagues, and create/respond to help requests

## Main Features

- **Company Registration**: Company admins can register their company on the platform
- **Employee Onboarding**: Employees can be onboarded to their respective companies
- **Location Management**: Employees have both a `baseCity` (home/primary location) and `currentCity` (current working location)
- **Employee Discovery**: Employees can find other employees from the same company who are located in a given city
- **Help Requests**: Employees can create help requests and other employees can respond to provide assistance

## Technology Stack

### Backend
- **Framework**: Spring Boot 3.2.x
- **Database**: MySQL
- **Authentication**: JWT (to be implemented later)
- **ORM**: Spring Data JPA / Hibernate

### Mobile Application
- **Framework**: Flutter (to be developed)

## Database Design (Initial)

### Company
- `id` (Primary Key)
- `name` (Company name)
- `registrationDate` (When the company was registered)
- `status` (Active/Inactive status)
- `createdAt` (Timestamp)
- `updatedAt` (Timestamp)

### Employee
- `id` (Primary Key)
- `email` (Unique identifier for login)
- `firstName`
- `lastName`
- `phoneNumber`
- `baseCity` (Home/primary location)
- `currentCity` (Current working location)
- `companyId` (Foreign Key to Company)
- `role` (Employee role/position)
- `status` (Active/Inactive status)
- `createdAt` (Timestamp)
- `updatedAt` (Timestamp)

### HelpRequest
- `id` (Primary Key)
- `requestorId` (Foreign Key to Employee - who created the request)
- `responderId` (Foreign Key to Employee - who responded, nullable)
- `title` (Request title)
- `description` (Request details)
- `city` (City where help is needed)
- `status` (Pending/In Progress/Completed/Cancelled)
- `requestDate` (When the request was created)
- `responseDate` (When someone responded, nullable)
- `completedDate` (When the request was completed, nullable)
- `createdAt` (Timestamp)
- `updatedAt` (Timestamp)


