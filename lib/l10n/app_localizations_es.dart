// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Brisyn Focus';

  @override
  String get appTagline => 'Mantente enfocado. Logra más.';

  @override
  String get navigation_home => 'Inicio';

  @override
  String get navigation_timer => 'Temporizador';

  @override
  String get navigation_tasks => 'Tareas';

  @override
  String get navigation_statistics => 'Estadísticas';

  @override
  String get navigation_profile => 'Perfil';

  @override
  String get navigation_settings => 'Ajustes';

  @override
  String get timer_focus => 'Enfoque';

  @override
  String get timer_shortBreak => 'Descanso Corto';

  @override
  String get timer_longBreak => 'Descanso Largo';

  @override
  String get timer_start => 'Iniciar';

  @override
  String get timer_pause => 'Pausar';

  @override
  String get timer_resume => 'Reanudar';

  @override
  String get timer_stop => 'Detener';

  @override
  String get timer_reset => 'Reiniciar';

  @override
  String get timer_skip => 'Saltar';

  @override
  String get timer_sessionComplete => '¡Sesión Completa!';

  @override
  String get timer_breakComplete => '¡Descanso Completo!';

  @override
  String timer_minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timer_seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String timer_sessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
    );
    return '$_temp0';
  }

  @override
  String get timer_preset_quick => 'Rápido';

  @override
  String get timer_preset_standard => 'Estándar';

  @override
  String get timer_preset_deep => 'Profundo';

  @override
  String get timer_preset_custom => 'Personalizado';

  @override
  String get tasks_title => 'Tareas';

  @override
  String get tasks_addTask => 'Agregar Tarea';

  @override
  String get tasks_editTask => 'Editar Tarea';

  @override
  String get tasks_deleteTask => 'Eliminar Tarea';

  @override
  String get tasks_taskName => 'Nombre de la tarea';

  @override
  String get tasks_taskDescription => 'Descripción (opcional)';

  @override
  String get tasks_category => 'Categoría';

  @override
  String get tasks_priority => 'Prioridad';

  @override
  String get tasks_dueDate => 'Fecha de vencimiento';

  @override
  String get tasks_noTasks => 'Sin tareas aún';

  @override
  String get tasks_noTasksDescription =>
      'Agrega tu primera tarea para comenzar';

  @override
  String get tasks_completed => 'Completadas';

  @override
  String get tasks_pending => 'Pendientes';

  @override
  String get tasks_all => 'Todas';

  @override
  String get tasks_today => 'Hoy';

  @override
  String get tasks_upcoming => 'Próximas';

  @override
  String get tasks_overdue => 'Vencidas';

  @override
  String get tasks_priorityHigh => 'Alta';

  @override
  String get tasks_priorityMedium => 'Media';

  @override
  String get tasks_priorityLow => 'Baja';

  @override
  String get tasks_priorityNone => 'Sin prioridad';

  @override
  String get tasks_deleteConfirmTitle => 'Eliminar Tarea';

  @override
  String get tasks_deleteConfirmMessage =>
      '¿Estás seguro de que quieres eliminar esta tarea?';

  @override
  String get tasks_markComplete => 'Marcar como completa';

  @override
  String get tasks_markIncomplete => 'Marcar como incompleta';

  @override
  String get statistics_title => 'Estadísticas';

  @override
  String get statistics_today => 'Hoy';

  @override
  String get statistics_thisWeek => 'Esta Semana';

  @override
  String get statistics_thisMonth => 'Este Mes';

  @override
  String get statistics_allTime => 'Todo el Tiempo';

  @override
  String get statistics_focusTime => 'Tiempo de Enfoque';

  @override
  String get statistics_sessions => 'Sesiones';

  @override
  String get statistics_tasksCompleted => 'Tareas Completadas';

  @override
  String get statistics_currentStreak => 'Racha Actual';

  @override
  String get statistics_longestStreak => 'Racha Más Larga';

  @override
  String get statistics_totalXP => 'XP Total';

  @override
  String get statistics_level => 'Nivel';

  @override
  String statistics_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String statistics_days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get statistics_averageDaily => 'Promedio Diario';

  @override
  String get statistics_mostProductiveDay => 'Día Más Productivo';

  @override
  String get statistics_mostProductiveTime => 'Hora Más Productiva';

  @override
  String gamification_level(int level) {
    return 'Nivel $level';
  }

  @override
  String gamification_xp(int count) {
    return '$count XP';
  }

  @override
  String gamification_streak(int count) {
    return 'Racha de $count días';
  }

  @override
  String get gamification_achievements => 'Logros';

  @override
  String get gamification_badges => 'Insignias';

  @override
  String get gamification_leaderboard => 'Clasificación';

  @override
  String get gamification_challenges => 'Desafíos';

  @override
  String get gamification_levelBeginner => 'Principiante';

  @override
  String get gamification_levelApprentice => 'Aprendiz';

  @override
  String get gamification_levelFocused => 'Enfocado';

  @override
  String get gamification_levelDedicated => 'Dedicado';

  @override
  String get gamification_levelExpert => 'Experto';

  @override
  String get gamification_levelMaster => 'Maestro';

  @override
  String get gamification_levelGrandmaster => 'Gran Maestro';

  @override
  String get gamification_levelLegend => 'Leyenda';

  @override
  String get gamification_levelMythic => 'Mítico';

  @override
  String get gamification_levelTranscendent => 'Trascendente';

  @override
  String get settings_title => 'Ajustes';

  @override
  String get settings_general => 'General';

  @override
  String get settings_timer => 'Temporizador';

  @override
  String get settings_notifications => 'Notificaciones';

  @override
  String get settings_appearance => 'Apariencia';

  @override
  String get settings_account => 'Cuenta';

  @override
  String get settings_about => 'Acerca de';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_themeDark => 'Oscuro';

  @override
  String get settings_themeLight => 'Claro';

  @override
  String get settings_themeSystem => 'Sistema';

  @override
  String get settings_accentColor => 'Color de Acento';

  @override
  String get settings_focusDuration => 'Duración del Enfoque';

  @override
  String get settings_shortBreakDuration => 'Duración del Descanso Corto';

  @override
  String get settings_longBreakDuration => 'Duración del Descanso Largo';

  @override
  String get settings_sessionsBeforeLongBreak =>
      'Sesiones Antes del Descanso Largo';

  @override
  String get settings_autoStartBreaks => 'Iniciar Descansos Automáticamente';

  @override
  String get settings_autoStartNextSession =>
      'Iniciar Siguiente Sesión Automáticamente';

  @override
  String get settings_keepScreenOn => 'Mantener Pantalla Encendida';

  @override
  String get settings_sound => 'Sonido';

  @override
  String get settings_soundEnabled => 'Sonido Habilitado';

  @override
  String get settings_notificationSound => 'Sonido de Notificación';

  @override
  String get settings_vibration => 'Vibración';

  @override
  String get settings_dailyReminder => 'Recordatorio Diario';

  @override
  String get settings_reminderTime => 'Hora del Recordatorio';

  @override
  String get settings_weeklyReview => 'Revisión Semanal';

  @override
  String get settings_privacyPolicy => 'Política de Privacidad';

  @override
  String get settings_termsOfService => 'Términos de Servicio';

  @override
  String get settings_version => 'Versión';

  @override
  String get settings_rateApp => 'Calificar App';

  @override
  String get settings_shareApp => 'Compartir App';

  @override
  String get settings_contactSupport => 'Contactar Soporte';

  @override
  String get settings_logout => 'Cerrar Sesión';

  @override
  String get settings_deleteAccount => 'Eliminar Cuenta';

  @override
  String get auth_login => 'Iniciar Sesión';

  @override
  String get auth_signup => 'Registrarse';

  @override
  String get auth_logout => 'Cerrar Sesión';

  @override
  String get auth_email => 'Correo Electrónico';

  @override
  String get auth_password => 'Contraseña';

  @override
  String get auth_confirmPassword => 'Confirmar Contraseña';

  @override
  String get auth_forgotPassword => '¿Olvidaste tu Contraseña?';

  @override
  String get auth_resetPassword => 'Restablecer Contraseña';

  @override
  String get auth_orContinueWith => 'O continuar con';

  @override
  String get auth_google => 'Google';

  @override
  String get auth_apple => 'Apple';

  @override
  String get auth_alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get auth_dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get auth_createAccount => 'Crear Cuenta';

  @override
  String get auth_welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get auth_getStarted => 'Comenzar';

  @override
  String get premium_title => 'Brisyn Pro';

  @override
  String get premium_subtitle => 'Desbloquea todo tu potencial';

  @override
  String get premium_monthlyPrice => '\$4.99/mes';

  @override
  String get premium_yearlyPrice => '\$39.99/año';

  @override
  String get premium_yearlySavings => 'Ahorra 33%';

  @override
  String get premium_subscribe => 'Suscribirse';

  @override
  String get premium_restore => 'Restaurar Compras';

  @override
  String get premium_feature_cloudSync => 'Sincronización en la Nube';

  @override
  String get premium_feature_cloudSyncDesc =>
      'Sincroniza tus datos en todos tus dispositivos';

  @override
  String get premium_feature_advancedAnalytics => 'Análisis Avanzado';

  @override
  String get premium_feature_advancedAnalyticsDesc =>
      'Reportes detallados e información';

  @override
  String get premium_feature_advancedTasks => 'Tareas Avanzadas';

  @override
  String get premium_feature_advancedTasksDesc =>
      'Tareas recurrentes, subtareas y vista Kanban';

  @override
  String get premium_feature_smartReminders => 'Recordatorios Inteligentes';

  @override
  String get premium_feature_smartRemindersDesc =>
      'Sugerencias de horarios óptimos con IA';

  @override
  String get premium_feature_leaderboards => 'Clasificaciones';

  @override
  String get premium_feature_leaderboardsDesc =>
      'Compite con amigos y usuarios globales';

  @override
  String get premium_feature_challenges => 'Desafíos Semanales';

  @override
  String get premium_feature_challengesDesc =>
      'Completa desafíos para obtener XP extra';

  @override
  String get premium_currentPlan => 'Plan Actual';

  @override
  String premium_expiresOn(String date) {
    return 'Expira el $date';
  }

  @override
  String get common_save => 'Guardar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_done => 'Listo';

  @override
  String get common_next => 'Siguiente';

  @override
  String get common_back => 'Atrás';

  @override
  String get common_skip => 'Saltar';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_loading => 'Cargando...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Éxito';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_yes => 'Sí';

  @override
  String get common_no => 'No';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_noResults => 'No se encontraron resultados';

  @override
  String get common_seeAll => 'Ver Todo';

  @override
  String get common_today => 'Hoy';

  @override
  String get common_yesterday => 'Ayer';

  @override
  String get common_tomorrow => 'Mañana';

  @override
  String get error_generic => 'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get error_network =>
      'Sin conexión a internet. Por favor, verifica tu red.';

  @override
  String get error_auth_invalidEmail =>
      'Por favor, ingresa un correo electrónico válido.';

  @override
  String get error_auth_weakPassword =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get error_auth_emailInUse => 'Este correo electrónico ya está en uso.';

  @override
  String get error_auth_wrongCredentials =>
      'Correo electrónico o contraseña inválidos.';

  @override
  String get error_auth_userNotFound =>
      'No se encontró ninguna cuenta con este correo.';

  @override
  String get onboarding_welcome_title => 'Bienvenido a Brisyn Focus';

  @override
  String get onboarding_welcome_description =>
      'Tu compañero personal de productividad para trabajo enfocado y mejor gestión del tiempo.';

  @override
  String get onboarding_timer_title => 'Temporizador Poderoso';

  @override
  String get onboarding_timer_description =>
      'Usa la técnica Pomodoro para mantenerte enfocado y tomar descansos regulares.';

  @override
  String get onboarding_tasks_title => 'Gestiona Tareas';

  @override
  String get onboarding_tasks_description =>
      'Organiza tu trabajo con tareas, categorías y prioridades.';

  @override
  String get onboarding_gamification_title => 'Mantente Motivado';

  @override
  String get onboarding_gamification_description =>
      'Gana XP, sube de nivel y desbloquea logros mientras te enfocas.';

  @override
  String get onboarding_getStarted => 'Comenzar';
}
