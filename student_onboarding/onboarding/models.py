from django.db import models


class StudentOnboarding(models.Model):
    """A minimal record created only after deterministic onboarding approval."""

    student_id = models.PositiveIntegerField()
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    email = models.EmailField()
    age = models.PositiveSmallIntegerField()
    tenant_code = models.CharField(max_length=64)
    consent_confirmed = models.BooleanField()
    onboarding_approved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "student_onboarding"

    def __str__(self):
        return f"{self.student_id}: {self.first_name} {self.last_name}"
