-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 15, 2024 at 07:29 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `proyek`
--

-- --------------------------------------------------------

--
-- Table structure for table `laporan_keuangan`
--

CREATE TABLE `laporan_keuangan` (
  `id_laporan` int(11) NOT NULL,
  `tanggal` datetime NOT NULL,
  `deskripsi` varchar(255) NOT NULL,
  `jumlah` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `menu`
--

CREATE TABLE `menu` (
  `id_menu` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `kategori` varchar(100) NOT NULL,
  `harga` int(11) NOT NULL,
  `stok` int(11) NOT NULL,
  `gambar` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `menu`
--

INSERT INTO `menu` (`id_menu`, `nama`, `kategori`, `harga`, `stok`, `gambar`, `created_at`, `updated_at`) VALUES
(22, 'Basreng', 'Makanan', 5000, 0, 'uploads/updated_image_22.png', '2024-12-09 18:28:38', '2024-12-15 13:26:30'),
(23, 'Teh', 'Minuman', 5000, 1, 'uploads/pxfuel (3).jpg', '2024-12-09 18:29:18', '2024-12-09 18:29:18'),
(25, 'Dimsum', 'Makanan', 5000, 0, 'uploads/pxfuel (4).jpg', '2024-12-12 19:10:00', '2024-12-12 19:10:00'),
(26, 'Mie Rebus', 'Makanan', 5000, 0, 'uploads/pxfuel.jpg', '2024-12-12 19:10:27', '2024-12-12 19:10:27'),
(27, 'Mie Goreng', 'Makanan', 5000, 0, 'uploads/pxfuel (1).jpg', '2024-12-12 19:10:46', '2024-12-12 19:10:46'),
(28, 'Pop Ice', 'Minuman', 5000, 0, 'uploads/Wallpaper JKT 48.png', '2024-12-12 19:11:19', '2024-12-12 19:11:19'),
(29, 'Es Coklat', 'Minuman', 5000, 0, 'uploads/pxfuel (2).jpg', '2024-12-12 19:11:38', '2024-12-12 19:11:38'),
(30, 'Kopi Panas', 'Minuman', 5000, 0, 'uploads/pxfuel.jpg', '2024-12-12 19:11:55', '2024-12-12 19:11:55'),
(31, 'Cappucino', 'Minuman', 5000, 0, 'uploads/pxfuel (5).jpg', '2024-12-12 19:12:32', '2024-12-12 19:12:32');

-- --------------------------------------------------------

--
-- Table structure for table `pecahan`
--

CREATE TABLE `pecahan` (
  `id_pecahan` int(11) NOT NULL,
  `pecahan` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pecahan`
--

INSERT INTO `pecahan` (`id_pecahan`, `pecahan`, `jumlah`) VALUES
(3, 100000, 0),
(4, 50000, 0),
(5, 20000, 2),
(6, 10000, 0),
(7, 5000, 3),
(8, 2000, 1),
(9, 1000, 0),
(10, 500, 0);

-- --------------------------------------------------------

--
-- Table structure for table `pesan`
--

CREATE TABLE `pesan` (
  `id_pesan` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `tgl_order` datetime DEFAULT current_timestamp(),
  `total_harga` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pesan_detail`
--

CREATE TABLE `pesan_detail` (
  `id_detail` int(11) NOT NULL,
  `id_pesan` int(11) NOT NULL,
  `id_menu` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `harga` int(11) NOT NULL,
  `total_harga` int(11) GENERATED ALWAYS AS (`jumlah` * `harga`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_users` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('Admin','Kasir') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_users`, `username`, `password`, `role`) VALUES
(1, 'admin', 'admin', 'Admin'),
(2, 'kasir', 'kasir', 'Kasir');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `laporan_keuangan`
--
ALTER TABLE `laporan_keuangan`
  ADD PRIMARY KEY (`id_laporan`);

--
-- Indexes for table `menu`
--
ALTER TABLE `menu`
  ADD PRIMARY KEY (`id_menu`);

--
-- Indexes for table `pecahan`
--
ALTER TABLE `pecahan`
  ADD PRIMARY KEY (`id_pecahan`);

--
-- Indexes for table `pesan`
--
ALTER TABLE `pesan`
  ADD PRIMARY KEY (`id_pesan`);

--
-- Indexes for table `pesan_detail`
--
ALTER TABLE `pesan_detail`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_pesan` (`id_pesan`),
  ADD KEY `id_menu` (`id_menu`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_users`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `laporan_keuangan`
--
ALTER TABLE `laporan_keuangan`
  MODIFY `id_laporan` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `menu`
--
ALTER TABLE `menu`
  MODIFY `id_menu` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `pecahan`
--
ALTER TABLE `pecahan`
  MODIFY `id_pecahan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `pesan`
--
ALTER TABLE `pesan`
  MODIFY `id_pesan` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pesan_detail`
--
ALTER TABLE `pesan_detail`
  MODIFY `id_detail` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_users` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `pesan_detail`
--
ALTER TABLE `pesan_detail`
  ADD CONSTRAINT `pesan_detail_ibfk_1` FOREIGN KEY (`id_pesan`) REFERENCES `pesan` (`id_pesan`) ON DELETE CASCADE,
  ADD CONSTRAINT `pesan_detail_ibfk_2` FOREIGN KEY (`id_menu`) REFERENCES `menu` (`id_menu`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
