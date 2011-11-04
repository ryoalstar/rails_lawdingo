-- MySQL dump 10.13  Distrib 5.1.37, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: law_development
-- ------------------------------------------------------
-- Server version	5.1.37-1ubuntu5.5

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `app_parameters`
--

DROP TABLE IF EXISTS `app_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `app_parameters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_parameters`
--

LOCK TABLES `app_parameters` WRITE;
/*!40000 ALTER TABLE `app_parameters` DISABLE KEYS */;
INSERT INTO `app_parameters` VALUES (1,'charge per minute','1.22','2011-10-20 07:47:11','2011-10-21 16:22:16'),(2,'Homepage Tag Line','Legal advice, over video chat, billed by the minute','2011-10-20 07:47:11','2011-10-20 23:33:53');
/*!40000 ALTER TABLE `app_parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `card_details`
--

DROP TABLE IF EXISTS `card_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `card_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `postal_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `card_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `card_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expire_month` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expire_year` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `card_verification` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `card_details`
--

LOCK TABLES `card_details` WRITE;
/*!40000 ALTER TABLE `card_details` DISABLE KEYS */;
INSERT INTO `card_details` VALUES (1,5,'Shishir','Paudyal','Street Address','City','State','Postal Code','United States','visa','4242424242424242','1','2013','1234','2011-10-21 12:15:14','2011-10-21 12:15:14'),(2,11,'First Name','Last Name','Street Address','City','State','Postal Code','United States','visa','4242424242424242','11','2013','1234','2011-10-23 11:55:01','2011-10-23 11:55:01'),(3,3,'Nikhil','Nirmel','636 Octavia St. Apt 106','CA','State','94102','United States','visa','5443687776384222','9','2014','241','2011-10-31 02:53:04','2011-10-31 02:53:04');
/*!40000 ALTER TABLE `card_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `lawyer_id` int(11) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `billable_time` int(11) DEFAULT NULL,
  `lawyer_rate` float DEFAULT NULL,
  `billed_amount` float DEFAULT '0',
  `paid_to_lawyer` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `has_been_charged` tinyint(1) DEFAULT '0',
  `payment_params` text COLLATE utf8_unicode_ci,
  `lawdingo_charge` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
INSERT INTO `conversations` VALUES (1,2,1,'2011-10-21 12:15:25','2011-10-21 12:46:53',31,0,1,1,'2011-10-21 12:15:25','2011-10-21 12:15:25',0,NULL,1),(2,2,1,'2011-10-23 11:55:20','2011-10-23 12:26:48',31,0,1.22,1,'2011-10-23 11:55:20','2011-10-23 11:55:20',0,NULL,1.22),(3,2,1,'2011-10-24 01:51:16','2011-10-24 02:22:44',31,0,1.22,1,'2011-10-24 01:51:16','2011-10-24 01:51:16',0,NULL,1.22),(4,2,1,'2011-10-31 02:53:14','2011-10-31 03:24:42',31,0,1.22,1,'2011-10-31 02:53:14','2011-10-31 02:53:14',0,NULL,1.22);
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `page_header` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `is_deleted` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES (1,'about','About Us','About Us','<b>About Lawdingo</b></p>\r\nLawdingo is for people who want quality legal advice without the awkward hassle and\r\ncost involved in actually getting it.\r\nSimply pick a lawyer on Lawdingo, talk to them over video chat, and pay by the minute\r\nfor their counsel.\r\n</p>\r\nWe believe that any traditionally-local service that can be done remotely over the web\r\nshould be and will be done remotely, and we would like to lead the move to that model,\r\nstarting with legal services.\r\n</p>\r\nThe company is based in the vibrant city of San Francisco and is founded by <a href\r\n= \"http://www.google.com/search?q=nikhil+nirmel\">Nikhil Nirmel</a>. </p>\r\nNikhil previously led <a href = \"http://en.wikipedia.org/wiki/\r\nBusiness_intelligence\">business intelligence analysis</a> at SF-based <a href\r\n= \"http://www.yelp.com\">Yelp</a> and at NYC-based <a href = \"http://\r\nwww.yodle.com\">Yodle</a>, and graduated with honors from the <a href = \"http:/\r\n/opimweb.wharton.upenn.edu/\">OPIM department</a> of the <a href = \"http:/\r\n/www.wharton.upenn.edu/\">Wharton School</a> of the <a href = \"http://\r\nwww.upenn.edu/\">University of Pennsylvania</a>.\r\n',NULL,'2011-10-20 07:49:02','2011-10-20 07:49:02');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `lawyer_id` int(11) NOT NULL,
  `conversation_id` int(11) NOT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20110927113553'),('20110927115021'),('20110928052252'),('20111014072907'),('20111014081829'),('20111014091232'),('20111014112315'),('20111014114308'),('20111020112423'),('20111021084255'),('20111021103441'),('20111021111022'),('20111102072919');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hashed_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `skype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `balance` float DEFAULT '0',
  `is_online` tinyint(1) DEFAULT '0',
  `last_login` datetime DEFAULT NULL,
  `last_online` datetime DEFAULT NULL,
  `user_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `bar_memberships` text COLLATE utf8_unicode_ci,
  `undergraduate_school` text COLLATE utf8_unicode_ci,
  `law_school` text COLLATE utf8_unicode_ci,
  `alma_maters` text COLLATE utf8_unicode_ci,
  `practice_areas` text COLLATE utf8_unicode_ci,
  `law_firm` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `rate` float DEFAULT '0',
  `payment_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `photo_file_size` int(11) DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  `personal_tagline` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bar_ids` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT '0',
  `has_payment_info` tinyint(1) DEFAULT '0',
  `peer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Administrator','nav1982@gmail.com','7c4a8d09ca3762af61e59520943dc26494f8941b',NULL,NULL,0,1,NULL,NULL,'ADMIN',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-16 08:49:44','2011-10-20 10:17:10','lawyer.jpeg','image/jpeg',7639,'2011-10-16 08:49:43','Test for User',NULL,0,0,'0'),(2,'Shishir','ritushishir@gmail.com','7c4a8d09ca3762af61e59520943dc26494f8941b',NULL,NULL,0,1,NULL,NULL,'LAWYER','Test','Tesst','Test',NULL,'Test',NULL,10,'ritushishir@gmail.com','2011-10-16 08:55:13','2011-10-21 06:09:51','willis.jpeg','image/jpeg',1872,'2011-10-16 08:55:13','Test for Lawyer','Test',0,0,'0'),(3,'nikhil n','nikhil.nirmel@gmail.com','9e8d2056d7444adcb677e674c1025c2f80929a96',NULL,NULL,0,1,NULL,NULL,'CLIENT',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-17 18:33:11','2011-10-31 02:53:04','ami.jpg','image/jpeg',23991,'2011-10-17 18:33:11','no tagline',NULL,0,1,'0'),(4,'nn','nikhi.lnirmel@gmail.com','9e8d2056d7444adcb677e674c1025c2f80929a96',NULL,NULL,0,1,NULL,NULL,'CLIENT',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-19 16:35:21','2011-10-19 16:35:21',NULL,NULL,NULL,NULL,NULL,NULL,0,0,'0'),(5,'bisu','bardan.rana','afaba266adf3302e985bdf1ddf36b7c800af016d',NULL,NULL,0,1,NULL,NULL,'CLIENT',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-19 16:54:34','2011-11-02 10:38:48',NULL,NULL,NULL,NULL,NULL,NULL,0,1,'532535353454'),(6,'Nikhil','nikhil.nirmal@gmail.com','7c4a8d09ca3762af61e59520943dc26494f8941b',NULL,NULL,0,1,NULL,NULL,'LAWYER','Test','Test','Test',NULL,'',NULL,0,'','2011-10-19 17:22:01','2011-10-20 06:00:59','willis.jpeg','image/jpeg',1872,'2011-10-19 17:22:01','Test Tagline for the lawyer','t',1,0,'0'),(7,'Bob Ma','bobby@hotmail.com','9e8d2056d7444adcb677e674c1025c2f80929a96',NULL,NULL,0,1,NULL,NULL,'LAWYER','i','e','i',NULL,'3ii',NULL,0,'bobby@hotmail.com','2011-10-20 06:47:47','2011-10-20 10:20:36','favicon.ico','image/vnd.microsoft.icon',4406,'2011-10-20 10:20:36','I am cool','l',1,0,'0'),(8,'Shishir Paudyal','amsonfine@ag.com','afaba266adf3302e985bdf1ddf36b7c800af016d',NULL,NULL,0,1,NULL,NULL,'CLIENT',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-20 10:47:35','2011-10-20 10:47:35',NULL,NULL,NULL,NULL,NULL,NULL,0,0,'0'),(9,'nik n','nn@rr.com','9e8d2056d7444adcb677e674c1025c2f80929a96',NULL,NULL,0,1,NULL,NULL,'CLIENT',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-20 16:02:34','2011-10-20 16:02:34',NULL,NULL,NULL,NULL,NULL,NULL,0,0,'0'),(10,'Bob Silverman','bob.silverman@silvermanlaw.com','9e8d2056d7444adcb677e674c1025c2f80929a96',NULL,NULL,0,1,NULL,NULL,'LAWYER','California, Nevada','UCLA','Hastings Law School',NULL,'Immigration, Divorce, Lawsuits',NULL,4.25,'bob.silverman@gmail.com','2011-10-20 23:32:44','2011-10-21 12:09:09','ami.jpg','image/jpeg',23991,'2011-10-20 23:32:43','Immigration attorney specializing in H1-B visas','2048242340',1,0,'0'),(11,'Bardan Samsher JBR','bardan@gmail.com','7c4a8d09ca3762af61e59520943dc26494f8941b',NULL,NULL,0,1,NULL,NULL,'CLIENT',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-22 15:26:06','2011-10-31 12:47:29',NULL,NULL,NULL,NULL,NULL,NULL,0,1,'0'),(12,'Nav','nav@gmail.com','7c4a8d09ca3762af61e59520943dc26494f8941b',NULL,NULL,0,1,NULL,NULL,'LAWYER','test','test','test',NULL,'test',NULL,10,'nav@gmail.com','2011-10-22 15:28:17','2011-10-22 15:29:13',NULL,NULL,NULL,NULL,'Personal tabline','test',1,0,'0'),(13,'NN','client@gmail.com','9e8d2056d7444adcb677e674c1025c2f80929a96',NULL,NULL,0,0,NULL,NULL,'CLIENT',NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2011-10-23 16:35:28','2011-10-23 16:35:28',NULL,NULL,NULL,NULL,NULL,NULL,0,0,'0');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-11-04  7:38:43
