# Student Current-Month Attendance API

## Endpoint

```http
GET /api/student/attendance
```

Live URL:

```text
https://averroesint.com/averroes_school_erp/api/student/attendance
```

The endpoint always returns attendance from the first day of the current month through the current date, using the server timezone `Asia/Dhaka`. The student is identified from the bearer token; do not send a student ID in the URL or query string.

## Request headers

```http
Authorization: Bearer {access_token}
Accept: application/json
```

Use the access token returned by `POST /api/login`.

## Success response

```json
{
  "status": "success",
  "data": {
    "student": {
      "student_id": 296,
      "student_uid": "2026296",
      "student_name": "Example Student",
      "roll_no": 12,
      "session": {
        "id": 7,
        "name": "2026-2027",
        "is_current": true
      },
      "class": {
        "id": 5,
        "name": "Class 3"
      },
      "section": {
        "id": 14,
        "name": "Aqua"
      }
    },
    "month": {
      "value": "2026-08",
      "label": "August 2026",
      "from": "2026-08-01",
      "to": "2026-08-31",
      "timezone": "Asia/Dhaka"
    },
    "summary": {
      "calendar_days_to_date": 31,
      "recorded_days": 20,
      "present": 16,
      "absent": 2,
      "late": 1,
      "leave": 1,
      "not_recorded": 11,
      "device_punch_days": 17,
      "attendance_percentage": 89.47
    },
    "attendance": [
      {
        "date": "2026-08-31",
        "day": "Monday",
        "status": "P",
        "status_label": "Present",
        "is_recorded": true,
        "is_today": true,
        "source": "formal_and_device",
        "check_in": "07:42:18",
        "check_out": "13:21:09",
        "total_punches": 2,
        "remarks": null
      }
    ]
  },
  "message": "Current month attendance loaded.",
  "request_id": "example-request-id"
}
```

The values above are examples. The actual month, student, attendance and summary values come from the server.

## Attendance statuses

| Code | Label | Meaning |
| --- | --- | --- |
| `P` | Present | Present in formal attendance or at least one valid device punch exists |
| `A` | Absent | Formally marked absent by the school |
| `L` | Late | Formally marked late |
| `H` | Leave | Formally marked leave |
| `N` | Not recorded | No formal attendance and no device punch exists for that date |

Do not display `N` as Absent. It can represent a weekend, holiday, future school processing, or a date when attendance was not entered.

## Source values

| Source | Meaning |
| --- | --- |
| `formal` | Saved in the school attendance register |
| `device` | Derived from biometric/device punches |
| `formal_and_device` | Formal attendance exists and device punch details are also available |
| `none` | No attendance data exists for that date |

Formal attendance is authoritative when both sources exist. Device punches still appear as `check_in`, `check_out`, and `total_punches`.

If only one device punch exists, it is returned as `check_in` and `check_out` is `null`. When multiple punches exist, the first punch is check-in and the last punch is check-out.

## Attendance percentage

```text
(Present + Late) / (Present + Late + Absent) × 100
```

Leave and Not-recorded dates are excluded. The value is `null` when there are no applicable recorded days.

## Common errors

| HTTP status | Meaning |
| --- | --- |
| `401` | Bearer token is missing, invalid, revoked, or expired |
| `403` | Student account is inactive or an unassigned class/section was requested |
| `409` | The student has no enrollment |
| `500` | Server could not complete the request; provide `request_id` when reporting it |

No database update or new SQL migration is required for this endpoint.
