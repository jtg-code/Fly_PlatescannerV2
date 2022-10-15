CREATE TABLE `fly_platescanner` (
  `date` varchar(1000) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Speed` varchar(100) NOT NULL,
  `Price` varchar(100) NOT NULL,
  `Identifier` varchar(100) NOT NULL,
  `id` int(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `fly_platescanner`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `fly_platescanner`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
COMMIT;