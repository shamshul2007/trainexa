/// Utility class to map between UI-friendly values and database values
class ProfileValueMappings {
  // Sex mappings
  static const Map<String, String> sexUiToDb = {
    'Male': 'male',
    'Female': 'female',
    'Other': 'other',
  };
  
  static const Map<String, String> sexDbToUi = {
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
  };

  // Experience level mappings
  static const Map<String, String> experienceUiToDb = {
    'Beginner': 'beginner',
    'Intermediate': 'intermediate',
    'Advanced': 'advanced',
  };
  
  static const Map<String, String> experienceDbToUi = {
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
  };

  // Primary goal mappings
  static const Map<String, String> goalUiToDb = {
    'Lose Weight': 'weight_loss',
    'Build Muscle': 'muscle',
    'Get Stronger': 'strength',
    'Improve Endurance': 'endurance',
    'General Fitness': 'toned',
  };
  
  static const Map<String, String> goalDbToUi = {
    'weight_loss': 'Lose Weight',
    'muscle': 'Build Muscle',
    'strength': 'Get Stronger',
    'endurance': 'Improve Endurance',
    'toned': 'General Fitness',
    'hybrid': 'General Fitness', // Map hybrid to General Fitness as fallback
    'stress': 'General Fitness', // Map stress to General Fitness as fallback
    'maintain': 'General Fitness', // Map maintain to General Fitness as fallback
  };

  // Helper methods
  static String sexToDb(String uiValue) => sexUiToDb[uiValue] ?? uiValue.toLowerCase();
  static String sexToUi(String dbValue) => sexDbToUi[dbValue] ?? dbValue;
  
  static String experienceToDb(String uiValue) => experienceUiToDb[uiValue] ?? uiValue.toLowerCase();
  static String experienceToUi(String dbValue) => experienceDbToUi[dbValue] ?? dbValue;
  
  static String goalToDb(String uiValue) => goalUiToDb[uiValue] ?? uiValue.toLowerCase();
  static String goalToUi(String dbValue) => goalDbToUi[dbValue] ?? dbValue;
}
