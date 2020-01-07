CREATE DATABASE IF NOT EXISTS `palacio_de_hierro_gourmet`;
USE palacio_de_hierro_gourmet;

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `borrarcategoria_ysubcategoria_ysusproductos_porID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarcategoria_ysubcategoria_ysusproductos_porID` (IN `cate` INT)  BEGIN
DELETE from producto where id_producto = (select id_producto from categoria_producto where id_categoria = cate);
DELETE from categoria_producto where id_categoria = cate;
DELETE from derivado where id_categoria = cate;
DELETE from categoria where id_categoria = cate;
END$$

DROP PROCEDURE IF EXISTS `borrarproductos_porIDsubcategoria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarproductos_porIDsubcategoria` (IN `id_deriv` INT)  BEGIN
DELETE from producto where id_derviado = id_deriv;
END$$

DROP PROCEDURE IF EXISTS `borrarproductos_porsubcategoria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarproductos_porsubcategoria` (IN `var_deriv` VARCHAR(60))  BEGIN
DELETE from producto where id_derviado = (select d.id_derivado from derivado where d.name like var_deriv);
END$$

DROP PROCEDURE IF EXISTS `borrarproducto_porcodigo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarproducto_porcodigo` (IN `codigo` INT)  BEGIN
DELETE from producto where id_producto = codigo;
END$$

DROP PROCEDURE IF EXISTS `borrarproducto_pornombre`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarproducto_pornombre` (IN `var_borr` VARCHAR(60))  BEGIN
DELETE from producto where name like var_borr;
END$$

DROP PROCEDURE IF EXISTS `borrarsubcategoria_ysusproductos_porID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarsubcategoria_ysusproductos_porID` (IN `deriv` INT)  BEGIN
DELETE from producto where id_derviado = deriv;
DELETE from derivado where name like var_deriv;
END$$

DROP PROCEDURE IF EXISTS `borrarsubcategoria_ysusproductos_pornombre`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarsubcategoria_ysusproductos_pornombre` (IN `var_deriv` VARCHAR(60))  BEGIN
DELETE from producto  where id_derviado = (select d.id_derivado from derivado where d.name like var_deriv);
DELETE from derivado where name like var_deriv;
END$$

DROP PROCEDURE IF EXISTS `borrartodoslosproductos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `borrartodoslosproductos` ()  BEGIN
DELETE from producto;
END$$

DROP PROCEDURE IF EXISTS `buscar`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar` (IN `var_busc` VARCHAR(60))  BEGIN
select * from producto where name like var_busc;
END$$

DELIMITER ;
drop procedure if exists comprobarSub;
delimiter //
create procedure comprobarSub(in xcat varchar(80), in xsub varchar(80))
begin
	declare existe int;
    set existe = (select count(*) from categoria c, subcategoria s where s.id_categoria = c.id_categoria and c.name = xcat and s.name = xsub);
    select existe as x;
end;//
delimiter ;

drop procedure if exists traeSub;
delimiter //
create procedure traeSub(in xCat varchar(80))
begin
	declare existe int;
    set existe = (select count(*) from categoria where name = xCat);
    if existe = 1 then
		select s.name as nombre from subcategoria s, categoria c where  s.id_categoria = c.id_categoria and c.name = xCat;
    end if;
end;//
delimiter ;

drop procedure if exists getDatosProducto;
delimiter //
create procedure getDatosProducto(in id int(11))
begin
	declare existe int;
    set existe = (select count(*) from datosProductos where id_producto = id);
    if existe = 1 then
		select id_producto, nombre, img, precio, descripcion, stock from datosProductos where id_producto = id;
    end if;
end;//
delimiter ;

drop procedure if exists insertarProductosCarrito;
delimiter //
create procedure insertarProductosCarrito(in idProd int(11), idUser int(11), xcantidad int(11))
begin
	declare existe int;
    declare msj varchar(32);
    set existe = (select count(*) from producto where id_producto = idProd);
    if existe = 1 then
		if (select existencia from producto where id_producto = idProd) >= xcantidad then
			set existe = (select count(*) from carrito where id_producto = idProd and id_user = idUser);
            update producto set existencia =  existencia - xcantidad where id_producto = idProd;
			if existe = 0 then
				insert into carrito values(idProd, idUser, xcantidad);
				set msj = 'ok';
			else
				update carrito set cantidad = cantidad + xcantidad where id_producto = idProd and id_user = idUser;
				set msj = 'update';
			end if;
		else
			set msj = 'No';
		end if;
	else
		set msj = 'No';
    end if;
    select msj;
end;//
delimiter ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito`
--

DROP TABLE IF EXISTS `carrito`;
CREATE TABLE IF NOT EXISTS `carrito` (
  `id_producto` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  KEY `id_producto` (`id_producto`),
  KEY `id_user` (`id_user`)
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

DROP TABLE IF EXISTS `categoria`;
CREATE TABLE IF NOT EXISTS `categoria` (
  `id_categoria` int(11) NOT NULL,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id_categoria`)
) ;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`id_categoria`, `name`) VALUES
(1, 'Vinos'),
(2, 'Destilados y Licores'),
(3, 'Aperitivos y Cremas'),
(4, 'Mundo saludable'),
(5, 'Alimentos Gourmet'),
(6, 'Marcas destacadas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_producto`
--

DROP TABLE IF EXISTS `categoria_producto`;
CREATE TABLE IF NOT EXISTS `categoria_producto` (
  `id_categoria` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  KEY `id_categoria` (`id_categoria`),
  KEY `id_producto` (`id_producto`)
) ;

--
-- Volcado de datos para la tabla `categoria_producto`
--

INSERT INTO `categoria_producto` (`id_categoria`, `id_producto`) VALUES
(1, 1),
(2, 123);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

DROP TABLE IF EXISTS `producto`;
CREATE TABLE IF NOT EXISTS `producto` (
  `id_producto` int(11) NOT NULL,
  `name` varchar(80) NOT NULL,
  `precio` float(6,2) NOT NULL,
  `descripcion` varchar(1500) DEFAULT NULL,
  `imagen` varchar(80) DEFAULT NULL,
  `existencia` int(11) NOT NULL,
  PRIMARY KEY (`id_producto`)
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subcategoria`
--

DROP TABLE IF EXISTS `subcategoria`;
CREATE TABLE IF NOT EXISTS `subcategoria` (
  `id_derivado` int(11) NOT NULL,
  `name` varchar(80) NOT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_derivado`),
  KEY `id_categoria` (`id_categoria`)
) ;

--
-- Volcado de datos para la tabla `subcategoria`
--

INSERT INTO `subcategoria` (`id_derivado`, `name`, `id_categoria`) VALUES
(1, 'vino tinto', 1),
(9, 'mezcal', 2),
(2, 'Vino Blanco', 1),
(3, 'Vino Rosado', 1),
(4, 'Vino Espumoso', 1),
(5, 'Vino Miniatura', 1),
(6, 'Vino Asti', 1),
(7, 'Champagne', 1),
(8, 'Licores', 2),
(10, 'Tequila', 2),
(11, 'Ron', 2),
(12, 'Whisky', 2),
(13, 'Ginebra', 2),
(14, 'Vodka', 2),
(15, 'Brandy', 2),
(16, 'Cremas', 3),
(17, 'Jerez', 3),
(18, 'Oporto', 3),
(19, 'Aceites', 4),
(20, 'Bebidas y Jarabes', 4),
(21, 'Libres de Azúcar', 4),
(22, 'Libres de Glúten', 4),
(23, 'Organicos', 4),
(24, 'Pastas', 4),
(25, 'Snacks', 4),
(26, 'Aceites', 5),
(27, 'Aderezos', 5),
(28, 'Condimentos', 5),
(29, 'Conservas y Frutos', 5),
(30, 'Conservas de mar', 5),
(31, 'Bacardi', 6),
(32, 'Casa Dragones', 6),
(33, 'Don Julio', 6),
(34, 'El Cielo', 6),
(35, 'Jonhnni Walker', 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `subcategoria_producto`
--

DROP TABLE IF EXISTS `subcategoria_producto`;
CREATE TABLE IF NOT EXISTS `subcategoria_producto` (
  `id_subcategoria` int(11) DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  KEY `id_subcategoria` (`id_subcategoria`),
  KEY `id_producto` (`id_producto`)
) ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE IF NOT EXISTS `usuario` (
  `id_user` int(11) NOT NULL,
  `firstname` varchar(60) NOT NULL,
  `apellidos` varchar(90) NOT NULL,
  `correo` varchar(80) NOT NULL,
  `pass` varchar(40) NOT NULL,
  PRIMARY KEY (`id_user`)
) ;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_user`, `firstname`, `apellidos`, `correo`, `pass`) VALUES
(1, 'Albertino', 'Ehad', 'Asies@gmail.com', 'root');



insert into producto values(1, 'Protos', 2350, 'Vino Tinto Tempranillo; Protos Gran Reserva de un intenso color rojo cereza oscuro y brillante, con ribete granate que en nariz se presume expresivo, potente, complejo y elegantemente tostado con un sutil olor a chocolate negro y fruta caramelizada. En boca exhibe notas de sabor cremoso especiado con un final largo y sedoso', 
'\\1 Vino tinto\\imagenProtos.jpg', 24);
insert into subcategoria_producto values(1,1);

insert into producto values(2, 'Del Fin del Mundo', 641, 'Vino Tinto Cabernet Sauvignon, Malbec, Merlot; Del Fin del Mundo, está elaborado a base de los mejores viñedos. Su crianza en barricas nuevas de roble francés durante 15 meses le otorga una gran complejidad, en la que se pueden descubrir infinidad de sensaciones a medida que se investiga en sus recovecos aromáticos. ', 
'\\1 Vino tinto\\delfindelmundo.jpg', 20);
insert into subcategoria_producto values(1,2);

insert into producto values(3, 'MariaTinto', 462, 'Un vino de gran potencia aromática con notas de zarzamora, frambuesa, cuero limpio y espresso. En boca es intenso y balanceado, con un fresco y elegante final. Elaborado con la base de tempranillo, syrah, adornos de grenache, petit syrah, cabernet franc, nebbiolo y merlot.',
 '\\1 Vino tinto\\imagenMariaTinto.jpg', 20);
insert into subcategoria_producto values(1,3);

insert into producto values(4, 'Matarromera', 576, 'Vino Tinto Tempranillo; Matarromera, es un vino envejecido 14 meses en barrica de roble americano. De color picota muy oscuro, con abundantes tonos violáceos, muy cubierto de capa, limpio y brillante. En nariz posee gran intensidad y complejidad.',
'\\1 Vino tinto\\imagenMatarromera.jpg', 50);
insert into subcategoria_producto values(1,4);

insert into producto values(5, 'Megacero', 536, 'Vino Tinto Merlot; Megacero, intenso y profundo color cereza oscuro con ribetes de color teja, aroma a frutos negros, notas florales y especias. El sabor es corpulento pero aterciopelado, taninos suaves y maduros que llenan el paladar. Gran balance e integración en la madera con dejos de Vainilla.',
'\\1 Vino tinto\\megacero.jpg', 50);
insert into subcategoria_producto values(1,5);

/*------------------------------*/

insert into producto values(6, 'Santiago Ruiz', 279, 'Vino Blanco Combinada; Santiago Ruiz es de color amarillo con reflejos verdosos, muy limpio y brillante. Su olor recuerda a una gran variedad de frutas como la manzana, la fruta de hueso y fruta tropical. Las notas herbáceas le dan una gran frescura. En boca es muy fresco, ligeros y con buena acidez.',
 '\\2 Vino Blanco\\santiagoruiz.jpg', 50);
insert into subcategoria_producto values(2,6);

insert into producto values(7, 'Monte Xanic', 300, 'Vino Blanco Sauvignon Blanc; Monte Xanic seco con acidez viva, en aroma a notas de guayaba, piña madura, cítricos particularmente el pomelo y suave percepción herbal. De cuerpo firme y persistencia larga.', 
'\\2 Vino Blanco\\montexanic.jpg', 20);
insert into subcategoria_producto values(2,7);

insert into producto values(8, 'Santa Rita', 168, 'Vino Blanco Sauvignon Blanc; Santa Rita dice la leyenda que fueron 120 los patriotas que después de librar una dura batalla por la Independencia de Chile, llegaron hasta las tierras de Santa Rita encontrando refugio en las bodegas donde nacen vino como el 120 Suavignon Blanc.',
 '\\2 Vino Blanco\\santarita.jpg', 30);
insert into subcategoria_producto values(2,8);

insert into producto values(9, 'Cono Sur', 180, 'Vino Blanco Chardonnay; Cono Sur con tonos verde-amarillo brillantes, expresivos aromas a lima, piña y flores blancas; un paladar frutal con suaves notas.',
'\\2 Vino Blanco\\Conosur.jpg', 50);
insert into subcategoria_producto values(2,9);

insert into producto values(10, 'Cyrnos', 644, 'Vino blanco Meursault Cyrnos; el vino más popular de la casa: amarillo pajizo, reflejos dorados, vainilla, pan, frutas maduras y mantequilla, notas de melocotón, almendra, membrillo y vainilla.',
'\\2 Vino Blanco\\cyrnos.jpg', 50);
insert into subcategoria_producto values(2,10);

/*--------------------------------------------*/

insert into producto values(11, 'Vegamar Brut Nature', 196, 'Vino Rosado Espumoso Vegamar Brut Nature; esta cava nace de la conjunción de las mejores uvas occidentales de Requena, cultivadas con exposiciones norte, y de la paciencia y quietud de su crianza en nuestra bodega.',
'\\3 Vino Rosado\\vegamar.jpg', 50);
insert into subcategoria_producto values(3,11);

insert into producto values(12, 'La Redonda', 236, 'Vino Dulce Moscatel; Orlandi elaborado únicamente a partir de la variedad Moscatel de cosecha tardía y fortificado después de fermentación, cuenta con al menos seis meses de crianza en barricas de roble americano.',
'\\3 Vino Rosado\\la redonda.jpg', 50);
insert into subcategoria_producto values(3,12);

insert into producto values(13, 'Manon', 232, 'Vino Rosado Garnacha, Cinsault, Syrah; Manon a la vista muestra un tono rosa límpido y brillante. En nariz revela un aroma con fragancias de flores blancas (madreselva) y de frutas con carozo (durazno), mientras en boca es rico, potente y fresco, con persistencia aromática remarcable y estructura sedosa.',
'\\3 Vino Rosado\\manon.jpg', 50);
insert into subcategoria_producto values(3,13);

insert into producto values(14, 'El Palacio', 208, 'Vino Rosado Alfa Tauri De color rosa pálido y elegante que recuerda a la piel de la pesca con reflejos brillantes y brillantes. En nariz se caracteriza por aromas de fruta blanca fresca, muy intensos y acogedores. Especialmente el melocotón, la fresa y notas tropicales de mango y papaya en el fondo.',
'\\3 Vino Rosado\\palacio.jpg', 50);
insert into subcategoria_producto values(3,14);

insert into producto values(15, 'Señorío de Mogrovejo', 140, 'Vino Rosado Señorío de Mogrovejo; con aspecto rosa frambuesa con reflejos violáceos. Aroma a fruta roja fresca, floral, especies dulces y vainilla. En boca potente, sabroso, frutoso y con una agradable acidez final.',
'\\3 Vino Rosado\\mogrovejo.jpg', 50);
insert into subcategoria_producto values(3,15);

/*--------------------------------------------*/
insert into producto values(16,'Chandon Brut',336,'Vino Espumoso Chandon Brut Chandonstar de la mezcla de Chardonnay, Pinot Noir; Suave y muy afrutado, se destaca por su refinamiento. La precisión y largo final en boca son los principales rasgos diferenciadores en el paladar.',
'\\4 Vino Espumoso\\chandon.jpg',40);
insert into subcategoria_producto values(4,16);
insert into producto values(17, 'Chandon Délice', 352, 'Vino Espumoso Chandon Délice con variedad de uvas Chardonnay, Pinot Noir, Petit Manseng; es la sutil variante de un estilo. Vérsatil por combinar lo clásico del Chardonnay y Pinot Noir con lo vanguardista del Sémillon y Petit Manseng. Este espumante traspasa la frontera de sabores.',
'\\4 Vino Espumoso\\chandon_delice.jpg', 50);
insert into subcategoria_producto values(4,17);
insert into producto values(18, 'Freixenet', 455, 'Vino Blanco Espumoso; Freixenet posee un color amarillo dorado pero matizado por el color de la botella. En nariz resulta complejo y brillante, destacando matices afrutados en especial la manzana. En boca es rico con final amplio, largo y fondo de mediana intensidad. Elaborado con la varietal de Macabeo, Xarel-lo y Parellada.',
'\\4 Vino Espumoso\\freixened.jpg', 70);
insert into subcategoria_producto values(4,18);
insert into producto values(19, 'Cinzano', 232, 'Vino Blanco Espumoso Muscat Blanco; Cinzano la exposición al sol y las características del suelo le infunden a esté vino su intenso color amarillo, su sabor seco y su aromático buquet floral.',
'\\4 Vino Espumoso\\cinzano.jpg', 50);
insert into subcategoria_producto values(4,19);
insert into producto values(20, 'Lancers ', 111.20, 'Vino Blanco Espumoso Fernão Pires; Lancers está elaborado con una mezcla que comprende principalmente Fernão Pires con pequeñas cantidades uva blanca. Tiene color pajizo brillante con reflejos dorados; su aroma es limpio y ligero, con notas de bayas dulces. Es de sabor seco, suave y refrescante, con delicados toques frutales y acabado suave.',
'\\4 Vino Espumoso\\lancers.jpg', 50);
insert into subcategoria_producto values(4,20);
/*--------------------------------------------*/
insert into producto values(21,'Moët & Chandon',292,'Champagne Moët & Chandon Imperial Brut; creado a partir de más de 100 vinos diferentes, de los cuales el 20% y el 30% son vinos de reserva especialmente seleccionados para mejorar su madurez, la complejidad y la constancia; en conjunto refleja la diversidad y el complemento de tres variedades de uvas: Pinot Noir, Pinot Meunier y Chardonnay.',
'\\5 Vino Miniatura\\moet___chandon.jpg',50);
insert into subcategoria_producto values(5,21);
insert into producto values(22, 'Estefanya', 36, 'Vino Tinto Merlot; Estefanya de color rojo profundo. Con aroma a fresa y mora madura, con frutas secas como ciruela, higo y cereza; suave en el paladar con final ligero y equilibrado.',
'\\5 Vino Miniatura\\estefanya.jpg', 50);
insert into subcategoria_producto values(5,22);
insert into producto values(23, 'JP. Chenet Cabernet Syrah ', 53.60, 'Vino Tinto JP. Chenet Cabernet Syrah; un bouquet intenso de cereza y grosella negra, realzado con una nota especiada ligera y delicada. Color rojo rubí profundo y oscuro, elaborado con 60% Cabernet y 40% Syrah.',
'\\5 Vino Miniatura\\jp_chanet.jpg', 70);
insert into subcategoria_producto values(5,23);
insert into producto values(24, 'Miniblack ', 183.20, 'Vino Espumoso; Miniblack es ligero y fresco con elaboración multivarietal de uvas, donde destacan las notas frutales que caracterizan tanto su sabor como sus finos aromas.',
'\\5 Vino Miniatura\\miniblack.jpg', 50);
insert into subcategoria_producto values(5,24);
insert into producto values(25, 'Sangre de Toro', 60, 'Vino Tinto Combinadas; Sangre de Toro de color cereza picota. Con aromas frescos, expresivos e intensos de frutas rojas y con un toque sutil de crianza en barrica de roble; en boca es aterciopelado y persistente, con taninos redondos sobre un fondo de frutas confitadas.',
'\\5 Vino Miniatura\\sangretoro.jpg', 50);
insert into subcategoria_producto values(5,25);
/*--------------------------------------------*/
insert into producto values(26,'Cinzano Asti',239.20,'Vino Blanco Espumoso Moscatel; Cinzano Asti es el más reconocido de los vinos espumosos Cinzano, se produce a partir de una uva Moscato el en área de Asti, en el corazón de Piedmont. Tiene un delicado y afrutado sabor, su dulzura de miel y notas de melocotón lo hacen la opción perfecta para combinar postres o celebrar cualquier ocasión.',
'\\6 Vino asti\\Cinzano asti.jpg',50);
insert into subcategoria_producto values(6,26);
insert into producto values(27, 'Asti ', 292, 'Vino Espumoso, Asti; espumoso, fabricado con el método Martinotti, de armonía aromática, en nariz fruta blanca y acacia. En boca es semi-seco, fructoso, fresco y medio intenso; notas de pera verde, manzana y melocotón.',
'\\6 Vino asti\\asti.jpg', 50);
insert into subcategoria_producto values(6,22);
insert into producto values(28, 'André', 153.60, 'Vino Rosado Espumoso Combinado; André presenta un color rosado y espumoso con sabores de naranja y cereza que reúne la cantidad perfecta de elegancia y diversión.',
'\\6 Vino asti\\andre.jpg', 70);
insert into subcategoria_producto values(6,28);
/*--------------------------------------------*/
insert into producto values(29,'Taittinger',1104,'Champagne Brut; Taittinger es sutil e intenso, gracias a las uvas seleccionadas de los propios viñedos de Pinot Meunier y un toque suave de Pinot Noir. De color rosado con aroma a frutos rojos como la cereza y frambuesa. En boca es equilibrado con sabor a frutos frescos.',
'\\7 Champagne\\taittinger.jpg',50);
insert into subcategoria_producto values(7,29);
insert into producto values(30, 'Dom Pérignon', 3039.20, 'Champagne Dom Pérignon; elaborado con uvas de extraordinaria madurez y salud. En nariz está lleno de vida, la almendra y el cacao en polvo se mezclan progresivamente con las frutas blancas y las flores secas. Las notas clásicas de la torrefacción terminan por completar el conjunto firmando una hermosa madurez.',
'\\7 Champagne\\domperignon.jpg', 50);
insert into subcategoria_producto values(7,30);
insert into producto values(31, 'Moët & Chandon', 1079.20, 'Champagne Rosada; Moët & Chandon es una expresión espontánea, radiante y romántica del estilo Moët, que se distingue por una fruta viva, un paladar seductor y una madurez elegante. Refleja una mezcla de diversidad y complementariedad de las tres variedades de uva elegidas para mejorar su intensidad, sutileza y constancia.',
'\\7 Champagne\\moet_chandon.jpg', 70);
insert into subcategoria_producto values(7,31);
insert into producto values(32, 'Louis Roederer', 9680, 'Champagne Brut; Louis Roederer intenso, fresco y de una gran precisión, el bouquet revela una gama completa y compleja de sabores; el conjunto es sedoso, carnoso, fundente, aéreo, de una gran pureza aromática.',
'\\7 Champagne\\louisreoederer.jpg', 50);
insert into subcategoria_producto values(7,32);
insert into producto values(33, 'Veuve Clicquot', 1701.20, 'Champagne Brut; Veuve Clicquot de color luminoso con atractivos reflejos rosados; en nariz, generoso y elegante, aromas de fruta fresca roja; perfectamente equilibrado en el mejor estilo Veuve Clicquot de champagnes rosados, combinando elegancia y estilo.',
'\\7 Champagne\\vuevecliequot.jpg', 60);
insert into subcategoria_producto values(7,33);
/*--------------------------------------------*/
insert into producto values(34,'Nonino',452,'Aguardiente Nonino Grappa 1897 destilado 100% artesanal.',
'\\8 Licores\\nonino.jpg',50);
insert into subcategoria_producto values(8,34);
insert into producto values(35, 'Paolo Lazzaroni & Figli', 300, 'Licor de Ajenjo Paolo Lazzaroni & Figli; Elaborado según la clásica receta de principios del siglo pasado con la infusión de hojas de ajenjo de los Alpes, de anís y cilantro. Ideal para servir diluido con agua fría (1 parte de licor de ajenjo y 4 partes de agua).',
'\\8 Licores\\Lazzoroni.jpg', 50);
insert into subcategoria_producto values(8,35);
insert into producto values(36, 'Licor 43', 389.60, 'Licor 43; bienvenido al licor 43, el licor más versátil del mundo, explora esta milagrosa "Sensación Dorada" y su maravillosa variedad de cócteles.',
'\\8 Licores\\licor43.jpg', 70);
insert into subcategoria_producto values(8,36);
insert into producto values(37, 'Chartreuse Diffusion', 744, 'Licor Chartreuse Verde; es un licor 100% de hierbas, elaborado con ingredientes naturales, sin adición de colorantes, por Monjes Cartujos.',
'\\8 Licores\\chartreuse.jpg', 50);
insert into subcategoria_producto values(8,37);
insert into producto values(38, 'Tokutei Meisho Shu', 103.20, 'Un sake al estilo más tradicional japonés. Por su sabor, Hide es excelente para maridar con platillo ligeramente sazonados.',
'\\8 Licores\\tokutei.jpg', 60);
insert into subcategoria_producto values(8,38);

/*--------------------------------------------*/

insert into producto values(39,'Espíritu Corsa',440,'Mezcal Santa Pedrera; mezcal joven 100% de agave, cuando bebes Santa Pedrera, no bebes mezcal; bebes 100% agave espadín, bebes años de tradición oaxaqueña, bebes procesos artesanales, bebes pureza. Somos más que un mezcal, somos: El rompedor de tristezas.',
'\\9 Mezcal\\espiritucorsa.jpg',50);
insert into subcategoria_producto values(9,39);
insert into producto values(40, 'Las Garrafas', 3560, 'Mezcal Máscara de Xaguar Naranja Las Garrafas; este ensamble, está compuesto por 3 agaves: Arroqueño, Espadín y Tobalá. La maduración del Tobalá, nos lleva desde 12 hasta 14 años. Es un agave muy especial, además de ser completamente silvestre. ',
'\\9 Mezcal\\garrafas.jpg', 50);
insert into subcategoria_producto values(9,40);
insert into producto values(41, 'Bruxo', 479.20, 'Bruxo No. 2 Pechuga de Maguey es un mezcal artesanal dedicado a los que por su sabiduría comprenden el tiempo y bondades de la tierra. Elaborado en Agua del Espino, Oaxaca.',
'\\9 Mezcal\\Bruxo.jpg', 70);
insert into subcategoria_producto values(9,41);
insert into producto values(42, 'Mezcal Mortal de Oaxaca ', 700, 'Mezcal Mortal de Oaxaca Cupreata es un destilado 100% orgánico; elaborado a base de piñas ahumadas de Agave, fermentadas en agua de manantial y sintetizadas mediante el tiempo y trabajo de manos mexicanas.',
'\\9 Mezcal\\Mezcaloaxaca.jpg', 50);
insert into subcategoria_producto values(9,42);
insert into producto values(43, 'Gracias a Dios', 792, 'Mezcal Gracias a Dios 100% agave silvestre de 15 años. Agave monumental y único, donde la piña crece fuera de la tierra. Fuerte aroma a musgo y humedad, persistentes sabores a clavo, pimiento blanca, canela y manzanas. Excelente para acompañar con pollo, ensaladas o menús mediterráneos.',
'\\9 Mezcal\\graciasadios.jpg', 60);
insert into subcategoria_producto values(9,43);

/*--------------------------------------------*/
insert into producto values(44,'Casa José Cuervo',224,'Elaborado 100% agave azul y seleccionado con las mejores uvas, es reposado en barricas nuevas de roble blanco y sujeto a un proceso llamado selección suave, posee tonos naturales de vainilla y clavo, lo que lo hace un tequila suave con toque de dulce. El resultado es único, para tomar solo o combinado.',
'\\10 Tequila\\casajosecuerv.jpg',50);
insert into subcategoria_producto values(10,44);
insert into producto values(45, 'Ex Haciendo los Camichines', 180, 'Un tequila suave que desde su nombre muestra el orgullo por su origen y calidad, 100% agave azul. Forma parte de la línea gran centenario y tiene toda la fuerza de un agave que se arriesga; ansioso por salir de un reposo de dos meses en barricas de roble blanco y tomar las riendas de su propio mundo. ',
'\\10 Tequila\\exhacienda.jpg', 50);
insert into subcategoria_producto values(10,45);
insert into producto values(46, 'José Cuervo', 148, 'Tequila José Cuervo Especial Plata José Cuervo; en la destilería La Rojeña de José Cuervo nos sentimos orgullosos de honrar el legado del hombre que la fundó, nuestro tequila usa el agave azul más fino y es perfecto para tomarse solo o con tu mezclador favorito.',
'\\10 Tequila\\cuervo.jpg', 70);
insert into subcategoria_producto values(10,46);
insert into producto values(47, 'Don Julio', 516, 'Tequila Reposado Don Julio elaborado en 100% agave pasa ocho meses en barricas de roble blanco, es de color ámbar dorado y ofrece un acabado rico y suave, la esencia misma del tequila perfecto en barrica. Con un sabor suave y elegante y un aroma acogedor.',
'\\10 Tequila\\julio.jpg', 50);
insert into subcategoria_producto values(10,47);
insert into producto values(48, 'Ex Hacienda Los Camichines', 440, 'Un exquisito y fino tequila 100% de agave azul, para verdaderos conocedores. Añejado en barricas nuevas de encino americano y roble francés, para lograr el tono y sabor amaderado que distingue a los tequila 1800. ',
'\\10 Tequila\\1800anejo.jpg', 60);
insert into subcategoria_producto values(10,48);

/*--------------------------------------------*/
insert into producto values(49,'Maison Ferrand',224,'Elaborado 100% agave azul y seleccionado con las mejores uvas, es reposado en barricas nuevas de roble blanco y sujeto a un proceso llamado selección suave, posee tonos naturales de vainilla y clavo, lo que lo hace un tequila suave con toque de dulce. El resultado es único, para tomar solo o combinado.',
'\\11 Ron\\ferrand.jpg',50);
insert into subcategoria_producto values(11,49);
insert into producto values(50, 'Valdeflores', 959.20, 'Ron Valdeflores, estilo francés proveniente del jugo de la caña de azúcar orgánica, destilado en alambique, tipo europeo que le brinda sabor y carácter único. Reposado por 8 años en barricas de roble blanco de primer uso.',
'\\11 Ron\\valdeflores.jpg', 50);
insert into subcategoria_producto values(11,50);
insert into producto values(51, 'Bacardí', 888, 'Ron Santa Teresa 1796 es el único ron de edad que se produce en su totalidad con el método largo de solera, un proceso artesanal con barricas de roble tradicionalmente reservadas para el jerez y brandy español. Este ron y ron firme es delicado con un sabor complejo y suave.',
'\\11 Ron\\bacacho.jpg', 70);
insert into subcategoria_producto values(11,51);
insert into producto values(52, 'Añejos de Altura', 2088, 'Ron Zacapa XO es la mejor expresión de nuestro singular proceso de añejamiento y mezclas con el "Sistema Solar" que se realiza en las montañas de Guatemala. Este proceso, que combina arte y tradición, fomenta la mezcla de rones de diferentes edades y personalidades para que pueda seguir añejando en barricas seleccionadas.',
'\\11 Ron\\anejosaltura.jpg', 50);
insert into subcategoria_producto values(11,52);
insert into producto values(53, 'Dos Maderas ', 852, 'Ron Dos Maderas 5 + 5 es un ron con doble proceso de crianza, en un primer momento reposa durante cinco años en el Caribe, en botas de roble americano. Posteriormente es trasladado a las instalaciones bodegueras de Williams & Humbert en Jerez de la Frontera de Andalucía, España, donde pasará su última fase de envejecimiento, que dura 3 años más.',
'\\11 Ron\\maderas.jpg', 60);
insert into subcategoria_producto values(11,53);

/*--------------------------------------------*/
insert into producto values(54, 'Johnnie Walker', 4040, 'Whisky Johnnie Walker, un blended creado para reflejar el estilo de los whiskies del siglo XIX nace como un homenaje al fundador. Su carácter combina la rareza de 9 whiskies incluyendo las destilerías Glen Albyn y Cambus bajo un diseño numerado y único decantador en cristal Baccarat soplado, pulido y grabado por uno de sus grandes maestros artesanos del mundo.',
'\\12 Whisky\\jw.jpg', 50);
insert into subcategoria_producto values(12,54);
insert into producto values(55, 'Dewars', 4799.20, 'Whisky Dewars Aged 25 Years; envejecido durante un cuarto de siglo, un homenaje al arte de la mezcla. La acumulación de conocimiento, aprendizaje y habilidad transmitida a través de la generación de Dewars Master Blenders de 1864, es evidente en cada preciosa gota.',
'\\12 Whisky\\wars.jpg', 50);
insert into subcategoria_producto values(12,55);
insert into producto values(56, 'BUCHANAN´S', 659.20, 'La regla de oro del whisky dicta que la mejor forma de beberlo es como a uno le gusta. Buchanans De Luxe te ofrece los más finos ingredientes de Escocia, whiskies de malta y grano que descansan 12 años en barricas de roble. El resultado es un suave sabor a mandarinas, naranjas y limones que dan paso a un ligero toque de chocolate con leche. ',
'\\12 Whisky\\buchannans.jpg', 50);
insert into subcategoria_producto values(12,56);
insert into producto values(57, 'Rare Cask', 5152, 'Whisky Rare Cask; opulento, suave, ligeramente serpenteante, imagina una orquesta de vainilla con notas profundas y pasas en negrilla aunque sólo en hechizos. Un dulce conjunto de manzana, limón y naranja; bellamente equilibrado con un cuarteto picante de raíz de jengibre, canela, nuez moscada y clavo de olor. Roble maduro y elegante que sólo el tiempo ofrece.',
'\\12 Whisky\\cask.jpg', 50);
insert into subcategoria_producto values(12,57);
insert into producto values(58, ' Johnnie Walker Red Label', 348, 'Whisky Johnnie Walker Red Label; es nuestra mezcla pionera, la que ha representado nuestro whisky en todo el mundo. Una mezcla versátil de carácter acentuado y con un perfil que se mantiene incluso al ser combinado.',
'\\12 Whisky\\label.jpg', 50);
insert into subcategoria_producto values(12,58);
/*--------------------------------------------*/
insert into producto values(59, 'Flor de Sevilla', 440, 'Ginebra Tanqueray Flor de Sevilla; increíblemente exquisita, la innovación de Charles Tanqueray, con un sabor cítrico, afrutado refrescante e intenso, con notas a mandarina, enebro y cilantro. Sus notas lo hacen ideal para disfrutar con Prosseco o un gin and tonic. ',
'\\13 Ginebra\\flordesevilla.jpg', 59);
insert into subcategoria_producto values(13,59);
insert into producto values(60, 'Monkey 47', 880, 'Gin Monkey 47 posee un buen tercio de los ingredientes que vienen de la Selva Negra y definitivamente no son lo que se podría llamar saborizantes típicos de ginebra. En total, 47 ingredientes escogidos a mano, preparados en agua de manantial extremadamente suave dan a MONKEY 47.',
'\\13 Ginebra\\monkey47.jpg', 50);
insert into subcategoria_producto values(13,60);
insert into producto values(61, 'Tanqueray London Dry', 345.60, 'Ginebra Tanqueray London Dry Gin de tono transparente y limpio, de cuerpo medio, destacando en el aroma el alcohol, enebro y cítricos. Su especial e inconfundible sabor, es suave y equilibrado con notas de limón que dan un final largo y espaciado.',
'\\13 Ginebra\\tanqueray.jpg', 50);
insert into subcategoria_producto values(13,61);
insert into producto values(62, 'Bombay Sapphire', 424, 'Ginebra Bombay Sapphire; A diferencia del resto de ginebras, Bombay Sapphire utiliza una técnica de elaboración exclusiva llamada Infusión al Vapor: la manera más cuidada de transmitir el sabor de los botánicos a la ginebra y conseguir una ginebra con un sabor suave y equilibrado, perfecta para combinar. ',
'\\13 Ginebra\\bombay.jpg', 50);
insert into subcategoria_producto values(13,62);
insert into producto values(63, 'Bulldog London Dry', 420, 'Ginebra Bulldog mezcla el trigo de la región Anglia Oriental de Inglaterra con doce ingredientes botánicos muy exóticos como: el ojo de dragón chino, semillas de amapolas blancas turcas, hojas de loto de Asia, enebro italiano, cilantro de Marruecos, limón español, regaliz chino, orris italiano, almendras españolas, canela asiática, lavanda francesa y una planta germánica.',
'\\13 Ginebra\\bulldog.jpg', 50);
insert into subcategoria_producto values(13,63);
/*--------------------------------------------*/
insert into producto values(64, 'Vodka Absolut Regular', 208, 'Presentado por primera vez en 1979 en Nueva York, Absolut Vodka se hizo famoso por su sabor rico, suave y dulce que se logra de manera natural y sin el uso de azúcar. Con el carácter distintivo del grano de trigo, seguido de un toque de frutas secas.',
'\\14 Vodka\\vodkabsolut.jpg', 50);
insert into subcategoria_producto values(14,64);
insert into producto values(65, 'X1 Spicy Tamarind', 144, 'Vodka Smirnoff X1 Spicy Tamarind; El clásico vodka ruso combinado con el típico fruto mexicano del tamarindo, lo cual le da un sabor dulce y picante, perfecto para tomarse bien frío.',
'\\14 Vodka\\smirnoff.jpg', 50);
insert into subcategoria_producto values(14,65);
insert into producto values(66, 'Skyy', 136, 'Fabricado en San Francisco, California, desde donde se recibe el alcohol destilado, Vodka Skyy se logra través de un proceso original de Maurice Kanbar que consta de una cuádruple destilación de trigo y filtrado en tres ocasiones. Su presentación es en una botella estilizada color azul cobalto.',
'\\14 Vodka\\sky.jpg', 50);
insert into subcategoria_producto values(14,66);
insert into producto values(67, ' DQ', 780, 'El Vodka más suave y sutil, creado hace más de un siglo. Puede beberse a temperatura ambiente a diferencias de los demás. Es una experiencia gratificante y extra-sensorial ya que su sabor resulta agradable al tacto y exquisito al paladar. Destilado con agua y grano de trigo.',
'\\14 Vodka\\DQ.jpg', 50);
insert into subcategoria_producto values(14,67);
insert into producto values(68, 'Grey Goose', 568, 'Vodka Grey Goose; Inspirado en la vida nocturna, este aromático vodka elaborado con el mejor trigo francés, filtrado con piedra caliza de champagne y cinco destilaciones, aseguran su frescura única, clara y suave. De diseño en botella con tapón de corcho y cierre estampado, lo hacen atractivo y diferente a cualquier otro.',
'\\14 Vodka\\greygoose.jpg', 50);
insert into subcategoria_producto values(14,68);
/*--------------------------------------------*/
insert into producto values(69, 'Torres 10 ', 248, 'Desde 1946, su cuidadosa elaboración y largo envejecimiento en barricas de roble lo convierten en un brandy excepcional. De la mano de Miguel Torres Carbó, tercera generación de la familia, a pesar de los difíciles momentos históricos que se vivían en la época, nació Torres 10, la marca más emblemática de brandy Torres.',
'\\15 Brandy\\torres10.jpg', 50);
insert into subcategoria_producto values(15,54);
insert into producto values(70, 'Azteca de Oro Solera Reservada', 133.60, 'Brandy Azteca de Oro Solera Reservada es el único brandy mexicano ganador de medallas que avalan su calidad, sabor y nobleza a nivel internacional. Un brandy con solera exquisita.',
'\\15 Brandy\\aztecadeoro.jpg', 50);
insert into subcategoria_producto values(15,70);
insert into producto values(71, 'Fundador', 184, 'Brandy Fundador de jerez 100% de uva; su aroma es distinguido, elegante y duradero, característico de su selecta calidad y prolongada maduración. El sabor es amable, equilibrado y persistente, que en contacto con la madera envinada que había servido para la crianza de jerez.',
'\\15 Brandy\\fundador.jpg', 50);
insert into subcategoria_producto values(15,71);
insert into producto values(72, 'Magno Solera Reserva', 212.80, 'Brandy Magno Solera Reserva; de color caoba, luminoso y brillante, es intenso con armonía en la nariz pero muy persistente, además ligeramente abocado y ensamblado bajo los distintos aguardientes de vino, envejecido en botas de roble siguiendo el tradicional proceso de soleras. ',
'\\15 Brandy\\magno.jpg', 50);
insert into subcategoria_producto values(15,72);
insert into producto values(73, 'Don Pedro Gran Reserva Especial', 136, 'Brandy Don Pedro sobresale gracias a la selección especial de uvas y el mejor añejamiento en barricas de roble blanco, combinando el equilibrio y la madurez que caracteriza a la casa Pedro Domecq.',
'\\15 Brandy\\donpedro.jpg', 50);
insert into subcategoria_producto values(15,73);
/*--------------------------------------------*/
insert into producto values(74, 'Crema Tres Leches', 268, 'Crema Baileys Tres Leches; ahora con todo lo delicioso del pastel de tres leches, entre notas de caramelo, miel, nueces, vainilla y el clásico toque del whisky irlandés.',
'\\16 Cremas\\baileys.jpg', 50);
insert into subcategoria_producto values(16,74);
insert into producto values(75, 'Rompope', 92, 'Rompope Coronado es delicioso cuando se toma solo, y por su dulce y cremoso sabor vainilla, almendra y también capuchino, también es el complemento perfecto para preparar postres y mezclar con otras bebidas.',
'\\16 Cremas\\rompope.jpg', 50);
insert into subcategoria_producto values(16,75);
insert into producto values(76, 'Créme de Sake Nigori', 199.20, 'Nigori Crème de Sake posee un sabor ligeramente más seco, sabor rico y robusto con arroz. Suave Aroma.',
'\\16 Cremas\\sakenigori.jpg', 50);
insert into subcategoria_producto values(16,76);
insert into producto values(77, 'La Crema Sonoma Coast', 759.20, 'Vino Tinto Freixenet La Crema Sonoma Coast 2015 Pinot Noir; aromas de cereza roja, frambuesa, granada y tabaco dulce. Sabores de varias capas de bayas rojas, azules y negras y ciruelas.',
'\\16 Cremas\\sonoma coast.jpg', 50);
insert into subcategoria_producto values(16,77);
insert into producto values(78, 'Licor de Café Sheridans', 392, 'Licor de café Sheridans; Un licor único que consiste en dos botellas que, cuando se mezclan en proporciones correctas, se asemejan a un café irlandés fenomenal. Contiene 16% de alcohol por volumen.',
'\\16 Cremas\\sheridans.jpg', 50);
insert into subcategoria_producto values(16,78);
/*-----------------------------------------------------*/
insert into producto values(79, 'Tío Pepe', 254.40, 'El Jerez Tío Pepe nace en los pagos históricos de Carrascal y Macharnudo, donde la familia González tiene viñedos desde hace más de 100 años. Fresco y distintivo. Tío Pepe es inolvidable como aperitivo y para tapear. ',
'\\17 Jerez\\tiopepe.jpg', 50);
insert into subcategoria_producto values(17,79);
insert into producto values(80, 'Dry Sack Medium', 196, 'Jerez Williams Humbert de color ámbar brillante con aroma intenso que recuerda a frutos secos y nuez. Al paladar resulta pleno, armonioso, poco ácido y ligeramente dulce. ',
'\\17 Jerez\\drysack.jpg', 50);
insert into subcategoria_producto values(17,80);
insert into producto values(81, 'La Ina Fino', 287.20, 'Vino Jerez La Ina Fino; es considerado por los expertos como el más fino de los Finos. Se cría siguiendo el tradicional sistema de Solera y Criaderas en Jerez de la Frontera. De color amarillo pajizo, nítido y brillante.',
'\\17 Jerez\\lainafina.jpg', 50);
insert into subcategoria_producto values(17,81);
insert into producto values(82, 'Fino Quinta', 252, 'Bodegas Osborne elabora este vino con uvas Palomino Fino en sus bodegas de El Puente de Santa María. Un cuidadoso proceso de elaboración y envejecimiento tradicional de criaderas y soleras en botas de roble americano.',
'\\17 Jerez\\finoquinta.jpg', 50);
insert into subcategoria_producto values(17,82);
insert into producto values(83, 'Palo Cortado Tradición', 1875.20, 'Jerez Palo Cortado Tradición Vors Bodegas Tradición de color oro viejo, con finura, ligereza y elegancia inigualable. En paladar es seco y persistente, con la finura del Amontillado y el bouquet del Oloroso.',
'\\17 Jerez\\palocortado.jpg', 50);
insert into subcategoria_producto values(17,83);
/*-----------------------------------------------------*/
insert into producto values(84, 'Sademan Tawny', 335.20, 'Sademan Tawny es brillante y de intenso color ámbar; intensas notas de frutos secos como pasas, avellanas frscas, miel, nueces, pasas tostadas, y especies como la nuez moscada y vainilla.',
'\\18 Oporto\\sedeman.jpg', 50);
insert into subcategoria_producto values(18,84);
insert into producto values(85, 'Ferreira Tawny', 319, 'Oporto Ferreira Twany posee un aroma fresco y delicado, especialmente apreciado si se acompaña con frutos secos, melón y dulces a base de fruta.',
'\\18 Oporto\\ferreira.jpg', 50);
insert into subcategoria_producto values(18,85);
insert into producto values(86, 'Quinta Do Crasto',256, 'Porto Finest Reserve muestra un complejo bouquet de frutas rojas maduras, higos y un ligero toque de hierbas silvestres.',
'\\18 Oporto\\quintadocastro.jpg', 50);
insert into subcategoria_producto values(18,86);
insert into producto values(87, 'Ramos Pinto Tawny', 700, 'Vino Oporto Interamericana Ramos Pinto Tawny 10 Años; es de color rojo ladrillo, incluso oro. En nariz cuenta con especias del oriente, aromas exóticos y picantes; albaricoque y ciruelas. ',
'\\18 Oporto\\ramospint.jpg', 50);
insert into subcategoria_producto values(18,87);
insert into producto values(88, 'Dry White', 292, 'Porto Niepoort con un color oro marrón y un delicioso aroma de nueces y almendras que se notan en el paladar con un final fresco y concentrado, derivado del envejecimiento en pequeñas barricas de roble.',
'\\18 Oporto\\drywhite.jpg', 50);
insert into subcategoria_producto values(18,88);
/*-----------------------------------------------------*/
insert into producto values(89, 'Aceite de Oliva Extra Virgen Lestornell', 252, 'Aceite de oliva de categoría superior obtenido directamente de aceitunas y sólo mediante procedimientos mecánicos. Extracción en frío de aceitunas Arbequinas con sistema de control.',
'\\19 Aceites\\lestornell.jpg', 50);
insert into subcategoria_producto values(19,89);
insert into producto values(90, 'Aceite de Aguacate Inés', 100 , 'Aceite de aguacate con antioxidantes naturales y libre de colesterol. Por su sabor ligero puede sustituir al aceite de oliva en la preparación de cualquier platillo, gracias a su alto punto de humeo es recomendable para freír.',
'\\19 Aceites\\Ines.jpg', 50);
insert into subcategoria_producto values(19,90);
insert into producto values(91, ' Aceite de Aguacate Orgánico Enature', 68, 'Aceite extra virgen de aguacate orgánico, 100% natural, rico en Omega 9. Elaborado con ingredientes de calidad Premium. Excelente alternativa para acompañar tus ensaladas y aderezos. ',
'\\19 Aceites\\enature.jpg', 50);
insert into subcategoria_producto values(19,91);
insert into producto values(92, 'Aceite de Aguacate Cate de mi Corazón', 56, 'Aceite puro de aguacate sin colesterol para darle un toque sano a tus platillos. Es ideal para ensaladas, pastas, carnes y mariscos.',
'\\19 Aceites\\catedemicorazon.jpg', 50);
insert into subcategoria_producto values(19,92);
insert into producto values(93, 'Aceite Natural Avocare', 76.80, 'Aceite 100% natural, ideal para cocinar alimentos y preparar ensaladas; fuente de Omega 3, 6, 9 y vitamina E. Elaborado 100% en México ',
'\\19 Aceites\\avocare.jpg', 50);
insert into subcategoria_producto values(19,93);
/*-----------------------------------------------------*/
insert into producto values(94, 'Soya en Polvo Sabor Plátano', 67.20, 'Bebida con proteína vegetal aislado de soya, aceite vegetal, sólidos de la leche, fosfato de calcio (antihumectante), azúcar, saborizante natural y artificial de vainilla, monoglicéridos y diglicéridos de ácidos grasos.',
'\\20 Bebida y Jarabes\\soysabor.jpg', 50);
insert into subcategoria_producto values(20,94);
insert into producto values(95, 'Té Matcha Orgánico Masara', 172.80, 'Hoja de té verde molida. Una cucharada de té Matcha equivale a 10 bolsas de té verde en antioxidantes. ',
'\\20 Bebida y Jarabes\\tematcha.jpg', 50);
insert into subcategoria_producto values(20,95);
insert into producto values(96, 'Bebida de Soya Calcimel', 58.40, 'Bebida de soya Calcimel Bio; Llena de ventajas de principio a fin. Es especialmente rica en proteínas de alta calidad y contiene algas biológicas que le aportan calcio',
'\\20 Bebida y Jarabes\\bebidasoya.jpg', 50);
insert into subcategoria_producto values(20,96);
insert into producto values(97, 'Leche de Almendras Santiveri', 83.20, 'Leche de almendras Santiveri; elaborada con ingredientes procedentes de la agricultura ecológica. 100% Vegetal. Sin lactosa. Sin gluten.',
'\\20 Bebida y Jarabes\\santiveri.jpg', 50);
insert into subcategoria_producto values(20,97);
insert into producto values(98, 'Miel Mantequilla Mielcom', 100, 'Miel cristalizada con textura suave y untable; elaborado con miel de abeja 100% orgánica. Contiene todas las bondades de la naturaleza, su aroma y sabor son dulces florales y frutales. ',
'\\20 Bebida y Jarabes\\mielcom.jpg', 50);
insert into subcategoria_producto values(20,98);
/*-----------------------------------------------------*/
insert into producto values(99, 'Duro de Almendras Santiveri', 134.40 , 'Duro de Almendras Santiveri elaborado con almendra tostada, edulcorantes, clara de huevo y oblea. ',
'\\21 Libres de Azucar\\santiveri.jpg', 50);
insert into subcategoria_producto values(21,99);
insert into producto values(100, 'Polvo de té Lakanto Oná', 477, 'Polvo de té Lakanto oná; polvo de té verde concentrado con azúcar del monje, eritritol y probióticos.',
'\\21 Libres de Azucar\\polvote.jpg', 50);
insert into subcategoria_producto values(21,100);
insert into producto values(101, 'Pasita con Chocolate Semiamargo Bel Ara', 75.20, 'Pasas Bel Ara con chocolate semiamargo sin azucares añadidos, sólo los propios de la fruta.',
'\\21 Libres de Azucar\\Bel ara.jpg', 50);
insert into subcategoria_producto values(21,101);
insert into producto values(102, 'Stevia Líquida', 98.40, 'Stevia Líquida Santiveri; edulcorante de origen natural procedente de la planta Stevia rebaudiana.',
'\\21 Libres de Azucar\\stevia.jpg', 50);
insert into subcategoria_producto values(21,102);
insert into producto values(103, 'Agavezucar', 88.80, 'Jarabe de agave en polvo 100% natural con elevado poder endulcorante que mejora e intensifica los sabores, fácil asimilación para el cuerpo por su bajo índice glucémico.',
'\\21 Libres de Azucar\\agaveazu.jpg', 50);
insert into subcategoria_producto values(21,103);
/*-----------------------------------------------------*/
insert into producto values(104, 'Corn Flakes sin Gluten Noglut', 60, 'Hojuelas de maíz tostado, aplastado y cocido, con azúcar y sal.',
'\\22 Libres de Glúten\\noglut.jpg', 50);
insert into subcategoria_producto values(22,104);
insert into producto values(106, 'Fusilli 48 Gluten Free', 72, 'Rummo Fusilli 48 Gluten Free,400 G. ',
'\\22 Libres de Glúten\\fussil.jpg', 50);
insert into subcategoria_producto values(22,106);
insert into producto values(107, 'Quínoa Roja', 105, 'Quinoa Roja Sin Gluten 400 G.',
'\\22 Libres de Glúten\\quinoaroja.jpg', 50);
insert into subcategoria_producto values(22,107);
insert into producto values(108, 'Galletas Rellenas de Cacao Noglut', 80, 'Galletas Rellenas de Cacao Noglut 150 G',
'\\22 Libres de Glúten\\galletasnoglut.jpg', 50);
insert into subcategoria_producto values(22,108);
/*--------------------------------------------*/
insert into producto values(109, 'Té Peppermint', 118, 'Té orgánico elaborado con hojas de menta, un refrescante sabor y unas exquisitas hojas que provienes de la ciudad de Egipto. ',
'\\23 Organicos\\peppermint.jpg', 50);
insert into subcategoria_producto values(23,109);
insert into producto values(110, 'Cúrcuma Masara', 45.90, 'Cúrcuma Masara oná; la cúrcuma es una raíz parecida al jengibre de colora anaranjado que se debe a la curcumina el cual es un fitoquímico que ayuda a la inflamación. ',
'\\23 Organicos\\curcuma.jpg', 50);
insert into subcategoria_producto values(23,110);
insert into producto values(111, 'Muesli Naturalia Cereales', 61.60, 'Muesli Santiveri Naturalia con una mezcla de cereales en hojuelas y pasas. Delicioso muesli natural, excelente fuente de fibra y con toda la fuerza de los cereales. ',
'\\23 Organicos\\muesli.jpg', 50);
insert into subcategoria_producto values(23,111);
insert into producto values(112, 'Pasta de Chícharo Fusilli', 85.60, 'Castagno Pasta de Chícharo – Fusilli; contiene: proteínas, grasas totales, carbohidratos totales, azucares, fibra dietética, hierro y fosforo. ',
'\\23 Organicos\\chicharo.jpg', 50);
insert into subcategoria_producto values(23,112);
insert into producto values(113, 'Alcachofas al Natural Ecológicas', 204, 'Elaborado con alcachofas, agua, sal y acidulante: ácido cítrico 400 G.',
'\\23 Organicos\\alcachofas.jpg', 50);
insert into subcategoria_producto values(23,113);
/*-----------------------------------------------------*/
insert into producto values(114, 'Fusilli El Dorado', 90, 'Fusilli El Dorado, pasta sin gluten con harina de arroz, quinoa real negra y agua; fuente de fibra y libre de transgénicos. ',
'\\24 Pastas\\fusillidorado.jpg', 50);
insert into subcategoria_producto values(24,114);
insert into producto values(115, 'Pasta de Arroz Fusilli', 55.20, 'Pasta elaborada con harina de arroz y harina de maíz blanco en forma de fusilli.Es 100% natural. ',
'\\24 Pastas\\pastaarroz.jpg', 50);
insert into subcategoria_producto values(24,115);
insert into producto values(116, 'Caldo Vegetal', 50.40, 'Caldo de vegetales en forma de pastillas, elaborado con sal, grasa vegetal refinada de palma, potenciador del sabor y extracto de levadura.',
'\\24 Pastas\\caldovegetal.jpg', 50);
insert into subcategoria_producto values(24,116);
insert into producto values(117, 'Macarrón Nogut', 74.40, 'Pasta en forma de macarrón elaborada con harina de maíz, emulgente (monoglicéridos y diglicéridos de los ácidos grasos). ',
'\\24 Pastas\\macarron.jpg', 50);
insert into subcategoria_producto values(24,117);
insert into producto values(118, 'Spaghetti Naturalia', 70.40, 'Pasta elaborada con sémola de trigo duro y salvado de trigo, procedentes de la agricultura biológica.',
'\\24 Pastas\\spaghetti.jpg', 50);
insert into subcategoria_producto values(24,118);
/*-----------------------------------------------------*/
insert into producto values(119, 'Arándanos Seeberger', 52.80, 'Arándanos secos y cristalizados de la marca alemana Seeberger, fundada en 1844 y que comenzó con la comercialización de café.',
'\\25 Snacks\\arandanos.jpg', 50);
insert into subcategoria_producto values(25,119);
insert into producto values(120, 'Veggie Chips', 31.20, 'Botana de harina de papa con tomate y espinaca, aceite de cártamo, azúcar, pasta de tomate, cúrcuma, espinaca en polvo y remolacha en polvo.',
'\\25 Snacks\\veggiechips.jpg', 50);
insert into subcategoria_producto values(25,120);
insert into producto values(121, 'Polen de Abeja Mielcom', 104, 'Producto natural elaborado con 100% Polen de abeja. Ideal para ensaladas, con yogurt y licuados. ',
'\\25 Snacks\\polen.jpg', 50);
insert into subcategoria_producto values(25,121);
insert into producto values(122, 'Chía Orgánica',98.40, 'Chía, un alimento milenario y ancestral. Es orgánica, tanto que que ayuda a tener sensación de saciedad, alta concentración de vitaminas minerales y ácidos grasos.',
'\\25 Snacks\\chia.jpg', 50);
insert into subcategoria_producto values(25,122);
insert into producto values(123, 'Mango Natural Frutas-Lio', 147.20, 'Mango natural en cubos que conserva su olor, sabor, minerales y vitaminas. Elaborado de manera artesanal e ideal para probarlo con tu cereal o ensalada.',
'\\25 Snacks\\mango.jpg', 50);
insert into subcategoria_producto values(25,123);
/*-----------------------------------------------------*/
insert into producto values(124, 'Aceite de Oliva Arbequina', 458.60, 'Aceite Bravoleum extra virgen con extracción en frío, selección especial de aceites hacienda el palo. ',
'\\26 Aceites\\arberquina.jpg', 50);
insert into subcategoria_producto values(26,124);
insert into producto values(125, 'Aceite de Oliva Manzanilla', 280, 'Aceite Hanseatik presenta un sabor intenso e incomparable',
'\\26 Aceites\\aceiteoliva.jpg', 50);
insert into subcategoria_producto values(26,125);
insert into producto values(126, 'Vinagre de cava Club del gourmet', 55.20, 'Vinagre de cava; antioxidante, un vinagre seco y afrutado, idóneo para mariscos, carnes y para aromatizar cualquier plato.',
'\\26 Aceites\\vinagre.jpg', 50);
insert into subcategoria_producto values(26,126);
insert into producto values(127, 'Vinagre a la Trufa', 135.20, 'Vinagre a la Trufa Retartú; ingredientes: aceite de oliva extra virgen, aceite balsámico y aromas.',
'\\26 Aceites\\trufa.jpg', 50);
insert into subcategoria_producto values(26,127);
insert into producto values(128, 'Vinagre Balsámico Amarillo', 205.60, 'Vinagre Balsámico Il Tinello del Balsamico Amarillo; ingredientes: mosto de uva concentrado y acetato de vino; contiene sulfitos. ',
'\\26 Aceites\\balsamico.jpg', 50);
insert into subcategoria_producto values(26,128);
/*-----------------------------------------------------*/
insert into producto values(129, 'Gari Jengibre Preparado', 34.40, 'Jengibre Morimoto preparado con agua, sal yodada, vinagre, ácido acético, ácido cítrico, ácido málico, sorbato de potasio, y color. ',
'\\27 Aderezos\\garijengibre.jpg', 50);
insert into subcategoria_producto values(27,129);
insert into producto values(130, 'Paté de Aceituna Negra', 107, 'Paté de aceituna negra Vecchia Maremma. Ingredientes: aceitunas negras, aceite de oliva virgen extra, almendras, saborizantes naturales, vinagre. ',
'\\27 Aderezos\\aceituna.jpg', 50);
insert into subcategoria_producto values(27,130);
insert into producto values(131, 'Pesto de Albahaca', 108, 'Pesto de albahaca Il Cipressino. Ingredientes: basil, aceite de girasol, hojuelas de papa, aceite de oliva, piñones, sal de mesa, jugo de limón.',
'\\27 Aderezos\\pestodi.jpg', 50);
insert into subcategoria_producto values(27,131);
insert into producto values(132, 'Salsa de Tomate con Tocino Ahumado', 172, 'Salsa de tomate con tocino ahumado Al Dente la Salsa. Ingredientes: tomate natural, tocino ahumado, cebolla, vino blanco, ajo, chile.',
'\\27 Aderezos\\salsatomate.jpg', 50);
insert into subcategoria_producto values(27,132);
insert into producto values(133, 'Mostaza con Miel', 74.40, 'Mostaza con miel Club del Gourmet. Ingredientes: granos de mostaza, vinagre de alcohol, agua, miel, sal.',
'\\27 Aderezos\\moztaza.jpg', 50);
insert into subcategoria_producto values(27,133);
/*-----------------------------------------------------*/
insert into producto values(134, 'Ajo en Polvo Terana', 42.40, 'Especia selecta de ajo molido para sazonar omelettes y huevos revueltos; mezcle ajo en polvo con media taza de mantequilla y úselo para untar sobre pan, vegetales y carnes a la parrilla.',
'\\28 Condimentos\\ajo.jpg', 50);
insert into subcategoria_producto values(28,134);
insert into producto values(135, 'Pimienta Negra Molida', 56, 'Pimienta negra molida que puede acompañarse con platillos al momento de servirlos o durante su cocimiento. Úsela en carnes, pescado, ensaladas y salsas.',
'\\28 Condimentos\\pimientanegra.jpg', 50);
insert into subcategoria_producto values(28,135);
insert into producto values(136, 'Flor de Sal con Gusano de Maguey', 96, 'Elaborada con flor de sal de Coyutlán, Colima preparada con Gusano de maguey, variedad de chiles secos e ingredientes preshispánicos de la cocina mexicana molidos artesanalmente en molcajete. ',
'\\28 Condimentos\\florsal.jpg', 50);
insert into subcategoria_producto values(28,136);
insert into producto values(137, 'Extracto de Vainilla The Mexican Vanilla', 88, 'Envase con extracto de vainilla procedente de Totonacapan, una región de Veracruz con una gran tradición de cultivo de vainilla. ',
'\\28 Condimentos\\extractodevainilla.jpg', 50);
insert into subcategoria_producto values(28,137);
insert into producto values(138, 'Sazonador de Pollo Bovril', 87.20, 'Sazonador elaborado con agua, sal, caldo de pollo, pollo en polvo, hidrolizado de levadura, almidón de maíz, cebolla en polvo, perejil, extracto de especias y de hierbas. ',
'\\28 Condimentos\\sazonador.jpg', 50);
insert into subcategoria_producto values(28,138);
/*-----------------------------------------------------*/
insert into producto values(139, 'Aceitunas Rellenas de Anchoas', 107.20, 'Un producto elaborado con agua, aceituna manzanilla, relleno de anchoa y  acentuador del sabor. ',
'\\29 Conservas y Frutos\\aceitunas.jpg', 50);
insert into subcategoria_producto values(29,139);
insert into producto values(140, 'Aceituna Negra Kalamata Amanida',171.20, 'Aceituna entera negra natural kalamata con aceite de oliva extra virgen con agua y sal.  ',
'\\29 Conservas y Frutos\\aceitunanegra.jpg', 50);
insert into subcategoria_producto values(29,140);
insert into producto values(141, 'Puré de Jitomate Mutti', 44, 'Puré elaborado con jitomates rojos y sal. Un producto 100% Italiano. ',
'\\29 Conservas y Frutos\\salsatoma.jpg', 50);
insert into subcategoria_producto values(29,141);
insert into producto values(142, 'Espárragos Verdes San Lázaro', 49.60, 'Espárragos verdes en conserva elaborados con agua, sal común y ácido cítrico. ',
'\\29 Conservas y Frutos\\esparragos.jpg', 50);
insert into subcategoria_producto values(29,142);
insert into producto values(143, 'Ciruela Pasa sin Hueso Asprocica', 71.20, 'Ciruela Pasa sin Hueso; son una opción ideal a la hora de disfrutar de algunas frutas.',
'\\29 Conservas y Frutos\\ciruela.jpg', 50);
insert into subcategoria_producto values(29,143);
/*-----------------------------------------------------*/
insert into producto values(144, 'Filetes de Anchoa', 155, 'Filetes de anchoa Brisamar; Con aceite vegetal comestible y sal yodada. No contiene conservadores. Refrigérese una vez abierto.',
'\\30 Conservas de mar\\filetees.jpg', 50);
insert into subcategoria_producto values(30,144);
insert into producto values(145, 'Nori Sushi Morimoto', 31.20, 'Con el alga marina de Morimoto podrás preparar deliciosas recetas de sushi. ¡Sorprende a tu familia con una rica comida japonesa!. ',
'\\30 Conservas de mar\\sushi.jpg', 50);
insert into subcategoria_producto values(30,145);
insert into producto values(146, 'Sardina en Aceite de Oliva', 28, 'Brunswick Sardina en aceite de Oliva, empacado al vacío y cerrado hermético en envase de hojalata resistente al manejo manual y condiciones ambientales normales, ',
'\\30 Conservas de mar\\sardina.jpg', 50);
insert into subcategoria_producto values(30,146);
insert into producto values(147, 'Condimento Japonés Wasabi ', 25.60, 'Condimento elaborado con rábano, mostaza, harina de maíz, ácido cítrico, vitamina C y colorante artificial. Acompañe con makis/rollos y sashimi.',
'\\30 Conservas de mar\\wasabi.jpg', 50);
insert into subcategoria_producto values(30,147);
insert into producto values(148, 'Cebollas Rellenas de Bonito', 151.20, 'Cebollas elaboradas con bonito (atún blanco de hojuelas), tomate, aceite de oliva, pimienta, vino blanco, ajo, perejil y sal.',
'\\30 Conservas de mar\\cebollas.jpg', 50);
insert into subcategoria_producto values(30,148);
/*-----------------------------------------------------*/
insert into producto values(149, 'Ron Bacardí', 173.60, 'Ron Bacardí tiene notas de vainilla y almendra que se intensifican por los barriles de roble y con una suavidad única por la mezcla de carbón. ',
'\\31 Bacardi\\bacardi.jpg', 50);
insert into subcategoria_producto values(31,149);
insert into producto values(150, 'Ron Santa Teresa 1796 de Solera', 888, 'Ron Santa Teresa 1796 es el único ron de edad que se produce en su totalidad con el método largo de solera. ',
'\\31 Bacardi\\santatere.jpg', 50);
insert into subcategoria_producto values(31,150);
insert into producto values(151, 'Ron Bacardi Añejo', 159.20, 'Reposado en barricas de roble blanco por más de tres años, Ron Bacardi Añejo es una mezcla ligera y un Ron premium por su antigüedad.',
'\\31 Bacardi\\añejo.jpg', 50);
insert into subcategoria_producto values(31,151);
insert into producto values(152, 'Ron Solera', 203.20, 'Ron Bacardí Solera; un ron dorado con sabor completo de la barrica. Tiene buena presencia de madera, con notas de vainilla, caramelo y frutos secos.',
'\\31 Bacardi\\solera.jpg', 50);
insert into subcategoria_producto values(31,152);
insert into producto values(153, 'Ron Gran Reserva Diez Años', 736, 'Ron Bacardi Gran Reserva Diez Años; añejado ininterrumpidamente durante 10 años bajo el sol del caribe.',
'\\31 Bacardi\\reserva.jpg', 50);
insert into subcategoria_producto values(31,153);
/*-----------------------------------------------------*/
insert into producto values(154, 'Tequila Blanco Casa Dragones', 856, 'Nombrado como el "Mejor Tequila Blanco" por la revista Epicurious, Casa Dragones Blanco es un Tequila 100% puro de Agave Azul, producido en pequeños lotes, mediante un proceso innovador que se enfoca en la pureza del agave. ',
'\\32 Casa de Dragones\\blanco.jpg', 50);
insert into subcategoria_producto values(32,154);
insert into producto values(155, 'Tequila Joven Casa Dragones', 3000, 'Tequila Casa Dragones es 100% puro agave azul con un sabor ligero y terso con notas de vainilla y un toque de especias, balanceado y con delicados matices de pera, con tonos platinos brillantes; sutil aroma floral y cítrico.',
'\\32 Casa de Dragones\\joven.png', 50);
insert into subcategoria_producto values(32,155);
insert into producto values(156, 'Tequila Blanco Casa Dragones', 520, 'Tequila Casa Dragones Blanco; balance único de notas semidulces de agave con tonos de pimienta y clavo. Suave y ligero con notas dulces de almendras y un retrogusto limpio y elegante.',
'\\32 Casa de Dragones\\blanco2.jpg', 50);

/*-----------------------------------------------------*/
insert into producto values(159, 'Tequila Don Julio 1942', 1760, 'Un tequila distinguido de brillante matiz dorado cubierto bajo un intenso aroma a dulce caramelo, así el paladar se cubre de los suaves sabores que incluyen toques de roble quemado, pimienta y canela.',
'\\33 Don Julio\\1942.jpg', 50);
insert into subcategoria_producto values(33,159);
insert into producto values(160, 'Tequila Reposado Claro', 456, 'Tequila Don Julio reposado claro, elaborado artesanalmente, madurado en barricas de roble blanco americano, para luego ser cuidadosamente filtrado, hasta entregar sutilmente notas de madera, vainilla y toronja.',
'\\33 Don Julio\\claro.jpg', 50);
insert into subcategoria_producto values(33,160);
insert into producto values(161, 'Tequila Añejo Don Julio Real', 3904, 'Don Julio Real 100% de agave azul añejado en barricas de roble blanco para desarrollar uno de los más finos tequilas. Elaborado artesanalmente. ',
'\\33 Don Julio\\añejo.jpg', 50);
insert into subcategoria_producto values(33,161);
insert into producto values(162, 'Tequila Blanco Don Julio', 364, 'Un destilado lleno de tradición con sabor mexicano, así es Tequila Don Julio. Posee un fresco aroma de agave y cítrico, bajo un suave sabor que despierta al paladar más exigente.',
'\\33 Don Julio\\blanco.jpg', 50);
insert into subcategoria_producto values(33,162);
insert into producto values(163, 'Tequila Reposado Don Julio', 420, 'Tequila Don julio reposado es suave, elegante y de color parecido al de la paja. Con finos aromas cítricos limón, capas de especias y toques de fruta con hueso madura.',
'\\33 Don Julio\\reposado.jpg', 50);
insert into subcategoria_producto values(33,163);
/*-----------------------------------------------------*/
insert into producto values(164, 'Vino Tinto Hubble', 351.20, 'Vino tinto El Cielo Hubble; es un vino Merlot con crianza de 24 meses en barricas nuevas de roble francés, intenso a la vista, aromático destacando frutos rojos y negros,',
'\\34 El cielo\\hubble.jpg', 50);
insert into subcategoria_producto values(34,164);
insert into producto values(165, 'Vino Blanco Andromeda', 319.20, 'Vino blanco El Cielo Andromeda; este vino de una Chenin Blanc de viñas de temporal de más de 45 años, cultivadas por descendientes de los inmigrantes rusos molakanes. ',
'\\34 El cielo\\andromeda.jpg', 50);
insert into subcategoria_producto values(34,165);
insert into producto values(166, 'Vino Tinto Orion 204',580 ,'Vino tinto El Cielo Orion; lo mejor del Viejo Mundo, como su mitología, su arte y la pasión con la frescura, riqueza y magia de los sabores de México. ',
'\\34 El cielo\\orion.jpg', 50);
insert into subcategoria_producto values(34,166);
insert into producto values(167, 'Vino Blanco Capricornius', 351.20, 'Vino blanco El Cielo Capricornius; durante capricornius se dan los tiempos de lluvia en el Valle de Guadalupe y la vid renueva sus sarmientos que darán vida a los nuevos frutos. ',
'\\34 El cielo\\capricor.jpg', 50);
insert into subcategoria_producto values(34,167);
insert into producto values(168, 'Vino Tinto Procyon', 799.20, 'Vino tinto El Cielo; cuidadosa selección manual de las mejores parcelas. 85% Syrah, 15% Grenache de más de 50 años de edad. 22 meses en barrica nueva de roble francés y 20 meses en botella.',
'\\34 El cielo\\procyon.jpg', 50);
insert into subcategoria_producto values(34,168);
/*-----------------------------------------------------*/
insert into producto values(169, 'Whisky Johnnie Walker Blue Label', 4040, 'Whisky Johnnie Walker, un blended creado para reflejar el estilo de los whiskies del siglo XIX nace como un homenaje al fundador.',
'\\35 Jonhnni Walker\\bluelabel.jpg', 50);
insert into subcategoria_producto values(35,169);
insert into producto values(170, 'Whisky Blue Label Ghost and Rare Port Ellen', 5268, 'Whisky Johnnie Walker Blue Label Ghost and Rare Port Ellen; es el segundo de una serie de lanzamientos especiales creados con insustituibles "fantasmas".',
'\\35 Jonhnni Walker\\portellen.jpg', 50);
insert into subcategoria_producto values(35,170);
insert into producto values(171, 'Whisky John Walker & Sons Private Collection 28 Years', 3599 , 'Whisky Johnnie Walker John Walker & Sons Private Collection 28 Years; la quinta y última edición de la Colección Privada John Walker & Sons.',
'\\35 Jonhnni Walker\\28years.jpg', 50);
insert into subcategoria_producto values(35,171);
insert into producto values(172, 'Whisky Blue Label Tom Dixon', 5084, 'Whisky Blue Label Tom Dixon Ed 750 Johnnie Walker; inspirado en la destreza y el patrimonio de cada gota de Johnnie Walker,el galardonado diseñador británico Tom Dixon.',
'\\35 Jonhnni Walker\\dixon.jpg', 50);
insert into subcategoria_producto values(35,172);
insert into producto values(173, 'Whisky Johnnie Walker Añejo 18 Años', 1492, 'Whisky Añejado 18 Años Johnnie Walker; fue inspirado por la tradición de John Walker & Sons de regalar mezclas privadas a un círculo cercano de amigos de la familia.',
'\\35 Jonhnni Walker\\18años.jpg', 50);
insert into subcategoria_producto values(35,173);
/*-----------------------------------------------------*/
alter table carrito add primary key (id_producto, id_user);
drop view if exists datosProductos;
create view datosProductos as select id_producto, name as nombre, precio, descripcion, imagen as img, existencia as stock from producto;
 /*-----------------------------------------------------*/