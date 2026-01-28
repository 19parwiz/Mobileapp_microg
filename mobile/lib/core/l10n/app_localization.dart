/// App localization data structure
/// Defines all translatable strings in the application
/// Supports: English (en), Farsi (fa), Kazakh (kk), Russian (ru)
class AppLocalization {
  final String locale;
  
  // Common strings
  final String appTitle;
  final String home;
  final String profile;
  final String settings;
  final String camera;
  final String ai;
  final String devices;
  final String addDevice;
  final String editDevice;
  final String deleteDevice;
  final String delete;
  final String edit;
  final String goBack;
  final String save;
  final String cancel;
  final String retry;
  final String loading;
  final String error;
  final String noData;
  final String success;
  
  // Device-related strings
  final String myDevices;
  final String deviceDetails;
  final String deviceNotFound;
  final String noDevicesFound;
  final String addYourFirstDevice;
  final String status;
  final String active;
  final String inactive;
  final String location;
  final String description;
  final String deviceType;
  
  // Settings-related strings
  final String appearance;
  final String darkMode;
  final String notifications;
  final String enableNotifications;
  final String preferences;
  final String language;
  final String temperatureUnit;
  final String autoRefresh;
  final String autoRefreshDescription;
  
  // Profile-related strings
  final String editProfile;
  final String updateProfile;
  final String myProfile;
  final String english;
  final String farsi;
  final String kazakh;
  final String russian;
  
  AppLocalization({
    required this.locale,
    required this.appTitle,
    required this.home,
    required this.profile,
    required this.settings,
    required this.camera,
    required this.ai,
    required this.devices,
    required this.addDevice,
    required this.editDevice,
    required this.deleteDevice,
    required this.delete,
    required this.edit,
    required this.goBack,
    required this.save,
    required this.cancel,
    required this.retry,
    required this.loading,
    required this.error,
    required this.noData,
    required this.success,
    required this.myDevices,
    required this.deviceDetails,
    required this.deviceNotFound,
    required this.noDevicesFound,
    required this.addYourFirstDevice,
    required this.status,
    required this.active,
    required this.inactive,
    required this.location,
    required this.description,
    required this.deviceType,
    required this.appearance,
    required this.darkMode,
    required this.notifications,
    required this.enableNotifications,
    required this.preferences,
    required this.language,
    required this.temperatureUnit,
    required this.autoRefresh,
    required this.autoRefreshDescription,
    required this.editProfile,
    required this.updateProfile,
    required this.myProfile,
    required this.english,
    required this.farsi,
    required this.kazakh,
    required this.russian,
  });
}

/// English localization
class EnglishLocalization extends AppLocalization {
  EnglishLocalization()
      : super(
          locale: 'en',
          appTitle: 'Microgreens Management',
          home: 'Home',
          profile: 'Profile',
          settings: 'Settings',
          camera: 'Camera',
          ai: 'AI',
          devices: 'Devices',
          addDevice: 'Add Device',
          editDevice: 'Edit Device',
          deleteDevice: 'Delete Device',
          delete: 'Delete',
          edit: 'Edit',
          goBack: 'Go Back',
          save: 'Save',
          cancel: 'Cancel',
          retry: 'Retry',
          loading: 'Loading...',
          error: 'Error',
          noData: 'No data available',
          success: 'Success',
          myDevices: 'My Devices',
          deviceDetails: 'Device Details',
          deviceNotFound: 'Device not found',
          noDevicesFound: 'No devices found',
          addYourFirstDevice: 'Add your first IoT device to start monitoring',
          status: 'Status',
          active: 'Active',
          inactive: 'Inactive',
          location: 'Location',
          description: 'Description',
          deviceType: 'Device Type',
          appearance: 'Appearance',
          darkMode: 'Dark Mode',
          notifications: 'Notifications',
          enableNotifications: 'Enable Notifications',
          preferences: 'Preferences',
          language: 'Language',
          temperatureUnit: 'Temperature Unit',
          autoRefresh: 'Auto Refresh',
          autoRefreshDescription: 'Automatically refresh sensor data',
          editProfile: 'Edit Profile',
          updateProfile: 'Update Profile',
          myProfile: 'My Profile',
          english: 'English',
          farsi: 'فارسی',
          kazakh: 'Қазақ',
          russian: 'Русский',
        );
}

/// Farsi localization
class FarsiLocalization extends AppLocalization {
  FarsiLocalization()
      : super(
          locale: 'fa',
          appTitle: 'مدیریت ریزپوستان',
          home: 'خانه',
          profile: 'پروفایل',
          settings: 'تنظیمات',
          camera: 'دوربین',
          ai: 'هوش مصنوعی',
          devices: 'دستگاه‌ها',
          addDevice: 'افزودن دستگاه',
          editDevice: 'ویرایش دستگاه',
          deleteDevice: 'حذف دستگاه',
          delete: 'حذف',
          edit: 'ویرایش',
          goBack: 'برگشت',
          save: 'ذخیره',
          cancel: 'انصراف',
          retry: 'تلاش دوباره',
          loading: 'در حال بارگذاری...',
          error: 'خطا',
          noData: 'داده‌ای دردسترس نیست',
          success: 'موفق',
          myDevices: 'دستگاه‌های من',
          deviceDetails: 'جزئیات دستگاه',
          deviceNotFound: 'دستگاه یافت نشد',
          noDevicesFound: 'دستگاهی یافت نشد',
          addYourFirstDevice: 'اولین دستگاه IoT خود را اضافه کنید تا نظارت را شروع کنید',
          status: 'وضعیت',
          active: 'فعال',
          inactive: 'غیرفعال',
          location: 'محل',
          description: 'توضیحات',
          deviceType: 'نوع دستگاه',
          appearance: 'ظاهر',
          darkMode: 'حالت تاریک',
          notifications: 'اطلاعات',
          enableNotifications: 'فعال‌سازی اطلاعات',
          preferences: 'تنظیمات',
          language: 'زبان',
          temperatureUnit: 'واحد دما',
          autoRefresh: 'بازنشانی خودکار',
          autoRefreshDescription: 'بازنشانی خودکار داده‌های سنسور',
          editProfile: 'ویرایش پروفایل',
          updateProfile: 'به‌روزرسانی پروفایل',
          myProfile: 'پروفایل من',
          english: 'English',
          farsi: 'فارسی',
          kazakh: 'Қазақ',
          russian: 'Русский',
        );
}

/// Kazakh localization
class KazakhLocalization extends AppLocalization {
  KazakhLocalization()
      : super(
          locale: 'kk',
          appTitle: 'Микрочалындылардың басқарылуы',
          home: 'Басты бет',
          profile: 'Профиль',
          settings: 'Параметрлер',
          camera: 'Камера',
          ai: 'Жасанды зеңбіреу',
          devices: 'Құрылғылар',
          addDevice: 'Құрылғы қосу',
          editDevice: 'Құрылғыны өңдеу',
          deleteDevice: 'Құрылғыны жою',
          delete: 'Жою',
          edit: 'Өңдеу',
          goBack: 'Артқа қайту',
          save: 'Сохранить',
          cancel: 'Бас тарту',
          retry: 'Қайта әрекет',
          loading: 'Жүктелуде...',
          error: 'Қате',
          noData: 'Деректер қол жетімді емес',
          success: 'Сәтті',
          myDevices: 'Менің құрылғыларым',
          deviceDetails: 'Құрылғы туралы мәліметтер',
          deviceNotFound: 'Құрылғы табылмады',
          noDevicesFound: 'Құрылғы табылмады',
          addYourFirstDevice: 'Бақылауды бастау үшін бірінші IoT құрылғысын қосыңыз',
          status: 'Құрылымы',
          active: 'Белсенді',
          inactive: 'Белсенді емес',
          location: 'Орналасқан жері',
          description: 'Сипаттамасы',
          deviceType: 'Құрылғының түрі',
          appearance: 'Түрі',
          darkMode: 'Қара тақырып',
          notifications: 'Хабарламалар',
          enableNotifications: 'Хабарламаларын қосу',
          preferences: 'Ұйғарымдар',
          language: 'Тіл',
          temperatureUnit: 'Температура бірлігі',
          autoRefresh: 'Автоматты жаңарту',
          autoRefreshDescription: 'Сенсордың деректерін автоматты түрде жаңарту',
          editProfile: 'Профильді өңдеу',
          updateProfile: 'Профильді жаңарту',
          myProfile: 'Менің профилім',
          english: 'English',
          farsi: 'فارسی',
          kazakh: 'Қазақ',
          russian: 'Русский',
        );
}

/// Russian localization
class RussianLocalization extends AppLocalization {
  RussianLocalization()
      : super(
          locale: 'ru',
          appTitle: 'Управление микрозеленью',
          home: 'Главная',
          profile: 'Профиль',
          settings: 'Настройки',
          camera: 'Камера',
          ai: 'ИИ',
          devices: 'Устройства',
          addDevice: 'Добавить устройство',
          editDevice: 'Редактировать устройство',
          deleteDevice: 'Удалить устройство',
          delete: 'Удалить',
          edit: 'Редактировать',
          goBack: 'Вернуться',
          save: 'Сохранить',
          cancel: 'Отмена',
          retry: 'Повторить',
          loading: 'Загрузка...',
          error: 'Ошибка',
          noData: 'Данные недоступны',
          success: 'Успех',
          myDevices: 'Мои устройства',
          deviceDetails: 'Детали устройства',
          deviceNotFound: 'Устройство не найдено',
          noDevicesFound: 'Устройства не найдены',
          addYourFirstDevice: 'Добавьте первое устройство IoT, чтобы начать мониторинг',
          status: 'Статус',
          active: 'Активно',
          inactive: 'Неактивно',
          location: 'Местоположение',
          description: 'Описание',
          deviceType: 'Тип устройства',
          appearance: 'Внешний вид',
          darkMode: 'Темный режим',
          notifications: 'Уведомления',
          enableNotifications: 'Включить уведомления',
          preferences: 'Предпочтения',
          language: 'Язык',
          temperatureUnit: 'Единица температуры',
          autoRefresh: 'Автоматическое обновление',
          autoRefreshDescription: 'Автоматически обновлять данные датчика',
          editProfile: 'Редактировать профиль',
          updateProfile: 'Обновить профиль',
          myProfile: 'Мой профиль',
          english: 'English',
          farsi: 'فارسی',
          kazakh: 'Қазақ',
          russian: 'Русский',
        );
}

/// Localization service to manage app language
/// Supports switching between en, fa, kk, ru
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  LocalizationService._internal();

  static AppLocalization currentLocalization = EnglishLocalization();

  /// Get localization for a specific language code
  static AppLocalization getLocalization(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'fa':
        return FarsiLocalization();
      case 'kk':
        return KazakhLocalization();
      case 'ru':
        return RussianLocalization();
      case 'en':
      default:
        return EnglishLocalization();
    }
  }

  /// Set the current localization and update the app
  static void setLocalization(String languageCode) {
    currentLocalization = getLocalization(languageCode);
  }

  /// Get current localization strings
  static AppLocalization get strings => currentLocalization;

  /// Get all supported language codes
  static List<String> get supportedLanguages => ['en', 'fa', 'kk', 'ru'];

  /// Get language display name
  static String getLanguageName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'fa':
        return currentLocalization.farsi;
      case 'kk':
        return currentLocalization.kazakh;
      case 'ru':
        return currentLocalization.russian;
      case 'en':
      default:
        return currentLocalization.english;
    }
  }
}
