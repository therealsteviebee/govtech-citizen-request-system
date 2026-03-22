🏛️ Citizen Request Automation System (GovTech Demo)

This project simulates a real-world government service request system, where citizens can submit issues (e.g., broken streetlights, potholes), and the system automatically routes, tracks, and notifies relevant departments.

🚀 Overview

This solution demonstrates how modern municipalities can leverage automation and SaaS integrations to streamline service delivery and improve response times.

🧱 Architecture
Frontend: Request submission form
Backend: Azure Functions (HTTP-triggered)
Workflow Engine: Jira Service Management
Notifications: Slack API
Integration Layer: REST APIs + Webhooks

🔄 Workflow
Citizen submits request
Azure Function processes request
Jira ticket is created automatically
Request is routed to appropriate team
Slack notification is triggered
Status tracking (optional enhancement)

🧪 Technologies Used
Azure Functions
PowerShell
Jira REST API
Slack API
Microsoft Graph (optional expansion)

🎯 Purpose
This project was built to demonstrate:
Workflow automation in public-sector environments
SaaS platform integration using APIs
Event-driven architecture design
Scalable service request handling systems

📸 Architecture Diagram
(See /architecture/diagram.png)
