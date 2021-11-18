-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: mariadb
-- Erstellungszeit: 17. Nov 2021 um 11:17
-- Server-Version: 10.5.9-MariaDB-1:10.5.9+maria~focal
-- PHP-Version: 7.4.16

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `authorization`
--
CREATE DATABASE IF NOT EXISTS `authorization` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `authorization`;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `refresh_tokens`
--
-- Erstellt am: 12. Nov 2021 um 20:40
-- Zuletzt aktualisiert: 17. Nov 2021 um 09:31
--

DROP TABLE IF EXISTS `refresh_tokens`;
CREATE TABLE `refresh_tokens` (
  `refresh_token_id` int(11) NOT NULL,
  `refresh_token` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `expires` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `refresh_tokens`:
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `refresh_token_scopes`
--
-- Erstellt am: 12. Nov 2021 um 22:35
-- Zuletzt aktualisiert: 17. Nov 2021 um 09:31
--

DROP TABLE IF EXISTS `refresh_token_scopes`;
CREATE TABLE `refresh_token_scopes` (
  `mapping_id` int(11) NOT NULL,
  `refresh_token_id` int(11) DEFAULT NULL,
  `scope_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `refresh_token_scopes`:
--   `refresh_token_id`
--       `refresh_tokens` -> `refresh_token_id`
--   `scope_id`
--       `scopes` -> `scope_id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `refresh_token_token`
--
-- Erstellt am: 12. Nov 2021 um 21:29
-- Zuletzt aktualisiert: 17. Nov 2021 um 09:31
--

DROP TABLE IF EXISTS `refresh_token_token`;
CREATE TABLE `refresh_token_token` (
  `mapping_id` int(11) NOT NULL,
  `refresh_token_id` int(11) DEFAULT NULL,
  `access_token_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores the assignments between refresh_tokens and access_tokens';

--
-- RELATIONEN DER TABELLE `refresh_token_token`:
--   `refresh_token_id`
--       `refresh_tokens` -> `refresh_token_id`
--   `access_token_id`
--       `tokens` -> `token_id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `roles`
--
-- Erstellt am: 05. Nov 2021 um 15:25
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_description` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `roles`:
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `role_scopes`
--
-- Erstellt am: 06. Nov 2021 um 16:45
--

DROP TABLE IF EXISTS `role_scopes`;
CREATE TABLE `role_scopes` (
  `mapping_id` int(11) NOT NULL,
  `role_id` int(11) DEFAULT NULL,
  `scope_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `role_scopes`:
--   `role_id`
--       `roles` -> `role_id`
--   `scope_id`
--       `scopes` -> `scope_id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `scopes`
--
-- Erstellt am: 05. Nov 2021 um 15:24
-- Zuletzt aktualisiert: 17. Nov 2021 um 10:18
--

DROP TABLE IF EXISTS `scopes`;
CREATE TABLE `scopes` (
  `scope_id` int(11) NOT NULL,
  `scope_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `scope_description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `scope_value` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `scopes`:
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `tokens`
--
-- Erstellt am: 12. Nov 2021 um 20:41
-- Zuletzt aktualisiert: 17. Nov 2021 um 09:31
--

DROP TABLE IF EXISTS `tokens`;
CREATE TABLE `tokens` (
  `token_id` int(11) NOT NULL,
  `token` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `expires` int(11) DEFAULT NULL COMMENT 'UNIX Timestamp',
  `created` int(11) NOT NULL,
  `active` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `tokens`:
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `token_scopes`
--
-- Erstellt am: 12. Nov 2021 um 22:12
-- Zuletzt aktualisiert: 17. Nov 2021 um 09:31
--

DROP TABLE IF EXISTS `token_scopes`;
CREATE TABLE `token_scopes` (
  `mapping_id` int(11) NOT NULL,
  `token_id` int(11) DEFAULT NULL,
  `scope_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `token_scopes`:
--   `scope_id`
--       `scopes` -> `scope_id`
--   `token_id`
--       `tokens` -> `token_id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `users`
--
-- Erstellt am: 06. Nov 2021 um 13:16
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `users`:
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `user_roles`
--
-- Erstellt am: 06. Nov 2021 um 16:44
--

DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `mapping_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `user_roles`:
--   `role_id`
--       `roles` -> `role_id`
--   `user_id`
--       `users` -> `user_id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `user_scopes`
--
-- Erstellt am: 13. Nov 2021 um 19:25
--

DROP TABLE IF EXISTS `user_scopes`;
CREATE TABLE `user_scopes` (
  `mapping_id` int(11) NOT NULL,
  `scope_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `user_scopes`:
--   `scope_id`
--       `scopes` -> `scope_id`
--   `user_id`
--       `users` -> `user_id`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `user_tokens`
--
-- Erstellt am: 12. Nov 2021 um 22:11
-- Zuletzt aktualisiert: 17. Nov 2021 um 09:31
--

DROP TABLE IF EXISTS `user_tokens`;
CREATE TABLE `user_tokens` (
  `mapping_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `token_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- RELATIONEN DER TABELLE `user_tokens`:
--   `token_id`
--       `tokens` -> `token_id`
--   `user_id`
--       `users` -> `user_id`
--

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`refresh_token_id`),
  ADD UNIQUE KEY `refresh_tokens_refresh_token_uindex` (`refresh_token`) USING HASH,
  ADD KEY `refresh_tokens_tokens_token_id_fk` (`active`);

--
-- Indizes für die Tabelle `refresh_token_scopes`
--
ALTER TABLE `refresh_token_scopes`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `refresh_token_scopes_refresh_tokens_refresh_token_id_fk` (`refresh_token_id`),
  ADD KEY `refresh_token_scopes_scopes_scope_id_fk` (`scope_id`);

--
-- Indizes für die Tabelle `refresh_token_token`
--
ALTER TABLE `refresh_token_token`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `refresh_token_token_refresh_tokens_refresh_token_id_fk` (`refresh_token_id`),
  ADD KEY `refresh_token_token_tokens_token_id_fk` (`access_token_id`);

--
-- Indizes für die Tabelle `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `unique_role_name` (`role_name`);

--
-- Indizes für die Tabelle `role_scopes`
--
ALTER TABLE `role_scopes`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `role_scopes_roles_role_id_fk` (`role_id`),
  ADD KEY `role_scopes_scopes_scope_id_fk` (`scope_id`);

--
-- Indizes für die Tabelle `scopes`
--
ALTER TABLE `scopes`
  ADD PRIMARY KEY (`scope_id`),
  ADD UNIQUE KEY `unqiue_scope_name` (`scope_name`),
  ADD UNIQUE KEY `unqiue_scope_value` (`scope_value`);

--
-- Indizes für die Tabelle `tokens`
--
ALTER TABLE `tokens`
  ADD PRIMARY KEY (`token_id`);

--
-- Indizes für die Tabelle `token_scopes`
--
ALTER TABLE `token_scopes`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `token_scopes_scopes_scope_id_fk` (`scope_id`),
  ADD KEY `token_scopes_tokens_token_id_fk` (`token_id`);

--
-- Indizes für die Tabelle `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `unique_name` (`first_name`,`last_name`),
  ADD UNIQUE KEY `unqiue_username` (`username`),
  ADD UNIQUE KEY `unique_password` (`password`) USING HASH;

--
-- Indizes für die Tabelle `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `user_roles_roles_role_id_fk` (`role_id`),
  ADD KEY `user_roles_users_user_id_fk` (`user_id`);

--
-- Indizes für die Tabelle `user_scopes`
--
ALTER TABLE `user_scopes`
  ADD PRIMARY KEY (`mapping_id`),
  ADD UNIQUE KEY `unique_assignment` (`scope_id`,`user_id`),
  ADD KEY `user_scopes_users_user_id_fk` (`user_id`);

--
-- Indizes für die Tabelle `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `user_tokens_tokens_token_id_fk` (`token_id`),
  ADD KEY `user_tokens_users_user_id_fk` (`user_id`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `refresh_token_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `refresh_token_scopes`
--
ALTER TABLE `refresh_token_scopes`
  MODIFY `mapping_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `refresh_token_token`
--
ALTER TABLE `refresh_token_token`
  MODIFY `mapping_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `role_scopes`
--
ALTER TABLE `role_scopes`
  MODIFY `mapping_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `scopes`
--
ALTER TABLE `scopes`
  MODIFY `scope_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `tokens`
--
ALTER TABLE `tokens`
  MODIFY `token_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `token_scopes`
--
ALTER TABLE `token_scopes`
  MODIFY `mapping_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `mapping_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `user_scopes`
--
ALTER TABLE `user_scopes`
  MODIFY `mapping_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `user_tokens`
--
ALTER TABLE `user_tokens`
  MODIFY `mapping_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `refresh_token_scopes`
--
ALTER TABLE `refresh_token_scopes`
  ADD CONSTRAINT `refresh_token_scopes_refresh_tokens_refresh_token_id_fk` FOREIGN KEY (`refresh_token_id`) REFERENCES `refresh_tokens` (`refresh_token_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `refresh_token_scopes_scopes_scope_id_fk` FOREIGN KEY (`scope_id`) REFERENCES `scopes` (`scope_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `refresh_token_token`
--
ALTER TABLE `refresh_token_token`
  ADD CONSTRAINT `refresh_token_token_refresh_tokens_refresh_token_id_fk` FOREIGN KEY (`refresh_token_id`) REFERENCES `refresh_tokens` (`refresh_token_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `refresh_token_token_tokens_token_id_fk` FOREIGN KEY (`access_token_id`) REFERENCES `tokens` (`token_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `role_scopes`
--
ALTER TABLE `role_scopes`
  ADD CONSTRAINT `role_scopes_roles_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `role_scopes_scopes_scope_id_fk` FOREIGN KEY (`scope_id`) REFERENCES `scopes` (`scope_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `token_scopes`
--
ALTER TABLE `token_scopes`
  ADD CONSTRAINT `token_scopes_scopes_scope_id_fk` FOREIGN KEY (`scope_id`) REFERENCES `scopes` (`scope_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `token_scopes_tokens_token_id_fk` FOREIGN KEY (`token_id`) REFERENCES `tokens` (`token_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_roles_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_roles_users_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `user_scopes`
--
ALTER TABLE `user_scopes`
  ADD CONSTRAINT `user_scopes_scopes_scope_id_fk` FOREIGN KEY (`scope_id`) REFERENCES `scopes` (`scope_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_scopes_users_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints der Tabelle `user_tokens`
--
ALTER TABLE `user_tokens`
  ADD CONSTRAINT `user_tokens_tokens_token_id_fk` FOREIGN KEY (`token_id`) REFERENCES `tokens` (`token_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_tokens_users_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;
SET FOREIGN_KEY_CHECKS=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
