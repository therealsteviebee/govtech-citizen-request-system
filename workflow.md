# Workflow Breakdown

## Step 1: Request Submission
User submits a service request via form.

## Step 2: Processing
Azure Function receives and parses request data.

## Step 3: Ticket Creation
Function calls Jira API to create a service ticket.

## Step 4: Notification
Slack API sends alert to designated channel.

## Step 5: Tracking
Ticket progresses through Jira workflow lifecycle.
