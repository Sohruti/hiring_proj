from django.urls import path

from .views import StudentOnboardingCreateAPIView

urlpatterns = [
    path("onboarding/", StudentOnboardingCreateAPIView.as_view(), name="student-onboarding"),
]
