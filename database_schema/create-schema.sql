SET foreign_key_checks = 0;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements` (
 `announcementid` mediumint(8) unsigned NOT NULL auto_increment,
 `announcement_text` text NOT NULL,
 `priority` mediumint(8),
 `start_date` datetime,
 `end_date` datetime,
 PRIMARY KEY (`announcementid`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `layouts`
--

DROP TABLE IF EXISTS `layouts`;
CREATE TABLE `layouts` (
 `layout_id` mediumint(8) unsigned NOT NULL auto_increment,
 `timezone` varchar(50) NOT NULL,
 PRIMARY KEY (`layout_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `time_blocks`
--

DROP TABLE IF EXISTS `time_blocks`;
CREATE TABLE `time_blocks` (
 `block_id` mediumint(8) unsigned NOT NULL auto_increment,
 `label` varchar(85),
 `end_label` varchar(85),
 `availability_code` tinyint(2) unsigned NOT NULL,
 `layout_id` mediumint(8) unsigned NOT NULL,
 `start_time` time NOT NULL,
 `end_time` time NOT NULL,
 PRIMARY KEY (`block_id`),
 INDEX (`layout_id`),
 FOREIGN KEY (`layout_id`) 
	REFERENCES layouts(`layout_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
CREATE TABLE `schedules` (
 `schedule_id` smallint(5) unsigned NOT NULL auto_increment,
 `name` varchar(85) NOT NULL,
 `isdefault` tinyint(1) unsigned NOT NULL,
 `weekdaystart` tinyint(2) unsigned NOT NULL,
 `daysvisible` tinyint(2) unsigned NOT NULL default '7',
 `layout_id` mediumint(8) unsigned NOT NULL,
 `legacyid` char(16),
 PRIMARY KEY (`schedule_id`),
 INDEX (`layout_id`),
 FOREIGN KEY (`layout_id`)
	REFERENCES layouts(`layout_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;


--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
 `group_id` smallint(5) unsigned NOT NULL auto_increment,
 `name` varchar(85) NOT NULL,
 `admin_group_id` smallint(5) unsigned,
 `legacyid` char(16),
 PRIMARY KEY (`group_id`),
 FOREIGN KEY (`admin_group_id`)
	REFERENCES groups(`group_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;


--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
 `role_id` tinyint(2) unsigned NOT NULL,
 `name` varchar(85),
 `role_level` tinyint(2) unsigned,
 PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `group_roles`;
CREATE TABLE `group_roles` (
 `group_id` smallint(8) unsigned NOT NULL,
 `role_id` tinyint(2) unsigned NOT NULL,
 PRIMARY KEY (`group_id`, `role_id`),
 INDEX (`group_id`),
 FOREIGN KEY (`group_id`)
	REFERENCES groups(`group_id`)
	ON UPDATE CASCADE ON DELETE CASCADE,
 INDEX (`role_id`),
 FOREIGN KEY (`role_id`)
	REFERENCES roles(`role_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `user_statuses`
--

DROP TABLE IF EXISTS `user_statuses`;
CREATE TABLE `user_statuses` (
 `status_id` tinyint(2) unsigned NOT NULL,
 `description` varchar(85),
 PRIMARY KEY (`status_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
 `user_id` mediumint(8) unsigned NOT NULL auto_increment,
 `fname` varchar(85),
 `lname` varchar(85),
 `username` varchar(85),
 `email` varchar(85) NOT NULL,
 `password` varchar(85) NOT NULL,
 `salt` varchar(85) NOT NULL,
 `organization` varchar(85),
 `position` varchar(85),
 `phone` varchar(85),
 `timezone` varchar(85) NOT NULL,
 `language` VARCHAR(10) NOT NULL,
 `homepageid` tinyint(2) unsigned NOT NULL default '1',
 `date_created` datetime NOT NULL,
 `last_modified` timestamp,
 `lastlogin` datetime,
 `status_id` tinyint(2) unsigned NOT NULL,
 `legacyid` char(16),
 `legacypassword` varchar(32),
 PRIMARY KEY (`user_id`),
 INDEX (`status_id`),
 FOREIGN KEY (`status_id`) 
	REFERENCES user_statuses(`status_id`)
	ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `user_groups`
--

DROP TABLE IF EXISTS `user_groups`;
CREATE TABLE `user_groups` (
 `user_id` mediumint(8) unsigned NOT NULL,
 `group_id` smallint(5) unsigned NOT NULL,
 PRIMARY KEY (`group_id`, `user_id`),
 INDEX (`user_id`),
 FOREIGN KEY (`user_id`) 
	REFERENCES users(`user_id`)
	ON UPDATE CASCADE ON DELETE CASCADE,
 INDEX (`group_id`),
 FOREIGN KEY (`group_id`) 
	REFERENCES groups(`group_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;


--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
CREATE TABLE `resources` (
 `resource_id` smallint(5) unsigned NOT NULL auto_increment,
 `name` varchar(85) NOT NULL,
 `location` varchar(85),
 `contact_info` varchar(85),
 `description` text,
 `notes` text,
 `isactive` tinyint(1) unsigned NOT NULL default '1',
 `min_duration` int,
 `min_increment` int,
 `max_duration` int,
 `unit_cost` dec(7,2),
 `autoassign` tinyint(1) unsigned NOT NULL default '1',
 `requires_approval` tinyint(1) unsigned NOT NULL,
 `allow_multiday_reservations` tinyint(1) unsigned NOT NULL default '1',
 `max_participants` mediumint(8) unsigned,
 `min_notice_time` int,
 `max_notice_time` int,
 `image_name` varchar(50),
 `schedule_id` smallint(5) unsigned NOT NULL,
 `legacyid` char(16),
 PRIMARY KEY (`resource_id`),
 INDEX (`schedule_id`),
 FOREIGN KEY (`schedule_id`)
	REFERENCES schedules(`schedule_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `user_resource_permissions`
--

DROP TABLE IF EXISTS `user_resource_permissions`;
CREATE TABLE `user_resource_permissions` (
 `user_id` mediumint(8) unsigned NOT NULL,
 `resource_id` smallint(5) unsigned NOT NULL,
 `permission_id` tinyint(2) unsigned NOT NULL default '1',
 PRIMARY KEY (`user_id`, `resource_id`),
 INDEX (`user_id`),
 FOREIGN KEY (`user_id`) 
	REFERENCES users(`user_id`)
	ON UPDATE CASCADE ON DELETE CASCADE,
 INDEX (`resource_id`),
 FOREIGN KEY (`resource_id`) 
	REFERENCES resources(`resource_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `group_resource_permissions`
--

DROP TABLE IF EXISTS `group_resource_permissions`;
CREATE TABLE `group_resource_permissions` (
 `group_id` smallint(5) unsigned NOT NULL,
 `resource_id` smallint(5) unsigned NOT NULL,
 PRIMARY KEY (`group_id`, `resource_id`),
 INDEX (`group_id`),
 FOREIGN KEY (`group_id`) 
	REFERENCES groups(`group_id`) 
	ON UPDATE CASCADE ON DELETE CASCADE,
INDEX (`resource_id`),
FOREIGN KEY (`resource_id`) 
	REFERENCES resources(`resource_id`) 
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `reservation_types`
--

DROP TABLE IF EXISTS `reservation_types`;
CREATE TABLE `reservation_types` (
 `type_id` tinyint(2) unsigned NOT NULL,
 `label` varchar(85) NOT NULL,
 PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `reservation_statuses`
--

DROP TABLE IF EXISTS `reservation_statuses`;
CREATE TABLE `reservation_statuses` (
 `status_id` tinyint(2) unsigned NOT NULL,
 `label` varchar(85) NOT NULL,
 PRIMARY KEY (`status_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `reservation_series`
--
DROP TABLE IF EXISTS `reservation_series`;
CREATE TABLE  `reservation_series` (
  `series_id` int unsigned NOT NULL auto_increment,
  `date_created` datetime NOT NULL,
  `last_modified` datetime,
  `title` varchar(85) NOT NULL,
  `description` text,
  `allow_participation` tinyint(1) unsigned NOT NULL,
  `allow_anon_participation` tinyint(1) unsigned NOT NULL,
  `type_id` tinyint(2) unsigned NOT NULL,
  `status_id` tinyint(2) unsigned NOT NULL,
  `repeat_type` varchar(10) default NULL,
  `repeat_options` varchar(255) default NULL,
  `owner_id` mediumint(8) unsigned NOT NULL,
  `legacyid` char(16),
  PRIMARY KEY  (`series_id`),
  KEY `type_id` (`type_id`),
  KEY `status_id` (`status_id`),
  CONSTRAINT `reservations_type` FOREIGN KEY (`type_id`) REFERENCES `reservation_types` (`type_id`) ON UPDATE CASCADE,
  CONSTRAINT `reservations_status` FOREIGN KEY (`status_id`) REFERENCES `reservation_statuses` (`status_id`) ON UPDATE CASCADE,
  CONSTRAINT `reservations_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`)  ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--
-- Table structure for table `reservation_instances`
--

DROP TABLE IF EXISTS `reservation_instances`;
CREATE TABLE  `reservation_instances` (
  `reservation_instance_id` int unsigned NOT NULL auto_increment,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `reference_number` varchar(50) NOT NULL,
  `series_id` int unsigned NOT NULL,
  PRIMARY KEY  (`reservation_instance_id`),
  KEY `start_date` (`start_date`),
  KEY `end_date` (`end_date`),
  KEY `reference_number` (`reference_number`),
  KEY `series_id` (`series_id`),
  CONSTRAINT `reservations_series` FOREIGN KEY (`series_id`) REFERENCES `reservation_series` (`series_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--
-- Table structure for table `reservation_users`
--

DROP TABLE IF EXISTS `reservation_users`;
CREATE TABLE `reservation_users` (
  `reservation_instance_id` int unsigned NOT NULL,
  `user_id` mediumint(8) unsigned NOT NULL,
  `reservation_user_level` tinyint(2) unsigned NOT NULL,
  PRIMARY KEY  (`reservation_instance_id`,`user_id`),
  KEY `reservation_instance_id` (`reservation_instance_id`),
  KEY `user_id` (`user_id`),
  KEY `reservation_user_level` (`reservation_user_level`),
  FOREIGN KEY (`reservation_instance_id`) REFERENCES `reservation_instances` (`reservation_instance_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


--
-- Table structure for table `reservation_resources`
--

DROP TABLE IF EXISTS `reservation_resources`;
CREATE TABLE `reservation_resources` (
 `series_id` int unsigned NOT NULL,
 `resource_id` smallint(5) unsigned NOT NULL,
 `resource_level_id` tinyint(2) unsigned NOT NULL,
 PRIMARY KEY (`series_id`, `resource_id`),
 INDEX (`resource_id`),
 FOREIGN KEY (`resource_id`) 
	REFERENCES resources(`resource_id`)
	ON UPDATE CASCADE ON DELETE CASCADE,
 INDEX (`series_id`),
 FOREIGN KEY (`series_id`) 
	REFERENCES reservation_series(`series_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `blackout_series`
--
DROP TABLE IF EXISTS `blackout_series`;
CREATE TABLE  `blackout_series` (
  `blackout_series_id` int unsigned NOT NULL auto_increment,
  `date_created` datetime NOT NULL,
  `last_modified` datetime,
  `title` varchar(85) NOT NULL,
  `description` text,
  `owner_id` mediumint(8) unsigned NOT NULL,
  `resource_id` mediumint(8) unsigned NOT NULL,
  `legacyid` char(16),
  PRIMARY KEY  (`blackout_series_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--
-- Table structure for table `blackout_instances`
--

DROP TABLE IF EXISTS `blackout_instances`;
CREATE TABLE  `blackout_instances` (
  `blackout_instance_id` int unsigned NOT NULL auto_increment,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `blackout_series_id` int unsigned NOT NULL,
  PRIMARY KEY  (`blackout_instance_id`),
  INDEX `start_date` (`start_date`),
  INDEX `end_date` (`end_date`),
  INDEX `blackout_series_id` (`blackout_series_id`),
  FOREIGN KEY (`blackout_series_id`)
  	REFERENCES `blackout_series` (`blackout_series_id`)
  	ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--
-- Table structure for table `user_email_preferences`
--

DROP TABLE IF EXISTS `user_email_preferences`;
CREATE TABLE `user_email_preferences` (
  `user_id` mediumint(8) unsigned NOT NULL,
  `event_category` varchar(45) NOT NULL,
  `event_type` varchar(45) NOT NULL,
 PRIMARY KEY (`user_id`, `event_category`, `event_type`),
 FOREIGN KEY (`user_id`)
	REFERENCES users(`user_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Table structure for table `quotas`
--

DROP TABLE IF EXISTS `quotas`;
CREATE TABLE `quotas` (
 `quota_id` mediumint(8) unsigned NOT NULL auto_increment,
 `quota_limit` decimal(7,2) unsigned NOT NULL,
 `unit` varchar(25) NOT NULL,
 `duration` varchar(25) NOT NULL,
 `resource_id` smallint(5) unsigned,
 `group_id` smallint(5) unsigned,
 `schedule_id` smallint(5) unsigned,
 PRIMARY KEY (`quota_id`),
 FOREIGN KEY (`resource_id`)
	REFERENCES resources(`resource_id`)
	ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (`group_id`)
	REFERENCES groups(`group_id`)
	ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (`schedule_id`)
	REFERENCES schedules(`schedule_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `accessories`
--

DROP TABLE IF EXISTS `accessories`;
CREATE TABLE `accessories` (
 `accessory_id` smallint(5) unsigned NOT NULL auto_increment,
 `accessory_name` varchar(85) NOT NULL,
 `accessory_quantity` tinyint(2) unsigned,
 `legacyid` char(16),
 PRIMARY KEY (`accessory_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

--
-- Table structure for table `accessories`
--

DROP TABLE IF EXISTS `reservation_accessories`;
CREATE TABLE `reservation_accessories` (
 `series_id` int unsigned NOT NULL,
 `accessory_id` smallint(5) unsigned NOT NULL,
 `quantity` tinyint(2) unsigned NOT NULL,
 PRIMARY KEY (`series_id`, `accessory_id`),
 INDEX (`accessory_id`),
 FOREIGN KEY (`accessory_id`)
	REFERENCES accessories(`accessory_id`)
	ON UPDATE CASCADE ON DELETE CASCADE,
 INDEX (`series_id`),
 FOREIGN KEY (`series_id`)
	REFERENCES reservation_series(`series_id`)
	ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

SET foreign_key_checks = 1;

-- UPGRADE TO VERSION 2.1



DROP TABLE IF EXISTS `dbversion`;
CREATE TABLE `dbversion` (
 `version_number` DOUBLE unsigned NOT NULL DEFAULT 0,
 `version_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

ALTER TABLE `resources` ADD COLUMN `admin_group_id` SMALLINT(5) unsigned;
ALTER TABLE `resources` ADD CONSTRAINT `admin_group_id` FOREIGN KEY (`admin_group_id`) REFERENCES groups(`group_id`) ON DELETE SET NULL;

ALTER TABLE `users` ADD COLUMN `public_id` VARCHAR(20);
CREATE UNIQUE INDEX `public_id` ON `users` (`public_id`);

ALTER TABLE `resources` ADD COLUMN `public_id` VARCHAR(20);
CREATE UNIQUE INDEX `public_id` ON `resources` (`public_id`);

ALTER TABLE `schedules` ADD COLUMN `public_id` VARCHAR(20);
CREATE UNIQUE INDEX `public_id` ON `schedules` (`public_id`);

ALTER TABLE `users` ADD COLUMN `allow_calendar_subscription` TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE `resources` ADD COLUMN `allow_calendar_subscription` TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE `schedules` ADD COLUMN `allow_calendar_subscription` TINYINT(1) NOT NULL DEFAULT 0;

-- UPGRADE TO VERSION 2.2



DROP TABLE IF EXISTS `custom_attributes`;
CREATE TABLE `custom_attributes` (
 `custom_attribute_id` mediumint(8) unsigned NOT NULL auto_increment,
 `display_label` varchar(50) NOT NULL,
 `display_type` tinyint(2) unsigned NOT NULL,
 `attribute_category` tinyint(2) unsigned NOT NULL,
 `validation_regex` varchar(50),
 `is_required` tinyint(1) unsigned NOT NULL,
 `possible_values` text,
 `sort_order` tinyint(2) unsigned,
  PRIMARY KEY (`custom_attribute_id`),
  INDEX (`attribute_category`),
  INDEX (`display_label`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

DROP TABLE IF EXISTS `custom_attribute_values`;
CREATE TABLE `custom_attribute_values` (
 `custom_attribute_value_id` mediumint(8) unsigned NOT NULL auto_increment,
 `custom_attribute_id` mediumint(8) unsigned NOT NULL,
 `attribute_value` text NOT NULL,
 `entity_id` mediumint(8) unsigned NOT NULL,
 `attribute_category`  tinyint(2) unsigned NOT NULL,
  PRIMARY KEY (`custom_attribute_value_id`),
  INDEX (`custom_attribute_id`),
  INDEX `entity_category` (`entity_id`, `attribute_category`),
  INDEX `entity_attribute` (`entity_id`, `custom_attribute_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

DROP TABLE IF EXISTS `account_activation`;
CREATE TABLE `account_activation` (
 `account_activation_id` mediumint(8) unsigned NOT NULL auto_increment,
 `user_id` mediumint(8) unsigned NOT NULL,
 `activation_code` varchar(30) NOT NULL,
 `date_created` datetime NOT NULL,
  PRIMARY KEY (`account_activation_id`),
  INDEX (`activation_code`),
  UNIQUE KEY (`activation_code`),
  FOREIGN KEY (`user_id`)
	REFERENCES users(`user_id`)
	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

DROP TABLE IF EXISTS `reservation_files`;
CREATE TABLE IF NOT EXISTS `reservation_files` (
  `file_id` int unsigned NOT NULL auto_increment,
  `series_id` int unsigned NOT NULL,
  `file_name` varchar(250) NOT NULL,
  `file_type` varchar(15) NOT NULL,
  `file_size` varchar(45) NOT NULL,
  `file_extension` varchar(10) NOT NULL,
  PRIMARY KEY  (`file_id`),
  FOREIGN KEY (`series_id`)
  	REFERENCES reservation_series(`series_id`)
  	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

-- UPGRADE TO VERSION 2.3



ALTER TABLE `schedules` ADD COLUMN `admin_group_id` SMALLINT(5) unsigned;
ALTER TABLE `schedules` ADD CONSTRAINT `schedules_groups_admin_group_id` FOREIGN KEY (`admin_group_id`) REFERENCES groups(`group_id`) ON DELETE SET NULL;

DROP TABLE IF EXISTS `saved_reports`;
CREATE TABLE `saved_reports` (
 `saved_report_id` mediumint(8) unsigned NOT NULL auto_increment,
 `report_name` varchar(50),
 `user_id` mediumint(8) unsigned NOT NULL,
 `date_created` datetime NOT NULL,
 `report_details` varchar(500) NOT NULL,
  PRIMARY KEY (`saved_report_id`),
  FOREIGN KEY (`user_id`)
	REFERENCES users(`user_id`)
	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8;

ALTER TABLE `resources` ADD COLUMN `sort_order` TINYINT(2) unsigned;