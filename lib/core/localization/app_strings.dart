import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

/// Central translation map.
///
/// Usage:
///   context.tr('add_activity')
///
/// Add new keys here as you migrate screens. Always provide both
/// 'en' and 'es'. If a key is missing for the current language,
/// it falls back to 'en', then to the raw key itself.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _strings = {
    // ─── Common ───────────────────────────────────────────────
    'cancel': {'en': 'Cancel', 'es': 'Cancelar'},
    'save': {'en': 'Save', 'es': 'Guardar'},
    'delete': {'en': 'Delete', 'es': 'Eliminar'},
    'edit': {'en': 'Edit', 'es': 'Editar'},
    'add': {'en': 'Add', 'es': 'Añadir'},
    'done': {'en': 'Done', 'es': 'Hecho'},
    'error': {'en': 'Error', 'es': 'Error'},
    'retry': {'en': 'Retry', 'es': 'Reintentar'},
    'close': {'en': 'Close', 'es': 'Cerrar'},
    'good_morning': {'en': 'Good morning', 'es': 'Buenos días'},
    'good_afternoon': {'en': 'Good afternoon', 'es': 'Buenas tardes'},
    'good_evening': {'en': 'Good evening', 'es': 'Buenas noches'},

    // ─── Settings / Language ──────────────────────────────────
    'settings': {'en': 'Settings', 'es': 'Ajustes'},
    'language': {'en': 'Language', 'es': 'Idioma'},
    'language_system': {'en': 'System', 'es': 'Sistema'},
    'language_english': {'en': 'English', 'es': 'Inglés'},
    'language_spanish': {'en': 'Spanish', 'es': 'Español'},

    // ─── Home / Trips ─────────────────────────────────────────
    'no_trips_yet': {'en': 'No trips yet', 'es': 'Aún no hay viajes'},
    'create_trip_or_join': {
      'en': 'Create your first trip or join\nan existing one with a code',
      'es': 'Crea tu primer viaje o únete\na uno existente con un código',
    },
    'create_trip': {'en': 'Create Trip', 'es': 'Crear viaje'},
    'join_with_code': {'en': 'Join with code', 'es': 'Unirse con código'},
    'archived': {'en': 'Archived', 'es': 'Archivados'},
    'ongoing': {'en': 'Ongoing', 'es': 'En curso'},
    'upcoming': {'en': 'Upcoming', 'es': 'Próximo'},
    'past': {'en': 'Past', 'es': 'Pasado'},
    'past_trip': {'en': 'Past trip', 'es': 'Viaje pasado'},
    'days': {'en': 'days', 'es': 'días'},
    'members': {'en': 'members', 'es': 'miembros'},
    'last_day': {'en': 'Last day', 'es': 'Último día'},
    'starts_tomorrow': {'en': 'Starts tomorrow', 'es': 'Empieza mañana'},
    'days_to_go': {'en': 'days to go', 'es': 'días restantes'},
    'day_of': {'en': 'Day', 'es': 'Día'},
    'of': {'en': 'of', 'es': 'de'},

    // ─── Trip dashboard tabs ──────────────────────────────────
    'timeline': {'en': 'Timeline', 'es': 'Itinerario'},
    'expenses': {'en': 'Expenses', 'es': 'Gastos'},
    'checklist': {'en': 'Checklist', 'es': 'Lista'},

    // ─── Timeline ─────────────────────────────────────────────
    'no_activities_yet': {'en': 'No activities yet', 'es': 'Aún no hay actividades'},
    'swipe_to_add_activity': {
      'en': 'Swipe right on a day to add\nyour first activity',
      'es': 'Desliza a la derecha en un día para\nañadir tu primera actividad',
    },
    'no_days_yet': {'en': 'No days yet', 'es': 'Aún no hay días'},
    'no_days_configured': {
      'en': 'This trip has no days configured yet',
      'es': 'Este viaje todavía no tiene días configurados',
    },

    // ─── Expenses ─────────────────────────────────────────────
    'no_expenses_yet': {'en': 'No expenses yet', 'es': 'Aún no hay gastos'},
    'track_expenses_desc': {
      'en': 'Track what everyone spends\nand split costs easily',
      'es': 'Registra lo que gasta cada uno\ny divide los costes fácilmente',
    },
    'add_expense': {'en': 'Add Expense', 'es': 'Añadir gasto'},
    'total_spent': {'en': 'Total spent', 'es': 'Total gastado'},
    'balances': {'en': 'Balances', 'es': 'Balances'},
    'settlements': {'en': 'Settlements', 'es': 'Liquidaciones'},
    'all_settled_up': {'en': 'All settled up! 🎉', 'es': '¡Todo saldado! 🎉'},
    'gets_back': {'en': 'gets back', 'es': 'recibe'},
    'owes': {'en': 'owes', 'es': 'debe'},

    // ─── Checklist ────────────────────────────────────────────
    'no_items_yet': {'en': 'No items yet', 'es': 'Aún no hay elementos'},
    'checklist_empty_desc': {
      'en': 'Add things to pack or tasks\nto complete before your trip',
      'es': 'Añade cosas que empacar o tareas\npor completar antes del viaje',
    },
    'add_item': {'en': 'Add Item', 'es': 'Añadir elemento'},
    'all_done': {'en': 'All done! 🎉', 'es': '¡Todo listo! 🎉'},

    // ─── Activity card ────────────────────────────────────────
    'edit_activity': {'en': 'Edit Activity', 'es': 'Editar actividad'},
    'add_activity': {'en': 'Add Activity', 'es': 'Añadir actividad'},
    'delete_activity_q': {'en': 'Delete activity?', 'es': '¿Eliminar actividad?'},

    // ─── Trip card swipe actions ──────────────────────────────
    'leave': {'en': 'Leave', 'es': 'Salir'},
    'leave_trip_q': {'en': 'Leave trip?', 'es': '¿Salir del viaje?'},
    'leave_trip_desc': {
      'en': 'You will be removed from "{name}".',
      'es': 'Se te eliminará de "{name}".',
    },
    'delete_trip_q': {'en': 'Delete trip?', 'es': '¿Eliminar viaje?'},
    'delete_trip_desc': {
      'en': 'This will permanently delete "{name}" and all its data.',
      'es': 'Esto eliminará permanentemente "{name}" y todos sus datos.',
    },
    'trip_deleted': {'en': '{name} deleted', 'es': '{name} eliminado'},
    'left_trip': {'en': 'Left {name}', 'es': 'Has salido de {name}'},

    // ─── Invite / Members ─────────────────────────────────────
    'invite_friends': {'en': 'Invite Friends', 'es': 'Invitar amigos'},
    'invite_someone': {'en': 'Invite Someone', 'es': 'Invitar a alguien'},
    'share_invite_code': {'en': 'Share Invite Code', 'es': 'Compartir código'},
    'code_copied': {'en': 'Code copied', 'es': 'Código copiado'},
    'host': {'en': 'Host', 'es': 'Anfitrión'},
    'co_host': {'en': 'Co-host', 'es': 'Coanfitrión'},
    'member': {'en': 'Member', 'es': 'Miembro'},
    'make_co_host': {'en': 'Make co-host', 'es': 'Hacer coanfitrión'},

    // ─── Join trip ────────────────────────────────────────────
    'join_trip': {'en': 'Join Trip', 'es': 'Unirse a viaje'},
    'enter_invite_code': {'en': 'Enter the invite code', 'es': 'Introduce el código de invitación'},
    'invalid_code_format': {'en': 'Invalid invite code format', 'es': 'Formato de código inválido'},
    'enter_invite_code_error': {'en': 'Please enter an invite code', 'es': 'Introduce un código de invitación'},
    'failed_to_join': {'en': 'Failed to join trip', 'es': 'No se pudo unir al viaje'},
    'scan_qr': {'en': 'Scan QR', 'es': 'Escanear QR'},

    // ─── QR Scanner ───────────────────────────────────────────
    'point_at_qr': {'en': 'Point at the trip QR code', 'es': 'Apunta al código QR del viaje'},
    'code_detected': {'en': '✓ Code detected!', 'es': '✓ ¡Código detectado!'},
    'code_format_hint': {'en': 'The code looks like TRVL-XXXXXX', 'es': 'El código tiene el formato TRVL-XXXXXX'},
    'invalid_invite_code': {'en': 'Invalid invite code', 'es': 'Código de invitación inválido'},

    // ─── Auth ─────────────────────────────────────────────────
    'sign_in': {'en': 'Sign In', 'es': 'Iniciar sesión'},
    'sign_up': {'en': 'Sign Up', 'es': 'Registrarse'},
    'continue_with_google': {'en': 'Continue with Google', 'es': 'Continuar con Google'},
    'email': {'en': 'Email', 'es': 'Correo electrónico'},
    'password': {'en': 'Password', 'es': 'Contraseña'},
    'name': {'en': 'Name', 'es': 'Nombre'},
    'or': {'en': 'OR', 'es': 'O'},
    'plan_adventures_together': {
      'en': 'Plan your adventures together',
      'es': 'Planifica tus aventuras juntos',
    },
    'already_have_account': {
      'en': 'Already have an account? Sign In',
      'es': '¿Ya tienes una cuenta? Inicia sesión',
    },
    'no_account_sign_up': {
      'en': "Don't have an account? Sign Up",
      'es': '¿No tienes una cuenta? Regístrate',
    },
  };

  static String get(String key, String languageCode, {Map<String, String>? params}) {
    final entry = _strings[key];
    String value = entry?[languageCode] ?? entry?['en'] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }

    return value;
  }
}

/// Convenience extension for ConsumerWidgets/ConsumerStates: `ref.tr('key')`.
///
/// This reads [effectiveLanguageCodeProvider] reactively, so the widget
/// rebuilds automatically when the user changes language in Settings.
extension TranslationRefX on WidgetRef {
  String tr(String key, {Map<String, String>? params}) {
    final languageCode = watch(effectiveLanguageCodeProvider);
    return AppStrings.get(key, languageCode, params: params);
  }
}

/// Convenience extension for plain BuildContext (non-reactive).
///
/// Use this only in places without access to a WidgetRef (e.g. inside
/// dialogs/sheets builders before reaching a Consumer). It reads the
/// current value once and will NOT rebuild on language change.
extension TranslationContextX on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    final languageCode = ProviderScope.containerOf(this).read(effectiveLanguageCodeProvider);
    return AppStrings.get(key, languageCode, params: params);
  }
}
