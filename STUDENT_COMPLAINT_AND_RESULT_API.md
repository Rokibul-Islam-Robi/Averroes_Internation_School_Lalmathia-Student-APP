# Averroes Mobile App API Update

## Student Complaints and Published Results

API base URL:

```text
https://averroesint.com/averroes_school_erp/api
```

All endpoints below require the token returned by `POST /api/login`:

```http
Authorization: Bearer {access_token}
Accept: application/json
Content-Type: application/json
```

Common successful response format:

```json
{
  "status": "success",
  "data": {},
  "message": "OK",
  "request_id": "request-trace-id"
}
```

Common error response format:

```json
{
  "status": "error",
  "data": null,
  "message": "Validation or authentication message",
  "request_id": "request-trace-id"
}
```

## Complaint endpoints

### 1. Get departments

```http
GET /api/student/complaint-departments
```

Example response data:

```json
{
  "departments": [
    { "id": 4, "name": "Accounts" },
    { "id": 8, "name": "Academic" }
  ]
}
```

Use the selected `id` as `department_id` when `against_type` is `department`.

### 2. Get employees

```http
GET /api/student/complaint-employees?page=1&per_page=30
GET /api/student/complaint-employees?department_id=8&search=rahman&page=1&per_page=30
```

Query parameters:

| Parameter | Required | Description |
| --- | --- | --- |
| `department_id` | No | Return active employees of one department. |
| `search` | No | Search active employees by name or employee UID. Maximum 100 characters. |
| `page` | No | Default `1`. |
| `per_page` | No | Default `30`, maximum `100`. |

Example response data:

```json
{
  "employees": [
    {
      "id": 41,
      "employee_uid": "EMP-0041",
      "name": "Example Employee",
      "designation": "Officer",
      "department": { "id": 8, "name": "Academic" }
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 30,
    "total": 1,
    "last_page": 1
  }
}
```

### 3. Submit a complaint

```http
POST /api/student/complaints
```

Complaint against a department:

```json
{
  "against_type": "department",
  "department_id": 8,
  "subject": "Delay in receiving an academic document",
  "details": "I submitted the required request on 1 September but have not received an update.",
  "priority": "normal"
}
```

Complaint against an employee:

```json
{
  "against_type": "employee",
  "employee_id": 41,
  "subject": "Need review of an unresolved issue",
  "details": "I contacted the employee regarding the issue and need the matter reviewed.",
  "priority": "high"
}
```

Validation rules:

| Field | Rule |
| --- | --- |
| `against_type` | Required: `department` or `employee`. |
| `department_id` | Required only for a department complaint. Must be an active department. |
| `employee_id` | Required only for an employee complaint. Must be an active employee. |
| `subject` | Required, 5–180 characters. |
| `details` | Required, 10–5000 characters. |
| `priority` | Optional: `low`, `normal`, or `high`; default `normal`. |

A successful submission returns HTTP `201` and the full complaint. The server creates a reference such as `CMP-202609-000123`.

### 4. Get the student's complaints

```http
GET /api/student/complaints?page=1&per_page=30
GET /api/student/complaints?status=under_review&page=1&per_page=30
```

Supported status values:

```text
submitted, under_review, action_taken, resolved, rejected, closed
```

The response contains only complaints belonging to the authenticated student. `internal_note` is never returned.

### 5. Get one complaint

```http
GET /api/student/complaints/{complaintId}
```

Example response data:

```json
{
  "complaint": {
    "id": 123,
    "complaint_no": "CMP-202609-000123",
    "against_type": "department",
    "target": { "type": "department", "id": 8, "name": "Academic" },
    "subject": "Delay in receiving an academic document",
    "details": "Complaint details...",
    "priority": "normal",
    "priority_label": "Normal",
    "status": "under_review",
    "status_label": "Under Review",
    "assigned_to": { "user_id": 15, "name": "Support Officer" },
    "response": {
      "message": "We are reviewing your request.",
      "responded_at": "2026-09-03 13:30:00"
    },
    "submitted_at": "2026-09-03 12:10:00",
    "reviewed_at": "2026-09-03 13:00:00",
    "resolved_at": null,
    "closed_at": null,
    "updated_at": "2026-09-03 13:30:00"
  }
}
```

## Result endpoints

Only exams where `exams.is_published = 1` are returned. The server also verifies that the exam session belongs to the authenticated student's enrollment history.

### 6. Get published result list

```http
GET /api/student/results?page=1&per_page=30
GET /api/student/results?session_id=12&page=1&per_page=30
```

Each list item contains exam information, academic context, summary, and attendance. Subject rows are omitted from the list response.

Example result summary:

```json
{
  "exam": {
    "id": 8,
    "name": "First Term",
    "year": "2026",
    "start_date": "2026-08-01",
    "end_date": "2026-08-12",
    "is_published": true
  },
  "academic_context": {
    "session": { "id": 12, "name": "2026-2027" },
    "class": { "id": 4, "name": "Class 3" },
    "section": { "id": 9, "name": "Aqua" },
    "roll_no": 2026123
  },
  "summary": {
    "subjects_count": 7,
    "subjects_with_marks": 7,
    "full_marks": 700,
    "obtained_marks": 590,
    "percentage": 84.29,
    "overall_grade": "A+",
    "grade_point": 5,
    "remarks": "Excellent",
    "position_in_section": 4,
    "absent_subjects": 0,
    "failed_subjects": 0,
    "has_failed_subject": false,
    "source": "calculated"
  },
  "attendance": {
    "present_days": 85,
    "working_days": 90,
    "percentage": 94.44
  }
}
```

`summary.source` is `published_summary` when an official row exists in `result_summaries`; otherwise it is calculated from the saved subject marks.

### 7. Get result details by exam

```http
GET /api/student/results/{examId}
```

This returns the same result information plus `subjects`:

```json
{
  "subjects": [
    {
      "id": 21,
      "code": "ENG",
      "name": "English",
      "full_marks": 100,
      "pass_marks": 50,
      "marks_entered": true,
      "is_absent": false,
      "homework": 9,
      "class_test": 18,
      "exam": 58,
      "total": 85,
      "highest_in_section": 94,
      "grade": "A+",
      "passed": true
    }
  ]
}
```

When a subject has not been entered yet, `marks_entered` is `false` and its mark, grade, and passed fields are `null`. An absent subject returns `is_absent: true`.

## Important HTTP statuses

| Status | Meaning |
| --- | --- |
| `200` | Request completed. |
| `201` | Complaint created. |
| `401` | Bearer token is missing, invalid, expired, or revoked. |
| `403` | The requested student/session scope is not allowed. |
| `404` | The complaint or published result was not found for this student. |
| `409` | Student enrollment/context is incomplete. |
| `422` | Request fields or query parameters are invalid. |
| `503` | Complaint database migration has not been installed. |

## Recommended app flow

1. Log in and store the bearer token securely.
2. For a complaint, let the student choose Department or Employee.
3. Load departments, or search/filter employees as appropriate.
4. Submit the complaint and save/display `complaint_no`.
5. Use the complaint list for tracking status and school responses.
6. Use the result list for the result screen; call result detail after the student selects an exam.
7. Display only published results. Do not calculate grades or positions again in the app.

