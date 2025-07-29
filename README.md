# X_University_IS - project of the "Data Security in Information Systems" course

![Oracle](https://img.shields.io/badge/Oracle-red?style=for-the-badge)
![WinUI 3](https://img.shields.io/badge/WinUI%203-blue?style=for-the-badge)
![MVVM](https://img.shields.io/badge/MVVM-green?style=for-the-badge)


## 🚀 Overview
In this project, we analyze the security policies and the featuring requirements of a university information system. Continuing, we enforce security policies by using Oracle database features such as Role-Based Access Control (RBAC), Virtual Private Database (VPD), Oracle Label Security (OLS), and auditing. We also implement a UI application using WinUI 3 with MVVM pattern to manage the system. This application ensures that security policies are enforced for each user based on their roles and privileges. 

- Course: Data Security in Information Systems
- Team size: 3

## 📁 Project structure
```
.
├── Script/         # scripts to create database, enforce security policies
├── Source/         # UI source code with WinUI 3
├── .gitignore/     
└── README.md    
```
## ✨ Main Features
- Sign in to the system with different roles.
- View and manage data based on user roles.
- Admin
    - Manage user and role of system
    - Grant, revoke privileges on tables, views, procedure,...
- User
    - Manage data related to themselves (follow security policies)
- Enforce security policies for users by using RBAC, VPD, OLS.
- Enforce auditing policy.
- Backup and recovery data by using Oracle tools such as datapump, RMAN.
