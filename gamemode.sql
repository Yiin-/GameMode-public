-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.6.17 - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for gamemode
CREATE DATABASE IF NOT EXISTS `gamemode` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `gamemode`;


-- Dumping structure for table gamemode.chars
CREATE TABLE IF NOT EXISTS `chars` (
  `uid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Veikėjo unikalus id',
  `user_id` int(11) NOT NULL COMMENT 'Žaidėjo id',
  `gang` int(11) NOT NULL,
  `gang_rank` int(11) NOT NULL,
  `name` varchar(24) CHARACTER SET latin1 NOT NULL COMMENT 'Veikėjo vardas',
  `death_anim_lib` varchar(32) COLLATE cp1257_lithuanian_ci NOT NULL,
  `death_anim_name` varchar(32) COLLATE cp1257_lithuanian_ci NOT NULL,
  `health` float NOT NULL DEFAULT '50' COMMENT 'Veikėjo sveikata',
  `max_health` float NOT NULL DEFAULT '50' COMMENT 'Veikėjo pilnos sveikatos riba',
  `default_skin` int(10) unsigned NOT NULL COMMENT 'Veikėjo numatytoji išvaizda',
  `available_skins` varchar(300) CHARACTER SET latin1 NOT NULL COMMENT 'Veikėjo galimos išvaizdos',
  `current_skin` int(11) NOT NULL COMMENT 'Veikėjo dabartinė išvaizda',
  `cash` int(11) NOT NULL DEFAULT '60' COMMENT 'Žaidėjo pinigai rankose',
  `bank` int(11) NOT NULL COMMENT 'Žaidėjo pinigai banko sąskaitoje.',
  `bank_pin` int(11) NOT NULL COMMENT 'Žaidėjo banko sąskaitos pin-kodas',
  `level` int(11) NOT NULL COMMENT 'Žaidėjo lygis.',
  `job` int(11) NOT NULL COMMENT 'Žaidėjo darbas.',
  `job_rank` int(11) NOT NULL COMMENT 'Žaidėjo pareigos darbe.',
  `posX` float NOT NULL,
  `posY` float NOT NULL,
  `posZ` float NOT NULL,
  `angle` float NOT NULL,
  `exp` int(11) NOT NULL COMMENT 'Veikėjo patirtis',
  `creation_timestamp` int(11) NOT NULL,
  `state` int(11) NOT NULL,
  `mining_xp` int(11) NOT NULL,
  `mining_lvl` int(11) NOT NULL,
  `wanted` int(11) NOT NULL COMMENT 'Veikėjo ieškomumo lygis',
  `jailed` int(11) NOT NULL COMMENT 'Ar žaidėjas yra kalėjime?',
  `jail_time_wait` int(11) NOT NULL COMMENT 'Kiek laiko jam reikia sedėti',
  `jail_time_start` int(11) NOT NULL COMMENT 'Nuo kada jis sėdi',
  `jail_type` int(11) NOT NULL COMMENT 'Kokiame kalėjime jis sėdi',
  `jail_room` int(11) NOT NULL COMMENT 'Kokioje kameroje veikėjas sėdi?',
  `salary` int(11) NOT NULL,
  `job_exp` varchar(200) CHARACTER SET latin1 NOT NULL,
  `admin` int(10) unsigned DEFAULT NULL,
  `experience` int(11) NOT NULL,
  `gang_join_time` int(11) NOT NULL,
  `fires_extinguished` int(11) DEFAULT NULL,
  `exit_x` int(11) DEFAULT NULL,
  `exit_y` int(11) DEFAULT NULL,
  `exit_z` int(11) DEFAULT NULL,
  `stink` int(11) DEFAULT NULL,
  `pizza_delivery_lvl` int(11) DEFAULT NULL,
  `pizza_delivery_xp` int(11) DEFAULT NULL,
  `minijob` int(11) DEFAULT NULL,
  `current_house` int(11) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `name` (`name`),
  KEY `FK_chars_users` (`user_id`),
  CONSTRAINT `FK_chars_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=cp1257 COLLATE=cp1257_lithuanian_ci COMMENT='Žaidėjų veikėjų informacija';

-- Dumping data for table gamemode.chars: ~11 rows (approximately)
/*!40000 ALTER TABLE `chars` DISABLE KEYS */;
INSERT INTO `chars` (`uid`, `user_id`, `gang`, `gang_rank`, `name`, `death_anim_lib`, `death_anim_name`, `health`, `max_health`, `default_skin`, `available_skins`, `current_skin`, `cash`, `bank`, `bank_pin`, `level`, `job`, `job_rank`, `posX`, `posY`, `posZ`, `angle`, `exp`, `creation_timestamp`, `state`, `mining_xp`, `mining_lvl`, `wanted`, `jailed`, `jail_time_wait`, `jail_time_start`, `jail_type`, `jail_room`, `salary`, `job_exp`, `admin`, `experience`, `gang_join_time`, `fires_extinguished`, `exit_x`, `exit_y`, `exit_z`, `stink`, `pizza_delivery_lvl`, `pizza_delivery_xp`, `minijob`, `current_house`) VALUES
	(-1, 0, 0, 0, 'Server', '', '', 50, 50, 0, '', 0, 60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(1, 1, 1, -1, 'Yiin_Debug', 'PED', 'Drown', 4871.52, 5000, 293, '', 293, 3126, 0, 0, 3, 0, -1, 1362.69, 256.686, 19.5669, 189.133, 165, 1433987014, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 255, 0, 0, 0, 1461, 342, 19, -5, 1, 144, 61, -1),
	(2, 1, 0, 0, 'Yiin_Tttt', 'PED', 'KO_skid_back', 50, 50, 202, '', 202, 0, 0, 0, 0, 0, 0, 1278.06, 177.225, 19.9197, 3.02698, 12, 1434091920, 0, 0, 0, 78, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 255, 0, 0, 0, NULL, NULL, NULL, -5, NULL, NULL, NULL, NULL),
	(4, 1, 0, 0, 'Vardas_Pavarde', '', '', 38.9087, 150, 101, '', 101, 0, 0, 0, 2, 2, 0, 138.665, -1496.8, 18.7733, 144.533, 85, 1434096626, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(6, 4, 0, 0, 'Compadre_Estebano', '', '', 50, 50, 58, '', 58, 0, 0, 0, 0, 0, 0, 689.492, -457.027, 21.0241, 55.9868, 0, 1436022404, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(7, 4, 2, -1, 'Paulius_Nesveikas', '', '', 50, 50, 35, '', 35, 0, 0, 0, 0, 0, 0, 700.786, -455.538, 16.3361, 307.259, 0, 1436022532, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(8, 5, 0, 0, 'The_Bebras', '', '', 12.9409, 50, 101, '', 101, 0, 0, 0, 0, 0, 0, 685.076, -563.451, 15.814, 94.3424, 0, 1436032590, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(9, 6, 0, 0, 'The_Dredas', '', '', 50, 50, 101, '', 101, 0, 0, 0, 0, 0, 0, 680.997, -531.754, 15.8442, 179.965, 0, 1436032639, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(10, 7, 0, 0, 'The_Bebrasname', '', '', 50, 50, 58, '', 58, 0, 0, 0, 0, 0, 0, 672.911, -589.614, 19.031, 0, 0, 1436032766, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(11, 8, 0, 0, 'Uzimtas_Nick', 'PED', 'KO_shot_front', 50, 50, 58, '', 58, 0, 0, 0, 0, 0, 0, 1416.37, -213.619, 6.59318, 242.794, 0, 1436032789, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '6,0,0,0,0,0,0,', 0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	(15, 1, 1, -1, 'Your_Angel', 'PED', 'KO_skid_back', 20, 50, 190, '', 190, 0, 0, 0, 0, 0, 0, 1458.64, 336.195, 18.8438, 328.586, 0, 1441497293, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, '0,0,0,0,0,0,0,', 255, 0, 0, 0, 1461, 342, 19, -5, 0, 0, 0, -1);
/*!40000 ALTER TABLE `chars` ENABLE KEYS */;


-- Dumping structure for table gamemode.furniture
CREATE TABLE IF NOT EXISTS `furniture` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `house_id` int(11) NOT NULL DEFAULT '0',
  `modelid` int(11) NOT NULL DEFAULT '0',
  `x` float NOT NULL DEFAULT '0',
  `y` float NOT NULL DEFAULT '0',
  `z` float NOT NULL DEFAULT '0',
  `rx` float NOT NULL DEFAULT '0',
  `ry` float NOT NULL DEFAULT '0',
  `rz` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  KEY `FK_furniture_houses` (`house_id`),
  CONSTRAINT `FK_furniture_houses` FOREIGN KEY (`house_id`) REFERENCES `houses` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Baldai patalpose';

-- Dumping data for table gamemode.furniture: ~0 rows (approximately)
/*!40000 ALTER TABLE `furniture` DISABLE KEYS */;
/*!40000 ALTER TABLE `furniture` ENABLE KEYS */;


-- Dumping structure for table gamemode.gangs
CREATE TABLE IF NOT EXISTS `gangs` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(24) NOT NULL DEFAULT '??',
  `leader` int(11) NOT NULL,
  `points` int(11) NOT NULL DEFAULT '0',
  `base` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`uid`),
  KEY `FK_gangs_chars` (`leader`),
  CONSTRAINT `FK_gangs_chars` FOREIGN KEY (`leader`) REFERENCES `chars` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

-- Dumping data for table gamemode.gangs: ~2 rows (approximately)
/*!40000 ALTER TABLE `gangs` DISABLE KEYS */;
INSERT INTO `gangs` (`uid`, `name`, `leader`, `points`, `base`, `created_at`) VALUES
	(1, 'Žulikai', 1, 32, 0, '2015-07-25 18:13:27'),
	(2, 'GStreet', 7, 103, 0, '2015-07-25 18:14:13');
/*!40000 ALTER TABLE `gangs` ENABLE KEYS */;


-- Dumping structure for table gamemode.gangwars
CREATE TABLE IF NOT EXISTS `gangwars` (
  `gangid` int(11) DEFAULT NULL,
  `enemy` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `required_points` int(11) DEFAULT NULL,
  KEY `FK_gangwars_gangs` (`gangid`),
  KEY `FK_gangwars_gangs_2` (`enemy`),
  CONSTRAINT `FK_gangwars_gangs` FOREIGN KEY (`gangid`) REFERENCES `gangs` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_gangwars_gangs_2` FOREIGN KEY (`enemy`) REFERENCES `gangs` (`uid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table gamemode.gangwars: ~2 rows (approximately)
/*!40000 ALTER TABLE `gangwars` DISABLE KEYS */;
INSERT INTO `gangwars` (`gangid`, `enemy`, `points`, `required_points`) VALUES
	(1, 2, 32, 200),
	(2, 1, 105, 320);
/*!40000 ALTER TABLE `gangwars` ENABLE KEYS */;


-- Dumping structure for table gamemode.houses
CREATE TABLE IF NOT EXISTS `houses` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) DEFAULT '0',
  `locked` int(11) DEFAULT '0',
  `state` int(11) DEFAULT '0',
  `price` int(11) DEFAULT '0',
  `rent_price` int(11) DEFAULT '0',
  `owner` int(11) DEFAULT '-1',
  `tenant` int(11) DEFAULT '-1',
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL,
  PRIMARY KEY (`uid`),
  KEY `FK__chars` (`owner`),
  KEY `FK_houses_chars` (`tenant`),
  CONSTRAINT `FK_houses_chars` FOREIGN KEY (`tenant`) REFERENCES `chars` (`uid`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `FK__chars` FOREIGN KEY (`owner`) REFERENCES `chars` (`uid`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COMMENT='Namai';

-- Dumping data for table gamemode.houses: ~1 rows (approximately)
/*!40000 ALTER TABLE `houses` DISABLE KEYS */;
INSERT INTO `houses` (`uid`, `type`, `locked`, `state`, `price`, `rent_price`, `owner`, `tenant`, `x`, `y`, `z`) VALUES
	(6, 1, 1, 0, 9221, 0, -1, -1, 1461.46, 341.747, 18.953);
/*!40000 ALTER TABLE `houses` ENABLE KEYS */;


-- Dumping structure for table gamemode.users
CREATE TABLE IF NOT EXISTS `users` (
  `uid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Žaidėjo unikalus ID',
  `username` varchar(24) NOT NULL COMMENT 'Prisijungimo vardas',
  `password` varchar(150) NOT NULL COMMENT 'Slaptažodis',
  `last_gpci` varchar(41) NOT NULL,
  `last_ip` int(11) NOT NULL,
  `email` varchar(100) NOT NULL COMMENT 'Žaidėjo el. paštas',
  `register_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Registracijos data',
  `first_char_timestamp` int(11) NOT NULL DEFAULT '0',
  `remember_token` int(11) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COMMENT='Žaidėjų prisijungimo informacija';

-- Dumping data for table gamemode.users: ~9 rows (approximately)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`uid`, `username`, `password`, `last_gpci`, `last_ip`, `email`, `register_date`, `first_char_timestamp`, `remember_token`) VALUES
	(0, 'Server', '', '', 0, '', '2015-09-04 10:57:41', 0, NULL),
	(1, 'Cher', '822A19EDB23FD5F1D01B9E547BF3A8E15B13B7569D5F42C382BE59A1BA4244A5BF71208935F1512B929C14DD218BC2312FA63BCE11617F35202018B523E63823', '9AF4C9FCE05A494D95CFCA908DEC594E80F9ACEE', 2130706433, '', '2015-06-11 04:43:11', 0, 1),
	(3, 'Yiin_Debug', '822A19EDB23FD5F1D01B9E547BF3A8E15B13B7569D5F42C382BE59A1BA4244A5BF71208935F1512B929C14DD218BC2312FA63BCE11617F35202018B523E63823', '9AF4C9FCE05A494D95CFCA908DEC594E80F9ACEE', 2130706433, '', '2015-06-16 09:13:46', 0, NULL),
	(4, 'Compadre_Estebano', 'A368BB85A5AE10157F643BD9F40A76441878E78239AAC3CA47C121D8472E8C7EE7B09A758B89834EDEC8527B1FB95512BBE5263BEB04B897ACDE7E278AC2E7C7', 'ADF95CF99F4C5C4CC8EDED4E9D44CDE9CE94D09D', 1312481914, '', '2015-07-04 18:06:08', 0, NULL),
	(5, 'Bebras', 'DEC5CE811BCB834100F463C9C6761935193D749AB23DA02B0C1908B72208B743C6E704544A79CCB12E09A8DAC52505D750A6B7E7ED52296784D4CB854D800C75', 'CDD5948AEECCC5FE0A4DC8ED498A88AE89CDCEE5', 1312395252, '', '2015-07-04 20:56:09', 0, NULL),
	(6, 'DreDas', 'F22DB46ED53B26D525B1B5B1631A11C2D03BA96B394C804B2185FD20306B4999404BC56D86703F3EA9F8A659DAF543FFA9D3F885AAC934C61A47BD5D0C19BA6C', 'A45898ADF8E58044C80044940A8FCEDC4C884ADF', 1312487140, '', '2015-07-04 20:56:53', 0, 0),
	(7, 'The_Bebras', 'DEC5CE811BCB834100F463C9C6761935193D749AB23DA02B0C1908B72208B743C6E704544A79CCB12E09A8DAC52505D750A6B7E7ED52296784D4CB854D800C75', 'CDD5948AEECCC5FE0A4DC8ED498A88AE89CDCEE5', 1312395252, '', '2015-07-04 20:59:06', 0, NULL),
	(8, 'The_Dredas', 'F22DB46ED53B26D525B1B5B1631A11C2D03BA96B394C804B2185FD20306B4999404BC56D86703F3EA9F8A659DAF543FFA9D3F885AAC934C61A47BD5D0C19BA6C', 'A45898ADF8E58044C80044940A8FCEDC4C884ADF', 1312487140, '', '2015-07-04 20:59:10', 0, NULL),
	(9, 'dioksid728', '822A19EDB23FD5F1D01B9E547BF3A8E15B13B7569D5F42C382BE59A1BA4244A5BF71208935F1512B929C14DD218BC2312FA63BCE11617F35202018B523E63823', '9AF4C9FCE05A494D95CFCA908DEC594E80F9ACEE', 2130706433, '', '2015-06-13 08:16:58', 0, 0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;


-- Dumping structure for table gamemode.vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `plate` varchar(8) NOT NULL,
  `timestamp` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `owner_type` int(11) NOT NULL,
  `fuel_type` int(11) NOT NULL,
  `health` float NOT NULL DEFAULT '1000',
  `fuel` float NOT NULL DEFAULT '20',
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `a` float NOT NULL,
  `color1` int(11) NOT NULL,
  `color2` int(11) NOT NULL,
  `run` float NOT NULL,
  `model` int(11) NOT NULL,
  `upgrdEngine` int(11) DEFAULT NULL,
  `upgrdBrakes` int(11) DEFAULT NULL,
  `upgrdFuel` int(11) DEFAULT NULL,
  `upgrdBody` int(11) DEFAULT NULL,
  `upgrdAcc` int(11) DEFAULT NULL,
  `errBrakes` int(11) DEFAULT NULL,
  `errFuel` int(11) DEFAULT NULL,
  `errPlug` int(11) DEFAULT NULL,
  `errTire0` int(11) DEFAULT NULL,
  `errTire1` int(11) DEFAULT NULL,
  `errTire2` int(11) DEFAULT NULL,
  `errTire3` int(11) DEFAULT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=latin1;

-- Dumping data for table gamemode.vehicles: ~19 rows (approximately)
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` (`uid`, `plate`, `timestamp`, `status`, `price`, `owner`, `owner_type`, `fuel_type`, `health`, `fuel`, `x`, `y`, `z`, `a`, `color1`, `color2`, `run`, `model`, `upgrdEngine`, `upgrdBrakes`, `upgrdFuel`, `upgrdBody`, `upgrdAcc`, `errBrakes`, `errFuel`, `errPlug`, `errTire0`, `errTire1`, `errTire2`, `errTire3`) VALUES
	(53, '348:XXB', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2273.2, -47, 26.155, 359.327, -1, -1, 0, 438, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(54, '212:JLY', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2268.9, -47, 26.157, 359.166, -1, -1, 0, 438, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(55, '900:RHH', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2264.6, -47, 26.157, 359.166, -1, -1, 0, 438, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(56, '542:LKN', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2260.3, -47, 26.157, 359.166, -1, -1, 0, 438, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(57, '300:LKF', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2256, -47, 26.157, 359.166, -1, -1, 0, 420, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(58, '718:VAE', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2273.5, -54.141, 26.159, 180.018, -1, -1, 0, 420, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(59, '162:BPZ', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2269.2, -54.141, 26.159, 180.018, -1, -1, 0, 420, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(60, '596:FXB', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2264.9, -54.141, 26.159, 180.018, -1, -1, 0, 420, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(61, '543:AXI', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2260.6, -54.141, 26.159, 180.018, -1, -1, 0, 420, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(62, '372:RKQ', 1439295899, 0, 0, 1, 2, 0, 1000, 20, 2256.3, -54.141, 26.159, 180.018, -1, -1, 0, 420, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(63, '942:NFK', 1439295899, 0, 0, 4, 2, 0, 1000, 20, 1306.93, 391.84, 19.767, 155.082, 3, 1, 0, 407, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(64, '089:JGD', 1439295899, 0, 0, 4, 2, 0, 1000, 20, 1311.89, 389.575, 19.766, 155.878, 3, 1, 0, 407, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(65, '522:DXD', 1439295899, 0, 0, 4, 2, 0, 1000, 20, 1317.1, 387.187, 19.766, 155.63, 3, 1, 0, 407, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(66, '182:URO', 1439295899, 0, 0, 4, 2, 0, 1000, 20, 1322.61, 384.817, 19.767, 155.823, 3, 1, 0, 407, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(67, '421:FBZ', 1439295899, 0, 0, 2, 2, 0, 1000, 20, 612.361, -596.883, 16.938, 90.174, -1, -1, 0, 598, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(68, '023:OWP', 1439295899, 0, 0, 2, 2, 0, 1000, 20, 614.141, -601.325, 16.935, 90.661, -1, -1, 0, 598, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(69, '296:OWF', 1439295899, 0, 0, 2, 2, 0, 1000, 20, 637.638, -609.808, 16.041, 180.505, -1, -1, 0, 598, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(70, '836:AUV', 1439295899, 0, 0, 2, 2, 0, 1000, 20, 632.903, -609.888, 16.04, 184.028, -1, -1, 0, 598, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
	(71, '302:FPH', 1439295899, 0, 0, 2, 2, 0, 1000, 20, 627.194, -609.689, 16.346, 177.052, -1, -1, 0, 598, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
