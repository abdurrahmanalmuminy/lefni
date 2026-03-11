Map<String, dynamic> lefniOnboarding = {
  "onboarding_id": "lefni_v1",
  "language": "ar",
  "steps": [
    {
      "step": 1,
      "title": "أسفرت وأنورت",
      "description": "منصتك القانونية المتكاملة للربط بين طالبي الاستشارات ونخبة من المحامين المعتمدين.",
      "image_path": "assets/images/welcome.png",
      "button_text": "ابدأ الآن"
    },
    {
      "step": 2,
      "title": "حدد هويتك",
      "description": "هل تبحث عن استشارة قانونية أم ترغب في تقديم خدماتك كخبير؟",
      "roles": [
        {"id": "client", "label": "عميل (أبحث عن محامي)", "icon": "user_icon"},
        {"id": "lawyer", "label": "محامي (أقدم استشارات)", "icon": "legal_icon"}
      ],
      "button_text": "التالي"
    },
    {
      "step": 3,
      "title": "قضاياك تهمنا",
      "description": "نوفر لك الحماية القانونية في مختلف المجالات: الشركات، الأحوال الشخصية، والقضايا الجنائية.",
      "image_path": "assets/images/legal_categories.png",
      "button_text": "استمرار"
    },
    {
      "step": 4,
      "title": "الأمان والخصوصية",
      "description": "بياناتك واستشاراتك مشفرة بالكامل لضمان أقصى درجات السرية والموثوقية.",
      "image_path": "assets/images/security.png",
      "button_text": "إنشاء حساب"
    }
  ],
  "common_ui": {
    "skip_text": "تخطي",
    "back_text": "رجوع",
    "finish_text": "ابدأ رحلتك القانونية"
  }
};