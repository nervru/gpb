CREATE TABLE `message` (
  `created` timestamp NOT NULL,
  `id` varchar(255) NOT NULL,
  `int_id` char(16) NOT NULL,
  `str` text,
  `status` tinyint(1) DEFAULT NULL,
  `log_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `message_created_idx` (`created`),
  KEY `message_int_id_idx` (`int_id`),
  KEY `log_id` (`log_id`)
);

CREATE TABLE `log` (
  `created` timestamp NOT NULL,
  `int_id` char(16) DEFAULT NULL,
  `str` text,
  `address` varchar(255) DEFAULT NULL,
  `log_id` int NOT NULL,
  KEY `log_address_idx` (`address`),
  KEY `log_id` (`log_id`)
);
