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
    'cancel': {
      'en': 'Cancel',
      'es': 'Cancelar',
      'de': 'Abbrechen',
      'fr': 'Annuler',
      'ja': 'キャンセル'
    },
    'save': {
      'en': 'Save',
      'es': 'Guardar',
      'de': 'Speichern',
      'fr': 'Enregistrer',
      'ja': '保存'
    },
    'delete': {
      'en': 'Delete',
      'es': 'Eliminar',
      'de': 'Löschen',
      'fr': 'Supprimer',
      'ja': '削除'
    },
    'edit': {
      'en': 'Edit',
      'es': 'Editar',
      'de': 'Bearbeiten',
      'fr': 'Modifier',
      'ja': '編集'
    },
    'add': {
      'en': 'Add',
      'es': 'Añadir',
      'de': 'Hinzufügen',
      'fr': 'Ajouter',
      'ja': '追加'
    },
    'done': {
      'en': 'Done',
      'es': 'Hecho',
      'de': 'Fertig',
      'fr': 'Terminé',
      'ja': '完了'
    },
    'error': {
      'en': 'Error',
      'es': 'Error',
      'de': 'Fehler',
      'fr': 'Erreur',
      'ja': 'エラー'
    },
    'retry': {
      'en': 'Retry',
      'es': 'Reintentar',
      'de': 'Wiederholen',
      'fr': 'Réessayer',
      'ja': '再試行'
    },
    'close': {
      'en': 'Close',
      'es': 'Cerrar',
      'de': 'Schließen',
      'fr': 'Fermer',
      'ja': '閉じる'
    },
    'good_morning': {
      'en': 'Good morning',
      'es': 'Buenos días',
      'de': 'Guten Morgen',
      'fr': 'Bonjour',
      'ja': 'おはようございます'
    },
    'good_afternoon': {
      'en': 'Good afternoon',
      'es': 'Buenas tardes',
      'de': 'Guten Tag',
      'fr': 'Bon après-midi',
      'ja': 'こんにちは'
    },
    'good_evening': {
      'en': 'Good evening',
      'es': 'Buenas noches',
      'de': 'Guten Abend',
      'fr': 'Bonsoir',
      'ja': 'こんばんは'
    },

    // ─── Settings / Language ──────────────────────────────────
    'settings': {
      'en': 'Settings',
      'es': 'Ajustes',
      'de': 'Einstellungen',
      'fr': 'Paramètres',
      'ja': '設定'
    },
    'language': {
      'en': 'Language',
      'es': 'Idioma',
      'de': 'Sprache',
      'fr': 'Langue',
      'ja': '言語'
    },
    'language_system': {
      'en': 'System',
      'es': 'Sistema',
      'de': 'System',
      'fr': 'Système',
      'ja': 'システム'
    },
    'language_english': {
      'en': 'English',
      'es': 'Inglés',
      'de': 'Englisch',
      'fr': 'Anglais',
      'ja': '英語'
    },
    'language_spanish': {
      'en': 'Spanish',
      'es': 'Español',
      'de': 'Spanisch',
      'fr': 'Espagnol',
      'ja': 'スペイン語'
    },
    'language_german': {
      'en': 'German',
      'es': 'Alemán',
      'de': 'Deutsch',
      'fr': 'Allemand',
      'ja': 'ドイツ語'
    },
    'language_french': {
      'en': 'French',
      'es': 'Francés',
      'de': 'Französisch',
      'fr': 'Français',
      'ja': 'フランス語'
    },
    'language_japanese': {
      'en': 'Japanese',
      'es': 'Japonés',
      'de': 'Japanisch',
      'fr': 'Japonais',
      'ja': '日本語'
    },

    // ─── Profile ──────────────────────────────────────────────
    'account': {
      'en': 'ACCOUNT',
      'es': 'CUENTA',
      'de': 'KONTO',
      'fr': 'COMPTE',
      'ja': 'アカウント'
    },
    'preferences': {
      'en': 'PREFERENCES',
      'es': 'PREFERENCIAS',
      'de': 'EINSTELLUNGEN',
      'fr': 'PRÉFÉRENCES',
      'ja': '設定'
    },
    'name': {
      'en': 'Name',
      'es': 'Nombre',
      'de': 'Name',
      'fr': 'Nom',
      'ja': '名前'
    },
    'email': {
      'en': 'Email',
      'es': 'Correo electrónico',
      'de': 'E-Mail',
      'fr': 'E-mail',
      'ja': 'メールアドレス'
    },
    'change_password': {
      'en': 'Change Password',
      'es': 'Cambiar contraseña',
      'de': 'Passwort ändern',
      'fr': 'Modifier le mot de passe',
      'ja': 'パスワード変更'
    },
    'dark_mode': {
      'en': 'Dark Mode',
      'es': 'Modo oscuro',
      'de': 'Dunkelmodus',
      'fr': 'Mode sombre',
      'ja': 'ダークモード'
    },
    'sign_out': {
      'en': 'Sign Out',
      'es': 'Cerrar sesión',
      'de': 'Abmelden',
      'fr': 'Se déconnecter',
      'ja': 'サインアウト'
    },
    'edit_name': {
      'en': 'Edit Name',
      'es': 'Editar nombre',
      'de': 'Name bearbeiten',
      'fr': 'Modifier le nom',
      'ja': '名前の編集'
    },
    'name_required': {
      'en': 'Name is required',
      'es': 'El nombre es obligatorio',
      'de': 'Name ist erforderlich',
      'fr': 'Le nom est requis',
      'ja': '名前は必須です'
    },
    'name_updated': {
      'en': 'Name updated!',
      'es': '¡Nombre actualizado!',
      'de': 'Name aktualisiert!',
      'fr': 'Nom mis à jour !',
      'ja': '名前が更新されました！'
    },
    'failed_update_name': {
      'en': 'Failed to update name',
      'es': 'Error al actualizar el nombre',
      'de': 'Name konnte nicht aktualisiert werden',
      'fr': 'Échec de la mise à jour du nom',
      'ja': '名前の更新に失敗しました'
    },
    'new_password': {
      'en': 'New Password',
      'es': 'Nueva contraseña',
      'de': 'Neues Passwort',
      'fr': 'Nouveau mot de passe',
      'ja': '新しいパスワード'
    },
    'confirm_password': {
      'en': 'Confirm Password',
      'es': 'Confirmar contraseña',
      'de': 'Passwort bestätigen',
      'fr': 'Confirmer le mot de passe',
      'ja': 'パスワードの確認'
    },
    'required': {
      'en': 'Required',
      'es': 'Obligatorio',
      'de': 'Erforderlich',
      'fr': 'Requis',
      'ja': '必須'
    },
    'min_6_chars': {
      'en': 'Min 6 characters',
      'es': 'Mínimo 6 caracteres',
      'de': 'Mindestens 6 Zeichen',
      'fr': '6 caractères minimum',
      'ja': '最低6文字'
    },
    'passwords_no_match': {
      'en': 'Passwords do not match',
      'es': 'Las contraseñas no coinciden',
      'de': 'Passwörter stimmen nicht überein',
      'fr': 'Les mots de passe ne correspondent pas',
      'ja': 'パスワードが一致しません'
    },
    'password_updated': {
      'en': 'Password updated!',
      'es': '¡Contraseña actualizada!',
      'de': 'Passwort aktualisiert!',
      'fr': 'Mot de passe mis à jour !',
      'ja': 'パスワードが更新されました！'
    },
    'failed_update_password': {
      'en': 'Failed to update password',
      'es': 'Error al actualizar la contraseña',
      'de': 'Passwort konnte nicht aktualisiert werden',
      'fr': 'Échec de la mise à jour du mot de passe',
      'ja': 'パスワードの更新に失敗しました'
    },
    'relogin_required': {
      'en': 'Please sign out and sign in again to change your password',
      'es':
          'Por favor cierra sesión y vuelve a iniciarla para cambiar la contraseña',
      'de': 'Bitte melden Sie sich ab und erneut an, um Ihr Passwort zu ändern',
      'fr':
          'Veuillez vous déconnecter et vous reconnecter pour modifier votre mot de passe',
      'ja': 'パスワードを変更するには、一度サインアウトしてから再度サインインしてください',
    },

    // ─── Home / Trips ─────────────────────────────────────────
    'no_trips_yet': {
      'en': 'No trips yet',
      'es': 'Aún no hay viajes',
      'de': 'Noch keine Reisen',
      'fr': 'Aucun voyage pour le moment',
      'ja': 'まだ旅行はありません'
    },
    'create_trip_or_join': {
      'en': 'Create your first trip or join\nan existing one with a code',
      'es': 'Crea tu primer viaje o únete\na uno existente con un código',
      'de':
          'Erstellen Sie Ihre erste Reise oder treten Sie\neiner bestehenden mit einem Code bei',
      'fr':
          'Créez votre premier voyage ou rejoignez\nun voyage existant avec un code',
      'ja': '最初の旅行を作成するか、\nコードを使って既存の旅行に参加してください',
    },
    'create_trip': {
      'en': 'Create Trip',
      'es': 'Crear viaje',
      'de': 'Reise erstellen',
      'fr': 'Créer un voyage',
      'ja': '旅行を作成'
    },
    'join_with_code': {
      'en': 'Join with code',
      'es': 'Unirse con código',
      'de': 'Mit Code beitreten',
      'fr': 'Rejoindre avec un code',
      'ja': 'コードで参加'
    },
    'archived': {
      'en': 'Archived',
      'es': 'Archivados',
      'de': 'Archiviert',
      'fr': 'Archivés',
      'ja': 'アーカイブ済み'
    },
    'ongoing': {
      'en': 'Ongoing',
      'es': 'En curso',
      'de': 'Laufend',
      'fr': 'En cours',
      'ja': '進行中'
    },
    'upcoming': {
      'en': 'Upcoming',
      'es': 'Próximo',
      'de': 'Demnächst',
      'fr': 'À venir',
      'ja': '今後の予定'
    },
    'past': {
      'en': 'Past',
      'es': 'Pasado',
      'de': 'Vergangen',
      'fr': 'Passés',
      'ja': '過去'
    },
    'past_trip': {
      'en': 'Past trip',
      'es': 'Viaje pasado',
      'de': 'Vergangene Reise',
      'fr': 'Voyage passé',
      'ja': '過去の旅行'
    },
    'days': {
      'en': 'days',
      'es': 'días',
      'de': 'Tage',
      'fr': 'jours',
      'ja': '日'
    },
    'members': {
      'en': 'members',
      'es': 'miembros',
      'de': 'Mitglieder',
      'fr': 'membres',
      'ja': 'メンバー'
    },
    'last_day': {
      'en': 'Last day',
      'es': 'Último día',
      'de': 'Letzter Tag',
      'fr': 'Dernier jour',
      'ja': '最終日'
    },
    'starts_tomorrow': {
      'en': 'Starts tomorrow',
      'es': 'Empieza mañana',
      'de': 'Beginnt morgen',
      'fr': 'Commence demain',
      'ja': '明日開始'
    },
    'days_to_go': {
      'en': 'days to go',
      'es': 'días restantes',
      'de': 'Tage übrig',
      'fr': 'jours restants',
      'ja': 'あと何日'
    },
    'day_of': {'en': 'Day', 'es': 'Día', 'de': 'Tag', 'fr': 'Jour', 'ja': '日'},
    'of': {'en': 'of', 'es': 'de', 'de': 'von', 'fr': 'de', 'ja': 'の'},

    // ─── Trip dashboard tabs ──────────────────────────────────
    'timeline': {
      'en': 'Timeline',
      'es': 'Itinerario',
      'de': 'Zeitleiste',
      'fr': 'Itinéraire',
      'ja': 'タイムライン'
    },
    'expenses': {
      'en': 'Expenses',
      'es': 'Gastos',
      'de': 'Ausgaben',
      'fr': 'Dépenses',
      'ja': '出費'
    },
    'checklist': {
      'en': 'Checklist',
      'es': 'Lista',
      'de': 'Checkliste',
      'fr': 'Checklist',
      'ja': 'チェックリスト'
    },

    // ─── Timeline ─────────────────────────────────────────────
    'no_activities_yet': {
      'en': 'No activities yet',
      'es': 'Aún no hay actividades',
      'de': 'Noch keine Aktivitäten',
      'fr': 'Aucune activité pour le moment',
      'ja': 'まだアクティビティはありません'
    },
    'swipe_to_add_activity': {
      'en': 'Swipe right on a day to add\nyour first activity',
      'es': 'Desliza a la derecha en un día para\nañadir tu primera actividad',
      'de':
          'Wischen Sie an einem Tag nach rechts, um\nIhre erste Aktivität hinzuzufügen',
      'fr':
          'Glissez vers la droite sur un jour pour\najouter votre première activité',
      'ja': '日付を右にスワイプして\n最初のアクティビティを追加します',
    },
    'no_days_yet': {
      'en': 'No days yet',
      'es': 'Aún no hay días',
      'de': 'Noch keine Tage',
      'fr': 'Aucun jour pour le moment',
      'ja': 'まだ日付がありません'
    },
    'no_days_configured': {
      'en': 'This trip has no days configured yet',
      'es': 'Este viaje todavía no tiene días configurados',
      'de': 'Für diese Reise sind noch keine Tage konfiguriert',
      'fr': "Ce voyage n'a pas encore de jours configurés",
      'ja': 'この旅行にはまだ日付が設定されていません',
    },

    // ─── Expenses ─────────────────────────────────────────────
    'no_expenses_yet': {
      'en': 'No expenses yet',
      'es': 'Aún no hay gastos',
      'de': 'Noch keine Ausgaben',
      'fr': 'Aucune dépense pour le moment',
      'ja': 'まだ出費はありません'
    },
    'track_expenses_desc': {
      'en': 'Track what everyone spends\nand split costs easily',
      'es': 'Registra lo que gasta cada uno\ny divide los costes fácilmente',
      'de':
          'Verfolgen Sie die Ausgaben aller\nund teilen Sie die Kosten ganz einfach',
      'fr': 'Suivez les dépenses de chacun\net divisez les coûts facilement',
      'ja': '全員員の支出を追跡し、\n簡単に費用を精算します',
    },
    'add_expense': {
      'en': 'Add Expense',
      'es': 'Añadir gasto',
      'de': 'Ausgabe hinzufügen',
      'fr': 'Ajouter une dépense',
      'ja': '出費を追加'
    },
    'total_spent': {
      'en': 'Total spent',
      'es': 'Total gastado',
      'de': 'Gesamtausgaben',
      'fr': 'Total dépensé',
      'ja': '合計支出'
    },
    'balances': {
      'en': 'Balances',
      'es': 'Balances',
      'de': 'Salden',
      'fr': 'Soldes',
      'ja': '残高'
    },
    'settlements': {
      'en': 'Settlements',
      'es': 'Liquidaciones',
      'de': 'Abrechnungen',
      'fr': 'Règlements',
      'ja': '精算'
    },
    'all_settled_up': {
      'en': 'All settled up! 🎉',
      'es': '¡Todo saldado! 🎉',
      'de': 'Alles abgerechnet! 🎉',
      'fr': 'Tout est réglé ! 🎉',
      'ja': 'すべて精算されました！ 🎉'
    },
    'gets_back': {
      'en': 'gets back',
      'es': 'recibe',
      'de': 'erhält zurück',
      'fr': 'reçoit',
      'ja': '返金を受け取る'
    },
    'owes': {
      'en': 'owes',
      'es': 'debe',
      'de': 'schuldet',
      'fr': 'doit',
      'ja': '借りがある'
    },

    // ─── Checklist ────────────────────────────────────────────
    'no_items_yet': {
      'en': 'No items yet',
      'es': 'Aún no hay elementos',
      'de': 'Noch keine Elemente',
      'fr': 'Aucun élément pour le moment',
      'ja': 'まだアイテムはありません'
    },
    'checklist_empty_desc': {
      'en': 'Add things to pack or tasks\nto complete before your trip',
      'es': 'Añade cosas que empacar o tareas\npor completar antes del viaje',
      'de':
          'Fügen Sie Dinge zum Packen oder Aufgaben hinzu,\ndie Sie vor Ihrer Reise erledigen müssen',
      'fr':
          'Ajoutez des choses à emporter ou des tâches\nà accomplir avant votre voyage',
      'ja': '旅行前に準備する持ち物や\nタスクを追加してください',
    },
    'add_item': {
      'en': 'Add Item',
      'es': 'Añadir elemento',
      'de': 'Element hinzufügen',
      'fr': 'Ajouter un élément',
      'ja': 'アイテムを追加'
    },
    'all_done': {
      'en': 'All done! 🎉',
      'es': '¡Todo listo! 🎉',
      'de': 'Alles erledigt! 🎉',
      'fr': 'Tout est fait ! 🎉',
      'ja': 'すべて完了！ 🎉'
    },
    'progress_done': {
      'en': '{done} of {total} done',
      'es': '{done} de {total} completadas',
      'de': '{done} von {total} erledigt',
      'fr': '{done} sur {total} fait(s)',
      'ja': '{total}個中{done}個完了',
    },

    // ─── Activity card ────────────────────────────────────────
    'edit_activity': {
      'en': 'Edit Activity',
      'es': 'Editar actividad',
      'de': 'Aktivität bearbeiten',
      'fr': "Modifier l'activité",
      'ja': 'アクティビティを編集'
    },
    'add_activity': {
      'en': 'Add Activity',
      'es': 'Añadir actividad',
      'de': 'Aktivität hinzufügen',
      'fr': 'Ajouter une activité',
      'ja': 'アクティビティを追加'
    },
    'delete_activity_q': {
      'en': 'Delete activity?',
      'es': '¿Eliminar actividad?',
      'de': 'Aktivität löschen?',
      'fr': "Supprimer l'activité ?",
      'ja': 'アクティビティを削除しますか？'
    },

    // ─── Trip card swipe actions ──────────────────────────────
    'leave': {
      'en': 'Leave',
      'es': 'Salir',
      'de': 'Verlassen',
      'fr': 'Quitter',
      'ja': '退出'
    },
    'leave_trip_q': {
      'en': 'Leave trip?',
      'es': '¿Salir del viaje?',
      'de': 'Reise verlassen?',
      'fr': 'Quitter le voyage ?',
      'ja': '旅行から退出しますか？'
    },
    'leave_trip_desc': {
      'en': 'You will be removed from "{name}".',
      'es': 'Se te eliminará de "{name}".',
      'de': 'Sie werden aus "{name}" entfernt.',
      'fr': 'Vous serez supprimé de "{name}".',
      'ja': '「{name}」から削除されます。',
    },
    'delete_trip_q': {
      'en': 'Delete trip?',
      'es': '¿Eliminar viaje?',
      'de': 'Reise löschen?',
      'fr': 'Supprimer le voyage ?',
      'ja': '旅行を削除しますか？'
    },
    'delete_trip_desc': {
      'en': 'This will permanently delete "{name}" and all its data.',
      'es': 'Esto eliminará permanentemente "{name}" y todos sus datos.',
      'de':
          'Dadurch wird "{name}" und alle zugehörigen Daten dauerhaft gelöscht.',
      'fr': 'Cela supprimera définitivement "{name}" et toutes ses données.',
      'ja': 'これにより、「{name}」とそのすべてのデータが完全に削除されます。',
    },
    'trip_deleted': {
      'en': '{name} deleted',
      'es': '{name} eliminado',
      'de': '{name} gelöscht',
      'fr': '{name} supprimé',
      'ja': '{name}を削除しました'
    },
    'left_trip': {
      'en': 'Left {name}',
      'es': 'Has salido de {name}',
      'de': '{name} verlassen',
      'fr': 'Vous avez quitté {name}',
      'ja': '{name}から退出しました'
    },

    // ─── Invite / Members ─────────────────────────────────────
    'invite_friends': {
      'en': 'Invite Friends',
      'es': 'Invitar amigos',
      'de': 'Freunde einladen',
      'fr': 'Inviter des amis',
      'ja': '友達を招待'
    },
    'invite_someone': {
      'en': 'Invite Someone',
      'es': 'Invitar a alguien',
      'de': 'Jemanden einladen',
      'fr': "Inviter quelqu'un",
      'ja': '誰かを招待'
    },
    'share_invite_code': {
      'en': 'Share Invite Code',
      'es': 'Compartir código',
      'de': 'Einladungscode teilen',
      'fr': "Partager le code d'invitation",
      'ja': '招待コードを共有'
    },
    'code_copied': {
      'en': 'Code copied',
      'es': 'Código copiado',
      'de': 'Code kopiert',
      'fr': 'Code copié',
      'ja': 'コードをコピーしました'
    },
    'host': {
      'en': 'Host',
      'es': 'Anfitrión',
      'de': 'Gastgeber',
      'fr': 'Hôte',
      'ja': 'ホスト'
    },
    'co_host': {
      'en': 'Co-host',
      'es': 'Coanfitrión',
      'de': 'Mitgastgeber',
      'fr': 'Co-hôte',
      'ja': 'コホスト'
    },
    'member': {
      'en': 'Member',
      'es': 'Miembro',
      'de': 'Mitglied',
      'fr': 'Membre',
      'ja': 'メンバー'
    },
    'make_co_host': {
      'en': 'Make co-host',
      'es': 'Hacer coanfitrión',
      'de': 'Zum Mitgastgeber machen',
      'fr': 'Nommer co-hôte',
      'ja': 'コホストに指定'
    },

    // ─── Join trip ────────────────────────────────────────────
    'join_trip': {
      'en': 'Join Trip',
      'es': 'Unirse a viaje',
      'de': 'Reise beitreten',
      'fr': 'Rejoindre le voyage',
      'ja': '旅行に参加'
    },
    'enter_invite_code': {
      'en': 'Enter the invite code',
      'es': 'Introduce el código de invitación',
      'de': 'Einladungscode eingeben',
      'fr': "Saisir le code d'invitation",
      'ja': '招待コードを入力'
    },
    'invalid_code_format': {
      'en': 'Invalid invite code format',
      'es': 'Formato de código inválido',
      'de': 'Ungültiges Format des Einladungscodes',
      'fr': "Format du code d'invitation invalide",
      'ja': '招待コードの形式が不正です'
    },
    'enter_invite_code_error': {
      'en': 'Please enter an invite code',
      'es': 'Introduce un código de invitación',
      'de': 'Bitte geben Sie einen Einladungscode ein',
      'fr': "Veuillez saisir un code d'invitation",
      'ja': '招待コードを入力してください'
    },
    'failed_to_join': {
      'en': 'Failed to join trip',
      'es': 'No se pudo unir al viaje',
      'de': 'Beitritt zur Reise fehlgeschlagen',
      'fr': 'Échec du ralliement au voyage',
      'ja': '旅行への参加に失敗しました'
    },
    'scan_qr': {
      'en': 'Scan QR',
      'es': 'Escanear QR',
      'de': 'QR-Code scannen',
      'fr': 'Scanner le QR',
      'ja': 'QRコードをスキャン'
    },

    // ─── QR Scanner ───────────────────────────────────────────
    'point_at_qr': {
      'en': 'Point at the trip QR code',
      'es': 'Apunta al código QR del viaje',
      'de': 'Auf den Reise-QR-Code zeigen',
      'fr': "Visez le code QR du voyage",
      'ja': '旅行のQRコードに向けてください'
    },
    'code_detected': {
      'en': '✓ Code detected!',
      'es': '✓ ¡Código detectado!',
      'de': '✓ Code erkannt!',
      'fr': '✓ Code détecté !',
      'ja': '✓ コードを検出しました！'
    },
    'code_format_hint': {
      'en': 'The code looks like TRVL-XXXXXX',
      'es': 'El código tiene el formato TRVL-XXXXXX',
      'de': 'Der Code sieht aus wie TRVL-XXXXXX',
      'fr': 'Le code ressemble à TRVL-XXXXXX',
      'ja': 'コードは TRVL-XXXXXX のようになります'
    },
    'invalid_invite_code': {
      'en': 'Invalid invite code',
      'es': 'Código de invitación inválido',
      'de': 'Ungültiger Einladungscode',
      'fr': "Code d'invitation invalide",
      'ja': '無効な招待コード'
    },

    // ─── Auth ─────────────────────────────────────────────────
    'sign_in': {
      'en': 'Sign In',
      'es': 'Iniciar sesión',
      'de': 'Anmelden',
      'fr': 'Se connecter',
      'ja': 'サインイン'
    },
    'sign_up': {
      'en': 'Sign Up',
      'es': 'Registrarse',
      'de': 'Registrieren',
      'fr': "S'inscrire",
      'ja': 'サインアップ'
    },
    'continue_with_google': {
      'en': 'Continue with Google',
      'es': 'Continuar con Google',
      'de': 'Mit Google fortfahren',
      'fr': 'Continuer avec Google',
      'ja': 'Googleで続ける'
    },
    'password': {
      'en': 'Password',
      'es': 'Contraseña',
      'de': 'Passwort',
      'fr': 'Mot de passe',
      'ja': 'パスワード'
    },
    'or': {'en': 'OR', 'es': 'O', 'de': 'ODER', 'fr': 'OU', 'ja': 'または'},
    'plan_adventures_together': {
      'en': 'Plan your adventures together',
      'es': 'Planifica tus aventuras juntos',
      'de': 'Planen Sie Ihre Abenteuer gemeinsam',
      'fr': 'Planifiez vos aventures ensemble',
      'ja': '一緒に冒険を計画しよう',
    },
    'already_have_account': {
      'en': 'Already have an account? Sign In',
      'es': '¿Ya tienes una cuenta? Inicia sesión',
      'de': 'Bereits ein Konto? Anmelden',
      'fr': 'Vous avez déjà un compte ? Se connecter',
      'ja': 'すでにアカウントをお持ちですか？サインイン',
    },
    'no_account_sign_up': {
      'en': "Don't have an account? Sign Up",
      'es': '¿No tienes una cuenta? Regístrate',
      'de': 'Noch kein Konto? Registrieren',
      'fr': "Vous n'avez pas de compte ? S'inscrire",
      'ja': 'アカウントをお持ちでないですか？サインアップ',
    },

    // ─── Trip dashboard extra ─────────────────────────
    'failed_to_load_trip': {
      'en': 'Failed to load trip',
      'es': 'Error al cargar el viaje',
      'de': 'Reise konnte nicht geladen werden',
      'fr': 'Échec du chargement du voyage',
      'ja': '旅行 de 読み込みに失敗しました'
    },
    'go_back': {
      'en': 'Go back',
      'es': 'Volver',
      'de': 'Zurückgehen',
      'fr': 'Retourner',
      'ja': '戻る'
    },
    'members_count': {
      'en': 'Members',
      'es': 'Miembros',
      'de': 'Mitglieder',
      'fr': 'Membres',
      'ja': 'メンバー'
    },
    'updating_role': {
      'en': 'Updating role...',
      'es': 'Actualizando rol...',
      'de': 'Rolle wird aktualisiert...',
      'fr': 'Mise à jour du rôle...',
      'ja': '役割を更新中...'
    },
    'member_role_updated': {
      'en': 'Member role updated',
      'es': 'Rol actualizado',
      'de': 'Mitgliedsrolle aktualisiert',
      'fr': 'Rôle du membre mis à jour',
      'ja': 'メンバーの役割が更新されました'
    },
    'error_updating_role': {
      'en': 'Error updating role',
      'es': 'Error al actualizar el rol',
      'de': 'Fehler beim Aktualisieren der Rolle',
      'fr': 'Erreur lors de la mise à jour du rôle',
      'ja': '役割の更新中にエラーが発生しました'
    },

    // ─── Share ───────────────────────────────────────
    'share_trip_message': {
      'en': 'Join my trip on Travl! 🌍\nUse code: {code}',
      'es': '¡Únete a mi viaje en Travl! 🌍\nUsa el código: {code}',
      'de': 'Tritt meiner Reise auf Travl bei! 🌍\nNutze den Code: {code}',
      'fr': 'Rejoins mon voyage sur Travl ! 🌍\nUtilise le code : {code}',
      'ja': 'Travlで私の旅行に参加しましょう！ 🌍\nコード：{code}',
    },
    'all_settled': {
      'en': 'All settled up! 🎉',
      'es': '¡Todo saldado! 🎉',
      'de': 'Alles abgerechnet! 🎉',
      'fr': 'Tout est réglé ! 🎉',
      'ja': 'すべて精算されました！ 🎉'
    },
    'delete_expense': {
      'en': 'Delete expense?',
      'es': '¿Eliminar gasto?',
      'de': 'Ausgabe löschen?',
      'fr': 'Supprimer la dépense ?',
      'ja': '出費を削除しますか？'
    },

    // ─── Expense row ─────────────────────────
    'paid_by_with_count': {
      'en': 'Paid by {name} · {count} people',
      'es': 'Pagado por {name} · {count} personas',
      'de': 'Bezahlt von {name} · {count} Personen',
      'fr': 'Payé par {name} · {count} personnes',
      'ja': '{name}が支払いました · {count}人',
    },
    'expenses_description': {
      'en': 'Track what everyone spends\nand split costs easily',
      'es': 'Controla lo que gasta cada uno\ny divide los costes fácilmente',
      'de':
          'Verfolgen Sie die Ausgaben aller\nund teilen Sie die Kosten ganz einfach',
      'fr': 'Suivez les dépenses de chacun\net divisez les coûts facilement',
      'ja': '全員員の支出を追跡し、\n簡単に費用を精算します',
    },
    'category': {
      'en': 'Category',
      'es': 'Categoría',
      'de': 'Kategorie',
      'fr': 'Catégorie',
      'ja': 'カテゴリ'
    },
    'title': {
      'en': 'Title',
      'es': 'Título',
      'de': 'Titel',
      'fr': 'Titre',
      'ja': 'タイトル'
    },
    'expense_title_hint': {
      'en': 'e.g., Dinner at restaurant',
      'es': 'ej: Cena en restaurante',
      'de': 'z. B. Abendessen im Restaurant',
      'fr': 'ex : Dîner au restaurant',
      'ja': '例：レストランでの夕食'
    },
    'title_required': {
      'en': 'Title is required',
      'es': 'El título es obligatorio',
      'de': 'Titel ist erforderlich',
      'fr': 'Le titre est requis',
      'ja': 'タイトルは必須です'
    },
    'currency': {
      'en': 'Currency',
      'es': 'Moneda',
      'de': 'Währung',
      'fr': 'Devise',
      'ja': '通貨'
    },
    'amount': {
      'en': 'Amount',
      'es': 'Cantidad',
      'de': 'Betrag',
      'fr': 'Montant',
      'ja': '金額'
    },
    'amount_hint': {
      'en': '0.00',
      'es': '0.00',
      'de': '0.00',
      'fr': '0.00',
      'ja': '0.00'
    },
    'invalid_amount': {
      'en': 'Invalid amount',
      'es': 'Cantidad inválida',
      'de': 'Ungültiger Betrag',
      'fr': 'Montant invalide',
      'ja': '無効な金額'
    },
    'amount_greater_than_zero': {
      'en': 'Must be greater than 0',
      'es': 'Debe ser mayor que 0',
      'de': 'Muss größer als 0 sein',
      'fr': 'Doit être supérieur à 0',
      'ja': '0より大きい必要があります'
    },
    'split_with': {
      'en': 'Split with',
      'es': 'Dividir con',
      'de': 'Teilen mit',
      'fr': 'Diviser avec',
      'ja': '分割メンバー'
    },
    'you_label': {
      'en': '{name} (you)',
      'es': '{name} (tú)',
      'de': '{name} (du)',
      'fr': '{name} (vous)',
      'ja': '{name}（あなた）'
    },
    'each_person_pays': {
      'en': 'Each person pays {currency} {amount}',
      'es': 'Cada persona paga {currency} {amount}',
      'de': 'Jede Person zahlt {currency} {amount}',
      'fr': 'Chaque personne paie {currency} {amount}',
      'ja': '各自の支払い：{currency} {amount}',
    },

    // ─── Checklist ─────────────────────────
    'all_done_check': {
      'en': 'All done! 🎉',
      'es': '¡Todo listo! 🎉',
      'de': 'Alles erledigt! 🎉',
      'fr': 'Tout est fait ! 🎉',
      'ja': 'すべて完了！ 🎉'
    },
    'progress_done_check': {
      'en': '{done} of {total} done',
      'es': '{done} de {total} completados',
      'de': '{done} von {total} erledigt',
      'fr': '{done} sur {total} fait(s)',
      'ja': '{total}個中{done}個完了',
    },
    'progress_fraction': {
      'en': '· {done}/{total}',
      'es': '· {done}/{total}',
      'de': '· {done}/{total}',
      'fr': '· {done}/{total}',
      'ja': '· {done}/{total}'
    },
    'checklist_empty_description': {
      'en': 'Add things to pack or tasks\nto complete before your trip',
      'es': 'Añade cosas para llevar o tareas\nantes del viaje',
      'de':
          'Fügen Sie Dinge zum Packen oder Aufgaben hinzu,\ndie Sie vor Ihrer Reise erledigen müssen',
      'fr':
          'Ajoutez des choses à emporter ou des tâches\nà accomplir avant votre voyage',
      'ja': '旅行前に準備する持ち物や\nタスクを追加してください',
    },
    'add_item_check': {
      'en': 'Add Item',
      'es': 'Añadir ítem',
      'de': 'Element hinzufügen',
      'fr': 'Ajouter un élément',
      'ja': 'アイテムを追加'
    },
    'when': {
      'en': 'When',
      'es': 'Cuándo',
      'de': 'Wann',
      'fr': 'Quand',
      'ja': '日時'
    },
    'item': {
      'en': 'Item',
      'es': 'Ítem',
      'de': 'Element',
      'fr': 'Élément',
      'ja': 'アイテム'
    },
    'item_hint': {
      'en': 'e.g., Pack sunscreen',
      'es': 'ej: Llevar protector solar',
      'de': 'z. B. Sonnencreme einpacken',
      'fr': 'ex : Prendre de la crème solaire',
      'ja': '例：日焼け止めを持参'
    },

    // ─── Create Trip ─────────────────────────
    'select_start_end_dates': {
      'en': 'Please select both start and end dates',
      'es': 'Selecciona fecha de inicio y fin',
      'de': 'Bitte wählen Sie sowohl Start- als auch Enddatum aus',
      'fr': 'Veuillez sélectionner les dates de début et de fin',
      'ja': '開始日と終了日の両方を選択してください',
    },
    'failed_create_trip': {
      'en': 'Failed to create trip',
      'es': 'Error al crear el viaje',
      'de': 'Reise konnte nicht erstellt werden',
      'fr': 'Échec de la création du voyage',
      'ja': '旅行の作成に失敗しました'
    },
    'trip_name': {
      'en': 'Trip Name',
      'es': 'Nombre del viaje',
      'de': 'Name der Reise',
      'fr': 'Nom du voyage',
      'ja': '旅行名'
    },
    'trip_name_hint': {
      'en': 'e.g., Summer in Tokyo',
      'es': 'ej: Verano en Tokio',
      'de': 'z. B. Sommer in Tokio',
      'fr': 'ex : Été à Tokyo',
      'ja': '例：東京の夏'
    },
    'destination': {
      'en': 'Destination',
      'es': 'Destino',
      'de': 'Reiseziel',
      'fr': 'Destination',
      'ja': '目的地'
    },
    'destination_hint': {
      'en': 'e.g., Tokyo, Japan',
      'es': 'ej: Tokio, Japón',
      'de': 'z. B. Tokio, Japan',
      'fr': 'ex : Tokyo, Japon',
      'ja': '例：日本、東京'
    },
    'dates': {
      'en': 'Dates',
      'es': 'Fechas',
      'de': 'Daten',
      'fr': 'Dates',
      'ja': '日付'
    },
    'start_date': {
      'en': 'Start Date',
      'es': 'Fecha inicio',
      'de': 'Startdatum',
      'fr': 'Date de début',
      'ja': '開始日'
    },
    'end_date': {
      'en': 'End Date',
      'es': 'Fecha fin',
      'de': 'Enddatum',
      'fr': 'Date de fin',
      'ja': '終了日'
    },
    'select_date': {
      'en': 'Select date',
      'es': 'Seleccionar fecha',
      'de': 'Datum auswählen',
      'fr': 'Sélectionner la date',
      'ja': '日付を選択'
    },
    'joined_trip': {
      'en': 'Joined trip: {id}',
      'es': 'Te has unido al viaje: {id}',
      'de': 'Reise beigetreten: {id}',
      'fr': 'Voyage rejoint : {id}',
      'ja': '旅行に参加しました：{id}'
    },
    'invite_members': {
      'en': 'Invite Members',
      'es': 'Invitar miembros',
      'de': 'Mitglieder einladen',
      'fr': 'Inviter des membres',
      'ja': 'メンバーを招待'
    },
    'share_code_with_friends': {
      'en': 'Share this code with your friends:',
      'es': 'Comparte este código con tus amigos:',
      'de': 'Teilen Sie diesen Code mit Ihren Freunden:',
      'fr': 'Partavez ce code avec vos amis :',
      'ja': 'このコードを友達と共有してください：',
    },
    'edit_trip': {
      'en': 'Edit Trip',
      'es': 'Editar viaje',
      'de': 'Reise bearbeiten',
      'fr': 'Modifier le voyage',
      'ja': '旅行を編集'
    },
    'trip_updated': {
      'en': 'Trip updated!',
      'es': '¡Viaje actualizado!',
      'de': 'Reise aktualisiert!',
      'fr': 'Voyage mis à jour !',
      'ja': '旅行が更新されました！'
    },
    'failed_update_trip': {
      'en': 'Failed to update trip',
      'es': 'Error al actualizar el viaje',
      'de': 'Reise konnte nicht aktualisiert werden',
      'fr': 'Échec de la mise à jour du voyage',
      'ja': '旅行の更新に失敗しました'
    },
    'save_changes': {
      'en': 'Save Changes',
      'es': 'Guardar cambios',
      'de': 'Änderungen speichern',
      'fr': 'Enregistrer les modifications',
      'ja': '変更を保存'
    },
    'error_generic': {
      'en': 'Error',
      'es': 'Error',
      'de': 'Fehler',
      'fr': 'Erreur',
      'ja': 'エラー'
    },
    'drag_reorder_move': {
      'en': 'Drag to reorder · Hold to move to another day',
      'es': 'Arrastra para reordenar · Mantén para mover a otro día',
      'de':
          'Ziehen zum Neuanordnen · Halten, um zu einem anderen Tag zu wechseln',
      'fr':
          'Glisser pour réordonner · Maintenir pour déplacer vers un autre jour',
      'ja': 'ドラッグして並べ替え · 長押しで別の日へ移動',
    },
    'move_to_day': {
      'en': 'Move to day',
      'es': 'Mover a día',
      'de': 'Zum Tag verschieben',
      'fr': 'Déplacer vers le jour',
      'ja': '日に移動'
    },
    'no_other_days': {
      'en': 'No other days available',
      'es': 'No hay otros días disponibles',
      'de': 'Keine anderen Tage verfügbar',
      'fr': 'Aucun autre jour disponible',
      'ja': '利用可能な他の日付がありません'
    },
    'day_header': {
      'en': '{title} · {date}',
      'es': '{title} · {date}',
      'de': '{title} · {date}',
      'fr': '{title} · {date}',
      'ja': '{title} · {date}'
    },
    'offline_sync_message': {
      'en': 'You\'re offline. Changes will sync when connected.',
      'es':
          'Estás sin conexión. Los cambios se sincronizarán cuando vuelvas a estar online.',
      'de':
          'Sie sind offline. Änderungen werden synchronisiert, wenn eine Verbindung besteht.',
      'fr':
          'Vous êtes hors ligne. Les modifications seront synchronisées une fois connecté.',
      'ja': 'オフラインです。接続時に変更が同期されます。',
    },
    'type_label': {
      'en': 'TYPE',
      'es': 'TIPO',
      'de': 'TYP',
      'fr': 'TYPE',
      'ja': 'タイプ'
    },
    'title_required_label': {
      'en': 'Title *',
      'es': 'Título *',
      'de': 'Titel *',
      'fr': 'Titre *',
      'ja': 'タイトル *'
    },
    'activity_title_hint': {
      'en': 'e.g., Lunch at Sushi Restaurant',
      'es': 'ej: Comida en restaurante sushi',
      'de': 'z. B. Mittagessen im Sushi-Restaurant',
      'fr': 'ex : Déjeuner au restaurant de sushis',
      'ja': '例：寿司屋でのランチ'
    },
    'location_optional': {
      'en': 'Location (optional)',
      'es': 'Ubicación (opcional)',
      'de': 'Ort (optional)',
      'fr': 'Lieu (facultatif)',
      'ja': '場所（任意）'
    },
    'location_hint': {
      'en': 'e.g., Shibuya, Tokyo',
      'es': 'ej: Shibuya, Tokio',
      'de': 'z. B. Shibuya, Tokio',
      'fr': 'ex : Shibuya, Tokyo',
      'ja': '例：東京、渋谷'
    },
    'time_optional': {
      'en': 'Time (optional)',
      'es': 'Hora (opcional)',
      'de': 'Zeit (optional)',
      'fr': 'Heure (facultatif)',
      'ja': '時間（任意）'
    },
    'notes_optional': {
      'en': 'Notes (optional)',
      'es': 'Notas (opcional)',
      'de': 'Notizen (optional)',
      'fr': 'Notes (facultatif)',
      'ja': 'メモ（任意）'
    },
    'notes_hint': {
      'en': 'Add any additional notes...',
      'es': 'Añade notas adicionales...',
      'de': 'Weitere Notizen hinzufügen...',
      'fr': 'Ajouter des notes supplémentaires...',
      'ja': '追加のメモを入力...'
    },
    'something_wrong': {
      'en': 'Something went wrong',
      'es': 'Algo salió mal',
      'de': 'Etwas ist schiefgelaufen',
      'fr': "Quelque chose s'est mal passé",
      'ja': '問題が発生しました'
    },
    'flight_details': {
      'en': 'FLIGHT DETAILS',
      'es': 'DETALLES DEL VUELO',
      'de': 'FLUGDETAILS',
      'fr': 'DÉTAILS DU VOL',
      'ja': 'フライトの詳細'
    },
    'transport_details': {
      'en': 'TRANSPORT DETAILS',
      'es': 'DETALLES DE TRANSPORTE',
      'de': 'TRANSPORTDETAILS',
      'fr': 'DÉTAILS DU TRANSPORT',
      'ja': '交通機関の詳細'
    },
    'booking_details': {
      'en': 'BOOKING DETAILS',
      'es': 'DETALLES DE RESERVA',
      'de': 'BUCHUNGSDETAILS',
      'fr': 'DÉTAILS DE LA RÉSERVATION',
      'ja': '予約の詳細'
    },
    'flight_number': {
      'en': 'Flight Number',
      'es': 'Número de vuelo',
      'de': 'Flugnummer',
      'fr': 'Numéro de vol',
      'ja': '便名'
    },
    'train_number': {
      'en': 'Train / Bus Number',
      'es': 'Número de tren / bus',
      'de': 'Zug- / Busnummer',
      'fr': 'Numéro de train / bus',
      'ja': '列車・バスの番号'
    },
    'company': {
      'en': 'Company',
      'es': 'Compañía',
      'de': 'Unternehmen',
      'fr': 'Compagnie',
      'ja': '運行会社'
    },
    'booking_reference': {
      'en': 'Booking Reference',
      'es': 'Referencia de reserva',
      'de': 'Buchungsreferenz',
      'fr': 'Référence de réservation',
      'ja': '予約照会番号'
    },
    'activity_time': {
      'en': 'Time',
      'es': 'Hora',
      'de': 'Zeit',
      'fr': 'Heure',
      'ja': '時間'
    },
    'activity_location': {
      'en': 'Location',
      'es': 'Ubicación',
      'de': 'Ort',
      'fr': 'Lieu',
      'ja': '場所'
    },
    'activity_flight': {
      'en': 'Flight',
      'es': 'Vuelo',
      'de': 'Flug',
      'fr': 'Vol',
      'ja': 'フライト'
    },
    'activity_train': {
      'en': 'Train',
      'es': 'Tren',
      'de': 'Zug',
      'fr': 'Train',
      'ja': '列車'
    },
    'activity_reference': {
      'en': 'Reference',
      'es': 'Referencia',
      'de': 'Referenz',
      'fr': 'Référence',
      'ja': '参照'
    },
    'activity_notes': {
      'en': 'Notes',
      'es': 'Notas',
      'de': 'Notizen',
      'fr': 'Notes',
      'ja': 'メモ'
    },
    'reopen': {
      'en': 'Reopen',
      'es': 'Reabrir',
      'de': 'Wieder öffnen',
      'fr': 'Rouvrir',
      'ja': '再開する'
    },
    'complete': {
      'en': 'Complete',
      'es': 'Completar',
      'de': 'Abschließen',
      'fr': 'Terminer',
      'ja': '完了する'
    },
    'track_flight': {
      'en': 'Track Flight',
      'es': 'Rastrear vuelo',
      'de': 'Flug verfolgen',
      'fr': 'Suivre le vol',
      'ja': 'フライト追跡'
    },
    'flight_tracker_real_time': {
      'en': 'Real-time flight tracking',
      'es': 'Seguimiento en tiempo real',
      'de': 'Flugverfolgung in Echtzeit',
      'fr': 'Suivi des vols en temps réel',
      'ja': 'リアルタイムのフライト追跡'
    },
    'flight_tracker_status': {
      'en': 'Flight status & tracking',
      'es': 'Estado y seguimiento del vuelo',
      'de': 'Flugstatus & -verfolgung',
      'fr': 'Statut et suivi du vol',
      'ja': 'フライトステータスと追跡'
    },
    'flight_tracker_google': {
      'en': 'Check flight status',
      'es': 'Consultar estado del vuelo',
      'de': 'Flugstatus prüfen',
      'fr': 'Vérifier le statut du vol',
      'ja': 'フライトステータスを確認'
    },
    'trip_days': {
      'en': 'days',
      'es': 'días',
      'de': 'Tage',
      'fr': 'jours',
      'ja': '日'
    },
    'trip_member': {
      'en': 'member',
      'es': 'miembro',
      'de': 'Mitglied',
      'fr': 'membre',
      'ja': 'メンバー'
    },
    'trip_members': {
      'en': 'members',
      'es': 'miembros',
      'de': 'Mitglieder',
      'fr': 'membres',
      'ja': 'メンバー'
    },
    'join_trip_join_trip': {
      'en': 'Join Trip',
      'es': 'Unirse al viaje',
      'de': 'Reise beitreten',
      'fr': 'Rejoindre le voyage',
      'ja': '旅行に参加'
    },
    'enter_invite_code_join_trip': {
      'en': 'Enter the invite code',
      'es': 'Introduce el código de invitación',
      'de': 'Einladungscode eingeben',
      'fr': "Saisir le code d'invitation",
      'ja': '招待コードを入力'
    },
    'invite_code_hint_join_trip': {
      'en': 'TRVL-XXXXXX',
      'es': 'TRVL-XXXXXX',
      'de': 'TRVL-XXXXXX',
      'fr': 'TRVL-XXXXXX',
      'ja': 'TRVL-XXXXXX'
    },
    'enter_invite_code_error_join_trip': {
      'en': 'Please enter an invite code',
      'es': 'Por favor introduce un código de invitación',
      'de': 'Bitte geben Sie einen Einladungscode ein',
      'fr': "Veuillez saisir un code d'invitation",
      'ja': '招待コードを入力してください'
    },
    'invalid_invite_code_join_trip': {
      'en': 'Invalid invite code format',
      'es': 'Formato de código inválido',
      'de': 'Ungültiges Format des Einladungscodes',
      'fr': "Format du code d'invitation invalide",
      'ja': '招待コードの形式が不正です'
    },
    'failed_join_trip': {
      'en': 'Failed to join trip',
      'es': 'Error al unirse al viaje',
      'de': 'Beitritt zur Reise fehlgeschlagen',
      'fr': 'Échec du ralliement au voyage',
      'ja': '旅行への参加に失敗しました'
    },
    'scan_qr_join_trip': {
      'en': 'Scan QR',
      'es': 'Escanear QR',
      'de': 'QR-Code scannen',
      'fr': 'Scanner le QR',
      'ja': 'QRコードをスキャン'
    },
    'map_title': {
      'en': 'My Map 🗺️',
      'es': 'Mi mapa 🗺️',
      'de': 'Meine Karte 🗺️',
      'fr': 'Ma carte 🗺️',
      'ja': 'マイマップ 🗺️'
    },
    'map_subtitle': {
      'en': 'All your destinations',
      'es': 'Todos tus destinos',
      'de': 'Alle Ihre Reiseziele',
      'fr': 'Toutes vos destinations',
      'ja': 'すべての目的地'
    },
    'loading_destinations': {
      'en': 'Loading destinations...',
      'es': 'Cargando destinos...',
      'de': 'Reiseziele werden geladen...',
      'fr': 'Chargement des destinations...',
      'ja': '目的地を読み込み中...'
    },
    'error_prefix': {
      'en': 'Error:',
      'es': 'Error:',
      'de': 'Fehler:',
      'fr': 'Erreur :',
      'ja': 'エラー:'
    },
    'no_destinations': {
      'en': 'No destinations yet',
      'es': 'Aún no hay destinos',
      'de': 'Noch keine Reiseziele',
      'fr': 'Aucune destination pour le moment',
      'ja': 'まだ目的地がありません'
    },
    'no_destinations_description': {
      'en': 'Create a trip to see your\ndestinations on the map',
      'es': 'Crea un viaje para ver tus\ndestinos en el mapa',
      'de':
          'Erstellen Sie eine Reise, um Ihre\nReiseziele auf der Karte zu sehen',
      'fr': 'Créez un voyage pour voir vos\ndestinations sur la carte',
      'ja': '地図上に目的地を表示するには\n旅行を作成してください',
    },

    // ─── Home Navigation ─────────────────────────
    'trips_tab': {
      'en': 'Trips',
      'es': 'Viajes',
      'de': 'Reisen',
      'fr': 'Voyages',
      'ja': '旅行'
    },
    'map_tab': {
      'en': 'Map',
      'es': 'Mapa',
      'de': 'Karte',
      'fr': 'Carte',
      'ja': '地図'
    },
    'profile_tab': {
      'en': 'Profile',
      'es': 'Perfil',
      'de': 'Profil',
      'fr': 'Profil',
      'ja': 'プロフィール'
    },

    // ─── Home FAB / Bottom Sheet ─────────────────
    'what_do_you_want_to_do': {
      'en': 'What do you want to do?',
      'es': '¿Qué quieres hacer?',
      'de': 'Was möchten Sie tun?',
      'fr': 'Que voulez-vous faire ?',
      'ja': '何をしたいですか？'
    },
    'start_planning_adventure': {
      'en': 'Start planning a new adventure',
      'es': 'Empieza a planear una nueva aventura',
      'de': 'Planen Sie ein neues Abenteuer',
      'fr': 'Commencez à planifier une nouvelle aventure',
      'ja': '新しい冒険の計画を始めましょう'
    },
    'enter_code_or_scan': {
      'en': 'Enter an invite code or scan QR',
      'es': 'Introduce un código o escanea un QR',
      'de': 'Einladungscode eingeben oder QR-Code scannen',
      'fr': "Saisir un code d'invitation ou scanner un QR",
      'ja': '招待コードを入力するかQRコードをスキャン'
    },
    'day_n': {
      'en': 'Day {day}',
      'es': 'Día {day}',
      'de': 'Tag {day}',
      'fr': 'Jour {day}',
      'ja': '{day}日目'
    },

    'activity_type_flight': {
      'en': 'Flight',
      'es': 'Vuelo',
      'de': 'Flug',
      'fr': 'Vol',
      'ja': 'フライト'
    },
    'activity_type_transport': {
      'en': 'Transport',
      'es': 'Transporte',
      'de': 'Transport',
      'fr': 'Transport',
      'ja': '交通機関'
    },
    'activity_type_food': {
      'en': 'Food',
      'es': 'Comida',
      'de': 'Essen',
      'fr': 'Nourriture',
      'ja': '食事'
    },
    'activity_type_bar': {
      'en': 'Bar',
      'es': 'Bar',
      'de': 'Bar',
      'fr': 'Bar',
      'ja': 'バー'
    },
    'activity_type_place': {
      'en': 'Place',
      'es': 'Lugar',
      'de': 'Ort',
      'fr': 'Lieu',
      'ja': 'スポット'
    },
    'activity_type_hotel': {
      'en': 'Hotel',
      'es': 'Hotel',
      'de': 'Hotel',
      'fr': 'Hôtel',
      'ja': 'ホテル'
    },
    'activity_type_note': {
      'en': 'Note',
      'es': 'Nota',
      'de': 'Notiz',
      'fr': 'Note',
      'ja': 'メモ'
    },
    'activity_type_expense': {
      'en': 'Expense',
      'es': 'Gasto',
      'de': 'Ausgabe',
      'fr': 'Dépense',
      'ja': '出費'
    },

    'open_with': {
      'en': 'Open with',
      'es': 'Abrir con',
      'de': 'Öffnen mit',
      'fr': 'Ouvrir avec',
      'ja': 'アプリで開く'
    },
    'choose_maps_app': {
      'en': 'Choose your preferred maps app',
      'es': 'Elige tu app de mapas preferida',
      'de': 'Wählen Sie Ihre bevorzugte Karten-App',
      'fr': 'Choisissez votre application de cartes préférée',
      'ja': 'お好みの地図アプリを選択してください'
    },
    'always_ask': {
      'en': 'Always ask',
      'es': 'Preguntar siempre',
      'de': 'Immer fragen',
      'fr': 'Toujours demander',
      'ja': '常に確認'
    },

    'map_all': {
      'en': 'All',
      'es': 'Todos',
      'de': 'Alle',
      'fr': 'Toutes',
      'ja': 'すべて',
    },
    'view_trip': {
      'en': 'View trip',
      'es': 'Ver viaje',
      'de': 'Reise ansehen',
      'fr': 'Voir le voyage',
      'ja': '旅行を見る',
    },

    'confirm_sign_out': {
      'en': 'Are you sure you want to sign out?',
      'es': '¿Estás seguro de que quieres cerrar sesión?',
      'de': 'Möchten Sie sich wirklich abmelden?',
      'fr': 'Voulez-vous vraiment vous déconnecter ?',
      'ja': '本当にログアウトしますか？',
    },
    'edit_expense': {
      'en': 'Edit expense',
      'es': 'Editar gasto',
      'de': 'Ausgabe bearbeiten',
      'fr': 'Modifier la dépense',
      'ja': '支出を編集',
    },

    'calculation_info': {
      'en': 'How is this calculated?',
      'es': '¿Cómo se calcula?',
      'de': 'Wie wird das berechnet?',
      'fr': 'Comment est-ce calculé ?',
      'ja': 'どのように計算されていますか？',
    },
    'balance_explanation': {
      'en':
          'The balance shows how much each person should receive or pay after splitting all expenses.',
      'es':
          'El balance muestra cuánto debe recibir o pagar cada persona después de repartir todos los gastos.',
      'de':
          'Der Saldo zeigt, wie viel jede Person nach der Aufteilung aller Ausgaben erhalten oder zahlen sollte.',
      'fr':
          'Le solde indique combien chaque personne doit recevoir ou payer après le partage de toutes les dépenses.',
      'ja': '残高は、すべての支出を分割した後に各人が受け取る、または支払うべき金額を示します。',
    },
    'paid': {
      'en': 'Paid',
      'es': 'Pagado',
      'de': 'Bezahlt',
      'fr': 'Payé',
      'ja': '支払額',
    },
    'share': {
      'en': 'Share',
      'es': 'Parte',
      'de': 'Anteil',
      'fr': 'Part',
      'ja': '負担額',
    },

    'create_settlement': {
      'en': 'Create settlement',
      'es': 'Crear liquidación',
      'de': 'Ausgleich erstellen',
      'fr': 'Créer le règlement',
      'ja': '精算を作成',
    },
    'mark_as_paid': {
      'en': 'Mark as paid',
      'es': 'Marcar como pagado',
      'de': 'Als bezahlt markieren',
      'fr': 'Marquer comme payé',
      'ja': '支払い済みにする',
    },
    'edit_item': {
      'en': 'Edit Item',
      'es': 'Editar elemento',
      'de': 'Element bearbeiten',
      'fr': 'Modifier l’élément',
      'ja': 'アイテムを編集'
    },
    'checklist_type_preTip': {
      'en': 'Before trip',
      'es': 'Antes del viaje',
      'de': 'Vor der Reise',
      'fr': 'Avant le voyage',
      'ja': '旅行前'
    },
    'checklist_type_during': {
      'en': 'During trip',
      'es': 'Durante el viaje',
      'de': 'Während der Reise',
      'fr': 'Pendant le voyage',
      'ja': '旅行中'
    },
    'checklist_type_postTrip': {
      'en': 'After trip',
      'es': 'Después del viaje',
      'de': 'Nach der Reise',
      'fr': 'Après le voyage',
      'ja': '旅行後'
    },
    'assigned_to': {
      'en': 'Assigned to',
      'es': 'Asignado a',
      'de': 'Zugewiesen an',
      'fr': 'Assigné à',
      'ja': '担当者'
    },
    'unassigned': {
      'en': 'Unassigned',
      'es': 'Sin asignar',
      'de': 'Nicht zugewiesen',
      'fr': 'Non assigné',
      'ja': '未割り当て'
    },
    'assign_task': {
      'en': 'Assign task',
      'es': 'Asignar tarea',
      'de': 'Aufgabe zuweisen',
      'fr': 'Attribuer la tâche',
      'ja': 'タスクを割り当て'
    },
    'remove_assignment': {
      'en': 'Remove assignment',
      'es': 'Quitar asignación',
      'de': 'Zuweisung entfernen',
      'fr': 'Supprimer l’attribution',
      'ja': '割り当てを解除'
    },
    'delete_item': {
      'en': 'Delete item?',
      'es': '¿Eliminar elemento?',
      'de': 'Element löschen?',
      'fr': 'Supprimer l’élément ?',
      'ja': 'アイテムを削除しますか？'
    },
    'delete_item_description': {
      'en': 'This item will be permanently deleted.',
      'es': 'Este elemento se eliminará permanentemente.',
      'de': 'Dieses Element wird dauerhaft gelöscht.',
      'fr': 'Cet élément sera définitivement supprimé.',
      'ja': 'このアイテムは完全に削除されます。'
    },
    'edit_item_swipe': {
      'en': 'Edit',
      'es': 'Editar',
      'de': 'Bearbeiten',
      'fr': 'Modifier',
      'ja': '編集'
    },
    'delete_item_swipe': {
      'en': 'Delete',
      'es': 'Eliminar',
      'de': 'Löschen',
      'fr': 'Supprimer',
      'ja': '削除'
    },
    'choose_avatar': {
      'en': 'Choose your avatar',
      'es': 'Elige tu avatar',
      'de': 'Wähle deinen Avatar',
      'fr': 'Choisissez votre avatar',
      'ja': 'アバターを選択',
    },
    'avatar_background': {
      'en': 'Background',
      'es': 'Fondo',
      'de': 'Hintergrund',
      'fr': 'Arrière-plan',
      'ja': '背景',
    },
    'generate_new_avatar': {
      'en': 'Generate new',
      'es': 'Generar nuevos',
      'de': 'Neue generieren',
      'fr': 'Générer de nouveaux',
      'ja': '新しく生成',
    },
    'remove_avatar': {
      'en': 'Remove avatar',
      'es': 'Eliminar avatar',
      'de': 'Avatar entfernen',
      'fr': 'Supprimer l’avatar',
      'ja': 'アバターを削除',
    },
    'auth_email_required': {
      'en': 'Enter your email address.',
      'es': 'Introduce tu correo electrónico.',
      'de': 'Gib deine E-Mail-Adresse ein.',
      'fr': 'Saisissez votre adresse e-mail.',
      'ja': 'メールアドレスを入力してください。',
    },
    'auth_email_invalid': {
      'en': 'This email address doesn\'t look right. Check it and try again.',
      'es':
          'El correo electrónico no parece correcto. Revísalo e inténtalo de nuevo.',
      'de':
          'Diese E-Mail-Adresse scheint nicht korrekt zu sein. Bitte überprüfe sie.',
      'fr': 'Cette adresse e-mail ne semble pas correcte. Vérifiez-la.',
      'ja': 'メールアドレスの形式を確認してください。',
    },
    'auth_password_required': {
      'en': 'Enter your password to continue.',
      'es': 'Introduce tu contraseña para continuar.',
      'de': 'Gib dein Passwort ein, um fortzufahren.',
      'fr': 'Saisissez votre mot de passe pour continuer.',
      'ja': '続行するにはパスワードを入力してください。',
    },
    'auth_name_required': {
      'en': 'What should we call you?',
      'es': '¿Cómo te llamamos?',
      'de': 'Wie dürfen wir dich nennen?',
      'fr': 'Comment pouvons-nous vous appeler ?',
      'ja': 'お名前を入力してください。',
    },
    'auth_email_helper': {
      'en': 'Use the email address associated with your account.',
      'es': 'Utiliza el correo electrónico asociado a tu cuenta.',
      'de': 'Verwende die E-Mail-Adresse deines Kontos.',
      'fr': 'Utilisez l’adresse e-mail associée à votre compte.',
      'ja': 'アカウントに登録したメールアドレスを使用してください。',
    },
    'auth_password_helper': {
      'en': 'Your password is kept private and secure.',
      'es': 'Tu contraseña se mantiene privada y segura.',
      'de': 'Dein Passwort bleibt privat und sicher.',
      'fr': 'Votre mot de passe reste privé et sécurisé.',
      'ja': 'パスワードは安全に保護されます。',
    },
    'auth_error_invalid_credentials': {
      'en': 'Incorrect email or password.',
      'es': 'El correo o la contraseña no son correctos.',
      'de': 'E-Mail-Adresse oder Passwort falsch.',
      'fr': 'E-mail ou mot de passe incorrect.',
      'ja': 'メールアドレスまたはパスワードが正しくありません。',
    },

    'auth_error_email_in_use': {
      'en': 'This email is already registered.',
      'es': 'Este correo electrónico ya está registrado.',
      'de': 'Diese E-Mail-Adresse ist bereits registriert.',
      'fr': 'Cette adresse e-mail est déjà utilisée.',
      'ja': 'このメールアドレスは既に登録されています。',
    },

    'auth_error_weak_password': {
      'en': 'Your password is too weak.',
      'es': 'La contraseña es demasiado débil.',
      'de': 'Dein Passwort ist zu schwach.',
      'fr': 'Votre mot de passe est trop faible.',
      'ja': 'パスワードが弱すぎます。',
    },

    'auth_error_network': {
      'en': 'Check your internet connection.',
      'es': 'Comprueba tu conexión a Internet.',
      'de': 'Überprüfe deine Internetverbindung.',
      'fr': 'Vérifiez votre connexion Internet.',
      'ja': 'インターネット接続を確認してください。',
    },

    'auth_error_too_many_requests': {
      'en': 'Too many attempts. Try again later.',
      'es': 'Demasiados intentos. Inténtalo más tarde.',
      'de': 'Zu viele Versuche. Versuche es später erneut.',
      'fr': 'Trop de tentatives. Réessayez plus tard.',
      'ja': '試行回数が多すぎます。後でもう一度お試しください。',
    },

    'auth_error_user_disabled': {
      'en': 'This account has been disabled.',
      'es': 'Esta cuenta ha sido deshabilitada.',
      'de': 'Dieses Konto wurde deaktiviert.',
      'fr': 'Ce compte a été désactivé.',
      'ja': 'このアカウントは無効になっています。',
    },

    'auth_error_operation_not_allowed': {
      'en': 'This sign-in method is not enabled.',
      'es': 'Este método de acceso no está habilitado.',
      'de': 'Diese Anmeldemethode ist nicht aktiviert.',
      'fr': 'Cette méthode de connexion n’est pas activée.',
      'ja': 'このログイン方法は有効になっていません。',
    },

    'auth_error_generic': {
      'en': 'Something went wrong. Please try again.',
      'es': 'Algo ha salido mal. Inténtalo de nuevo.',
      'de': 'Etwas ist schiefgelaufen. Bitte versuche es erneut.',
      'fr': 'Une erreur s’est produite. Veuillez réessayer.',
      'ja': 'エラーが発生しました。もう一度お試しください。',
    },
  };

  static String get(String key, String languageCode,
      {Map<String, String>? params}) {
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
    final languageCode =
        ProviderScope.containerOf(this).read(effectiveLanguageCodeProvider);
    return AppStrings.get(key, languageCode, params: params);
  }
}
