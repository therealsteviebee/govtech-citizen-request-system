# Workflow Breakdown

## Step 1: Request Submission
A resident submits a request through a simple form with:
- full name
- email address
- request type
- location
- description

## Step 2: HTTP Trigger Processing
The Azure Function receives the payload and validates required fields.

## Step 3: Jira Ticket Creation
The function builds a Jira issue payload and creates a ticket in Jira Service Management.

## Step 4: Slack Notification
After the Jira issue is created, the function posts a Slack notification to the designated channel.

## Step 5: Tracking and Resolution
Operations or public works staff track the request in Jira through normal workflow states such as:
- Submitted
- In Review
- In Progress
- Resolved

## Suggested Future Enhancements
- Department-based routing logic
- Priority mapping by issue type
- Automatic resident confirmation email
- Dashboard reporting in Power BI or Jira
- GIS or map lookup integration
