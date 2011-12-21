-- MySQL dump 10.13  Distrib 5.1.49, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: law_development
-- ------------------------------------------------------
-- Server version	5.1.49-1ubuntu8.1

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
-- Table structure for table `practice_areas`
--

DROP TABLE IF EXISTS `practice_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `practice_areas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_areas`
--

LOCK TABLES `practice_areas` WRITE;
/*!40000 ALTER TABLE `practice_areas` DISABLE KEYS */;
INSERT INTO `practice_areas` VALUES (35,'Bankruptcy',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(36,'Divorce and Family',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(37,'Employment',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(38,'Immigration',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(40,'Real Estate / Rentals',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(41,'Startups / Business',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(42,'Tax',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(43,'Wills and Trusts',NULL,'2011-12-21 14:14:30','2011-12-21 14:14:30'),(45,'General bankruptcy',35,'2011-12-21 14:49:42','2011-12-21 14:49:42'),(46,'Filing for bankruptcy',35,'2011-12-21 14:49:43','2011-12-21 14:49:43'),(47,'Credit card repayment',35,'2011-12-21 14:49:43','2011-12-21 14:49:43'),(48,'Home foreclosure',35,'2011-12-21 14:49:43','2011-12-21 14:49:43'),(49,'General family law',36,'2011-12-21 14:54:35','2011-12-21 14:54:35'),(50,'Divorce',36,'2011-12-21 14:54:35','2011-12-21 14:54:35'),(51,'Pre-nuptial agreement',36,'2011-12-21 14:54:35','2011-12-21 14:54:35'),(52,'Child custody',36,'2011-12-21 14:54:35','2011-12-21 14:54:35'),(53,'Adoptions',36,'2011-12-21 14:54:35','2011-12-21 14:54:35'),(54,'General Employment',37,'2011-12-21 14:56:50','2011-12-21 14:56:50'),(55,'Employment contracts',37,'2011-12-21 14:56:50','2011-12-21 14:56:50'),(56,'Losing your job',37,'2011-12-21 14:56:50','2011-12-21 14:56:50'),(57,'Unemployment benefits',37,'2011-12-21 14:56:50','2011-12-21 14:56:50'),(59,'General immigration',38,'2011-12-21 14:59:25','2011-12-21 14:59:25'),(60,'Visas / visiting the USA',38,'2011-12-21 14:59:25','2011-12-21 14:59:25'),(61,'Green card application',38,'2011-12-21 14:59:25','2011-12-21 14:59:25'),(62,'Asylum & refugee status',38,'2011-12-21 14:59:25','2011-12-21 14:59:25'),(63,'Marriage-based citizenship',38,'2011-12-21 14:59:25','2011-12-21 14:59:25'),(64,'Employment / H1-B Visa',38,'2011-12-21 14:59:25','2011-12-21 14:59:25'),(65,'Deportation',38,'2011-12-21 14:59:25','2011-12-21 14:59:25'),(66,'General real estate',40,'2011-12-21 15:00:57','2011-12-21 15:03:36'),(67,'Buying / selling house',40,'2011-12-21 15:00:57','2011-12-21 15:03:36'),(68,'Lease agreements',40,'2011-12-21 15:00:57','2011-12-21 15:03:36'),(69,'Landlord-tenant disputes',40,'2011-12-21 15:00:57','2011-12-21 15:03:36'),(70,'Eviction',40,'2011-12-21 15:00:57','2011-12-21 15:03:36'),(71,'General startup questions',41,'2011-12-21 15:07:30','2011-12-21 15:07:30'),(72,'Incorporation',41,'2011-12-21 15:07:30','2011-12-21 15:07:30'),(73,'Financing documents',41,'2011-12-21 15:07:30','2011-12-21 15:07:30'),(74,'Contract review',41,'2011-12-21 15:07:30','2011-12-21 15:07:30'),(75,'Hiring employees',41,'2011-12-21 15:07:30','2011-12-21 15:07:30'),(76,'Hiring contractors',41,'2011-12-21 15:07:30','2011-12-21 15:07:30'),(77,'General tax',42,'2011-12-21 15:08:54','2011-12-21 15:08:54'),(78,'Personal tax',42,'2011-12-21 15:08:54','2011-12-21 15:08:54'),(79,'Property tax',42,'2011-12-21 15:08:54','2011-12-21 15:08:54'),(80,'Business tax',42,'2011-12-21 15:08:54','2011-12-21 15:08:54'),(81,'Tax audits',42,'2011-12-21 15:08:54','2011-12-21 15:08:54'),(82,'General wills and trusts',43,'2011-12-21 15:10:07','2011-12-21 15:10:07'),(83,'Creating a will',43,'2011-12-21 15:10:07','2011-12-21 15:10:07'),(84,'Granting power of attorney',43,'2011-12-21 15:10:08','2011-12-21 15:10:08'),(85,'Healthcare directives',43,'2011-12-21 15:10:08','2011-12-21 15:10:08');
/*!40000 ALTER TABLE `practice_areas` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-12-21 21:10:40
