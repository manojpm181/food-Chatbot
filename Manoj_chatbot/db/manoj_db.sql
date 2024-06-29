CREATE DATABASE IF NOT EXISTS `manoj_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `manoj_db`;

CREATE TABLE `food_items` (
  `item_id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `food_items` VALUES 
(1,'Pav Bhaji',6.00),
(2,'Chole Bhature',7.00),
(3,'Pizza',8.00),
(4,'Mango Lassi',5.00),
(5,'Masala Dosa',6.00),
(6,'Vegetable Biryani',9.00),
(7,'Vada Pav',4.00),
(8,'Rava Dosa',7.00),
(9,'Samosa',5.00);

CREATE TABLE `order_tracking` (
  `order_id` int NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `order_tracking` VALUES 
(40,'delivered'),
(41,'in transit');

CREATE TABLE `orders` (
  `order_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int DEFAULT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`item_id`),
  KEY `orders_ibfk_1` (`item_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `food_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `orders` VALUES 
(40,1,2,12.00),
(40,3,1,8.00),
(41,4,3,15.00),
(41,6,2,18.00),
(41,9,4,20.00);

DELIMITER ;;
CREATE FUNCTION `get_price_for_item`(p_item_name VARCHAR(255)) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_price DECIMAL(10, 2);
    IF (SELECT COUNT(*) FROM food_items WHERE name = p_item_name) > 0 THEN
        SELECT price INTO v_price
        FROM food_items
        WHERE name = p_item_name;
        RETURN v_price;
    ELSE
        RETURN -1;
    END IF;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE FUNCTION `get_total_order_price`(p_order_id INT) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_total_price DECIMAL(10, 2);
    IF (SELECT COUNT(*) FROM orders WHERE order_id = p_order_id) > 0 THEN
        SELECT SUM(total_price) INTO v_total_price
        FROM orders
        WHERE order_id = p_order_id;
        RETURN v_total_price;
    ELSE
        RETURN -1;
    END IF;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE `insert_order_item`(
  IN p_food_item VARCHAR(255),
  IN p_quantity INT,
  IN p_order_id INT
)
BEGIN
    DECLARE v_item_id INT;
    DECLARE v_price DECIMAL(10, 2);
    DECLARE v_total_price DECIMAL(10, 2);
    SET v_item_id = (SELECT item_id FROM food_items WHERE name = p_food_item);
    SET v_price = (SELECT get_price_for_item(p_food_item));
    SET v_total_price = v_price * p_quantity;
    INSERT INTO orders (order_id, item_id, quantity, total_price)
    VALUES (p_order_id, v_item_id, p_quantity, v_total_price);
END ;;
DELIMITER ;
