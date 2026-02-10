-- MySQL dump 10.13  Distrib 8.4.8, for Win64 (x86_64)
--
-- Host: localhost    Database: poke_sql_game
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `encounter`
--

DROP TABLE IF EXISTS `encounter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `encounter` (
  `location_id` int NOT NULL,
  `pokemon_id` int NOT NULL,
  `rate` int NOT NULL,
  `time_zone` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `min_level` int DEFAULT NULL,
  `max_level` int DEFAULT NULL,
  PRIMARY KEY (`location_id`,`pokemon_id`),
  KEY `fk_encounter_pokemon` (`pokemon_id`),
  CONSTRAINT `fk_encounter_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_encounter_pokemon` FOREIGN KEY (`pokemon_id`) REFERENCES `pokemon` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `encounter`
--

LOCK TABLES `encounter` WRITE;
/*!40000 ALTER TABLE `encounter` DISABLE KEYS */;
INSERT INTO `encounter` VALUES (1,10,30,NULL,2,6),(1,13,30,NULL,2,6),(1,25,5,'day',3,7),(2,16,40,NULL,2,5),(2,19,40,NULL,2,5);
/*!40000 ALTER TABLE `encounter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `learn`
--

DROP TABLE IF EXISTS `learn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learn` (
  `pokemon_id` int NOT NULL,
  `move_id` int NOT NULL,
  `method` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` int DEFAULT NULL,
  PRIMARY KEY (`pokemon_id`,`move_id`,`method`),
  KEY `fk_learn_move` (`move_id`),
  CONSTRAINT `fk_learn_move` FOREIGN KEY (`move_id`) REFERENCES `move` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_learn_pokemon` FOREIGN KEY (`pokemon_id`) REFERENCES `pokemon` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learn`
--

LOCK TABLES `learn` WRITE;
/*!40000 ALTER TABLE `learn` DISABLE KEYS */;
INSERT INTO `learn` VALUES (1,3,'level',7),(4,4,'level',9),(7,5,'level',8),(25,1,'level',1),(25,2,'level',1);
/*!40000 ALTER TABLE `learn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (1,'トキワの森'),(2,'ニビシティ周辺');
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `move`
--

DROP TABLE IF EXISTS `move`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `move` (
  `id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `power` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `move`
--

LOCK TABLES `move` WRITE;
/*!40000 ALTER TABLE `move` DISABLE KEYS */;
INSERT INTO `move` VALUES (1,'たいあたり','normal',40),(2,'でんきショック','electric',40),(3,'つるのムチ','grass',45),(4,'ひのこ','fire',40),(5,'みずでっぽう','water',40);
/*!40000 ALTER TABLE `move` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pokemon`
--

DROP TABLE IF EXISTS `pokemon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pokemon` (
  `id` int NOT NULL,
  `name_en` varchar(50) NOT NULL,
  `name_ja` varchar(50) DEFAULT NULL,
  `type1` varchar(20) NOT NULL,
  `type2` varchar(20) DEFAULT NULL,
  `height` int NOT NULL,
  `weight` int NOT NULL,
  `hp` int NOT NULL,
  `atk` int NOT NULL,
  `def` int NOT NULL,
  `spa` int NOT NULL,
  `spd` int NOT NULL,
  `spe` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pokemon`
--

LOCK TABLES `pokemon` WRITE;
/*!40000 ALTER TABLE `pokemon` DISABLE KEYS */;
INSERT INTO `pokemon` VALUES (1,'bulbasaur','フシギダネ','grass','poison',7,69,45,49,49,65,65,45),(2,'ivysaur','フシギソウ','grass','poison',10,130,60,62,63,80,80,60),(3,'venusaur','フシギバナ','grass','poison',20,1000,80,82,83,100,100,80),(4,'charmander','ヒトカゲ','fire',NULL,6,85,39,52,43,60,50,65),(5,'charmeleon','リザード','fire',NULL,11,190,58,64,58,80,65,80),(6,'charizard','リザードン','fire','flying',17,905,78,84,78,109,85,100),(7,'squirtle','ゼニガメ','water',NULL,5,90,44,48,65,50,64,43),(8,'wartortle','カメール','water',NULL,10,225,59,63,80,65,80,58),(9,'blastoise','カメックス','water',NULL,16,855,79,83,100,85,105,78),(10,'caterpie','キャタピー','bug',NULL,3,29,45,30,35,20,20,45),(11,'metapod','トランセル','bug',NULL,7,99,50,20,55,25,25,30),(12,'butterfree','バタフリー','bug','flying',11,320,60,45,50,90,80,70),(13,'weedle','ビードル','bug','poison',3,32,40,35,30,20,20,50),(14,'kakuna','コクーン','bug','poison',6,100,45,25,50,25,25,35),(15,'beedrill','スピアー','bug','poison',10,295,65,90,40,45,80,75),(16,'pidgey','ポッポ','normal','flying',3,18,40,45,40,35,35,56),(17,'pidgeotto','ピジョン','normal','flying',11,300,63,60,55,50,50,71),(18,'pidgeot','ピジョット','normal','flying',15,395,83,80,75,70,70,101),(19,'rattata','コラッタ','normal',NULL,3,35,30,56,35,25,35,72),(20,'raticate','ラッタ','normal',NULL,7,185,55,81,60,50,70,97),(21,'spearow','オニスズメ','normal','flying',3,20,40,60,30,31,31,70),(22,'fearow','オニドリル','normal','flying',12,380,65,90,65,61,61,100),(23,'ekans','アーボ','poison',NULL,20,69,35,60,44,40,54,55),(24,'arbok','アーボック','poison',NULL,35,650,60,95,69,65,79,80),(25,'pikachu','ピカチュウ','electric',NULL,4,60,35,55,40,50,50,90),(26,'raichu','ライチュウ','electric',NULL,8,300,60,90,55,90,80,110),(27,'sandshrew','サンド','ground',NULL,6,120,50,75,85,20,30,40),(28,'sandslash','サンドパン','ground',NULL,10,295,75,100,110,45,55,65),(29,'nidoran-f','ニドラン♀','poison',NULL,4,70,55,47,52,40,40,41),(30,'nidorina','ニドリーナ','poison',NULL,8,200,70,62,67,55,55,56),(31,'nidoqueen','ニドクイン','poison','ground',13,600,90,92,87,75,85,76),(32,'nidoran-m','ニドラン♂','poison',NULL,5,90,46,57,40,40,40,50),(33,'nidorino','ニドリーノ','poison',NULL,9,195,61,72,57,55,55,65),(34,'nidoking','ニドキング','poison','ground',14,620,81,102,77,85,75,85),(35,'clefairy','ピッピ','fairy',NULL,6,75,70,45,48,60,65,35),(36,'clefable','ピクシー','fairy',NULL,13,400,95,70,73,95,90,60),(37,'vulpix','ロコン','fire',NULL,6,99,38,41,40,50,65,65),(38,'ninetales','キュウコン','fire',NULL,11,199,73,76,75,81,100,100),(39,'jigglypuff','プリン','normal','fairy',5,55,115,45,20,45,25,20),(40,'wigglytuff','プクリン','normal','fairy',10,120,140,70,45,85,50,45),(41,'zubat','ズバット','poison','flying',8,75,40,45,35,30,40,55),(42,'golbat','ゴルバット','poison','flying',16,550,75,80,70,65,75,90),(43,'oddish','ナゾノクサ','grass','poison',5,54,45,50,55,75,65,30),(44,'gloom','クサイハナ','grass','poison',8,86,60,65,70,85,75,40),(45,'vileplume','ラフレシア','grass','poison',12,186,75,80,85,110,90,50),(46,'paras','パラス','bug','grass',3,54,35,70,55,45,55,25),(47,'parasect','パラセクト','bug','grass',10,295,60,95,80,60,80,30),(48,'venonat','コンパン','bug','poison',10,300,60,55,50,40,55,45),(49,'venomoth','モルフォン','bug','poison',15,125,70,65,60,90,75,90),(50,'diglett','ディグダ','ground',NULL,2,8,10,55,25,35,45,95),(51,'dugtrio','ダグトリオ','ground',NULL,7,333,35,100,50,50,70,120),(52,'meowth','ニャース','normal',NULL,4,42,40,45,35,40,40,90),(53,'persian','ペルシアン','normal',NULL,10,320,65,70,60,65,65,115),(54,'psyduck','コダック','water',NULL,8,196,50,52,48,65,50,55),(55,'golduck','ゴルダック','water',NULL,17,766,80,82,78,95,80,85),(56,'mankey','マンキー','fighting',NULL,5,280,40,80,35,35,45,70),(57,'primeape','オコリザル','fighting',NULL,10,320,65,105,60,60,70,95),(58,'growlithe','ガーディ','fire',NULL,7,190,55,70,45,70,50,60),(59,'arcanine','ウインディ','fire',NULL,19,1550,90,110,80,100,80,95),(60,'poliwag','ニョロモ','water',NULL,6,124,40,50,40,40,40,90),(61,'poliwhirl','ニョロゾ','water',NULL,10,200,65,65,65,50,50,90),(62,'poliwrath','ニョロボン','water','fighting',13,540,90,95,95,70,90,70),(63,'abra','ケーシィ','psychic',NULL,9,195,25,20,15,105,55,90),(64,'kadabra','ユンゲラー','psychic',NULL,13,565,40,35,30,120,70,105),(65,'alakazam','フーディン','psychic',NULL,15,480,55,50,45,135,95,120),(66,'machop','ワンリキー','fighting',NULL,8,195,70,80,50,35,35,35),(67,'machoke','ゴーリキー','fighting',NULL,15,705,80,100,70,50,60,45),(68,'machamp','カイリキー','fighting',NULL,16,1300,90,130,80,65,85,55),(69,'bellsprout','マダツボミ','grass','poison',7,40,50,75,35,70,30,40),(70,'weepinbell','ウツドン','grass','poison',10,64,65,90,50,85,45,55),(71,'victreebel','ウツボット','grass','poison',17,155,80,105,65,100,70,70),(72,'tentacool','メノクラゲ','water','poison',9,455,40,40,35,50,100,70),(73,'tentacruel','ドククラゲ','water','poison',16,550,80,70,65,80,120,100),(74,'geodude','イシツブテ','rock','ground',4,200,40,80,100,30,30,20),(75,'graveler','ゴローン','rock','ground',10,1050,55,95,115,45,45,35),(76,'golem','ゴローニャ','rock','ground',14,3000,80,120,130,55,65,45),(77,'ponyta','ポニータ','fire',NULL,10,300,50,85,55,65,65,90),(78,'rapidash','ギャロップ','fire',NULL,17,950,65,100,70,80,80,105),(79,'slowpoke','ヤドン','water','psychic',12,360,90,65,65,40,40,15),(80,'slowbro','ヤドラン','water','psychic',16,785,95,75,110,100,80,30),(81,'magnemite','コイル','electric','steel',3,60,25,35,70,95,55,45),(82,'magneton','レアコイル','electric','steel',10,600,50,60,95,120,70,70),(83,'farfetchd','カモネギ','normal','flying',8,150,52,90,55,58,62,60),(84,'doduo','ドードー','normal','flying',14,392,35,85,45,35,35,75),(85,'dodrio','ドードリオ','normal','flying',18,852,60,110,70,60,60,110),(86,'seel','パウワウ','water',NULL,11,900,65,45,55,45,70,45),(87,'dewgong','ジュゴン','water','ice',17,1200,90,70,80,70,95,70),(88,'grimer','ベトベター','poison',NULL,9,300,80,80,50,40,50,25),(89,'muk','ベトベトン','poison',NULL,12,300,105,105,75,65,100,50),(90,'shellder','シェルダー','water',NULL,3,40,30,65,100,45,25,40),(91,'cloyster','パルシェン','water','ice',15,1325,50,95,180,85,45,70),(92,'gastly','ゴース','ghost','poison',13,1,30,35,30,100,35,80),(93,'haunter','ゴースト','ghost','poison',16,1,45,50,45,115,55,95),(94,'gengar','ゲンガー','ghost','poison',15,405,60,65,60,130,75,110),(95,'onix','イワーク','rock','ground',88,2100,35,45,160,30,45,70),(96,'drowzee','スリープ','psychic',NULL,10,324,60,48,45,43,90,42),(97,'hypno','スリーパー','psychic',NULL,16,756,85,73,70,73,115,67),(98,'krabby','クラブ','water',NULL,4,65,30,105,90,25,25,50),(99,'kingler','キングラー','water',NULL,13,600,55,130,115,50,50,75),(100,'voltorb','ビリリダマ','electric',NULL,5,104,40,30,50,55,55,100),(101,'electrode','マルマイン','electric',NULL,12,666,60,50,70,80,80,150),(102,'exeggcute','タマタマ','grass','psychic',4,25,60,40,80,60,45,40),(103,'exeggutor','ナッシー','grass','psychic',20,1200,95,95,85,125,75,55),(104,'cubone','カラカラ','ground',NULL,4,65,50,50,95,40,50,35),(105,'marowak','ガラガラ','ground',NULL,10,450,60,80,110,50,80,45),(106,'hitmonlee','サワムラー','fighting',NULL,15,498,50,120,53,35,110,87),(107,'hitmonchan','エビワラー','fighting',NULL,14,502,50,105,79,35,110,76),(108,'lickitung','ベロリンガ','normal',NULL,12,655,90,55,75,60,75,30),(109,'koffing','ドガース','poison',NULL,6,10,40,65,95,60,45,35),(110,'weezing','マタドガス','poison',NULL,12,95,65,90,120,85,70,60),(111,'rhyhorn','サイホーン','ground','rock',10,1150,80,85,95,30,30,25),(112,'rhydon','サイドン','ground','rock',19,1200,105,130,120,45,45,40),(113,'chansey','ラッキー','normal',NULL,11,346,250,5,5,35,105,50),(114,'tangela','モンジャラ','grass',NULL,10,350,65,55,115,100,40,60),(115,'kangaskhan','ガルーラ','normal',NULL,22,800,105,95,80,40,80,90),(116,'horsea','タッツー','water',NULL,4,80,30,40,70,70,25,60),(117,'seadra','シードラ','water',NULL,12,250,55,65,95,95,45,85),(118,'goldeen','トサキント','water',NULL,6,150,45,67,60,35,50,63),(119,'seaking','アズマオウ','water',NULL,13,390,80,92,65,65,80,68),(120,'staryu','ヒトデマン','water',NULL,8,345,30,45,55,70,55,85),(121,'starmie','スターミー','water','psychic',11,800,60,75,85,100,85,115),(122,'mr-mime','バリヤード','psychic','fairy',13,545,40,45,65,100,120,90),(123,'scyther','ストライク','bug','flying',15,560,70,110,80,55,80,105),(124,'jynx','ルージュラ','ice','psychic',14,406,65,50,35,115,95,95),(125,'electabuzz','エレブー','electric',NULL,11,300,65,83,57,95,85,105),(126,'magmar','ブーバー','fire',NULL,13,445,65,95,57,100,85,93),(127,'pinsir','カイロス','bug',NULL,15,550,65,125,100,55,70,85),(128,'tauros','ケンタロス','normal',NULL,14,884,75,100,95,40,70,110),(129,'magikarp','コイキング','water',NULL,9,100,20,10,55,15,20,80),(130,'gyarados','ギャラドス','water','flying',65,2350,95,125,79,60,100,81),(131,'lapras','ラプラス','water','ice',25,2200,130,85,80,85,95,60),(132,'ditto','メタモン','normal',NULL,3,40,48,48,48,48,48,48),(133,'eevee','イーブイ','normal',NULL,3,65,55,55,50,45,65,55),(134,'vaporeon','シャワーズ','water',NULL,10,290,130,65,60,110,95,65),(135,'jolteon','サンダース','electric',NULL,8,245,65,65,60,110,95,130),(136,'flareon','ブースター','fire',NULL,9,250,65,130,60,95,110,65),(137,'porygon','ポリゴン','normal',NULL,8,365,65,60,70,85,75,40),(138,'omanyte','オムナイト','rock','water',4,75,35,40,100,90,55,35),(139,'omastar','オムスター','rock','water',10,350,70,60,125,115,70,55),(140,'kabuto','カブト','rock','water',5,115,30,80,90,55,45,55),(141,'kabutops','カブトプス','rock','water',13,405,60,115,105,65,70,80),(142,'aerodactyl','プテラ','rock','flying',18,590,80,105,65,60,75,130),(143,'snorlax','カビゴン','normal',NULL,21,4600,160,110,65,65,110,30),(144,'articuno','フリーザー','ice','flying',17,554,90,85,100,95,125,85),(145,'zapdos','サンダー','electric','flying',16,526,90,90,85,125,90,100),(146,'moltres','ファイヤー','fire','flying',20,600,90,100,90,125,85,90),(147,'dratini','ミニリュウ','dragon',NULL,18,33,41,64,45,50,50,50),(148,'dragonair','ハクリュー','dragon',NULL,40,165,61,84,65,70,70,70),(149,'dragonite','カイリュー','dragon','flying',22,2100,91,134,95,100,100,80),(150,'mewtwo','ミュウツー','psychic',NULL,20,1220,106,110,90,154,90,130),(151,'mew','ミュウ','psychic',NULL,4,40,100,100,100,100,100,100);
/*!40000 ALTER TABLE `pokemon` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-10  8:13:58
