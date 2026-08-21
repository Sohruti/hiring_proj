from rest_framework import generics

from .models import StudentOnboarding
from .serializers import StudentOnboardingSerializer


class StudentOnboardingCreateAPIView(generics.CreateAPIView):
    queryset = StudentOnboarding.objects.all()
    serializer_class = StudentOnboardingSerializer
