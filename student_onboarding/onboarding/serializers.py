from rest_framework import serializers

from .models import StudentOnboarding


class StudentOnboardingSerializer(serializers.ModelSerializer):
    """Validates a small, explicit student onboarding payload.

    DCYN (Decision Criteria: Yes/No): approve only if every field is valid and
    the student has explicitly confirmed consent.
    """

    student_id = serializers.IntegerField(required=True, min_value=1)
    first_name = serializers.CharField(required=True, min_length=1, max_length=50)
    last_name = serializers.CharField(required=True, min_length=1, max_length=50)
    email = serializers.EmailField(required=True, max_length=254)
    age = serializers.IntegerField(required=True, min_value=16, max_value=100)
    tenant_code = serializers.RegexField(
        required=True,
        regex=r"^[A-Za-z0-9_-]{1,64}$",
        max_length=64,
        error_messages={
            "invalid": "tenant_code may contain only letters, numbers, hyphens, and underscores."
        },
    )
    consent_confirmed = serializers.BooleanField(required=True)
    onboarding_approved = serializers.BooleanField(read_only=True)

    class Meta:
        model = StudentOnboarding
        fields = [
            "student_id",
            "first_name",
            "last_name",
            "email",
            "age",
            "tenant_code",
            "consent_confirmed",
            "onboarding_approved",
            "created_at",
        ]
        read_only_fields = ["created_at", "onboarding_approved"]

    def validate(self, attrs):
        self._validate_exact_json_types()

        # DCYN decision: consent is a strict Yes/No gate. A record is created
        # only for Yes (true) after all other field checks have passed.
        if attrs["consent_confirmed"] is not True:
            raise serializers.ValidationError(
                {"consent_confirmed": "Consent must be confirmed for onboarding approval."}
            )

        return attrs

    def _validate_exact_json_types(self):
        """Reject coercion such as '18' for an integer or 1 for a boolean."""

        expected_types = {
            "student_id": int,
            "first_name": str,
            "last_name": str,
            "email": str,
            "age": int,
            "tenant_code": str,
            "consent_confirmed": bool,
        }
        errors = {}

        for field_name, expected_type in expected_types.items():
            value = self.initial_data.get(field_name)
            if field_name in self.initial_data and type(value) is not expected_type:
                errors[field_name] = [
                    f"Must be a JSON {expected_type.__name__}; type coercion is not allowed."
                ]

        if errors:
            raise serializers.ValidationError(errors)

    def create(self, validated_data):
        validated_data["onboarding_approved"] = True
        return StudentOnboarding.objects.create(**validated_data)
