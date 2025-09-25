CREATE TABLE IF NOT EXISTS `lux_delivery` (
  `identifier` varchar(64) NOT NULL,
  `level` int NOT NULL DEFAULT 0,
  `xp` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;