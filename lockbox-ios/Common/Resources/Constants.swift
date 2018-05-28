/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
// swiftlint:disable line_length

import Foundation
import UIKit

struct Constant {
    struct app {
        static let redirectURI = "https://mozilla-lockbox.github.io/fxa/ios-redirect.html"
        static let faqURL = "https://lockbox.firefox.com/faq.html"
        static let provideFeedbackURL = "https://qsurvey.mozilla.com/s3/Lockbox-Input"
        static let useLockboxFAQ = "https://lockbox.firefox.com/faq.html#how-do-i-use-lockbox"
        static let enableSyncFAQ = "https://lockbox.firefox.com/faq.html#how-do-i-enable-sync-on-firefox"
    }

    struct color {
        static let cellBorderGrey = UIColor(hex: 0xC8C7CC)
        static let viewBackground = UIColor(hex: 0xEDEDF0)
        static let lightGrey = UIColor(hex: 0xEFEFEF)
        static let lockBoxBlue = UIColor(hex: 0x0060DF)
        static let lockBoxTeal = UIColor(hex: 0x00C8D7)
        static let kebabBlue = UIColor(hex: 0x003EAA)
        static let settingsHeader = UIColor(hex: 0x737373)
        static let tableViewCellHighlighted = UIColor(hex: 0xE5EFF9)
        static let buttonTitleColorNormalState = UIColor.white
        static let buttonTitleColorOtherState = UIColor(white: 1.0, alpha: 0.6)
    }

    struct fxa {
        static let clientID = "98adfa37698f255b"
        static let oauthHost = "oauth.accounts.firefox.com"
        static let profileHost = "profile.accounts.firefox.com"
    }

    struct string {
        static let account = NSLocalizedString("account", value: "Compte", comment: "Titre de la page de paramétrage permettant aux utilisateurs de gérer leurs comptes.")
        static let alphabetically = NSLocalizedString("alphabetically", value: "Par ordre alphabétique", comment: "Étiquette pour l'action de la feuille d'options permettant aux utilisateurs de trier une liste d'entrées par ordre alphabétique.")
        static let aToZ = NSLocalizedString("a_to_z", value: "A-Z", comment: "Étiquette pour le bouton permettant aux utilisateurs de trier une liste d'entrées par ordre alphabétique.")
        static let back = NSLocalizedString("back", value: "Rtour", comment: "Titre du bouton Précédent")
        static let cancel = NSLocalizedString("cancel", value: "Annuler", comment: "Titre du bouton Annuler")
        static let close = NSLocalizedString("close", value: "Fermer", comment: "Titre du bouton Précédent Fermer")
        static let unlink = NSLocalizedString("unlink", value: "Déconnecter", comment: "Déconnecter le titre du bouton")
        static let done = NSLocalizedString("done", value: "Terminer", comment: "Texte sur le bouton pour fermer les réglages")
        static let confirmDialogTitle = NSLocalizedString("confirm_dialog_title", value: "Déconnecter Firefox Lockbox ?", comment: "Confirmer le titre du dialogue")
        static let confirmDialogMessage = NSLocalizedString("confirm_dialog_message", value: "Cela supprimera les informations de votre compte Firefox et toutes les entrées sauvegardées de Firefox Lockbox.", comment: "Confirmer le message de dialogue")
        static let fieldNameCopied = NSLocalizedString("fieldNameCopied", value: "%@ copied", comment: "Texte d'alerte lorsqu'un champ a été copié, avec une valeur de nom de champ interpolé.")
        static let notes = NSLocalizedString("notes", value: "Notes", comment: "Titre de section pour la zone de notes de l'écran de détail du poste.")
        static let ok = NSLocalizedString("ok", value: "OK", comment: "Titre du boutton OK")
        static let password = NSLocalizedString("password", value: "Password", comment: "Texte du titre de la section pour le mot de passe dans l'écran de détail du poste.")
        static let recent = NSLocalizedString("recent", value: "Réçent", comment: "Titre du bouton lorsque la liste des entrées est triée selon la dernière entrée utilisée.")
        static let recentlyUsed = NSLocalizedString("recently_used", value: "Réçemment utilisé", comment: "Étiquette pour l'action de la feuille d'options permettant aux utilisateurs de trier une liste d'entrées en fonction des entrées les plus récemment utilisées.")
        static let signInFaceID = NSLocalizedString("signin_with_faceid", value: "Ouvrir une session avec Face ID", comment: "Ouvrir une session avec Face ID")
        static let signInTouchID = NSLocalizedString("signin_with_touchid", value: "Connectez-vous avec Touch ID", comment: "Étiquette pour le bouton permettant de déverrouiller l'appareil à l'aide de Touch ID.")
        static let sortEntries = NSLocalizedString("sort_entries", value: "Trie des entrées", comment: "Titre de la feuille d'options permettant aux utilisateurs de trier les entrées. ")
        static let unnamedEntry = NSLocalizedString("unnamed_entry", value: "Entrée non nommée", comment: "Texte de caractère de remplissage lorsqu'il n'y a pas de nom d'entrée.")
        static let username = NSLocalizedString("username", value: "Nom d'utilisateur", comment: "Texte du titre de la section pour le nom d'utilisateur sur l'écran de détail de l'article.")
        static let usernamePlaceholder = NSLocalizedString("username_placeholder", value: "(pas de nom d'utilisateur)", comment: "Texte du caractère de remplissage lorsqu'il n'y a pas de nom d'utilisateur")
        static let unlockPlaceholder = NSLocalizedString("unlock_placeholder", value: "Ceci déverrouillera l'application.", comment: "Texte de remplissage lorsque le courriel de l'utilisateur n'est pas disponible pendant le déverrouillage de la boîte postale, affiché dans les messages-guides Touch ID et Passcode.")
        static let webAddress = NSLocalizedString("web_address", value: "Addresse Web", comment: "Texte du titre de la section pour l'adresse Web sur l'écran de détail de l'article.")
        static let yourLockbox = NSLocalizedString("your_lockbox", value: "Votre Lockbox Firefox", comment: "Titre apparaissant au-dessus de la liste des entrées de l'écran principal de l'application.")
        static let settingsSupportSectionHeader = NSLocalizedString("settings.support.header", value: "SUPPORT", comment: "Etiquette de section de support dans les réglages")
        static let settingsConfigurationSectionHeader = NSLocalizedString("settings.configuration.header", value: "CONFIGURATION", comment: "Etiquette de configuration dans les réglages")
        static let settingsTitle = NSLocalizedString("settings.title", value: "Réglages", comment: "Titre sur l'écran de réglage")
        static let settingsProvideFeedback = NSLocalizedString("settings.provideFeedback", value: "Envoyer retour utilisateur", comment: "Option d'envoi de retour utilisateur dans les paramètres")
        static let settingsFaq = NSLocalizedString("settings.faq", value: "FAQ", comment: "Option FAQ dans les réglages")
        static let settingsAccount = NSLocalizedString("settings.account", value: "Compte", comment: "Option de compte dans les réglages")
        static let settingsAutoLock = NSLocalizedString("settings.autoLock", value: "Verrouillage automatique", comment: "Option d'auto-verrouillage dans les réglages")
        static let settingsBrowser = NSLocalizedString("settings.browser", value: "Ouvrir des sites Web dans", comment: "Option du navigateur préféré dans les paramètres de configuration")
        static let autoLockOnAppExit = NSLocalizedString("settings.autoLock.onAppExit", value: "A la sortie de l'application", comment: "Réglage du verrouillage automatique à la sortie de l'application")
        static let autoLockOneMinute = NSLocalizedString("settings.autoLock.oneMinute", value: "1 minute", comment: "Réglage du verrouillage automatique de 1 minute")
        static let autoLockFiveMinutes = NSLocalizedString("settings.autoLock.fiveMinutes", value: "5 minutes", comment: "Réglage du verrouillage automatique des 5 minutes")
        static let autoLockThirtyMinutes = NSLocalizedString("settings.autoLock.thirtyMinutes", value: "30 minutes", comment: "Réglage du verrouillage automatique des 30 minutes")
        static let autoLockOneHour = NSLocalizedString("settings.autoLock.oneHour", value: "1 heure", comment: "1 heure de verrouillage automatique")
        static let autoLockTwelveHours = NSLocalizedString("settings.autoLock.twelveHour", value: "12 heures", comment: "12 heures de verrouillage automatique")
        static let autoLockTwentyFourHours = NSLocalizedString("settings.autoLock.twentyFourHour", value: "24 heures", comment: "24 heures de verrouillage automatique")
        static let autoLockNever = NSLocalizedString("settings.autoLock.never", value: "Jamais", comment: "Jamais")
        static let autoLockHeader = NSLocalizedString("settings.autoLock.header", value: "Déconnectez-vous de la boîte postale Firefox après l'ouverture d'une session.", comment: "Affichage de l'en-tête au-dessus des paramètres de verrouillage automatique")
        static let settingsBrowserChrome = NSLocalizedString("settings.browser.chrome", value: "Google Chrome", comment: "Navigateur Chrome")
        static let settingsBrowserFirefox = NSLocalizedString("settings.browser.firefox", value: "Firefox", comment: "Navigateur Firefox")
        static let settingsBrowserFocus = NSLocalizedString("settings.browser.focus", value: "Firefox Focus", comment: "Navigateur Focus")
        static let settingsBrowserSafari = NSLocalizedString("settings.browser.safari", value: "Safari", comment: "Navigateur Safari")
        static let settingsUsageData = NSLocalizedString("settings.usageData", value: "Envoyer les données d'utilisation", comment: "Réglage de l'envoi de données d'utilisation")
        static let settingsUsageDataSubtitle = NSLocalizedString("settings.usageData.subtitle", value: "Mozilla s'efforce de ne collecter que ce dont nous avons besoin pour fournir et améliorer Firefox Lockbox pour tout le monde. ", comment: "Réglage pour l'envoi de sous-titres de données d'utilisation")
        static let learnMore = NSLocalizedString("settings.learnMore", value: "En savoir plus", comment: "Étiquette pour lien pour en savoir plus")
        static let notUsingPasscode = NSLocalizedString("not_using_passcode", value: "Vous n'utilisez pas de code d'accès.", comment:"Titre de la boîte de dialogue avec les informations de réglage du code d'accès")
        static let passcodeInformation = NSLocalizedString("passcode_info", value: "Vous devriez utiliser un code d'accès pour verrouiller votre iPhone. Sans code d'accès, toute personne possédant votre iPhone peut accéder aux informations enregistrées ici.", comment: "Texte informatif au sujet du ")
        static let skip = NSLocalizedString("skip", value: "Passer", comment: "Étiquette pour bouton permettant aux utilisateurs de sauter le réglage du code d'accès ou de la biométrie sur l'appareil.")
        static let setPasscode = NSLocalizedString("set_passcode", value: "Définir le code d'accès", comment: "Étiquette pour bouton permettant aux utilisateurs d'accéder aux paramètres du code d'accès.")
    }

    struct number {
        static let displayStatusAlertLength = TimeInterval(1.5)
        static let displayAlertFade = TimeInterval(0.3)
        static let displayAlertOpacity: CGFloat = 0.75
        static let displayAlertYPercentage: CGFloat = 0.4
        static let fxaButtonTopSpaceFirstLogin: CGFloat = 88.0
        static let fxaButtonTopSpaceUnlock: CGFloat = 40.0
        static let copyExpireTimeSecs = 60
    }

    struct setting {
        static let defaultBiometricLockEnabled = false
        static let defaultAutoLockTimeout = AutoLockSetting.FiveMinutes
        static let defaultPreferredBrowser = PreferredBrowserSetting.Safari
        static let defaultRecordUsageData = true
    }
}
