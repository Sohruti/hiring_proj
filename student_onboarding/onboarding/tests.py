from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import StudentOnboarding


class StudentOnboardingAPITests(APITestCase):
    def setUp(self):
        self.url = reverse("student-onboarding")
        self.valid_payload = {
            "student_id": 1001,
            "first_name": "Amina",
            "last_name": "Patel",
            "email": "amina.patel@example.com",
            "age": 18,
            "tenant_code": "TENANT_A",
            "consent_confirmed": True,
        }

    def test_valid_payload_creates_approved_record(self):
        response = self.client.post(self.url, self.valid_payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["onboarding_approved"])
        record = StudentOnboarding.objects.get(student_id=1001)
        self.assertTrue(record.onboarding_approved)

    def test_required_field_returns_error_and_creates_no_record(self):
        payload = self.valid_payload.copy()
        payload.pop("email")

        response = self.client.post(self.url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", response.data)
        self.assertEqual(StudentOnboarding.objects.count(), 0)

    def test_string_age_and_integer_boolean_are_rejected(self):
        payload = self.valid_payload | {"age": "18", "consent_confirmed": 1}

        response = self.client.post(self.url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("age", response.data)
        self.assertIn("consent_confirmed", response.data)
        self.assertEqual(StudentOnboarding.objects.count(), 0)

    def test_range_and_length_limits_are_enforced(self):
        payload = self.valid_payload | {"age": 15, "first_name": "A" * 51}

        response = self.client.post(self.url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("age", response.data)
        self.assertIn("first_name", response.data)
        self.assertEqual(StudentOnboarding.objects.count(), 0)

    def test_dcyn_no_consent_rejects_onboarding(self):
        payload = self.valid_payload | {"consent_confirmed": False}

        response = self.client.post(self.url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("consent_confirmed", response.data)
        self.assertEqual(StudentOnboarding.objects.count(), 0)
