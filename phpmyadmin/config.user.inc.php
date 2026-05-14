<?php
/**
 * Configuración de servidores MySQL para PymeTrack - Nueva Arquitectura
 */
$cfg['Servers'] = array();

// Servidor MySQL de Productos
$cfg['Servers'][1]['host'] = 'pymetrack-mysql-productos';
$cfg['Servers'][1]['port'] = '3306';
$cfg['Servers'][1]['user'] = 'root';
$cfg['Servers'][1]['password'] = 'password';
$cfg['Servers'][1]['auth_type'] = 'config';
$cfg['Servers'][1]['verbose'] = 'MySQL Productos';

// Servidor MySQL de Pedidos
$cfg['Servers'][2]['host'] = 'pymetrack-mysql-pedidos';
$cfg['Servers'][2]['port'] = '3306';
$cfg['Servers'][2]['user'] = 'root';
$cfg['Servers'][2]['password'] = 'password';
$cfg['Servers'][2]['auth_type'] = 'config';
$cfg['Servers'][2]['verbose'] = 'MySQL Pedidos';

// Servidor MySQL de Usuarios
$cfg['Servers'][3]['host'] = 'pymetrack-mysql-user';
$cfg['Servers'][3]['port'] = '3306';
$cfg['Servers'][3]['user'] = 'root';
$cfg['Servers'][3]['password'] = 'password';
$cfg['Servers'][3]['auth_type'] = 'config';
$cfg['Servers'][3]['verbose'] = 'MySQL Usuarios';
