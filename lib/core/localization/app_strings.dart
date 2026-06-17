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

    // ─── Profile ──────────────────────────────────────────────
    'account': {'en': 'ACCOUNT', 'es': 'CUENTA'},
    'preferences': {'en': 'PREFERENCES', 'es': 'PREFERENCIAS'},
    'name': {'en': 'Name', 'es': 'Nombre'},
    'email': {'en': 'Email', 'es': 'Correo electrónico'},
    'change_password': {'en': 'Change Password', 'es': 'Cambiar contraseña'},
    'dark_mode': {'en': 'Dark Mode', 'es': 'Modo oscuro'},
    'sign_out': {'en': 'Sign Out', 'es': 'Cerrar sesión'},
    'edit_name': {'en': 'Edit Name', 'es': 'Editar nombre'},
    'name_required': {'en': 'Name is required', 'es': 'El nombre es obligatorio'},
    'name_updated': {'en': 'Name updated!', 'es': '¡Nombre actualizado!'},
    'failed_update_name': {'en': 'Failed to update name', 'es': 'Error al actualizar el nombre'},
    'new_password': {'en': 'New Password', 'es': 'Nueva contraseña'},
    'confirm_password': {'en': 'Confirm Password', 'es': 'Confirmar contraseña'},
    'required': {'en': 'Required', 'es': 'Obligatorio'},
    'min_6_chars': {'en': 'Min 6 characters', 'es': 'Mínimo 6 caracteres'},
    'passwords_no_match': {'en': 'Passwords do not match', 'es': 'Las contraseñas no coinciden'},
    'password_updated': {'en': 'Password updated!', 'es': '¡Contraseña actualizada!'},
    'failed_update_password': {'en': 'Failed to update password', 'es': 'Error al actualizar la contraseña'},
    'relogin_required': {
      'en': 'Please sign out and sign in again to change your password',
      'es': 'Por favor cierra sesión y vuelve a iniciarla para cambiar la contraseña',
    },

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
    'all_done': {
      'en': 'All done! 🎉',
      'es': '¡Todo listo! 🎉',
    },

    'progress_done': {
      'en': '{done} of {total} done',
      'es': '{done} de {total} completadas',
    },


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
    'password': {'en': 'Password', 'es': 'Contraseña'},
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
    // ─── Trip dashboard extra ─────────────────────────
    'failed_to_load_trip': {
      'en': 'Failed to load trip',
      'es': 'Error al cargar el viaje',
    },

    'go_back': {
      'en': 'Go back',
      'es': 'Volver',
    },

    'members_count': {
      'en': 'Members',
      'es': 'Miembros',
    },

    'updating_role': {
      'en': 'Updating role...',
      'es': 'Actualizando rol...',
    },

    'member_role_updated': {
      'en': 'Member role updated',
      'es': 'Rol actualizado',
    },

    'error_updating_role': {
      'en': 'Error updating role',
      'es': 'Error al actualizar el rol',
    },

// ─── Share ───────────────────────────────────────
    'share_trip_message': {
      'en': 'Join my trip on Travl! 🌍\nUse code: {code}',
      'es': '¡Únete a mi viaje en Travl! 🌍\nUsa el código: {code}',
    },

    'all_settled': {
      'en': 'All settled up! 🎉',
      'es': '¡Todo saldado! 🎉',
    },

    'delete_expense': {
      'en': 'Delete expense?',
      'es': '¿Eliminar gasto?',
    },

// ─── Expense row ─────────────────────────
    'paid_by_with_count': {
      'en': 'Paid by {name} · {count} people',
      'es': 'Pagado por {name} · {count} personas',
    },

    'expenses_description': {
      'en': 'Track what everyone spends\nand split costs easily',
      'es': 'Controla lo que gasta cada uno\ny divide los costes fácilmente',
    },

    'category': {
      'en': 'Category',
      'es': 'Categoría',
    },

    'title': {
      'en': 'Title',
      'es': 'Título',
    },

    'expense_title_hint': {
      'en': 'e.g., Dinner at restaurant',
      'es': 'ej: Cena en restaurante',
    },

    'title_required': {
      'en': 'Title is required',
      'es': 'El título es obligatorio',
    },

    'currency': {
      'en': 'Currency',
      'es': 'Moneda',
    },

    'amount': {
      'en': 'Amount',
      'es': 'Cantidad',
    },

    'amount_hint': {
      'en': '0.00',
      'es': '0.00',
    },

    'invalid_amount': {
      'en': 'Invalid amount',
      'es': 'Cantidad inválida',
    },

    'amount_greater_than_zero': {
      'en': 'Must be greater than 0',
      'es': 'Debe ser mayor que 0',
    },

    'split_with': {
      'en': 'Split with',
      'es': 'Dividir con',
    },

    'you_label': {
      'en': '{name} (you)',
      'es': '{name} (tú)',
    },

    'each_person_pays': {
      'en': 'Each person pays {currency} {amount}',
      'es': 'Cada persona paga {currency} {amount}',
    },
    // ─── Checklist ─────────────────────────

    'all_done_check': {
      'en': 'All done! 🎉',
      'es': '¡Todo listo! 🎉',
    },

    'progress_done_check': {
      'en': '{done} of {total} done',
      'es': '{done} de {total} completados',
    },

    'progress_fraction': {
      'en': '· {done}/{total}',
      'es': '· {done}/{total}',
    },

    'checklist_empty_description': {
      'en': 'Add things to pack or tasks\nto complete before your trip',
      'es': 'Añade cosas para llevar o tareas\nantes del viaje',
    },

    'add_item_check': {
      'en': 'Add Item',
      'es': 'Añadir ítem',
    },

    'when': {
      'en': 'When',
      'es': 'Cuándo',
    },

    'item': {
      'en': 'Item',
      'es': 'Ítem',
    },

    'item_hint': {
      'en': 'e.g., Pack sunscreen',
      'es': 'ej: Llevar protector solar',
    },
    // ─── Create Trip ─────────────────────────
    'select_start_end_dates': {
      'en': 'Please select both start and end dates',
      'es': 'Selecciona fecha de inicio y fin',
    },

    'failed_create_trip': {
      'en': 'Failed to create trip',
      'es': 'Error al crear el viaje',
    },

    'trip_name': {
      'en': 'Trip Name',
      'es': 'Nombre del viaje',
    },

    'trip_name_hint': {
      'en': 'e.g., Summer in Tokyo',
      'es': 'ej: Verano en Tokio',
    },

    'destination': {
      'en': 'Destination',
      'es': 'Destino',
    },

    'destination_hint': {
      'en': 'e.g., Tokyo, Japan',
      'es': 'ej: Tokio, Japón',
    },

    'dates': {
      'en': 'Dates',
      'es': 'Fechas',
    },

    'start_date': {
      'en': 'Start Date',
      'es': 'Fecha inicio',
    },

    'end_date': {
      'en': 'End Date',
      'es': 'Fecha fin',
    },

    'select_date': {
      'en': 'Select date',
      'es': 'Seleccionar fecha',
    },
    'joined_trip': {
      'en': 'Joined trip: {id}',
      'es': 'Te has unido al viaje: {id}',
    },
    'invite_members': {
      'en': 'Invite Members',
      'es': 'Invitar miembros',
    },

    'share_code_with_friends': {
      'en': 'Share this code with your friends:',
      'es': 'Comparte este código con tus amigos:',
    },
    'edit_trip': {
      'en': 'Edit Trip',
      'es': 'Editar viaje',
    },

    'trip_updated': {
      'en': 'Trip updated!',
      'es': '¡Viaje actualizado!',
    },

    'failed_update_trip': {
      'en': 'Failed to update trip',
      'es': 'Error al actualizar el viaje',
    },

    'save_changes': {
      'en': 'Save Changes',
      'es': 'Guardar cambios',
    },
    'error_generic': {
      'en': 'Error',
      'es': 'Error',
    },

    'drag_reorder_move': {
      'en': 'Drag to reorder · Hold to move to another day',
      'es': 'Arrastra para reordenar · Mantén para mover a otro día',
    },

    'move_to_day': {
      'en': 'Move to day',
      'es': 'Mover a día',
    },

    'no_other_days': {
      'en': 'No other days available',
      'es': 'No hay otros días disponibles',
    },

    'day_header': {
      'en': '{title} · {date}',
      'es': '{title} · {date}',
    },
    'offline_sync_message': {
      'en': 'You\'re offline. Changes will sync when connected.',
      'es': 'Estás sin conexión. Los cambios se sincronizarán cuando vuelvas a estar online.',
    },
    'type_label': {
      'en': 'TYPE',
      'es': 'TIPO',
    },
    'title_required_label': {
      'en': 'Title *',
      'es': 'Título *',
    },
    'activity_title_hint': {
      'en': 'e.g., Lunch at Sushi Restaurant',
      'es': 'ej: Comida en restaurante sushi',
    },
    'location_optional': {
      'en': 'Location (optional)',
      'es': 'Ubicación (opcional)',
    },
    'location_hint': {
      'en': 'e.g., Shibuya, Tokyo',
      'es': 'ej: Shibuya, Tokio',
    },
    'time_optional': {
      'en': 'Time (optional)',
      'es': 'Hora (opcional)',
    },
    'notes_optional': {
      'en': 'Notes (optional)',
      'es': 'Notas (opcional)',
    },
    'notes_hint': {
      'en': 'Add any additional notes...',
      'es': 'Añade notas adicionales...',
    },
    'something_wrong': {
      'en': 'Something went wrong',
      'es': 'Algo salió mal',
    },
    'flight_details': {
      'en': 'FLIGHT DETAILS',
      'es': 'DETALLES DEL VUELO',
    },
    'transport_details': {
      'en': 'TRANSPORT DETAILS',
      'es': 'DETALLES DE TRANSPORTE',
    },
    'booking_details': {
      'en': 'BOOKING DETAILS',
      'es': 'DETALLES DE RESERVA',
    },
    'flight_number': {
      'en': 'Flight Number',
      'es': 'Número de vuelo',
    },
    'train_number': {
      'en': 'Train / Bus Number',
      'es': 'Número de tren / bus',
    },
    'company': {
      'en': 'Company',
      'es': 'Compañía',
    },
    'booking_reference': {
      'en': 'Booking Reference',
      'es': 'Referencia de reserva',
    },
    'activity_time': {
      'en': 'Time',
      'es': 'Hora',
    },

    'activity_location': {
      'en': 'Location',
      'es': 'Ubicación',
    },

    'activity_flight': {
      'en': 'Flight',
      'es': 'Vuelo',
    },

    'activity_train': {
      'en': 'Train',
      'es': 'Tren',
    },

    'activity_reference': {
      'en': 'Reference',
      'es': 'Referencia',
    },

    'activity_notes': {
      'en': 'Notes',
      'es': 'Notas',
    },

    'reopen': {
      'en': 'Reopen',
      'es': 'Reabrir',
    },

    'complete': {
      'en': 'Complete',
      'es': 'Completar',
    },

    'track_flight': {
      'en': 'Track Flight',
      'es': 'Rastrear vuelo',
    },

    'flight_tracker_real_time': {
      'en': 'Real-time flight tracking',
      'es': 'Seguimiento en tiempo real',
    },

    'flight_tracker_status': {
      'en': 'Flight status & tracking',
      'es': 'Estado y seguimiento del vuelo',
    },

    'flight_tracker_google': {
      'en': 'Check flight status',
      'es': 'Consultar estado del vuelo',
    },

    'trip_days': {
      'en': 'days',
      'es': 'días',
    },

    'trip_member': {
      'en': 'member',
      'es': 'miembro',
    },

    'trip_members': {
      'en': 'members',
      'es': 'miembros',
    },
    'join_trip_join_trip': {
      'en': 'Join Trip',
      'es': 'Unirse al viaje',
    },

    'enter_invite_code_join_trip': {
      'en': 'Enter the invite code',
      'es': 'Introduce el código de invitación',
    },

    'invite_code_hint_join_trip': {
      'en': 'TRVL-XXXXXX',
      'es': 'TRVL-XXXXXX',
    },

    'enter_invite_code_error_join_trip': {
      'en': 'Please enter an invite code',
      'es': 'Por favor introduce un código de invitación',
    },

    'invalid_invite_code_join_trip': {
      'en': 'Invalid invite code format',
      'es': 'Formato de código inválido',
    },

    'failed_join_trip': {
      'en': 'Failed to join trip',
      'es': 'Error al unirse al viaje',
    },

    'scan_qr_join_trip': {
      'en': 'Scan QR',
      'es': 'Escanear QR',
    },
    'map_title': {
      'en': 'My Map 🗺️',
      'es': 'Mi mapa 🗺️',
    },

    'map_subtitle': {
      'en': 'All your destinations',
      'es': 'Todos tus destinos',
    },

    'loading_destinations': {
      'en': 'Loading destinations...',
      'es': 'Cargando destinos...',
    },

    'error_prefix': {
      'en': 'Error:',
      'es': 'Error:',
    },

    'no_destinations': {
      'en': 'No destinations yet',
      'es': 'Aún no hay destinos',
    },

    'no_destinations_description': {
      'en': 'Create a trip to see your\ndestinations on the map',
      'es': 'Crea un viaje para ver tus\ndestinos en el mapa',
    },

    // ─── Home Navigation ─────────────────────────
    'trips_tab': {
      'en': 'Trips',
      'es': 'Viajes',
    },
    'map_tab': {
      'en': 'Map',
      'es': 'Mapa',
    },
    'profile_tab': {
      'en': 'Profile',
      'es': 'Perfil',
    },

// ─── Home FAB / Bottom Sheet ─────────────────
    'what_do_you_want_to_do': {
      'en': 'What do you want to do?',
      'es': '¿Qué quieres hacer?',
    },

    'start_planning_adventure': {
      'en': 'Start planning a new adventure',
      'es': 'Empieza a planear una nueva aventura',
    },

    'enter_code_or_scan': {
      'en': 'Enter an invite code or scan QR',
      'es': 'Introduce un código o escanea un QR',
    },
    'day_n': {
      'en': 'Day {day}',
      'es': 'Día {day}',
    },

    'activity_type_flight': {'en': 'Flight', 'es': 'Vuelo'},
    'activity_type_transport': {'en': 'Transport', 'es': 'Transporte'},
    'activity_type_food': {'en': 'Food', 'es': 'Comida'},
    'activity_type_bar': {'en': 'Bar', 'es': 'Bar'},
    'activity_type_place': {'en': 'Place', 'es': 'Lugar'},
    'activity_type_hotel': {'en': 'Hotel', 'es': 'Hotel'},
    'activity_type_note': {'en': 'Note', 'es': 'Nota'},
    'activity_type_expense': {'en': 'Expense', 'es': 'Gasto'},

    'open_with': {'en': 'Open with', 'es': 'Abrir con'},
    'choose_maps_app': {'en': 'Choose your preferred maps app', 'es': 'Elige tu app de mapas preferida'},
    'always_ask': {'en': 'Always ask', 'es': 'Preguntar siempre'},
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
