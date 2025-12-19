# Pulse Authentication Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         PULSE APP                                │
│                      (lib/main.dart)                             │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              Theme Configuration                        │    │
│  │  • AppTheme.lightTheme (Material Design 3)             │    │
│  │  • Google Fonts (Open Sans + DM Sans)                  │    │
│  │  • Color Scheme (Primary, Secondary, Background)       │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              Routing System                             │    │
│  │  • Named Routes: /, /role-selection, /login            │    │
│  │  • onGenerateRoute: /register (with role arg)          │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                           │
└─────────────────────────────────────────────────────────────────┘

         ┌──────────────────────────────────────┐
         │      1. ENTRY PAGE (/)               │
         │  ┌────────────────────────────────┐  │
         │  │  • Pulse Logo + Wave Animation │  │
         │  │  • "Get Started" Button        │  │
         │  │  • "Login" Button              │  │
         │  └────────────────────────────────┘  │
         └───────────┬──────────────┬───────────┘
                     │              │
          Get Started│              │Login
                     │              │
         ┌───────────▼──────────────┼───────────┐
         │                          │           │
         │                          │           │
┌────────▼────────────┐             │  ┌────────▼─────────────┐
│  2. ROLE SELECTION  │             │  │    4. LOGIN PAGE     │
│   (/role-selection) │             │  │      (/login)        │
│                     │             │  │                      │
│  ┌───┬───┐          │             │  │  ┌────────────────┐ │
│  │ P │ D │ 2x2 Grid │             │  │  │ Email Field    │ │
│  ├───┼───┤          │             │  │  │ Password Field │ │
│  │ S │ A │ Cards    │             │  │  │ Remember Me    │ │
│  └───┴───┘          │             │  │  │ Forgot Pass?   │ │
│                     │             │  │  │ [Login Button] │ │
│  [Next Button]      │             │  │  └────────────────┘ │
└──────┬──────────────┘             │  └──────────┬──────────┘
       │                            │             │
       │Next                        │             │Success
       │                            │             │
┌──────▼──────────────┐             │  ┌──────────▼──────────┐
│  3. REGISTER PAGE   │             │  │   DASHBOARD         │
│    (/register)      │             │  │  (To be connected)  │
│                     │             │  │                     │
│  ┌────────────────┐ │             │  │  Based on Role:     │
│  │ Full Name      │ │             │  │  • Patient → Home   │
│  │ Email          │ │             │  │  • Doctor → Doctor  │
│  │ Phone          │ │─────────────┘  │  • Staff → Staff    │
│  │ Address        │ │ Register       │  • Admin → Admin    │
│  │ Blood Type     │ │ Success        │                     │
│  │ Password       │ │                └─────────────────────┘
│  │ Confirm Pass   │ │
│  │ [Register Btn] │ │
│  └────────────────┘ │
└─────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    REUSABLE COMPONENTS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────┐  ┌───────────────┐  ┌──────────────────┐   │
│  │ PrimaryButton │  │CustomTextField│  │    RoleCard      │   │
│  ├───────────────┤  ├───────────────┤  ├──────────────────┤   │
│  │ • Filled      │  │ • Text Input  │  │ • Icon + Label   │   │
│  │ • Outlined    │  │ • Password    │  │ • Selectable     │   │
│  │ • Loading     │  │ • Dropdown    │  │ • Animated       │   │
│  │ • Icon        │  │ • Validation  │  │ • 4 Roles        │   │
│  └───────────────┘  └───────────────┘  └──────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    CORE CONFIGURATION                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐    │
│  │  AppColors   │  │  AppTheme    │  │  AppConstants     │    │
│  ├──────────────┤  ├──────────────┤  ├───────────────────┤    │
│  │ • Primary    │  │ • Text Theme │  │ • Routes          │    │
│  │ • Background │  │ • Input      │  │ • User Roles      │    │
│  │ • Secondary  │  │ • Buttons    │  │ • Validation      │    │
│  │ • Dark Text  │  │ • Cards      │  │ • Assets          │    │
│  └──────────────┘  └──────────────┘  └───────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    DATA FLOW (To be implemented)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Register Flow:                                                  │
│  User fills form → Validate → Firebase Auth createUser →        │
│  → Save to Firestore → Navigate to Login                        │
│                                                                  │
│  Login Flow:                                                     │
│  User enters credentials → Validate → Firebase Auth signIn →    │
│  → Fetch user data → Route to dashboard based on role           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

LEGEND:
─────────  Navigation Flow
P = Patient, D = Doctor, S = Staff, A = Admin
