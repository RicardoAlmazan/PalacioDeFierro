<%-- 
    Document   : index
    Created on : 27/05/2019, 10:43:26 AM
    Author     : Don Pendejo
--%>
<%@page import="java.util.ArrayList"%>
<%@page import="ldn.carrito"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%BD.cDatos sql = new BD.cDatos();
    int maxElemPorPg = 15, totalArt = 0, numPag = 0, inicio = 0, totalPag = 0, prodCar = 0;
    String consulta = "", categoria = "", subcategoria = "";
    boolean tieneCat = false, tieneSub = false;

    if (session.getAttribute("productosCarro") != null) {
        ArrayList<carrito> c = (ArrayList<carrito>) session.getAttribute("productosCarro");
        prodCar = c.size();
    }

    if (request.getParameter("categoria") != null) {
        tieneCat = true;
        categoria = request.getParameter("categoria");
        if (request.getParameter("subcat") != null) {
            try {
                sql.conectar();
                ResultSet rs = sql.consulta("call comprobarSub('" + categoria + "', '" + request.getParameter("subcat") + "');");
                if (rs.next()) {
                    if (Integer.parseInt(rs.getString("x")) == 1) {
                        subcategoria = request.getParameter("subcat");
                        tieneSub = true;
                    } else {
                        response.sendRedirect("?categoria=" + categoria);
                    }
                }
                sql.cierraConexion();
            } catch (Exception e) {
                out.println(e.getMessage());
            }
        }
    } else {
        if (request.getParameter("subcat") != null) {
            response.sendRedirect("");
        }
    }
    try {
        sql.conectar();
        ResultSet rs = null;
        if (!tieneCat) {
            rs = sql.consulta("select count(*) as total from datosProductos;");
        } else {
            if (!tieneSub) {
                rs = sql.consulta("select count(*) as total from datosProductos dp, subcategoria_producto sp,"
                        + " subcategoria s, categoria c where dp.id_producto = sp.id_producto and "
                        + "sp.id_subcategoria = s.id_derivado and s.id_categoria = c.id_categoria and c.name = '" + categoria + "';");
            } else {
                rs = sql.consulta("select count(*) as total from datosProductos dp, subcategoria_producto sp,"
                        + " subcategoria s where dp.id_producto = sp.id_producto and sp.id_subcategoria = s.id_derivado"
                        + " and s.name = '" + subcategoria + "';");

            }
        }
        if (rs.next()) {
            totalArt = Integer.parseInt(rs.getString("total"));
        }

        if (totalArt < 1) {
            response.sendRedirect("");
        }
        sql.cierraConexion();
    } catch (Exception e) {
        out.println(e.getMessage());
    }

    if (request.getParameter("pagina") != null) {
        try {
            numPag = Integer.parseInt(request.getParameter("pagina"));
            if ((numPag - 1) * maxElemPorPg > totalArt) {
                response.sendRedirect("");
            } else {
                inicio = (numPag - 1) * maxElemPorPg;
            }
        } catch (Exception e) {
            out.println(e.getMessage());
        }
    } else {
        numPag = 1;
        inicio = 0;
    }
    double d = Math.ceil((double) totalArt / maxElemPorPg);
    totalPag = (int) d;

    if (tieneCat) {
        try {
            sql.conectar();
            ResultSet rs = sql.consulta("select count(*) as num from categoria where name = '" + categoria + "';");
            if (rs.next()) {
                if (Integer.parseInt(rs.getString("num")) == 1) {
                    if (tieneSub) {
                        consulta = "select dp.id_producto, dp.nombre, dp.img, dp.descripcion, dp.precio "
                                + "from datosProductos dp, subcategoria_producto sp, subcategoria s "
                                + "where dp.id_producto = sp.id_producto and sp.id_subcategoria = s.id_derivado"
                                + " and s.name = '" + subcategoria + "';";
                    } else {
                        consulta = "select dp.id_producto, dp.nombre, dp.img, dp.descripcion, dp.precio "
                                + "from datosProductos dp, subcategoria_producto sp, subcategoria s, categoria c "
                                + "where dp.id_producto = sp.id_producto and sp.id_subcategoria = s.id_derivado and "
                                + "s.id_categoria = c.id_categoria and c.name = '" + categoria + "' limit " + inicio + "," + maxElemPorPg + ";";
                    }
                } else {
                    response.sendRedirect("");
                }
            }
            sql.cierraConexion();
        } catch (Exception e) {
            out.println(e.getMessage());
        }
    } else {
        consulta = "select id_producto, nombre, img, precio, descripcion from datosProductos limit " + inicio + "," + maxElemPorPg + ";";
    }
%>
<!DOCTYPE html>
<html>
    <head>

        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="description" content="">
        <meta name="author" content="">

        <title>Palacio de Fierro</title>

        <!-- Bootstrap core CSS -->
        <link href="css/bootstrap.min.css" rel="stylesheet">

        <!-- Custom styles for this template -->
        <link href="css/shop-homepage.css" rel="stylesheet">

    </head>
    <body> 
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
            <div class="container">
                <a class="navbar-brand" href="/Proyecto/">Palacio de Fierro</a>
                <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarResponsive">
                    <ul class="navbar-nav ml-auto">
                        <li class="nav-item active">
                            <a class="nav-link" href="#">Home
                                <span class="sr-only">(current)</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="carrito.jsp">Carrito(<%=prodCar%>)</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Page Content -->
        <div class="container">

            <div class="row">

                <div class="col-lg-3">

                    <h1 class="my-4">Palacio de Fierro</h1>
                    <div class="list-group">
                        <%try {
                                sql.conectar();
                                ResultSet r = sql.consulta("select name from categoria;");
                                while (r.next()) {
                        %>
                        <a href="/Proyecto/?categoria=<%out.print(r.getString("name"));%>" class="list-group-item <%=categoria.equals(r.getString("name")) ? "active" : ""%>"><%out.print(r.getString("name"));%></a>
                        <%}
                                sql.cierraConexion();
                            } catch (Exception ex) {
                                out.println(ex.getMessage());
                            } %>
                    </div>

                </div>
                <!-- /.col-lg-3 -->

                <div class="col-lg-9">

                    <div id="carouselExampleIndicators" class="carousel slide my-4" data-ride="carousel">
                        <ol class="carousel-indicators">
                            <li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
                            <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
                            <li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
                        </ol>
                        <div class="carousel-inner" role="listbox">
                            <div class="carousel-item active">
                                <img class="d-block img-fluid" src="images/img1.jpg" alt="First slide">
                            </div>
                            <div class="carousel-item">
                                <img class="d-block img-fluid" src="images/img2.jpg" alt="Second slide">
                            </div>
                            <div class="carousel-item">
                                <img class="d-block img-fluid" src="images/img3.jpg" alt="Third slide">
                            </div>
                        </div>
                        <a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="sr-only">Anterior</span>
                        </a>
                        <a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="sr-only">Siguiente</span>
                        </a>
                    </div>
                    <!--Subcategorías, creo.-->
                    <%if (tieneCat) {
                            try {
                                sql.conectar();
                                ResultSet rs = sql.consulta("select count(*) as num from subcategoria s, categoria c where  s.id_categoria = c.id_categoria and c.name = '" + categoria + "';");
                                if (rs.next()) {
                                    if (Integer.parseInt(rs.getString("num")) > 0) {
                    %>
                    <div class="card card-outline-secondary my-4">
                        <div class="card-body">
                            <button class="btn btn-dark btn-lg dropdown-toggle float-right" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                Selecciona una opción.
                            </button>
                            <div class="dropdown-menu">
                                <%rs = sql.consulta("call traeSub('" + categoria + "');");
                                    while (rs.next()) {%>
                                <a class="dropdown-item" href="/Proyecto/?categoria=<%=categoria + "&&subcat=" + rs.getString("nombre")%>"><%=rs.getString("nombre")%></a>
                                <%}%>
                            </div>
                        </div>
                    </div>
                    <%                                    }
                                }
                                sql.cierraConexion();
                            } catch (Exception e) {
                                out.println(e.getMessage());
                            }

                        }%>
                    <div class="row">
                        <%
                            try {
                                sql.conectar();
                                ResultSet rs = sql.consulta(consulta);
                                while (rs.next()) {
                        %>
                        <div class="col-lg-4 col-md-6 mb-4">
                            <div class="card h-100">
                                <a href="#"><img class="card-img-top" src="images<%=rs.getString("img")%>" alt=""></a>
                                <div class="card-body">
                                    <h4 class="card-title">
                                        <a href="#"><%out.print(rs.getString("nombre"));%></a>
                                    </h4>
                                    <h5>$<%=rs.getString("precio")%></h5>
                                    <p class="card-text"><%=rs.getString("descripcion")%></p>
                                </div>
                                <div class="card-footer">
                                    <center><a class="btn btn-dark" href="carrito.jsp?agregarProducto=<%out.print(rs.getString("id_producto"));%>" role="button">Agregar al carrito.</a></center>
                                    <!--<small class="text-muted">&#9733; &#9733; &#9733; &#9733; &#9734;</small>-->
                                </div>
                            </div>
                        </div>
                        <%}
                                sql.cierraConexion();
                            } catch (Exception e) {
                                out.println(e.getMessage());
                            } %>


                    </div>
                    <!-- /.row -->
                    <nav>
                        <ul class="pagination">
                            <%if (totalPag > 1) {
                                    if (numPag != 1) {%>
                            <li class="page-item"><a class="page-link"href="/Proyecto/<%=tieneCat ? "?categoria=" + categoria + "&&" : "?"%>pagina=<%=numPag - 1%>"><span aria-hidden="true">&laquo;</span></a></li>
                                <%}
                                    for (int i = 1; i < totalPag; i++) {

                                        if (numPag == i) {%><li class="page-item active"><a class="page-link" href="#"><%=numPag%></a></li><%
                                                                      } else {
                                %><li class="page-item"><a class="page-link" href="/Proyecto/<%=tieneCat ? "?categoria=" + categoria + "&&" : "?"%>pagina=<%=i%>"><%=i%></a></li><%
                                        }
                                    }
                                    if (numPag != totalPag) {%>
                            <li class="page-item">
                                <a class="page-link" href="/Proyecto/<%=tieneCat ? "?categoria=" + categoria + "&&" : "?"%>pagina=<%=numPag + 1%>">
                                    <span aria-hidden="true">&raquo;</span></a>
                            </li>
                            <%}
                                }%>
                        </ul>
                    </nav>

                </div>
                <!-- /.col-lg-9 -->

            </div>
            <!-- /.row -->

        </div>
        <!-- /.container -->

        <!-- Footer -->
        <footer class="py-5 bg-dark">
            <div class="container">
                <p class="m-0 text-center text-white">Copyright &copy; Palacio de Fierro 2019</p>
            </div>
            <!-- /.container -->
        </footer>

        <!-- Bootstrap core JavaScript -->
        <script src="jquery/jquery.min.js"></script>
        <script src="js/bootstrap.bundle.min.js"></script>

    </body>
</html>
